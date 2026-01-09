// lib/src/features/bookings/booking_detail_page.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sellefli/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/buttons/advanced_button.dart';
import '../../core/widgets/chips/chip_badge.dart';
import '../../core/widgets/avatar/avatar.dart';
import '../../core/widgets/rating_widget.dart';
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
    final routeBookingId =
        ModalRoute.of(context)?.settings.arguments as String?;
    final finalBookingId = bookingId ?? routeBookingId;

    return BlocProvider(
      create: (context) =>
          BookingCubit()..fetchBookingDetails(finalBookingId ?? ''),
      child: _BookingDetailPageContent(bookingId: finalBookingId ?? ''),
    );
  }
}

class _BookingDetailPageContent extends StatefulWidget {
  final String bookingId;
  const _BookingDetailPageContent({required this.bookingId});

  @override
  State<_BookingDetailPageContent> createState() =>
      _BookingDetailPageContentState();
}

class _BookingDetailPageContentState extends State<_BookingDetailPageContent> {
  late final String _bookingId = widget.bookingId;

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<BookingCubit, BookingState>(
          listener: (context, state) {
            if (state is BookingActionSuccess) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
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
            if (state is BookingLoading || state is BookingInitial || state is BookingActionSuccess) {
                // While an action just succeeded and we re-fetch details,
                // keep showing a loading state instead of "No booking data".
                return const Center(child: CircularProgressIndicator());
              }

            if (state is BookingError) {
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
                      l10n.bookingDetailsError(state.error),
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

            if (state is! BookingDetailsLoaded) {
              // Fallback: show a lightweight loader 
              return const Center(child: CircularProgressIndicator());
            }

            final booking = state.bookingDetails['booking'] as Booking;
            final item = state.bookingDetails['item'] as Item?;
            final borrower = state.bookingDetails['borrower'] as models.User?;
            final owner = state.bookingDetails['owner'] as models.User?;

            // Get current user ID from Supabase
            final currentUserId = context
                .read<BookingCubit>()
                .bookingRepository
                .supabase
                .auth
                .currentUser
                ?.id;
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
                double horizontalPadding = isSmallMobile
                    ? 12
                    : (isMobile ? 16 : (isTablet ? 24 : 32));
                double cardPadding = isSmallMobile ? 12 : (isMobile ? 16 : 20);
                double maxCardWidth = isDesktop
                    ? 800
                    : (isTablet ? width * 0.9 : width * 0.95);

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
                            color: Colors.black.withAlpha(
                              ((0.04) * 255).toInt(),
                            ),
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
                                  l10n.bookingDetailsTitle,
                                  style: TextStyle(
                                    fontSize: isSmallMobile
                                        ? 16
                                        : (isMobile ? 18 : 20),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.close,
                                  size: isSmallMobile ? 18 : 20,
                                ),
                                onPressed: () => Navigator.pop(context),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                          SizedBox(height: isMobile ? 16 : 24),

                          Text(
                            l10n.bookingSummaryTitle,
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
                                  image: () {
                                    final imageUrl =
                                        state.bookingDetails['imageUrl']
                                            as String?;
                                    if (imageUrl != null &&
                                        imageUrl.isNotEmpty) {
                                      return DecorationImage(
                                        image: NetworkImage(imageUrl),
                                        fit: BoxFit.cover,
                                      );
                                    }
                                    return null;
                                  }(),
                                ),
                                child: (() {
                                  final imageUrl =
                                      state.bookingDetails['imageUrl']
                                          as String?;
                                  if (imageUrl == null || imageUrl.isEmpty) {
                                    return const Icon(
                                      Icons.image,
                                      size: 40,
                                      color: Colors.grey,
                                    );
                                  }
                                  return null;
                                })(),
                              ),
                              SizedBox(width: isSmallMobile ? 8 : 12),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item?.title ?? l10n.itemDetailsTitle,
                                      style: TextStyle(
                                        fontSize: isSmallMobile ? 14 : 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: isSmallMobile ? 6 : 8),
                                    Row(
                                      children: [
                                        Avatar(
                                          imageUrl:
                                              borrower?.avatarUrl ??
                                              'https://cdn-icons-png.flaticon.com/512/666/666175.png',
                                          size: 15,
                                        ),
                                        const SizedBox(width: 6),
                                        Flexible(
                                          child: Text(
                                            l10n.bookingBorrowedBy(
                                              borrower?.username ?? '—',
                                            ),
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
                                          '${l10n.bookingDialogTotalCost}: ',
                                          style: TextStyle(
                                            fontSize: isSmallMobile ? 11 : 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          'DA ${booking.totalCost?.toStringAsFixed(2) ?? "0.00"}',
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons
                                                .account_balance_wallet_outlined,
                                            size: isSmallMobile ? 16 : 18,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            l10n.bookingDepositLabel,
                                            style: TextStyle(
                                              fontSize: isSmallMobile ? 12 : 14,
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            'DA ${item?.depositAmount?.toStringAsFixed(2) ?? "0.00"}',
                                            style: TextStyle(
                                              fontSize: isSmallMobile ? 14 : 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      ChipBadge(
                                        label: _depositStatusLabel(
                                          booking.depositStatus,
                                          l10n,
                                        ),
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
                                              Icons
                                                  .account_balance_wallet_outlined,
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
                                            'DA ${item?.depositAmount?.toStringAsFixed(2) ?? "0.00"}',
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

                          // Rate Your Experience button - only show if completed/closed and not yet rated
                          (() {
                            final bookingCubit = context.read<BookingCubit>();
                            final currentUserId = bookingCubit
                                .bookingRepository
                                .supabase
                                .auth
                                .currentUser
                                ?.id;
                            final isOwnerLocal =
                                currentUserId == booking.ownerId;
                            final targetUserId = isOwnerLocal
                                ? borrower?.id
                                : owner?.id;
                            final canRate =
                                (booking.status == BookingStatus.completed ||
                                    booking.status == BookingStatus.closed) &&
                                targetUserId != null &&
                                currentUserId != null;
                            if (!canRate) return const SizedBox.shrink();

                            final safeCurrentUserId = currentUserId;
                            final safeTargetUserId = targetUserId;

                            return FutureBuilder<bool>(
                              future: bookingCubit.hasAlreadyRated(
                                bookingId: booking.id,
                                raterUserId: safeCurrentUserId,
                              ),
                              builder: (context, snapshot) {
                                // While checking, show nothing
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const SizedBox.shrink();
                                }
                                // If already rated, don't show button
                                if (snapshot.data == true) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.success.withAlpha(
                                            25,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: AppColors.success.withAlpha(
                                              50,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.check_circle,
                                              color: AppColors.success,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            const Text(
                                              'You have already rated this booking',
                                              style: TextStyle(
                                                color: AppColors.success,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: isMobile ? 16 : 24),
                                    ],
                                  );
                                }
                                // Show rate button
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AdvancedButton(
                                      label: 'Rate Your Experience',
                                      onPressed: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/rating',
                                          arguments: RatingPageArguments(
                                            bookingId: booking.id,
                                            targetUserId: safeTargetUserId,
                                          ),
                                        );
                                      },
                                      gradient: const LinearGradient(
                                        colors: [
                                          AppColors.primary,
                                          AppColors.primaryDark,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    SizedBox(height: isMobile ? 16 : 24),
                                  ],
                                );
                              },
                            );
                          })(),

                          Text(
                            l10n.bookingStatusLabel,
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

                                Text(
                                  l10n.bookingCodeLabel,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
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
                              l10n.bookingOwnerActions,
                              style: TextStyle(
                                fontSize: isSmallMobile ? 14 : 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: isMobile ? 8 : 12),

                            // Mark deposit as received (only when accepted & deposit none)
                            AdvancedButton(
                              label: l10n.bookingMarkDepositReceived,
                              onPressed:
                                  booking.status == BookingStatus.accepted &&
                                      booking.depositStatus ==
                                          DepositStatus.none
                                  ? () {
                                      context
                                          .read<BookingCubit>()
                                          .markDepositReceived(booking.id);
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
                              label: l10n.bookingMarkDepositReturned,
                              onPressed:
                                  booking.depositStatus !=
                                          DepositStatus.returned &&
                                      booking.depositStatus !=
                                          DepositStatus.kept
                                  ? () {
                                      context
                                          .read<BookingCubit>()
                                          .markDepositReturned(booking.id);
                                    }
                                  : null,
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.primaryDark,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),

                            SizedBox(height: isMobile ? 8 : 12),

                            AdvancedButton(
                              label: l10n.bookingKeepDeposit,
                              onPressed:
                                  booking.depositStatus !=
                                          DepositStatus.returned &&
                                      booking.depositStatus !=
                                          DepositStatus.kept
                                  ? () {
                                      context.read<BookingCubit>().keepDeposit(
                                        booking.id,
                                      );
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
                              l10n.bookingOwnerInformation,
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          owner?.username ??
                                              l10n.itemDetailsOwner,
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

String _depositStatusLabel(DepositStatus status, AppLocalizations l10n) {
  switch (status) {
    case DepositStatus.none:
      return l10n.depositStatusNone;
    case DepositStatus.received:
      return l10n.depositStatusReceived;
    case DepositStatus.returned:
      return l10n.depositStatusReturned;
    case DepositStatus.kept:
      return l10n.depositStatusKept;
  }
}

class RatingDialog extends StatefulWidget {
  final Function(int) onSubmit;

  const RatingDialog({super.key, required this.onSubmit});

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  int _rating = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.bookingRateExperience),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.bookingRateQuestion),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 32,
                ),
                onPressed: () {
                  setState(() {
                    _rating = index + 1;
                  });
                },
              );
            }),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _rating > 0 ? () => widget.onSubmit(_rating) : null,
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
