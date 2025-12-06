import '../../../data/models/item_model.dart';

abstract class MyListingsState {
  const MyListingsState();
}

class MyListingsInitial extends MyListingsState {}

class MyListingsLoading extends MyListingsState {}

class MyListingsLoaded extends MyListingsState {
  final List<Item> items;
  final bool isOffline;
  const MyListingsLoaded({required this.items, this.isOffline = false});
}

class MyListingsError extends MyListingsState {
  final String message;
  const MyListingsError(this.message);
}

class MyListingsNavigateToEdit extends MyListingsState {
  final String itemId;
  const MyListingsNavigateToEdit(this.itemId);
}


