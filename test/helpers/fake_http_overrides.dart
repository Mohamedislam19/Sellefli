import 'dart:async';
import 'dart:convert';
import 'dart:io';

typedef FakeHttpMatcher = bool Function(String method, Uri uri);

class FakeHttpRoute {
  final FakeHttpMatcher matches;
  final int statusCode;
  final Map<String, String> headers;
  final String body;

  const FakeHttpRoute({
    required this.matches,
    required this.statusCode,
    required this.body,
    this.headers = const {'content-type': 'application/json; charset=utf-8'},
  });
}

class FakeHttpRouter {
  FakeHttpRouter._();

  static final FakeHttpRouter instance = FakeHttpRouter._();
  static bool _installed = false;

  List<FakeHttpRoute> _routes = const <FakeHttpRoute>[];
  void Function(String method, Uri uri)? _onRequest;

  static void install() {
    if (_installed) return;
    HttpOverrides.global = FakeHttpOverrides(FakeHttpRouter.instance);
    _installed = true;
  }

  void setRoutes(List<FakeHttpRoute> routes) {
    _routes = routes;
  }

  void clearRoutes() {
    _routes = const <FakeHttpRoute>[];
  }

  void setOnRequest(void Function(String method, Uri uri)? onRequest) {
    _onRequest = onRequest;
  }

  void clearOnRequest() {
    _onRequest = null;
  }
}

/// Minimal HttpOverrides to unit test code that constructs its own HTTP clients
/// (e.g. Supabase PostgREST, package:http IOClient) without production changes.
class FakeHttpOverrides extends HttpOverrides {
  final FakeHttpRouter router;

  FakeHttpOverrides(this.router);

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _FakeHttpClient(router);
  }
}

class _FakeHttpClient implements HttpClient {
  final FakeHttpRouter router;

  _FakeHttpClient(this.router);

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async {
    router._onRequest?.call(method.toUpperCase(), url);
    return _FakeHttpClientRequest(router, method, url);
  }

  @override
  Future<HttpClientRequest> open(
    String method,
    String host,
    int port,
    String path,
  ) {
    final scheme = port == 443 ? 'https' : 'http';
    return openUrl(method, Uri(scheme: scheme, host: host, port: port, path: path));
  }

  @override
  Future<HttpClientRequest> getUrl(Uri url) => openUrl('GET', url);

  @override
  Future<HttpClientRequest> postUrl(Uri url) => openUrl('POST', url);

  @override
  Future<HttpClientRequest> putUrl(Uri url) => openUrl('PUT', url);

  @override
  Future<HttpClientRequest> deleteUrl(Uri url) => openUrl('DELETE', url);

  @override
  Future<HttpClientRequest> patchUrl(Uri url) => openUrl('PATCH', url);

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHttpClientRequest implements HttpClientRequest {
  final FakeHttpRouter router;
  final String method;
  final Uri url;
  final BytesBuilder _body = BytesBuilder();
  final _FakeHttpHeaders _headers = _FakeHttpHeaders();

  final Completer<HttpClientResponse> _doneCompleter =
      Completer<HttpClientResponse>();

  bool _followRedirects = true;
  int _maxRedirects = 5;
  bool _persistentConnection = true;
  int _contentLength = -1;

  _FakeHttpClientRequest(this.router, this.method, this.url);

  @override
  Uri get uri => url;

  @override
  HttpHeaders get headers => _headers;

  @override
  Encoding get encoding => utf8;

  @override
  set encoding(Encoding _encoding) {}

  @override
  bool get followRedirects => _followRedirects;

  @override
  set followRedirects(bool value) {
    _followRedirects = value;
  }

  @override
  int get maxRedirects => _maxRedirects;

  @override
  set maxRedirects(int value) {
    _maxRedirects = value;
  }

  @override
  bool get persistentConnection => _persistentConnection;

  @override
  set persistentConnection(bool value) {
    _persistentConnection = value;
  }

  @override
  int get contentLength => _contentLength;

  @override
  set contentLength(int value) {
    _contentLength = value;
  }

  @override
  Future<HttpClientResponse> get done => _doneCompleter.future;

  @override
  void add(List<int> data) => _body.add(data);

  @override
  Future<void> addStream(Stream<List<int>> stream) async {
    await for (final chunk in stream) {
      _body.add(chunk);
    }
  }

  @override
  void write(Object? obj) {
    final text = obj?.toString() ?? '';
    _body.add(utf8.encode(text));
  }

  @override
  void writeln([Object? obj = ""]) {
    write(obj);
    write("\n");
  }

  @override
  void abort([Object? exception, StackTrace? stackTrace]) {
    if (!_doneCompleter.isCompleted) {
      _doneCompleter.completeError(
        exception ?? const HttpException('Request aborted'),
        stackTrace,
      );
    }
  }

  @override
  Future<HttpClientResponse> close() async {
    final route = router._routes.firstWhere(
      (r) => r.matches(method.toUpperCase(), url),
      orElse: () => FakeHttpRoute(
        matches: (_, __) => true,
        statusCode: 404,
        body: jsonEncode({'error': 'not found', 'path': url.path}),
      ),
    );

    final response = _FakeHttpClientResponse(route);
    if (!_doneCompleter.isCompleted) {
      _doneCompleter.complete(response);
    }
    return response;
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHttpHeaders implements HttpHeaders {
  final Map<String, List<String>> _values = {};

  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {
    final key = name.toLowerCase();
    _values.putIfAbsent(key, () => <String>[]).add(value.toString());
  }

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {
    _values[name.toLowerCase()] = <String>[value.toString()];
  }

  @override
  List<String>? operator [](String name) => _values[name.toLowerCase()];

  @override
  void forEach(void Function(String name, List<String> values) action) {
    _values.forEach(action);
  }

  @override
  void remove(String name, Object value) {
    final key = name.toLowerCase();
    final list = _values[key];
    if (list == null) return;
    list.remove(value.toString());
    if (list.isEmpty) _values.remove(key);
  }

  @override
  void removeAll(String name) {
    _values.remove(name.toLowerCase());
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHttpClientResponse extends Stream<List<int>>
    implements HttpClientResponse {
  final FakeHttpRoute route;

  _FakeHttpClientResponse(this.route);

  @override
  int get statusCode => route.statusCode;

  @override
  String get reasonPhrase {
    if (statusCode >= 200 && statusCode < 300) return 'OK';
    if (statusCode == 404) return 'Not Found';
    if (statusCode == 406) return 'Not Acceptable';
    return 'Error';
  }

  @override
  bool get isRedirect => false;

  @override
  List<RedirectInfo> get redirects => const <RedirectInfo>[];

  @override
  bool get persistentConnection => false;

  @override
  HttpConnectionInfo? get connectionInfo => null;

  @override
  int get contentLength => route.body.length;

  @override
  HttpHeaders get headers {
    final h = _FakeHttpHeaders();
    route.headers.forEach((k, v) => h.set(k, v));
    return h;
  }

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    final bytes = utf8.encode(route.body);
    return Stream<List<int>>.fromIterable([bytes]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
