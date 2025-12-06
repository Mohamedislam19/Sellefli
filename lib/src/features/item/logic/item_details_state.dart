import '../../../data/models/item_model.dart';
import '../../../data/models/item_image_model.dart';
import '../../../data/models/user_model.dart';

abstract class ItemDetailsState {
  const ItemDetailsState();
}

class ItemDetailsInitial extends ItemDetailsState {}

class ItemDetailsLoading extends ItemDetailsState {}

class ItemDetailsLoaded extends ItemDetailsState {
  final Item item;
  final List<ItemImage> images;
  final User? owner;
  const ItemDetailsLoaded({required this.item, required this.images, this.owner});
}

class ItemDetailsError extends ItemDetailsState {
  final String message;
  const ItemDetailsError(this.message);
}


