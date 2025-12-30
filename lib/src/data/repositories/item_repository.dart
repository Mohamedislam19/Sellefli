// ignore_for_file: unnecessary_null_comparison

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

import '../models/item_model.dart';
import '../models/item_image_model.dart';
import '../local/local_item_repository.dart';

class ItemRepository {
  /// Configure your backend base URL. Override via --dart-define=DJANGO_BASE_URL
  /// if needed.
  static const String _baseUrl = String.fromEnvironment(
    'DJANGO_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

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

  Map<String, String> get _jsonHeaders => {
    HttpHeaders.contentTypeHeader: 'application/json',
  };

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
      headers: _jsonHeaders,
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

  // ===========================================================================
  // GET ITEMS (Feed)
  // ===========================================================================
  Future<List<Item>> getItems({
    required int page,
    required int pageSize,
    String? excludeUserId,
    List<String>? categories,
    String? searchQuery,
  }) async {
    try {
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

      final res = await _client.get(_uri('/api/items/', query));
      final items = _decode<List<Item>>(res, (body) {
        final results = body is Map<String, dynamic> ? body['results'] : body;
        return (results as List)
            .map((json) => Item.fromJson(json as Map<String, dynamic>))
            .toList();
      });

      // Cache first page if no filters are applied
      if (page == 1 &&
          (searchQuery == null || searchQuery.isEmpty) &&
          (categories == null ||
              categories.isEmpty ||
              categories.contains('All'))) {
        // Fire and forget caching
        _localRepo.cacheItems(items.take(10).toList());
      }

      return items;
    } catch (e) {
      // If network fails and it's the first page, try local cache
      if (page == 1) {
        final cachedItems = await _localRepo.getCachedItems();
        if (cachedItems.isNotEmpty) {
          return cachedItems;
        }
      }
      rethrow;
    }
  }

  // ===========================================================================
  // GET ITEM
  // ===========================================================================
  Future<Item?> getItemById(String itemId) async {
    final res = await _client.get(_uri('/api/items/$itemId/'));
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

      final res = await _client.get(_uri('/api/items/my-items/', query));
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
    final res = await _client.get(_uri('/api/items/$itemId/images/'));
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
      headers: _jsonHeaders,
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
      headers: _jsonHeaders,
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
      headers: _jsonHeaders,
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
      headers: _jsonHeaders,
      body: jsonEncode({'item_id': itemId, 'allowed_ids': allowedIds.toList()}),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) return;
    throw HttpException('HTTP ${res.statusCode}: ${res.body}');
  }

  // Update position of an existing item_images row by id
  Future<void> updateItemImagePosition(String imageId, int position) async {
    final res = await _client.patch(
      _uri('/api/item-images/$imageId/'),
      headers: _jsonHeaders,
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
      headers: _jsonHeaders,
      body: jsonEncode({'ordered_ids': orderedImageIds}),
    );
    _decode(res, (body) => body);
  }

  // ===========================================================================
  // DELETE ITEM
  // ===========================================================================
  Future<void> deleteItem(String itemId) async {
    final oldImages = await getItemImages(itemId);

    for (final img in oldImages) {
      await deleteImage(img.imageUrl);
    }

    final res = await _client.delete(_uri('/api/items/$itemId/'));
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
