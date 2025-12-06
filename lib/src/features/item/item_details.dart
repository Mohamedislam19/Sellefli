// ignore_for_file: prefer_const_constructors_in_immutables, use_super_parameters

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sellefli/l10n/app_localizations.dart';
import 'package:sellefli/src/core/widgets/animated_return_button.dart';
import 'package:sellefli/src/core/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'logic/item_details_cubit.dart';
import 'logic/item_details_state.dart';
import '../../data/repositories/item_repository.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/repositories/booking_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/item_model.dart';
import '../../data/models/user_model.dart';
import '../../data/models/booking_model.dart';
import 'package:uuid/uuid.dart';
import '../../core/widgets/avatar/avatar.dart';

class ItemDetailsPage extends StatelessWidget {
  final String? itemId;

  const ItemDetailsPage({super.key, this.itemId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Get itemId from arguments if not provided
    final String? id =
        itemId ?? (ModalRoute.of(context)?.settings.arguments as String?);

    if (id == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 207, 225, 255),
          title: Text(l10n.itemDetailsTitle),
        ),
        body: Center(child: Text(l10n.itemDetailsNoId)),
      );
    }

    return BlocProvider(
      create: (context) => ItemDetailsCubit(
        itemRepository: context.read<ItemRepository>(),
        profileRepository: context.read<ProfileRepository>(),
      )..load(id),
      child: _ItemDetailsView(),
    );
  }
}

class _ItemDetailsView extends StatefulWidget {
  _ItemDetailsView({Key? key}) : super(key: key);

  @override
  State<_ItemDetailsView> createState() => _ItemDetailsViewState();
}

class _ItemDetailsViewState extends State<_ItemDetailsView> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    // Scale factor between 0.7 (at 245px) and 1 (at 350px or higher)
    final scale = (screenWidth / 350).clamp(0.7, 1.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 207, 225, 255),
        elevation: 1,
        centerTitle: true,
        leading: const AnimatedReturnButton(),
        title: Padding(
          padding: EdgeInsets.symmetric(vertical: 12 * scale),
          child: Text(
            l10n.itemDetailsTitle,
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
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: BlocBuilder<ItemDetailsCubit, ItemDetailsState>(
          builder: (context, state) {
            if (state is ItemDetailsLoading) {
              return Center(
                child: CircularProgressIndicator(color: AppColors.primaryBlue),
              );
            }

            if (state is ItemDetailsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.itemDetailsGoBack),
                    ),
                  ],
                ),
              );
            }

            if (state is ItemDetailsLoaded) {
              final item = state.item;
              final images = state.images;
              final owner = state.owner;
              final currentUser = context.read<AuthRepository>().currentUser;
              final isOwner = currentUser?.id == item.ownerId;

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  SizedBox(
                    height: 300,
                    child: images.isNotEmpty
                        ? PageView.builder(
                            itemCount: images.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black12,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.network(
                                    images[index].imageUrl,
                                    fit: BoxFit.contain,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.broken_image,
                                              size: 100,
                                              color: Colors.grey,
                                            ),
                                  ),
                                ),
                              );
                            },
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: _buildImage(
                              item.images.isNotEmpty ? item.images.first : '',
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),

                  _buildDetailsCard(item, l10n),
                  const SizedBox(height: 16),

                  if (!isOwner) ...[
                    _buildOwnerInfo(item, owner, l10n),
                    const SizedBox(height: 24),
                    _buildActionButtons(item, l10n),
                    const SizedBox(height: 20),
                  ],

                  Text(
                    l10n.itemDetailsDepositNote,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(
        height: 220,
        width: double.infinity,
        color: Colors.grey[200],
        child: const Center(
          child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
        ),
      );
    }
    if (imageUrl.startsWith('http') || imageUrl.startsWith('https')) {
      return Image.network(
        imageUrl,
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image, size: 100, color: Colors.grey),
      );
    } else {
      return Image.asset(
        imageUrl,
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image, size: 100, color: Colors.grey),
      );
    }
  }

  Widget _buildDetailsCard(Item item, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withAlpha(((0.05) * 255).toInt()),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            item.description ?? l10n.itemDetailsNoDescription,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          _buildDetailRow(l10n.itemDetailsCategory, item.category),
          if (item.estimatedValue != null)
            _buildDetailRow(
              l10n.itemDetailsValue,
              'DA ${item.estimatedValue!.toStringAsFixed(0)}',
            ),
          if (item.depositAmount != null)
            _buildDetailRow(
              l10n.itemDetailsDeposit,
              'DA ${item.depositAmount!.toStringAsFixed(0)}',
            ),
          if (item.startDate != null)
            _buildDetailRow(
              l10n.itemDetailsAvailableFrom,
              _formatDate(item.startDate!),
            ),
          if (item.endDate != null)
            _buildDetailRow(
              l10n.itemDetailsAvailableUntil,
              _formatDate(item.endDate!),
            ),
          _buildDetailRow(
            l10n.itemDetailsStatus,
            item.isAvailable
                ? l10n.itemStatusAvailable
                : l10n.itemStatusUnavailable,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Widget _buildOwnerInfo(Item item, User? owner, AppLocalizations l10n) {
    // Calculate average rating
    final double averageRating = owner != null && owner.ratingCount > 0
        ? owner.ratingSum / owner.ratingCount
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withAlpha(((0.05) * 255).toInt()),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Avatar(
            imageUrl: owner?.avatarUrl,
            initials: owner?.username?.isNotEmpty == true
                ? owner!.username![0].toUpperCase()
                : '?',
            size: 56,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  owner?.username ?? l10n.itemDetailsOwner,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 18, color: Color(0xFFFFC107)),
                    const SizedBox(width: 4),
                    Text(
                      averageRating.toStringAsFixed(1),
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n.itemDetailsOwnerReviews(
                        owner?.ratingCount ?? 0,
                      ),
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: const Color(0xFF9E9E9E),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Item item, AppLocalizations l10n) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: item.isAvailable
                ? () {
                    _showBookingDialog(item);
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              item.isAvailable
                  ? l10n.itemDetailsBookNow
                  : l10n.itemDetailsNotAvailable,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.black54, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _showBookingDialog(Item item) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return BookingDialog(
          item: item,
          bookingRepository: context.read<BookingRepository>(),
          authRepository: context.read<AuthRepository>(),
        );
      },
    );
  }
}

class BookingDialog extends StatefulWidget {
  final Item item;
  final BookingRepository bookingRepository;
  final AuthRepository authRepository;

  const BookingDialog({
    required this.item,
    required this.bookingRepository,
    required this.authRepository,
    super.key,
  });

  @override
  State<BookingDialog> createState() => _BookingDialogState();
}

class _BookingDialogState extends State<BookingDialog>
    with SingleTickerProviderStateMixin {
  late DateTime availableFrom;
  late DateTime availableUntil;
  DateTime? startDate;
  DateTime? endDate;
  int numDays = 0;
  int itemValue = 0;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _parseItemData();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  void _parseItemData() {
    availableFrom = widget.item.startDate ?? DateTime.now();
    availableUntil =
        widget.item.endDate ?? DateTime.now().add(const Duration(days: 30));
    itemValue = widget.item.estimatedValue?.toInt() ?? 0;
  }

  Future<void> _selectDate(bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? availableFrom : (startDate ?? availableFrom),
      firstDate: availableFrom,
      lastDate: availableUntil,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              surface: Colors.white,
              onSurface: AppColors.primaryBlue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
          if (endDate != null && endDate!.isBefore(startDate!)) {
            endDate = null;
          }
        } else {
          endDate = picked;
        }
        _calculateTotalCost();
      });
    }
  }

  void _calculateTotalCost() {
    if (startDate != null && endDate != null) {
      numDays = endDate!.difference(startDate!).inDays + 1;
      if (numDays < 1) {
        numDays = 0;
        endDate = null;
      }
    } else {
      numDays = 0;
    }
  }

  Future<void> _handleBookingConfirmation() async {
    final l10n = AppLocalizations.of(context);
    if (startDate == null || endDate == null || numDays <= 0) {
      return;
    }

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
            const Center(child: CircularProgressIndicator(color: Colors.white)),
      );

      // Get current user
      final currentUser = widget.authRepository.currentUser;
      if (currentUser == null) {
        throw Exception(l10n.bookingDialogAuthRequired);
      }

      // Calculate total cost
      final totalCost = itemValue * numDays;

      // Create booking
      final booking = Booking(
        id: const Uuid().v4(),
        itemId: widget.item.id,
        ownerId: widget.item.ownerId,
        borrowerId: currentUser.id,
        status: BookingStatus.pending,
        depositStatus: DepositStatus.none,
        startDate: startDate!,
        returnByDate: endDate!,
        totalCost: totalCost.toDouble(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await widget.bookingRepository.createBooking(booking);

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Close booking dialog
      if (mounted) Navigator.pop(context);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.bookingDialogSuccess(numDays)),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 3),
          ),
        );

        Navigator.pushReplacementNamed(
          context,
          '/request-order',
          arguments: {'initialTab': 'my_requests'},
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.bookingDialogFail(e.toString())),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FadeTransition(
      opacity: _opacityAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.bookingDialogTitle,
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                            letterSpacing: 0.5,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: const Icon(
                              Icons.close,
                              color: Colors.grey,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildDateField(
                      l10n.bookingDialogStartDate,
                      startDate,
                      true,
                    ),
                    const SizedBox(height: 16),
                    _buildDateField(l10n.bookingDialogEndDate, endDate, false),
                    const SizedBox(height: 24),
                    _buildTotalCostField(),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[100],
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              l10n.bookingDialogCancel,
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: numDays > 0
                                ? () async {
                                    await _handleBookingConfirmation();
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              disabledBackgroundColor: Colors.grey[300],
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              l10n.bookingDialogConfirm,
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: numDays > 0 ? Colors.white : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(String label, DateTime? date, bool isStartDate) {
    return GestureDetector(
      onTap: () => _selectDate(isStartDate),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!, width: 1),
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[50],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date != null
                      ? '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}'
                      : AppLocalizations.of(context).bookingDialogSelectDate,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: date != null ? AppColors.primaryBlue : Colors.grey,
                  ),
                ),
              ],
            ),
            Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalCostField() {
    final totalCost = numDays > 0 ? itemValue * numDays : 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary.withAlpha(100), width: 1.5),
        borderRadius: BorderRadius.circular(10),
        color: Color.fromARGB(255, 207, 225, 255),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).bookingDialogTotalCost,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                numDays > 0 ? 'DA$totalCost' : 'DA 0',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppLocalizations.of(context).bookingDialogDays,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$numDays',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


