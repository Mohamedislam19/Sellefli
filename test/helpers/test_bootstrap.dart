import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:sellefli/src/data/models/item_image_model.dart';
import 'package:sellefli/src/data/models/item_model.dart';

import 'fake_http_overrides.dart';

/// Shared bootstrap for unit tests.
///
/// Keeps test setup consistent across the suite.
void bootstrapUnitTests() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Install a shared HttpOverrides early so clients created during setUpAll
  // (e.g. Supabase) can be unit-tested without production code changes.
  FakeHttpRouter.install();

  // mocktail needs fallbacks for non-nullable args used with `any()`.
  registerFallbackValue(Uri.parse('http://localhost'));
  registerFallbackValue(<String, String>{});
  registerFallbackValue(<String, dynamic>{});
  registerFallbackValue(http.Request('GET', Uri.parse('http://localhost')));

  // Common types used in repository/cubit mocks.
  registerFallbackValue(File('mock_file'));

  // App models used as arguments in mocks.
  registerFallbackValue(
    Item(
      id: 'i',
      ownerId: 'u',
      title: 't',
      category: 'c',
      createdAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    ),
  );
  registerFallbackValue(
    ItemImage(id: 'img', itemId: 'i', imageUrl: 'url', position: 1),
  );
}
