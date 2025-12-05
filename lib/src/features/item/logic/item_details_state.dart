part of 'item_details_cubit.dart';

abstract class ItemDetailsState {
  const ItemDetailsState();
}

class ItemDetailsInitial extends ItemDetailsState {}

class ItemDetailsLoading extends ItemDetailsState {}

class ItemDetailsLoaded extends ItemDetailsState {
  final Item item;
  final List<ItemImage> images;
  const ItemDetailsLoaded({required this.item, required this.images});
}

class ItemDetailsError extends ItemDetailsState {
  final String message;
  const ItemDetailsError(this.message);
}
