// lib/src/features/item/presentation/edit_item_page.dart
// ignore_for_file: unused_field, deprecated_member_use, unused_import, unnecessary_null_comparison, avoid_print, use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:sellefli/src/core/widgets/snackbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sellefli/src/core/constants/categories.dart';

import 'package:sellefli/src/core/widgets/animated_return_button.dart';
import 'package:sellefli/src/core/theme/app_theme.dart';
import 'package:sellefli/src/core/widgets/image/image_gallery_edit.dart';
import 'package:sellefli/src/core/widgets/inputs/field_decoration.dart';
import 'package:sellefli/src/core/widgets/dropdown/animated_dropdown.dart';

import 'package:sellefli/src/features/item/logic/edit_item_cubit.dart';
import 'package:sellefli/src/data/repositories/item_repository.dart';

class EditItemPage extends StatefulWidget {
  final String itemId; // we pass only the id when navigating

  const EditItemPage({super.key, required this.itemId});

  @override
  State<EditItemPage> createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final supabase = Supabase.instance.client;

  String? _userId;

  // We'll keep controllers so fields are editable & show initial values
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _depositController = TextEditingController();

  static const int _maxImages = 3; // match repository/cubit maxImages
  DateTime? _fromDate;
  DateTime? _untilDate;
  LatLng? _locationLatLng;
  String? _category;
  bool _showImageError = false;
  late AnimationController _animController;

  final List<String> _categories = AppCategories.categories;

  final Map<String, IconData> _categoryIcons = AppCategories.categoryIcons;

  late EditItemCubit _cubit;

  void setUserId() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      print('No user is currently signed in.');
    } else {
      setState(() {
        _userId = user.id;
      });
      print('Current signed-in user ID: ${user.id}');
    }
  }

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 730),
    )..forward();

    // Create cubit with repository (using global Supabase instance)
    _cubit = EditItemCubit(
      itemRepository: ItemRepository(Supabase.instance.client),
    );

    // Load the item by id passed in the constructor
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cubit.loadItem(widget.itemId);
    });
    setUserId();
  }

  @override
  void dispose() {
    _animController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _valueController.dispose();
    _depositController.dispose();
    _cubit.close();
    super.dispose();
  }

  // Choose first empty slot index (0-based) using cubit's public getters
  int _firstEmptySlotIndex(EditItemLoaded state) {
    for (int i = 0; i < state.slots.length; i++) {
      final s = state.slots[i];
      if (s.isEmpty) return i;
    }
    return -1;
  }

  // Pick multiple images and fill available slots in order
  Future<void> _pickImages(BuildContext context, EditItemLoaded state) async {
    // Enforce max 3 total images (existing + new)
    final currentCount = state.slots.where((s) => !s.isEmpty).length;
    if (currentCount >= _maxImages) {
      SnackbarHelper.showSnackBar(
        context,
        message: 'You can upload up to $_maxImages images.',
        isSuccess: false,
      );
      return;
    }
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();
    if (picked == null || picked.isEmpty) return;

    int remaining = _maxImages - currentCount;
    int slot = _firstEmptySlotIndex(state);
    for (final x in picked) {
      if (remaining <= 0) break;
      if (slot == -1) break;
      await _cubit.pickImageForSlot(slot, x);
      remaining--;
      // compute next empty slot
      final updated = _cubit.state;
      if (updated is EditItemLoaded) {
        slot = _firstEmptySlotIndex(updated);
      } else {
        slot = -1;
      }
    }
    setState(() {
      _showImageError = false;
    });
  }

  // Pick single image from camera and fill first empty slot
  Future<void> _pickImageCamera(
    BuildContext context,
    EditItemLoaded state,
  ) async {
    // Enforce max 3 total images (existing + new)
    final currentCount = state.slots.where((s) => !s.isEmpty).length;
    if (currentCount >= _maxImages) {
      SnackbarHelper.showSnackBar(
        context,
        message: 'You can upload up to $_maxImages images.',
        isSuccess: false,
      );
      return;
    }
    final picker = ImagePicker();
    final taken = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 92,
    );
    if (taken == null) return;
    final slot = _firstEmptySlotIndex(state);
    if (slot == -1) {
      SnackbarHelper.showSnackBar(
        context,
        message: 'You can upload up to $_maxImages images.',
        isSuccess: false,
      );
      return;
    }
    await _cubit.pickImageForSlot(slot, taken);
    setState(() {
      _showImageError = false;
    });
  }

  Future<void> _selectDate(BuildContext context, bool isFrom) async {
    FocusScope.of(context).unfocus();
    final initDate = isFrom
        ? (_fromDate ?? DateTime.now())
        : (_untilDate ??
              (_fromDate ?? DateTime.now()).add(const Duration(days: 7)));
    final firstDate = isFrom ? DateTime.now() : (_fromDate ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initDate,
      firstDate: firstDate,
      lastDate: DateTime(DateTime.now().year + 3),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: AppColors.pageBackground,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
              ),
            ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: AppColors.appBarBackground,
              headerBackgroundColor: AppColors.primaryBlue,
              headerForegroundColor: Colors.white,
              // rangeSelectionOverlayColor: AppColors.primaryBlue.withOpacity(
              //   0.12,
              // ),
              dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                if (states.contains(WidgetState.disabled)) {
                  return Colors.grey.shade400;
                }
                return Colors.black87;
              }),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isFrom) {
          _fromDate = picked;
        } else {
          _untilDate = picked;
        }
      });
    }
  }

  Future<void> _selectLocation() async {
    FocusScope.of(context).unfocus();
    final result = await Navigator.pushNamed(context, '/map-picker');
    if (result is Map<String, dynamic>) {
      setState(() {
        _locationLatLng = result['latlng'] as LatLng?;
      });
    }
  }

  // Called when user taps the Edit button
  Future<void> _submit(BuildContext context) async {
    setState(() {
      _showImageError = false; // will be validated more below
    });

    final currentState = _cubit.state;
    if (currentState is! EditItemLoaded) {
      SnackbarHelper.showSnackBar(
        context,
        message: 'Item not loaded yet.',
        isSuccess: false,
      );
      return;
    }

    // If all image slots empty, error
    final anyImagePresent = currentState.slots.any((s) => !s.isEmpty);
    if (!anyImagePresent) {
      setState(() => _showImageError = true);
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) return;
    _formKey.currentState?.save();

    // Prepare numeric parsing
    final estVal = double.tryParse(_valueController.text) ?? 0;
    final deposit = double.tryParse(_depositController.text) ?? 0;

    // Call cubit update with collected fields
    await _cubit.updateItem(
      title: _titleController.text.trim(),
      category: _category ?? _categories.first,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      estimatedValue: estVal,
      depositAmount: deposit,
      startDate: _fromDate,
      endDate: _untilDate,
      lat: _locationLatLng?.latitude,
      lng: _locationLatLng?.longitude,
    );
    // result handled by BlocListener
  }

  // Build a visual images list for ImageGallery from cubit's slots
  // Each element is either: XFile (new local), String (remote url), or null (empty slot)
  List<dynamic> _buildVisualSlots(EditItemLoaded state) {
    return state.slots.map((s) {
      if (s.isNewFile) return s.file!;
      if (s.isOriginal) return s.original!.imageUrl;
      return null;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final double screenW = MediaQuery.of(context).size.width;
    final double scale = ((screenW / 350).clamp(0.8, 1.0)).toDouble();

    return BlocProvider<EditItemCubit>.value(
      value: _cubit,
      child: BlocListener<EditItemCubit, EditItemState>(
        listener: (context, state) {
          final messenger = ScaffoldMessenger.of(context);

          if (state is EditItemLoaded) {
            // Prefill controllers only when loaded
            _titleController.text = state.item.title;
            _descriptionController.text = state.item.description ?? '';
            _valueController.text = (state.item.estimatedValue ?? 0).toString();
            _depositController.text = (state.item.depositAmount ?? 0)
                .toString();
            _fromDate = state.item.startDate;
            _untilDate = state.item.endDate;
            if (state.item.lat != null && state.item.lng != null) {
              _locationLatLng = LatLng(state.item.lat!, state.item.lng!);
            }
            _category = state.item.category;
          } else if (state is EditItemSuccess) {
            // on success -> pop and show success snackbar
            Navigator.of(context).pop();
            messenger.clearSnackBars();
            SnackbarHelper.showSnackBar(
              context,
              message: 'Item updated successfully.',
              isSuccess: true,
            );
          } else if (state is EditItemError) {
            messenger.clearSnackBars();
            SnackbarHelper.showSnackBar(
              context,
              message: state.message,
              isSuccess: false,
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 207, 225, 255),
            elevation: 1,
            centerTitle: true,
            leading: const AnimatedReturnButton(),
            title: Padding(
              padding: EdgeInsets.symmetric(vertical: 12 * scale),
              child: Text(
                'Edit Item',
                style: GoogleFonts.outfit(
                  fontSize: 22 * scale,
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: FadeTransition(
              opacity: CurvedAnimation(
                parent: _animController,
                curve: Curves.easeOut,
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: 17 * scale,
                  vertical: 10 * scale,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Item Photos',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w600,
                          fontSize: 15 * scale,
                        ),
                      ),

                      // IMAGE GALLERY - same UI as create (horizontal, remove X)
                      BlocBuilder<EditItemCubit, EditItemState>(
                        builder: (context, state) {
                          if (state is EditItemLoaded) {
                            final visuals = _buildVisualSlots(state);
                            return ImageGallery(
                              images: visuals,
                              scale: scale,
                              showImageError: _showImageError,
                              onRemove: (idx) => _cubit.removeImageAt(idx),
                            );
                          } else {
                            return SizedBox(
                              height: 120,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                        },
                      ),

                      // Pick buttons use cubit slots; they need current EditItemLoaded state
                      SizedBox(height: 8),
                      BlocBuilder<EditItemCubit, EditItemState>(
                        builder: (context, state) {
                          if (state is EditItemLoaded) {
                            return Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () =>
                                        _pickImages(context, state),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryBlue,
                                      padding: EdgeInsets.symmetric(
                                        vertical: 13 * scale,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          9 * scale,
                                        ),
                                      ),
                                    ),
                                    icon: Icon(
                                      Icons.photo_library_outlined,
                                      size: 18 * scale,
                                    ),
                                    label: Text(
                                      'Gallery',
                                      style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12 * scale),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () =>
                                        _pickImageCamera(context, state),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        color: AppColors.primaryBlue,
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        vertical: 13 * scale,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          9 * scale,
                                        ),
                                      ),
                                      backgroundColor: AppColors.pageBackground,
                                    ),
                                    icon: Icon(
                                      Icons.camera_alt_outlined,
                                      color: AppColors.primaryBlue,
                                      size: 18 * scale,
                                    ),
                                    label: Text(
                                      'Camera',
                                      style: TextStyle(
                                        color: AppColors.primaryBlue,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: null,
                                    icon: Icon(
                                      Icons.photo_library_outlined,
                                      size: 18 * scale,
                                    ),
                                    label: Text('Gallery'),
                                  ),
                                ),
                                SizedBox(width: 12 * scale),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: null,
                                    icon: Icon(
                                      Icons.camera_alt_outlined,
                                      size: 18 * scale,
                                    ),
                                    label: Text('Camera'),
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      ),

                      AnimatedSize(
                        duration: const Duration(milliseconds: 230),
                        curve: Curves.easeInOut,
                        child: _showImageError
                            ? Padding(
                                padding: EdgeInsets.only(top: 8 * scale),
                                child: Text(
                                  'At least one photo is required.',
                                  style: TextStyle(
                                    color: Colors.red[700],
                                    fontSize: 12.8 * scale,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),

                      const SizedBox(height: 8),

                      // Title
                      Padding(
                        padding: EdgeInsets.only(
                          top: 12 * scale,
                          bottom: 4 * scale,
                        ),
                        child: Text(
                          'Title',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w600,
                            fontSize: 15 * scale,
                          ),
                        ),
                      ),
                      TextFormField(
                        controller: _titleController,
                        decoration: fieldDecoration(
                          label: null,
                          hint: 'e.g., Electric Drill, Bicycle',
                        ),
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Required' : null,
                      ),

                      // Category
                      Padding(
                        padding: EdgeInsets.only(
                          top: 14 * scale,
                          bottom: 4 * scale,
                        ),
                        child: Text(
                          'Category',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w600,
                            fontSize: 15 * scale,
                          ),
                        ),
                      ),
                      AnimatedDropdown(
                        categories: _categories,
                        categoryIcons: _categoryIcons,
                        selected: _category ?? _categories.first,
                        scale: scale,
                        onChanged: (v) => setState(() => _category = v),
                      ),

                      // Description
                      Padding(
                        padding: EdgeInsets.only(
                          top: 14 * scale,
                          bottom: 4 * scale,
                        ),
                        child: Text(
                          'Description',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w600,
                            fontSize: 15 * scale,
                          ),
                        ),
                      ),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: fieldDecoration(
                          label: null,
                          hint: 'Describe your item in detail...',
                        ),
                        maxLines: 3,
                        minLines: 3,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Required' : null,
                      ),

                      // Estimated Value
                      Padding(
                        padding: EdgeInsets.only(
                          top: 12 * scale,
                          bottom: 4 * scale,
                        ),
                        child: Text(
                          'Estimated Value',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w600,
                            fontSize: 15 * scale,
                          ),
                        ),
                      ),
                      TextFormField(
                        controller: _valueController,
                        decoration: fieldDecoration(
                          label: null,
                          hint: 'e.g., 150 DA',
                        ),
                        keyboardType: TextInputType.number,
                      ),

                      // Deposit
                      Padding(
                        padding: EdgeInsets.only(
                          top: 12 * scale,
                          bottom: 4 * scale,
                        ),
                        child: Text(
                          'Deposit Required',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w600,
                            fontSize: 15 * scale,
                          ),
                        ),
                      ),
                      TextFormField(
                        controller: _depositController,
                        decoration: fieldDecoration(
                          label: null,
                          hint: 'e.g., 50 DA (refundable)',
                        ),
                        keyboardType: TextInputType.number,
                      ),

                      SizedBox(height: 20 * scale),

                      // Dates row
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _selectDate(context, true),
                              child: AbsorbPointer(
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    labelText: 'Available From',
                                    hintText: 'MM/DD/YYYY',
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                    filled: true,
                                    fillColor: Colors.white,
                                    suffixIcon: Icon(
                                      Icons.calendar_today_outlined,
                                      color: AppColors.primaryBlue,
                                      size: 20,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(11),
                                      borderSide: BorderSide(
                                        color: Colors.grey[200]!,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(11),
                                      borderSide: BorderSide(
                                        color: Colors.grey[200]!,
                                        width: 1.1,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(11),
                                      borderSide: BorderSide(
                                        color: AppColors.primaryBlue,
                                        width: 1.8,
                                      ),
                                    ),
                                    labelStyle: GoogleFonts.outfit(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                      fontSize: 19 * scale,
                                    ),
                                    hintStyle: GoogleFonts.outfit(
                                      color: Colors.grey[400],
                                      fontSize: 12 * scale,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 6,
                                    ),
                                  ),
                                  controller: TextEditingController(
                                    text: _fromDate == null
                                        ? ''
                                        : '${_fromDate!.month}/${_fromDate!.day}/${_fromDate!.year}',
                                  ),
                                  validator: (val) =>
                                      _fromDate == null ? 'Required' : null,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 13 * scale),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _selectDate(context, false),
                              child: AbsorbPointer(
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    labelText: 'Available Until',
                                    hintText: 'MM/DD/YYYY',
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                    filled: true,
                                    fillColor: Colors.white,
                                    suffixIcon: Icon(
                                      Icons.calendar_today_outlined,
                                      color: AppColors.primaryBlue,
                                      size: 20,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(11),
                                      borderSide: BorderSide(
                                        color: Colors.grey[200]!,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(11),
                                      borderSide: BorderSide(
                                        color: Colors.grey[200]!,
                                        width: 1.1,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(11),
                                      borderSide: BorderSide(
                                        color: AppColors.primaryBlue,
                                        width: 1.8,
                                      ),
                                    ),
                                    labelStyle: GoogleFonts.outfit(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                      fontSize: 19 * scale,
                                    ),
                                    hintStyle: GoogleFonts.outfit(
                                      color: Colors.grey[400],
                                      fontSize: 12 * scale,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 6,
                                    ),
                                  ),
                                  controller: TextEditingController(
                                    text: _untilDate == null
                                        ? ''
                                        : '${_untilDate!.month}/${_untilDate!.day}/${_untilDate!.year}',
                                  ),
                                  validator: (val) =>
                                      _untilDate == null ? 'Required' : null,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Location
                      Padding(
                        padding: EdgeInsets.only(
                          top: 12 * scale,
                          bottom: 4 * scale,
                        ),
                        child: Text(
                          'Location',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w600,
                            fontSize: 15 * scale,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _selectLocation,
                        child: AbsorbPointer(
                          child: TextFormField(
                            decoration: fieldDecoration(
                              label: null,
                              hint: 'Pick on map',
                              icon: Icons.map_outlined,
                            ),
                            controller: TextEditingController(
                              text: _locationLatLng == null
                                  ? ''
                                  : 'Lat: ${_locationLatLng!.latitude.toStringAsFixed(5)}, Lng: ${_locationLatLng!.longitude.toStringAsFixed(5)}',
                            ),
                            validator: (val) {
                              if (_locationLatLng == null) return 'Required';
                              return null;
                            },
                          ),
                        ),
                      ),

                      SizedBox(height: 20 * scale),

                      // Save Button Animation + BlocBuilder to reflect saving state
                      AnimatedBuilder(
                        animation: _animController,
                        builder: (context, child) => Transform.translate(
                          offset: Offset(
                            0,
                            11 *
                                (1 -
                                    Curves.easeInOut.transform(
                                      _animController.value,
                                    )),
                          ),
                          child: child!,
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          height: 49 * scale,
                          child: BlocBuilder<EditItemCubit, EditItemState>(
                            builder: (context, state) {
                              final isSaving = state is EditItemSaving;
                              return ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryBlue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      11 * scale,
                                    ),
                                  ),
                                ),
                                onPressed: isSaving
                                    ? null
                                    : () => _submit(context),
                                child: isSaving
                                    ? SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : Text(
                                        'Edit Item',
                                        style: GoogleFonts.outfit(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 17 * scale,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
