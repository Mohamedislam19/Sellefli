// ignore_for_file: unused_field

import 'package:bloc/bloc.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:sellefli/src/data/models/item_model.dart';
import 'package:sellefli/src/data/repositories/auth_repository.dart';
import 'package:sellefli/src/data/repositories/item_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final ItemRepository _itemRepository;
  final AuthRepository _authRepository;
  static const int _pageSize = 20;

  // Cache instances to avoid recreating on every call
  final Connectivity _connectivity = Connectivity();
  static const Distance _distanceCalculator = Distance();

  HomeCubit(this._itemRepository, this._authRepository)
    : super(const HomeState());

  Future<void> loadItems({bool refresh = false}) async {
    if (state.status == HomeStatus.loading && !refresh) return;

    final isInitial = state.status == HomeStatus.initial || refresh;
    final page = isInitial ? 1 : state.page;

    // Show loading immediately for better UX
    if (isInitial) {
      emit(
        state.copyWith(
          status: HomeStatus.loading,
          items: [],
          hasReachedMax: false,
          page: 1,
        ),
      );
    }

    try {
      // Run connectivity check and API call in parallel for faster loading
      final results = await Future.wait([
        _connectivity.checkConnectivity(),
        _itemRepository.getItems(
          page: page,
          pageSize: _pageSize,
          categories: state.selectedCategories,
          searchQuery: state.searchQuery,
        ),
      ]);

      final connectivityResult = results[0] as List<ConnectivityResult>;
      final isOffline = connectivityResult.contains(ConnectivityResult.none);
      final items = results[1] as List<Item>;

      // If we are offline and got items, we assume we reached max because we only cache one page
      final hasReachedMax = items.length < _pageSize || isOffline;

      // Apply Location Filter if enabled
      List<Item> filteredItems = [];
      if (state.isLocationEnabled && state.userLocation != null) {
        for (var item in items) {
          if (item.lat == null || item.lng == null) continue;

          final distance = _distanceCalculator.as(
            LengthUnit.Kilometer,
            state.userLocation!,
            LatLng(item.lat!, item.lng!),
          );

          if (distance < state.radius) {
            filteredItems.add(item.copyWith(distance: distance));
          }
        }
      } else {
        filteredItems = items;
      }

      if (isInitial) {
        emit(
          state.copyWith(
            status: HomeStatus.success,
            items: filteredItems,
            hasReachedMax: hasReachedMax,
            page: page + 1,
            isOfflineMode: isOffline,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: HomeStatus.success,
            items: List.of(state.items)..addAll(filteredItems),
            hasReachedMax: hasReachedMax,
            page: page + 1,
            isOfflineMode: isOffline,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(status: HomeStatus.error, errorMessage: e.toString()),
      );
    }
  }

  void selectCategory(String category) {
    List<String> currentCategories = List.from(state.selectedCategories);

    if (category == 'All') {
      // If 'All' is selected, clear everything else and just have 'All'
      currentCategories = ['All'];
    } else {
      // If a specific category is selected
      if (currentCategories.contains('All')) {
        currentCategories.remove('All');
      }

      if (currentCategories.contains(category)) {
        currentCategories.remove(category);
      } else {
        currentCategories.add(category);
      }

      // If nothing is left selected, revert to 'All'
      if (currentCategories.isEmpty) {
        currentCategories = ['All'];
      }
    }

    emit(state.copyWith(selectedCategories: currentCategories));
    loadItems(refresh: true);
  }

  void updateSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
    loadItems(refresh: true);
  }

  void toggleLocation(bool isEnabled) async {
    emit(state.copyWith(isLocationEnabled: isEnabled));
    if (isEnabled) {
      await _getUserLocation();
      if (state.userLocation != null) {
        _startLocationUpdates();
      }
    } else {
      _stopLocationUpdates();
    }
    loadItems(refresh: true);
  }

  void updateRadius(double radius) {
    emit(state.copyWith(radius: radius));
    if (state.isLocationEnabled) {
      loadItems(refresh: true);
    }
  }

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      emit(
        state.copyWith(
          userLocation: LatLng(position.latitude, position.longitude),
        ),
      );
    } catch (e) {
      // Handle error
    }
  }

  StreamSubscription<Position>? _positionSubscription;

  void _startLocationUpdates() {
    _positionSubscription?.cancel();
    _positionSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 50,
          ),
        ).listen((position) {
          emit(
            state.copyWith(
              userLocation: LatLng(position.latitude, position.longitude),
            ),
          );
          loadItems(refresh: true);
        });
  }

  void _stopLocationUpdates() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  @override
  Future<void> close() {
    _stopLocationUpdates();
    return super.close();
  }
}
