import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sellefli/src/features/item/logic/create_item_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../helpers/fake_http_overrides.dart';
import '../../../../helpers/test_bootstrap.dart';

/// Minimal HttpOverrides to unit test cubits/repositories that construct their
/// own `http.Client()` internally.
///
/// This keeps us within the "no production code changes" constraint.
class _FakeHttpOverrides extends HttpOverrides {
  final Map<String, _FakeRoute> routes;

  _FakeHttpOverrides(this.routes);

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _FakeHttpClient(routes);
  }
}

class _FakeRoute {
  final int statusCode;
  final Map<String, String> headers;
  final String body;

  const _FakeRoute({
    required this.statusCode,
    required this.body,
    this.headers = const {'content-type': 'application/json; charset=utf-8'},
  });
}

class _FakeHttpClient implements HttpClient {
  final Map<String, _FakeRoute> routes;

  _FakeHttpClient(this.routes);

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async {
    return _FakeHttpClientRequest(routes, method, url);
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHttpClientRequest implements HttpClientRequest {
  final Map<String, _FakeRoute> routes;
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

  _FakeHttpClientRequest(this.routes, this.method, this.url);

  @override
  Uri get uri => url;

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
  Future<HttpClientResponse> close() async {
    final key = '${method.toUpperCase()} ${url.path}';
    final route =
        routes[key] ?? const _FakeRoute(statusCode: 404, body: '"not found"');
    final response = _FakeHttpClientResponse(route);
    if (!_doneCompleter.isCompleted) {
      _doneCompleter.complete(response);
    }
    return response;
  }

  @override
  HttpHeaders get headers => _headers;

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
  Encoding get encoding => utf8;

  @override
  set encoding(Encoding _encoding) {}

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
  void forEach(void Function(String name, List<String> values) action) {
    _values.forEach(action);
  }

  @override
  List<String>? operator [](String name) => _values[name.toLowerCase()];

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
  final _FakeRoute route;

  _FakeHttpClientResponse(this.route);

  @override
  int get statusCode => route.statusCode;

  @override
  String get reasonPhrase {
    if (statusCode >= 200 && statusCode < 300) return 'OK';
    if (statusCode == 404) return 'Not Found';
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

void main() {
  setUpAll(() async {
    bootstrapUnitTests();

    // supabase_flutter uses SharedPreferences-backed storage.
    SharedPreferences.setMockInitialValues(<String, Object>{});

    // CreateItemCubit -> ItemRepository reads Supabase.instance for auth headers.
    try {
      await Supabase.initialize(
        url: 'https://example.supabase.co',
        anonKey: 'test-anon-key',
      );
    } catch (_) {
      // Ignore if already initialized by another test.
    }
  });

  group('CreateItemCubit (unit)', () {
    test('initial state is CreateItemInitial', () {
      final cubit = CreateItemCubit();
      expect(cubit.state, isA<CreateItemInitial>());
      cubit.close();
    });

    blocTest<CreateItemCubit, CreateItemState>(
      'emits [Loading, Success] when backend create succeeds and images list empty',
      setUp: () {
        FakeHttpRouter.instance.setRoutes([
          FakeHttpRoute(
            matches: (method, uri) =>
                method == 'POST' && uri.path == '/api/items/',
            statusCode: 200,
            body: jsonEncode({'id': 'server-id'}),
          ),
          FakeHttpRoute(
            matches: (method, uri) =>
                method == 'GET' && uri.path == '/api/items/server-id/images/',
            statusCode: 200,
            body: '[]',
          ),
        ]);
      },
      tearDown: () {
        FakeHttpRouter.instance.clearRoutes();
      },
      build: () => CreateItemCubit(),
      act: (cubit) => cubit.createItem(
        ownerId: 'owner-1',
        title: 'Camera',
        category: 'Electronics',
        images: const <File>[],
      ),
      expect: () => [
        isA<CreateItemLoading>(),
        isA<CreateItemSuccess>().having((s) => s.itemId, 'itemId', 'server-id'),
      ],
    );

    blocTest<CreateItemCubit, CreateItemState>(
      'emits [Loading, Error] when backend create fails',
      setUp: () {
        FakeHttpRouter.instance.setRoutes([
          const FakeHttpRoute(
            matches: _matchPostItems,
            statusCode: 500,
            body: 'boom',
          ),
        ]);
      },
      tearDown: () {
        FakeHttpRouter.instance.clearRoutes();
      },
      build: () => CreateItemCubit(),
      act: (cubit) => cubit.createItem(
        ownerId: 'owner-1',
        title: 'Camera',
        category: 'Electronics',
        images: const <File>[],
      ),
      expect: () => [isA<CreateItemLoading>(), isA<CreateItemError>()],
    );
  });
}

bool _matchPostItems(String method, Uri uri) {
  return method == 'POST' && uri.path == '/api/items/';
}
