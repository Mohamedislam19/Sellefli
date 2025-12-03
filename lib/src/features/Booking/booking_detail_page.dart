// lib/src/features/bookings/booking_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/buttons/advanced_button.dart';
import '../../core/widgets/chips/chip_badge.dart';
import '../../core/widgets/avatar/avatar.dart';
import '../../data/models/booking_model.dart';
import '../../data/models/item_model.dart';
import '../../data/models/user_model.dart' as models;
import 'logic/booking_cubit.dart';

class BookingDetailPage extends StatelessWidget {
  final String? bookingId;
  
  const BookingDetailPage({super.key, this.bookingId});

  @override
  Widget build(BuildContext context) {
    // Get bookingId from route arguments if not provided
    final routeBookingId = ModalRoute.of(context)?.settings.arguments as String?;
    final finalBookingId = bookingId ?? routeBookingId;

    return BlocProvider(
      create: (context) => BookingCubit()..fetchBookingDetails(finalBookingId ?? ''),
      child: _BookingDetailPageContent(bookingId: finalBookingId ?? ''),
    );
  }
}

class _BookingDetailPageContent extends StatefulWidget {
  final String bookingId;
  const _BookingDetailPageContent({required this.bookingId});

  @override
  State<_BookingDetailPageContent> createState() => _BookingDetailPageContentState();
}

class _BookingDetailPageContentState extends State<_BookingDetailPageContent> {
  late final String _bookingId = widget.bookingId;

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<BookingCubit, BookingState>(
          listener: (context, state) {
            if (state is BookingActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
              // Refresh details in place so user sees updated status/deposit
              if (_bookingId.isNotEmpty) {
                context.read<BookingCubit>().fetchBookingDetails(_bookingId);
              }
            } else if (state is BookingError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is BookingLoading || state is BookingInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is BookingError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${state.error}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              );
            }

            if (state is! BookingDetailsLoaded) {
              return const Center(child: Text('No booking data'));
            }

            final booking = state.bookingDetails['booking'] as Booking;
            final item = state.bookingDetails['item'] as Item?;
            final borrower = state.bookingDetails['borrower'] as models.User?;
            final owner = state.bookingDetails['owner'] as models.User?;
            
            // Get current user ID from Supabase
            final currentUserId = context.read<BookingCubit>().bookingRepository.supabase.auth.currentUser?.id;
            final isOwner = currentUserId == booking.ownerId;

            return LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final height = constraints.maxHeight;
                final isSmallMobile = width < 360;
                final isMobile = width < 600;
                final isTablet = width >= 600 && width < 900;
                final isDesktop = width >= 900;
                
                // Responsive sizing
                double horizontalPadding = isSmallMobile ? 12 : (isMobile ? 16 : (isTablet ? 24 : 32));
                double cardPadding = isSmallMobile ? 12 : (isMobile ? 16 : 20);
                double maxCardWidth = isDesktop ? 800 : (isTablet ? width * 0.9 : width * 0.95);
                
                return Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 16,
                    ),
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: maxCardWidth,
                        minHeight: height * 0.5,
                      ),
                      padding: EdgeInsets.all(cardPadding),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,

                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(((0.04) * 255).toInt()),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              'Booking Details',
                              style: TextStyle(
                                fontSize: isSmallMobile ? 16 : (isMobile ? 18 : 20),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, size: isSmallMobile ? 18 : 20),
                            onPressed: () => Navigator.pop(context),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      SizedBox(height: isMobile ? 16 : 24),

                      Text(
                        'Item & Booking Summary',
                        style: TextStyle(
                          fontSize: isSmallMobile ? 14 : 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: isMobile ? 12 : 16),

                      /// Product info
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: isSmallMobile ? 60 : 70,
                            height: isSmallMobile ? 60 : 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: AppColors.primary.withOpacity(0.1),
                              image: item != null
                                  ? DecorationImage(
                                      image: NetworkImage(
                                        'https://via.placeholder.com/150',
                                      ),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: item == null
                                ? const Icon(Icons.image, size: 40, color: Colors.grey)
                                : null,
                          ),
                          SizedBox(width: isSmallMobile ? 8 : 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item?.title ?? 'Item',
                                style: TextStyle(
                                  fontSize: isSmallMobile ? 14 : 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: isSmallMobile ? 6 : 8),
                              Row(
                                children: [
                                  Avatar(
                                    imageUrl: borrower?.avatarUrl ??
                                        'https://cdn-icons-png.flaticon.com/512/666/666175.png',
                                    size: 15,
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      'Borrowed by: ${borrower?.username ?? "Unknown"}',
                                      style: TextStyle(
                                        fontSize: isSmallMobile ? 11 : 12,
                                        color: Colors.grey,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: isSmallMobile ? 10 : 12),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    size: isSmallMobile ? 12 : 14,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${_formatDate(booking.startDate)} - ${_formatDate(booking.returnByDate)}',
                                    style: TextStyle(
                                      fontSize: isSmallMobile ? 11 : 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: isSmallMobile ? 6 : 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.attach_money,
                                    size: isSmallMobile ? 12 : 14,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Total Cost: ',
                                    style: TextStyle(
                                      fontSize: isSmallMobile ? 11 : 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    '\$${booking.totalCost?.toStringAsFixed(2) ?? "0.00"}',
                                    style: TextStyle(
                                      fontSize: isSmallMobile ? 11 : 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                      SizedBox(height: isMobile ? 16 : 20),

                      Padding(
                        padding: EdgeInsets.all(isSmallMobile ? 8 : 12),
                        child: isMobile
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.account_balance_wallet_outlined,
                                        size: isSmallMobile ? 16 : 18,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Deposit:',
                                        style: TextStyle(fontSize: isSmallMobile ? 12 : 14),
                                      ),
                                      const Spacer(),
                                      Text(
                                        '\$${item?.depositAmount?.toStringAsFixed(2) ?? "0.00"}',
                                        style: TextStyle(
                                          fontSize: isSmallMobile ? 14 : 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ChipBadge(
                                    label: booking.depositStatus.name,
                                    type: ChipType.primary,
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  const Expanded(
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.account_balance_wallet_outlined,
                                          size: 18,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Deposit:',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        '\$${item?.depositAmount?.toStringAsFixed(2) ?? "0.00"}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: ChipBadge(
                                        label: booking.depositStatus.name,
                                        type: ChipType.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),

                      SizedBox(height: isMobile ? 16 : 24),

                      Text(
                        'Booking Status',
                        style: TextStyle(
                          fontSize: isSmallMobile ? 14 : 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: isMobile ? 8 : 12),

                      /// Status
                      Padding(
                        padding: EdgeInsets.all(isSmallMobile ? 8 : 12),
                      child: Row(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 14,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 8),

                          ChipBadge(
                            label: booking.status.name,
                            type: ChipType.primary,
                          ),

                          const Spacer(),

                          const Text(
                            'Booking Code:',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(width: 8),

                          Text(
                            booking.bookingCode ?? 'N/A',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                      SizedBox(height: isMobile ? 16 : 24),

                      // Show owner actions only if current user is the owner
                      if (isOwner) ...[
                        Text(
                          'Owner Actions',
                          style: TextStyle(
                            fontSize: isSmallMobile ? 14 : 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: isMobile ? 8 : 12),

                        // Mark deposit as received (only when accepted & deposit none)
                        AdvancedButton(
                          label: 'Mark Deposit Received',
                          onPressed: booking.status == BookingStatus.accepted &&
                                      booking.depositStatus == DepositStatus.none
                              ? () {
                                  context.read<BookingCubit>().markDepositReceived(booking.id);
                                }
                              : null,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),

                        SizedBox(height: isMobile ? 8 : 12),

                        AdvancedButton(
                          label: 'Mark Deposit as Returned',
                          onPressed: booking.depositStatus != DepositStatus.returned && 
                                    booking.depositStatus != DepositStatus.kept
                              ? () {
                                  context.read<BookingCubit>().markDepositReturned(booking.id);
                                }
                              : null,
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryDark],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),

                        SizedBox(height: isMobile ? 8 : 12),

                        AdvancedButton(
                          label: 'Keep Deposit',
                          onPressed: booking.depositStatus != DepositStatus.returned && 
                                    booking.depositStatus != DepositStatus.kept
                              ? () {
                                  context.read<BookingCubit>().keepDeposit(booking.id);
                                }
                              : null,
                          gradient: const LinearGradient(
                            colors: [AppColors.danger, Color(0xFFB63A2D)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ] else ...[
                        // Borrower view - show owner info instead
                        Text(
                          'Owner Information',
                          style: TextStyle(
                            fontSize: isSmallMobile ? 14 : 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: isMobile ? 8 : 12),
                        
                        Container(
                          padding: EdgeInsets.all(cardPadding),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Avatar(
                                imageUrl: owner?.avatarUrl,
                                size: isSmallMobile ? 40 : 48,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      owner?.username ?? 'Unknown Owner',
                                      style: TextStyle(
                                        fontSize: isSmallMobile ? 14 : 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (owner?.phone != null)
                                      Text(
                                        owner!.phone!,
                                        style: TextStyle(
                                          fontSize: isSmallMobile ? 12 : 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
          },
        ),
      ),
    );
  }
}
