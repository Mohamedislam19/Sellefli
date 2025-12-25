// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sellefli/l10n/app_localizations.dart';
import 'package:sellefli/src/core/widgets/animated_return_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/buttons/advanced_button.dart';
import '../../core/widgets/chips/chip_badge.dart';
import '../../core/widgets/nav/bottom_nav.dart';
import '../../data/models/booking_model.dart';
import '../Booking/logic/booking_cubit.dart';

class RequestsOrdersPage extends StatelessWidget {
  const RequestsOrdersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BookingCubit(),
      child: const _RequestsOrdersPageContent(),
    );
  }
}

class _RequestsOrdersPageContent extends StatefulWidget {
  const _RequestsOrdersPageContent({Key? key}) : super(key: key);

  @override
  State<_RequestsOrdersPageContent> createState() => _RequestsOrdersPageState();
}

class _RequestsOrdersPageState extends State<_RequestsOrdersPageContent> {
  int _currentIndex = 1;

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/listings');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/profile-page');
        break;
    }
  }

  bool _showIncoming = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['initialTab'] == 'my_requests') {
      if (_showIncoming) {
        setState(() {
          _showIncoming = false;
        });
        _loadBookings();
      }
    }
  }

  void _loadBookings() {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      if (_showIncoming) {
        context.read<BookingCubit>().fetchIncomingRequests(userId);
      } else {
        context.read<BookingCubit>().fetchMyRequests(userId);
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  // No mapping needed: use BookingStatus directly for consistency

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isSmallMobile = width < 360;
        final isMobile = width < 600;

        // Responsive scaling
        final scale = isSmallMobile ? 0.85 : (isMobile ? 0.95 : 1.0);

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
                l10n.requestsTitle,
                style: GoogleFonts.outfit(
                  fontSize: (isSmallMobile ? 18 : 22) * scale,
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
            child: Column(
              children: [
                // Tabs
                Padding(
                  padding: EdgeInsets.all(isSmallMobile ? 12 : 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _TabButton(
                          label: l10n.requestsIncomingTab,
                          isSelected: _showIncoming,
                          onTap: () {
                            setState(() => _showIncoming = true);
                            _loadBookings();
                          },
                          isSmallMobile: isSmallMobile,
                        ),
                      ),
                      SizedBox(width: isSmallMobile ? 8 : 12),
                      Expanded(
                        child: _TabButton(
                          label: l10n.requestsMyRequestsTab,
                          isSelected: !_showIncoming,
                          onTap: () {
                            setState(() => _showIncoming = false);
                            _loadBookings();
                          },
                          isSmallMobile: isSmallMobile,
                        ),
                      ),
                    ],
                  ),
                ),

                // List with BlocBuilder
                Expanded(
                  child: BlocConsumer<BookingCubit, BookingState>(
                    listener: (context, state) {
                      if (state is BookingActionSuccess) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(state.message)));
                        _loadBookings(); // Refresh list after action
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
                      if (state is BookingLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state is BookingError) {
                        return Center(
                          child: Column(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.requestsError(state.error),
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadBookings,
                                child: Text(l10n.retry),
                              ),
                            ],
                          ),
                        );
                      }

                      if (state is BookingListLoaded) {
                        if (state.bookings.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _showIncoming
                                      ? Icons.inbox
                                      : Icons.send_outlined,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _showIncoming
                                      ? l10n.requestsNoIncoming
                                      : l10n.requestsNoSent,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.separated(
                          padding: EdgeInsets.all(isSmallMobile ? 12 : 16),
                          itemCount: state.bookings.length,
                          separatorBuilder: (context, index) =>
                              SizedBox(height: isSmallMobile ? 8 : 12),
                          itemBuilder: (context, index) {
                            final data = state.bookings[index];
                            final booking = data['booking'] as Booking;
                            final item = data['item'];
                            final otherUser = _showIncoming
                                ? data['borrower']
                                : data['owner'];
                            final imageUrl = data['imageUrl'] as String?;
                            final avatarUrl = otherUser?.avatarUrl as String?;

                            return _RequestCard(
                              bookingId: booking.id,
                              imageUrl:
                                  imageUrl ?? 'https://via.placeholder.com/150',
                              title: item?.title ?? l10n.itemDetailsTitle,
                              sender: otherUser?.username ?? l10n.homeEmpty,
                              senderAvatarUrl: avatarUrl,
                              dateRange:
                                  '${_formatDate(booking.startDate)} - ${_formatDate(booking.returnByDate)}',
                              status: booking.status,
                              isSmallMobile: isSmallMobile,
                              isMobile: isMobile,
                              isOwnerView: _showIncoming,
                              l10n: l10n,
                              onAccept: () => context
                                  .read<BookingCubit>()
                                  .acceptBooking(booking.id),
                              onDecline: () => context
                                  .read<BookingCubit>()
                                  .declineBooking(booking.id),
                            );
                          },
                        );
                      }

                      // Initial state
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
              ],
            ),
          ),

          bottomNavigationBar: AnimatedBottomNav(
            currentIndex: _currentIndex,
            onTap: _onNavTap,
          ),
        );
      },
    );
  }
}

// ------------------ TABS ------------------

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isSmallMobile;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isSmallMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: isSmallMobile ? 10 : 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.primaryBlue,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(((0.2) * 255).toInt()),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.body.copyWith(
              color: isSelected ? Colors.white : AppColors.primaryBlue,
              fontWeight: FontWeight.w600,
              fontSize: isSmallMobile ? 13 : null,
            ),
          ),
        ),
      ),
    );
  }
}

// REQUEST CARD 

// Use BookingStatus across list and detail for consistency

class _RequestCard extends StatelessWidget {
  final String bookingId;
  final String imageUrl;
  final String title;
  final String sender;
  final String? senderAvatarUrl;
  final String dateRange;
  final BookingStatus status;
  final bool isSmallMobile;
  final bool isMobile;
  final bool isOwnerView;
  final AppLocalizations l10n;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _RequestCard({
    required this.bookingId,
    required this.imageUrl,
    required this.title,
    required this.sender,
    this.senderAvatarUrl,
    required this.dateRange,
    required this.status,
    this.isSmallMobile = false,
    this.isMobile = true,
    required this.isOwnerView,
    required this.l10n,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/booking-details', arguments: bookingId);
      },
      child: Container(
        padding: EdgeInsets.all(isSmallMobile ? 10 : 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(((0.05) * 255).toInt()),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: isSmallMobile ? 56 : 64,
                  height: isSmallMobile ? 56 : 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: isSmallMobile ? 8 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.subtitle.copyWith(
                          fontSize: isSmallMobile ? 14 : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: isSmallMobile ? 4 : 6),
                      Row(
                        children: [
                          // Sender avatar (fallback to icon if missing)
                          if (senderAvatarUrl != null &&
                              senderAvatarUrl!.isNotEmpty) ...[
                            Container(
                              width: isSmallMobile ? 16 : 18,
                              height: isSmallMobile ? 16 : 18,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: NetworkImage(senderAvatarUrl!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(width: isSmallMobile ? 4 : 6),
                          ] else ...[
                            Icon(
                              Icons.person_outline,
                              size: isSmallMobile ? 12 : 14,
                              color: AppColors.muted,
                            ),
                            SizedBox(width: isSmallMobile ? 3 : 4),
                          ],
                          Flexible(
                            child: Text(
                              l10n.requestsFromSender( sender),
                              style: AppTextStyles.caption.copyWith(
                                fontSize: isSmallMobile ? 11 : null,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isSmallMobile ? 3 : 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: isSmallMobile ? 12 : 14,
                            color: AppColors.muted,
                          ),
                          SizedBox(width: isSmallMobile ? 3 : 4),
                          Text(
                            dateRange,
                            style: AppTextStyles.caption.copyWith(
                              fontSize: isSmallMobile ? 11 : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: isSmallMobile ? 8 : 12),

            // List view: show only the status badge (actions happen in detail page)
            SizedBox(
              height: 36,
              child: Align(
                alignment: Alignment.centerLeft,
                child: _buildStatusBadge(status),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return ChipBadge(label: l10n.statusPending, type: ChipType.ghost);
      case BookingStatus.accepted:
        return ChipBadge(label: l10n.statusAccepted, type: ChipType.primary);
      case BookingStatus.declined:
        return ChipBadge(label: l10n.statusDeclined, type: ChipType.danger);
      case BookingStatus.active:
        return ChipBadge(label: l10n.statusActive, type: ChipType.primary);
      case BookingStatus.completed:
        return ChipBadge(label: l10n.statusCompleted, type: ChipType.primary);
      case BookingStatus.closed:
        return ChipBadge(label: l10n.statusClosed, type: ChipType.primary);
    }
  }
}


