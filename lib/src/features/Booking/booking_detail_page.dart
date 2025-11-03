// lib/src/features/bookings/booking_detail_page.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/buttons/advanced_button.dart';
import '../../core/widgets/chips/chip_badge.dart';
import '../../core/widgets/avatar/avatar.dart';

class BookingDetailPage extends StatelessWidget {
  const BookingDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            // keeps card scrollable only if screen is too small
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: screenWidth * 0.95,
                maxHeight: screenHeight * 0.95,
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
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
                        const Text(
                          'Booking Details',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Item & Booking Summary',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    /// Product info
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: const DecorationImage(
                              image: NetworkImage(
                                'https://guitarhaus.ca/cdn/shop/files/IMG_7006.heic?v=1711736295&width=713',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Vintage Acoustic Guitar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: const [
                                  Avatar(
                                    imageUrl:
                                        'https://cdn-icons-png.flaticon.com/512/666/666175.png',
                                    size: 15,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Borrowed by: Sarah J.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: const [
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Oct 20 - Oct 25',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: const [
                                  Icon(
                                    Icons.attach_money,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Total Cost: ',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    '\$45.00',
                                    style: TextStyle(
                                      fontSize: 12,
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

                    const SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: const [
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
                                '\$200.00',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: ChipBadge(
                                label: 'Paid',
                                type: ChipType.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Booking Status',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    /// Status
                    Padding(
                      padding: const EdgeInsets.all(12.0),
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

                          const ChipBadge(
                            label: 'Accepted',
                            type: ChipType.primary,
                          ),

                          const Spacer(),

                          const Text(
                            'Booking Code:',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(width: 8),

                          const Text(
                            'SF-XYZ-123',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Owner Actions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    AdvancedButton(
                      label: 'Mark Deposit as Returned',
                      onPressed: () {
                        Navigator.pushNamed(context, "/rating");
                      },
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),

                    const SizedBox(height: 12),

                    AdvancedButton(
                      label: 'Keep Deposit',
                      onPressed: () {},
                      gradient: const LinearGradient(
                        colors: [AppColors.danger, Color(0xFFB63A2D)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
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
}
