// ignore_for_file: unnecessary_null_comparison, unused_local_variable

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/item_model.dart';
import '../models/item_image_model.dart';
import '../local/local_item_repository.dart';

class ItemRepository {
  /// Configure your backend base URL. Override via --dart-define=DJANGO_BASE_URL
  /// if needed.
  /// Production: https://sellefli.onrender.com
  static const String _baseUrl = String.fromEnvironment(
    'DJANGO_BASE_URL',
    defaultValue: 'https://sellefli.onrender.com',
  );

  /// Request timeout duration - reduced to fail fast and use cache
  static const Duration _timeout = Duration(seconds: 5);

  final http.Client _client;
  final LocalItemRepository _localRepo = LocalItemRepository();

  ItemRepository([Object? client])
    : _client = client is http.Client ? client : http.Client();

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final uri = Uri.parse('$_baseUrl$path');
    if (query == null || query.isEmpty) return uri;
    return uri.replace(
      queryParameters: {
        ...uri.queryParameters,
        ...query.map((k, v) => MapEntry(k, v?.toString() ?? '')),
      },
    );
  }

  /// Get auth headers with Supabase JWT token
  /// Refreshes session if token is expired or about to expire (within 5 minutes)
  Future<Map<String, String>> get _authHeaders async {
    var session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      final expiresAt = session.expiresAt;
      if (expiresAt != null) {
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final timeUntilExpiry = expiresAt - now;

        // Refresh if token is EXPIRED (timeUntilExpiry <= 0) or about to expire within 5 minutes
        if (timeUntilExpiry < 300) {
          try {
            final response = await Supabase.instance.client.auth
                .refreshSession();
            session = response.session;
          } catch (e) {
            // If refresh fails and token is already expired, we need to re-authenticate
            if (timeUntilExpiry <= 0) {
              throw Exception('Session expired. Please log in again.');
            }
            // Otherwise continue with current token (it's still valid for a bit)
          }
        }
      }
    }

    final currentSession = Supabase.instance.client.auth.currentSession;
    final token = currentSession?.accessToken;

    return {
      HttpHeaders.contentTypeHeader: 'application/json',
      if (token != null) HttpHeaders.authorizationHeader: 'Bearer $token',
    };
  }

  T _decode<T>(http.Response res, T Function(dynamic) mapper) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final body = res.body.isEmpty ? null : jsonDecode(res.body);
      return mapper(body);
    }
    throw HttpException('HTTP ${res.statusCode}: ${res.body}');
  }

  // ===========================================================================
  // CREATE ITEM
  // ===========================================================================
  Future<String> createItem(Item item) async {
    final res = await _client.post(
      _uri('/api/items/'),
      headers: await _authHeaders,
      body: jsonEncode(item.toJson()),
    );

    return _decode<String>(res, (body) => body['id'] as String);
  }

  // ===========================================================================
  // UPLOAD IMAGES  (items/<itemId>/<filename>)
  // Returns list of inserted ItemImage records
  // ===========================================================================
  Future<List<ItemImage>> uploadItemImages(
    String itemId,
    List<File> images,
  ) async {
    final List<ItemImage> inserted = [];

    for (int i = 0; i < images.length; i++) {
      final file = images[i];
      final ext = file.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
      final bytes = await file.readAsBytes();
      final image = await _uploadMultipart(
        itemId: itemId,
        bytes: bytes,
        fileName: fileName,
        position: i + 1,
        contentType: _guessContentType(ext),
      );

      inserted.add(image);
    }

    return inserted;
  }

  // Upload a single image at a specific position
  Future<ItemImage> uploadItemImageAtPosition(
    String itemId,
    File file,
    int position,
  ) async {
    final ext = file.path.split('.').last;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
    final bytes = await file.readAsBytes();
    return _uploadMultipart(
      itemId: itemId,
      bytes: bytes,
      fileName: fileName,
      position: position,
      contentType: _guessContentType(ext),
    );
  }

  // Web-safe upload directly from XFile, falling back to File for non-web.
  Future<ItemImage> uploadXFileAtPosition(
    String itemId,
    XFile xfile,
    int position,
  ) async {
    final ext = (xfile.name.split('.').length > 1)
        ? xfile.name.split('.').last
        : 'jpg';
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
    final contentType = _guessContentType(ext);
    if (kIsWeb) {
      final bytes = await xfile.readAsBytes();
      return _uploadMultipart(
        itemId: itemId,
        bytes: bytes,
        fileName: fileName,
        position: position,
        contentType: contentType,
      );
    } else {
      final bytes = await File(xfile.path).readAsBytes();
      return _uploadMultipart(
        itemId: itemId,
        bytes: bytes,
        fileName: fileName,
        position: position,
        contentType: contentType,
      );
    }
  }

  String _guessContentType(String ext) {
    final lower = ext.toLowerCase();
    switch (lower) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      default:
        return 'application/octet-stream';
    }
  }

  Future<List<Item>> getItems({
    required int page,
    required int pageSize,
    String? excludeUserId,
    List<String>? categories,
    String? searchQuery,
  }) async {
    final stopwatch = Stopwatch()..start();

    // Try Supabase first (faster, direct connection)
    try {
      final items = await _getItemsFromSupabase(
        page: page,
        pageSize: pageSize,
        excludeUserId: excludeUserId,
        categories: categories,
        searchQuery: searchQuery,
      );
      // Cache first page if no filters are applied (fire and forget)
      if (page == 1 &&
          (searchQuery == null || searchQuery.isEmpty) &&
          (categories == null ||
              categories.isEmpty ||
              categories.contains('All'))) {
        _localRepo.cacheItems(items.take(10).toList());
      }

      return items;
    } catch (supabaseError) {
      // Fallback to Django backend
      try {
        return await _getItemsFromDjango(
          page: page,
          pageSize: pageSize,
          excludeUserId: excludeUserId,
          categories: categories,
          searchQuery: searchQuery,
        );
      } catch (djangoError) {
        // Last resort: try local cache for first page
        if (page == 1) {
          final cachedItems = await _localRepo.getCachedItems();
          if (cachedItems.isNotEmpty) {
            return cachedItems;
          }
        }
        rethrow;
      }
    }
  }

  /// Fetch items directly from Supabase (faster)
  Future<List<Item>> _getItemsFromSupabase({
    required int page,
    required int pageSize,
    String? excludeUserId,
    List<String>? categories,
    String? searchQuery,
  }) async {
    final offset = (page - 1) * pageSize;

    // Build query with joins for images and owner
    var query = Supabase.instance.client
        .from('items')
        .select(
          '*, item_images(*), owner:users!items_owner_id_fkey(id, username, avatar_url, rating_sum, rating_count)',
        )
        .order('created_at', ascending: false)
        .range(offset, offset + pageSize - 1);

    // Only use supported filters in Supabase query
    final rows = await query as List<dynamic>;

    List<Item> items = rows
        .map<Item>((e) => Item.fromJson(e as Map<String, dynamic>))
        .toList();

    // Filter in Dart for unsupported filters
    if (excludeUserId != null) {
      items = items.where((item) => item.ownerId != excludeUserId).toList();
    }
    if (categories != null &&
        categories.isNotEmpty &&
        !categories.contains('All')) {
      items = items
          .where((item) => categories.contains(item.category))
          .toList();
    }
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      items = items
          .where((item) => item.title.toLowerCase().contains(q))
          .toList();
    }
    return items;
  }

  /// Fetch items from Django backend (fallback)
  Future<List<Item>> _getItemsFromDjango({
    required int page,
    required int pageSize,
    String? excludeUserId,
    List<String>? categories,
    String? searchQuery,
  }) async {
    final query = <String, dynamic>{
      'page': page.toString(),
      'page_size': pageSize.toString(),
    };

    if (excludeUserId != null) {
      query['excludeUserId'] = excludeUserId;
    }
    if (categories != null &&
        categories.isNotEmpty &&
        !categories.contains('All')) {
      query['categories'] = categories.join(',');
    }
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query['searchQuery'] = searchQuery;
    }

    final res = await _client.get(_uri('/api/items/', query)).timeout(_timeout);
    return _decode<List<Item>>(res, (body) {
      final results = body is Map<String, dynamic> ? body['results'] : body;
      return (results as List)
          .map((json) => Item.fromJson(json as Map<String, dynamic>))
          .toList();
    });
  }

  // ===========================================================================
  // GET ITEM
  // ===========================================================================
  Future<Item?> getItemById(String itemId) async {
    final res = await _client
        .get(_uri('/api/items/$itemId/'))
        .timeout(_timeout);
    try {
      return _decode<Item?>(res, (body) => Item.fromJson(body));
    } on HttpException {
      if (res.statusCode == 404) return null;
      rethrow;
    }
  }

  // ===========================================================================
  // GET MY ITEMS (current user's listings)
  // ===========================================================================
  Future<List<Item>> getMyItems({
    required int page,
    required int pageSize,
  }) async {
    try {
      final query = <String, dynamic>{
        'page': page.toString(),
        'page_size': pageSize.toString(),
      };

      final res = await _client.get(
        _uri('/api/items/my-items/', query),
        headers: await _authHeaders,
      );
      final items = _decode<List<Item>>(res, (body) {
        final results = body is Map<String, dynamic> ? body['results'] : body;
        return (results as List)
            .map((json) => Item.fromJson(json as Map<String, dynamic>))
            .toList();
      });

      return items;
    } catch (e) {
      rethrow;
    }
  }

  // ===========================================================================
  // GET IMAGES
  // ===========================================================================
  Future<List<ItemImage>> getItemImages(String itemId) async {
    final res = await _client
        .get(_uri('/api/items/$itemId/images/'), headers: await _authHeaders)
        .timeout(_timeout);
    return _decode<List<ItemImage>>(res, (body) {
      return (body as List)
          .map<ItemImage>((json) => ItemImage.fromJson(json))
          .toList();
    });
  }

  // ===========================================================================
  // UPDATE ITEM FIELDS
  // ===========================================================================
  Future<void> updateItem(String itemId, Map<String, dynamic> updates) async {
    updates['updated_at'] = DateTime.now().toIso8601String();
    final res = await _client.patch(
      _uri('/api/items/$itemId/'),
      headers: await _authHeaders,
      body: jsonEncode(updates),
    );
    _decode(res, (body) => body);
  }

  // ===========================================================================
  // DELETE A SPECIFIC IMAGE (Storage + DB)
  // ===========================================================================
  Future<void> deleteImage(String imageUrl) async {
    if (imageUrl.isEmpty) return;
    final res = await _client.post(
      _uri('/api/item-images/delete-by-url/'),
      headers: await _authHeaders,
      body: jsonEncode({'image_url': imageUrl}),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) return;
    throw HttpException('HTTP ${res.statusCode}: ${res.body}');
  }

  // Delete image by id (fetch row first to get URL), safer for RLS policies
  Future<void> deleteImageById(String imageId) async {
    final res = await _client.delete(_uri('/api/item-images/$imageId/'));
    if (res.statusCode >= 200 && res.statusCode < 300) return;
    throw HttpException('HTTP ${res.statusCode}: ${res.body}');
  }

  // Delete all images for an item whose positions are NOT in the provided set.
  // Also removes from storage.
  Future<void> deleteImagesNotInPositions(
    String itemId,
    Set<int> allowedPositions,
  ) async {
    final res = await _client.post(
      _uri('/api/item-images/delete-not-in-positions/'),
      headers: await _authHeaders,
      body: jsonEncode({
        'item_id': itemId,
        'positions': allowedPositions.toList(),
      }),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) return;
    throw HttpException('HTTP ${res.statusCode}: ${res.body}');
  }

  // Delete all images for an item EXCEPT the ones with ids in allowedIds.
  // Also removes the corresponding storage objects.
  Future<void> deleteImagesExceptIds(
    String itemId,
    Set<String> allowedIds,
  ) async {
    final res = await _client.post(
      _uri('/api/item-images/delete-except-ids/'),
      headers: await _authHeaders,
      body: jsonEncode({'item_id': itemId, 'allowed_ids': allowedIds.toList()}),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) return;
    throw HttpException('HTTP ${res.statusCode}: ${res.body}');
  }

  // Update position of an existing item_images row by id
  Future<void> updateItemImagePosition(String imageId, int position) async {
    final res = await _client.patch(
      _uri('/api/item-images/$imageId/'),
      headers: await _authHeaders,
      body: jsonEncode({'position': position}),
    );
    _decode(res, (body) => body);
  }

  // ===========================================================================
  // REPLACE ALL IMAGES (Used when user re-uploads everything)
  // ===========================================================================
  Future<void> replaceItemImages(String itemId, List<File> newImages) async {
    final oldImages = await getItemImages(itemId);

    for (final img in oldImages) {
      await deleteImage(img.imageUrl);
    }

    await uploadItemImages(itemId, newImages);
  }

  // ===========================================================================
  // UPDATE ONLY SOME IMAGES (partial update)
  //
  // - removedImages: list of ItemImage (existing DB rows) to delete
  // - newAddedImages: list of File to upload (they will be appended and inserted)
  // Returns the full, current list of ItemImage rows after the operation.
  // ===========================================================================
  Future<List<ItemImage>> updateItemImages({
    required String itemId,
    required List<ItemImage> oldImages,
    required List<File> newAddedImages,
    required List<ItemImage> removedImages,
  }) async {
    // 1) Delete requested existing images
    for (final img in removedImages) {
      await deleteImage(img.imageUrl);
    }

    // 2) Keep existing behavior for appends (legacy callers)
    if (newAddedImages.isNotEmpty) {
      await uploadItemImages(itemId, newAddedImages);
    }

    // 4) Return fresh list of images
    return await getItemImages(itemId);
  }

  // ===========================================================================
  // REORDER IMAGES: set the position value for a list of image IDs in order.
  // orderedImageIds should be a list of item_image.id in the desired order.
  // ===========================================================================
  Future<void> reorderItemImages(
    String itemId,
    List<String> orderedImageIds,
  ) async {
    final res = await _client.post(
      _uri('/api/items/$itemId/images/reorder/'),
      headers: await _authHeaders,
      body: jsonEncode({'ordered_ids': orderedImageIds}),
    );
    _decode(res, (body) => body);
  }

  // ===========================================================================
  // DELETE ITEM
  // ===========================================================================
  Future<void> deleteItem(String itemId) async {
    // First get auth headers for authenticated request
    final headers = await _authHeaders;

    // Delete the item (backend will cascade delete images)
    final res = await _client.delete(
      _uri('/api/items/$itemId/'),
      headers: headers,
    );

    if (res.statusCode >= 200 && res.statusCode < 300) return;
    throw HttpException('HTTP ${res.statusCode}: ${res.body}');
  }

  Future<ItemImage> _uploadMultipart({
    required String itemId,
    required Uint8List bytes,
    required String fileName,
    required int position,
    String? contentType,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      _uri('/api/item-images/upload/'),
    );

    // Add auth headers
    final authHeaders = await _authHeaders;
    if (authHeaders.containsKey(HttpHeaders.authorizationHeader)) {
      request.headers[HttpHeaders.authorizationHeader] =
          authHeaders[HttpHeaders.authorizationHeader]!;
    }

    request.fields['item_id'] = itemId;
    request.fields['position'] = position.toString();
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: fileName,
        contentType: contentType != null ? MediaType.parse(contentType) : null,
      ),
    );

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    return _decode<ItemImage>(res, (body) => ItemImage.fromJson(body));
  }
}
