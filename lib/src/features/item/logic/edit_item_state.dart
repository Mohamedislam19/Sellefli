// ignore_for_file: library_private_types_in_public_api

part of 'edit_item_cubit.dart';

@immutable
abstract class EditItemState {}

class EditItemInitial extends EditItemState {}

class EditItemLoading extends EditItemState {}

/// Emitted when the item and its image slots are ready for editing
class EditItemLoaded extends EditItemState {
  final Item item;
  final List<_EditableImageSlot>
  slots; // UI can inspect originals/files & positions

  EditItemLoaded({required this.item, required List<_EditableImageSlot> slots})
    : slots = List.unmodifiable(slots);
}

class EditItemSaving extends EditItemState {}

class EditItemSuccess extends EditItemState {}

class EditItemError extends EditItemState {
  final String message;
  EditItemError(this.message);
}


