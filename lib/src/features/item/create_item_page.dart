// ignore_for_file: deprecated_member_use, avoid_print, unused_local_variable

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sellefli/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:sellefli/src/core/widgets/animated_return_button.dart';
import 'package:sellefli/src/core/widgets/snackbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sellefli/src/core/constants/categories.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/image/image_gallery.dart';
import '../../core/widgets/inputs/field_decoration.dart';
import '../../core/widgets/dropdown/animated_dropdown.dart';
import 'package:sellefli/src/features/item/logic/create_item_cubit.dart';

class CreateItemPage extends StatefulWidget {
  const CreateItemPage({super.key});

  @override
  State<CreateItemPage> createState() => _CreateItemPageState();
}

class _CreateItemPageState extends State<CreateItemPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  String? _userId;

  final supabase = Supabase.instance.client;

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

  List<XFile> _images = [];
  static const int _maxImages = 3;
  String? _title;
  String? _description;
  String? _category;
  double? _value;
  double? _deposit;
  DateTime? _fromDate;
  DateTime? _untilDate;
  LatLng? _locationLatLng;
  bool _showImageError = false;
  late AnimationController _animController;

  final List<String> _categories = AppCategories.categories;

  final Map<String, IconData> _categoryIcons = AppCategories.categoryIcons;

  @override
  void initState() {
    super.initState();
    _category = _categories.first;
    _value = 0;
    _deposit = 0;
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 730),
    )..forward();
    setUserId();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final l10n = AppLocalizations.of(context);
    if (_images.length >= _maxImages) {
      SnackbarHelper.showSnackBar(
        context,
        message: l10n.itemImageLimit(_maxImages),
        isSuccess: false,
      );
      return;
    }
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() {
        _images = [..._images, ...picked].take(_maxImages).toList();
        _showImageError = false;
      });
    }
  }

  Future<void> _pickImageCamera() async {
    final l10n = AppLocalizations.of(context);
    if (_images.length >= _maxImages) {
      SnackbarHelper.showSnackBar(
        context,
        message: l10n.itemImageLimit(_maxImages),
        isSuccess: false,
      );
      return;
    }
    final picker = ImagePicker();
    final taken = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 92,
    );
    if (taken != null) {
      setState(() {
        _images.add(taken);
        _showImageError = false;
      });
    }
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

  void _removeImage(int idx) {
    setState(() {
      _images.removeAt(idx);
    });
  }

  void _prepareImageErrorFlag() {
    setState(() {
      _showImageError = _images.isEmpty;
    });
  }

  Future<void> _submit(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    print('object');
    print(_userId);
    _prepareImageErrorFlag();
    if (_images.isEmpty) return;

    final form = _formKey.currentState;
    if (form == null) return;
    if (!(form.validate())) return;
    form.save();

    // Get current authenticated user id
    final ownerId = _userId;
    if (ownerId == null) {
      SnackbarHelper.showSnackBar(
        context,
        message: l10n.itemSignInRequired,
        isSuccess: false, // Triggers the red color
      );
      return;
    }

    // Convert XFile -> File
    final files = _images.map((x) => File(x.path)).toList();

    // Call cubit
    final cubit = context.read<CreateItemCubit>();
    await cubit.createItem(
      ownerId: ownerId,
      title: _title ?? '',
      category: _category ?? _categories.first,
      description: _description,
      estimatedValue: _value,
      depositAmount: _deposit,
      startDate: _fromDate,
      endDate: _untilDate,
      lat: _locationLatLng?.latitude,
      lng: _locationLatLng?.longitude,
      images: files,
    );
    // Note: result handled by BlocListener (success/error)
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final double screenW = MediaQuery.of(context).size.width;
    final double scale = ((screenW / 350).clamp(0.8, 1.0)).toDouble();

    return BlocProvider(
      create: (_) => CreateItemCubit(),
      child: BlocListener<CreateItemCubit, CreateItemState>(
        listener: (context, state) {
          final messenger = ScaffoldMessenger.of(context);
          if (state is CreateItemSuccess) {
            // close page and show success snackbar (styled)
            Navigator.of(context).pop();
            messenger.clearSnackBars();
            SnackbarHelper.showSnackBar(
              context,
              message: l10n.itemCreateSuccess,
              isSuccess: true, // Triggers the blue color
            );
          } else if (state is CreateItemError) {
            messenger.clearSnackBars();
            SnackbarHelper.showSnackBar(
              context,
              message: l10n.itemCreateError(state.message),
              isSuccess: false, // Triggers the red color
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
                l10n.itemCreateTitle,
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
                        l10n.itemPhotos,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w600,
                          fontSize: 15 * scale,
                        ),
                      ),

                      // IMAGE GALLERY (component)
                      ImageGallery(
                        images: _images,
                        scale: scale,
                        showImageError: _showImageError,
                        onRemove: _removeImage,
                      ),

                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _pickImages,
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
                                l10n.itemGallery,
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12 * scale),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _pickImageCamera,
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: AppColors.primaryBlue),
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
                                l10n.itemCamera,
                                style: TextStyle(
                                  color: AppColors.primaryBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      AnimatedSize(
                        duration: const Duration(milliseconds: 230),
                        curve: Curves.easeInOut,
                        child: _showImageError
                            ? Padding(
                                padding: EdgeInsets.only(top: 8 * scale),
                                child: Text(
                                  l10n.itemImageRequired,
                                  style: TextStyle(
                                    color: Colors.red[400],
                                    fontSize: 12.8 * scale,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),

                      SizedBox(height: 0 * scale),

                      // Title field
                      Padding(
                        padding: EdgeInsets.only(
                          top: 12 * scale,
                          bottom: 4 * scale,
                        ),
                        child: Text(
                          l10n.itemTitleLabel,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w600,
                            fontSize: 15 * scale,
                          ),
                        ),
                      ),
                      TextFormField(
                        decoration: fieldDecoration(
                          label: null,
                          hint: l10n.itemTitleHint,
                        ),
                        validator: (val) => val == null || val.isEmpty
                            ? l10n.itemRequiredField
                            : null,
                        onSaved: (val) => _title = val,
                      ),

                      // Category Dropdown
                      Padding(
                        padding: EdgeInsets.only(
                          top: 14 * scale,
                          bottom: 4 * scale,
                        ),
                        child: Text(
                          l10n.itemCategoryLabel,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w600,
                            fontSize: 15 * scale,
                          ),
                        ),
                      ),
                      AnimatedDropdown(
                        categories: _categories,
                        categoryIcons: _categoryIcons,
                        selected: _category!,
                        scale: scale,
                        onChanged: (v) => setState(() => _category = v),
                      ),
                      // Description field
                      Padding(
                        padding: EdgeInsets.only(
                          top: 14 * scale,
                          bottom: 4 * scale,
                        ),
                        child: Text(
                          l10n.itemDescriptionLabel,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w600,
                            fontSize: 15 * scale,
                          ),
                        ),
                      ),
                      TextFormField(
                        decoration: fieldDecoration(
                          label: null,
                          hint: l10n.itemDescriptionHint,
                        ),
                        maxLines: 3,
                        minLines: 3,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        validator: (val) => val == null || val.isEmpty
                            ? l10n.itemRequiredField
                            : null,
                        onSaved: (val) => _description = val,
                      ),

                      // Estimated Value
                      Padding(
                        padding: EdgeInsets.only(
                          top: 12 * scale,
                          bottom: 4 * scale,
                        ),
                        child: Text(
                          l10n.itemValuePerDayLabel,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w600,
                            fontSize: 15 * scale,
                          ),
                        ),
                      ),
                      TextFormField(
                        decoration: fieldDecoration(
                          label: null,
                          hint: l10n.itemValueHint,
                        ),
                        keyboardType: TextInputType.number,
                        onSaved: (val) => _value = val == null || val.isEmpty
                            ? 0
                            : double.tryParse(val) ?? 0,
                      ),

                      // Deposit
                      Padding(
                        padding: EdgeInsets.only(
                          top: 12 * scale,
                          bottom: 4 * scale,
                        ),
                        child: Text(
                          l10n.itemDepositLabel,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w600,
                            fontSize: 15 * scale,
                          ),
                        ),
                      ),
                      TextFormField(
                        decoration: fieldDecoration(
                          label: null,
                          hint: l10n.itemDepositHint,
                        ),
                        keyboardType: TextInputType.number,
                        onSaved: (val) => _deposit = val == null || val.isEmpty
                            ? 0
                            : double.tryParse(val) ?? 0,
                      ),

                      SizedBox(height: 20 * scale),

                      // Date pickers row
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _selectDate(context, true),
                              child: AbsorbPointer(
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    labelText: l10n.itemAvailableFrom,
                                    hintText: l10n.itemDateHint,
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
                                  validator: (val) => _fromDate == null
                                      ? l10n.itemRequiredField
                                      : null,
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
                                    labelText: l10n.itemAvailableUntil,
                                    hintText: l10n.itemDateHint,
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
                                  validator: (val) => _untilDate == null
                                      ? l10n.itemRequiredField
                                      : null,
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
                          l10n.itemLocationLabel,
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
                              hint: l10n.itemLocationHint,
                              icon: Icons.map_outlined,
                            ),
                            controller: TextEditingController(
                              text: _locationLatLng == null
                                  ? ''
                                  : 'Lat: ${_locationLatLng!.latitude.toStringAsFixed(5)}, Lng: ${_locationLatLng!.longitude.toStringAsFixed(5)}',
                            ),
                            validator: (val) {
                              if (_locationLatLng == null) {
                                return l10n.itemLocationRequired;
                              }
                              return null;
                            },
                          ),
                        ),
                      ),

                      SizedBox(height: 20 * scale),

                      // Save Button Animation + BlocBuilder to update state
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
                          child: BlocBuilder<CreateItemCubit, CreateItemState>(
                            builder: (context, state) {
                              final isLoading = state is CreateItemLoading;
                              return ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryBlue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      11 * scale,
                                    ),
                                  ),
                                ),
                                onPressed: isLoading
                                    ? null
                                    : () => _submit(context),
                                child: isLoading
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
                                        l10n.itemPublishButton,
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
