
// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:sellefli/src/core/widgets/animated_return_button.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/image/image_gallery.dart';
import '../../core/widgets/inputs/field_decoration.dart';
import '../../core/widgets/dropdown/animated_dropdown.dart';

class EditItemPage extends StatefulWidget {
  const EditItemPage({Key? key}) : super(key: key);

  @override
  State<EditItemPage> createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  List<XFile> _images = [];
  String? _title;
  String? _category;
  String? _description;
  double? _value;
  double? _deposit;
  DateTime? _fromDate;
  DateTime? _untilDate;
  LatLng? _locationLatLng;
  bool _showImageError = false;
  late AnimationController _animController;

  final List<String> _categories = [
    'Electronics & Tech',
    'Home & Appliances',
    'Furniture & Décor',
    'Tools & Equipment',
    'Vehicles & Mobility',
    'Sports & Outdoors',
    'Books & Study',
    'Fashion & Accessories',
    'Events & Celebrations',
    'Baby & Kids',
    'Health & Personal Care',
    'Musical Instruments',
    'Hobbies & Crafts',
    'Pet Supplies',
    'Other Items',
  ];

  final Map<String, IconData> _categoryIcons = {
    'Electronics & Tech': Icons.devices_rounded,
    'Home & Appliances': Icons.kitchen_rounded,
    'Furniture & Décor': Icons.chair_rounded,
    'Tools & Equipment': Icons.construction_rounded,
    'Vehicles & Mobility': Icons.directions_car_rounded,
    'Sports & Outdoors': Icons.sports_soccer_rounded,
    'Books & Study': Icons.menu_book_rounded,
    'Fashion & Accessories': Icons.checkroom_rounded,
    'Events & Celebrations': Icons.celebration_rounded,
    'Baby & Kids': Icons.child_care_rounded,
    'Health & Personal Care': Icons.favorite_rounded,
    'Musical Instruments': Icons.music_note_rounded,
    'Hobbies & Crafts': Icons.palette_rounded,
    'Pet Supplies': Icons.pets_rounded,
    'Other Items': Icons.category_rounded,
  };

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
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_images.length >= 5) return;
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();
    // ignore: unnecessary_null_comparison
    if (picked != null && picked.isNotEmpty) {
      setState(() {
        _images = [..._images, ...picked].take(5).toList();
        _showImageError = false;
      });
    }
  }

  Future<void> _pickImageCamera() async {
    if (_images.length >= 5) return;
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
        // wrap the date picker in a Theme to override colors locally
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryBlue, // header background, selected day
              onPrimary: Colors.white, // header & selected text color
              onSurface: Colors.black87, // default text color
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: AppColors.pageBackground,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
              ),
            ),
            // If your Flutter supports DatePickerThemeData you can add more:
            datePickerTheme: DatePickerThemeData(
              backgroundColor: AppColors.appBarBackground,
              headerBackgroundColor: AppColors.primaryBlue,
              headerForegroundColor: Colors.white,
              // rangeSelectionOverlayColor: AppColors.primaryBlue.withOpacity(
              //   0.12,
              // ),
              dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected))
                  return Colors.white;
                if (states.contains(WidgetState.disabled))
                  return Colors.grey.shade400;
                return Colors.black87;
              }),
              // todayForegroundColor: AppColors.primaryBlue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isFrom)
          _fromDate = picked;
        else
          _untilDate = picked;
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

  void _onSave() {
    setState(() {
      _showImageError = _images.isEmpty;
    });
    if (_images.isEmpty) return;
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenW = MediaQuery.of(context).size.width;
    final scale = (screenW / 350).clamp(0.8, 1.0);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 207, 225, 255),
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
      // backgroundColor: AppColors.pageBackground,
      body: 
      Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
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
                            padding: EdgeInsets.symmetric(vertical: 13 * scale),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9 * scale),
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
                          onPressed: _pickImageCamera,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.primaryBlue),
                            padding: EdgeInsets.symmetric(vertical: 13 * scale),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9 * scale),
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

                  SizedBox(height: 0 * scale),

                  // Title field
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
                    decoration: fieldDecoration(
                      label: null,
                      hint: 'e.g., Electric Drill, Bicycle',
                    ),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Required' : null,
                    onSaved: (val) => _title = val,
                  ),

                  // Category Dropdown
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
                    categoryIcons: _categoryIcons, // <-- ADD THIS
                    selected: _category!,
                    scale: scale,
                    onChanged: (v) => setState(() => _category = v),
                  ),
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
                    onSaved: (val) => _description = val,
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
                    decoration: fieldDecoration(
                      label: null,
                      hint: 'e.g., 150 DA',
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
                      'Deposit Required',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w600,
                        fontSize: 15 * scale,
                      ),
                    ),
                  ),
                  TextFormField(
                    decoration: fieldDecoration(
                      label: null,
                      hint: 'e.g., 50 DA (refundable)',
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
                                labelText: 'Available From',
                                hintText:
                                    'MM/DD/YYYY', // Placeholder date format
                                floatingLabelBehavior: FloatingLabelBehavior
                                    .always, // Always float
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
                                hintText:
                                    'MM/DD/YYYY', // Placeholder date format
                                floatingLabelBehavior: FloatingLabelBehavior
                                    .always, // Always float
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

                  // Save Button Animation
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
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11 * scale),
                          ),
                        ),
                        onPressed: _onSave,
                        child: Text(
                          'Edit Item',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w700,
                            fontSize: 17 * scale,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
