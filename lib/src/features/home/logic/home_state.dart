import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import 'package:sellefli/src/data/models/item_model.dart';

enum HomeStatus { initial, loading, success, error }

class HomeState extends Equatable {
  final HomeStatus status;
  final List<Item> items;
  final List<String> selectedCategories;
  final bool isLocationEnabled;
  final String searchQuery;
  final double radius;
  final LatLng? userLocation;
  final bool hasReachedMax;
  final int page;
  final String? errorMessage;
  final bool isOfflineMode;

  const HomeState({
    this.status = HomeStatus.initial,
    this.items = const [],
    this.selectedCategories = const ['All'],
    this.isLocationEnabled = false,
    this.searchQuery = '',
    this.radius = 5.0,
    this.userLocation,
    this.hasReachedMax = false,
    this.page = 1,
    this.errorMessage,
    this.isOfflineMode = false,
  });

  HomeState copyWith({
    HomeStatus? status,
    List<Item>? items,
    List<String>? selectedCategories,
    bool? isLocationEnabled,
    String? searchQuery,
    double? radius,
    LatLng? userLocation,
    bool? hasReachedMax,
    int? page,
    String? errorMessage,
    bool? isOfflineMode,
  }) {
    return HomeState(
      status: status ?? this.status,
      items: items ?? this.items,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      isLocationEnabled: isLocationEnabled ?? this.isLocationEnabled,
      searchQuery: searchQuery ?? this.searchQuery,
      radius: radius ?? this.radius,
      userLocation: userLocation ?? this.userLocation,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      page: page ?? this.page,
      errorMessage: errorMessage ?? this.errorMessage,
      isOfflineMode: isOfflineMode ?? this.isOfflineMode,
    );
  }

  @override
  List<Object?> get props => [
    status,
    items,
    selectedCategories,
    isLocationEnabled,
    searchQuery,
    radius,
    userLocation,
    hasReachedMax,
    page,
    errorMessage,
    isOfflineMode,
  ];
}
