part of 'create_item_cubit.dart';

abstract class CreateItemState {}

class CreateItemInitial extends CreateItemState {}

class CreateItemLoading extends CreateItemState {}

class CreateItemSuccess extends CreateItemState {
  final String itemId;

  CreateItemSuccess(this.itemId);
}

class CreateItemError extends CreateItemState {
  final String message;

  CreateItemError(this.message);
}


