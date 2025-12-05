part of 'my_listings_cubit.dart';

abstract class MyListingsState {
  const MyListingsState();
}

class MyListingsInitial extends MyListingsState {}

class MyListingsLoading extends MyListingsState {}

class MyListingsLoaded extends MyListingsState {
  final List<Item> items;
  const MyListingsLoaded({required this.items});
}

class MyListingsError extends MyListingsState {
  final String message;
  const MyListingsError(this.message);
}

class MyListingsNavigateToEdit extends MyListingsState {
  final String itemId;
  const MyListingsNavigateToEdit(this.itemId);
}
