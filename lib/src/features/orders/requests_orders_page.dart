import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sellefli/src/core/widgets/animated_return_button.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/buttons/advanced_button.dart';
import '../../core/widgets/chips/chip_badge.dart';
import '../../core/widgets/nav/bottom_nav.dart';

class RequestsOrdersPage extends StatefulWidget {
  const RequestsOrdersPage({Key? key}) : super(key: key);

  @override
  State<RequestsOrdersPage> createState() => _RequestsOrdersPageState();
}

class _RequestsOrdersPageState extends State<RequestsOrdersPage> {
  int _navIndex = 1;
  bool _showIncoming = true;

  @override
  Widget build(BuildContext context) {
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
            'Settings & Help',
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

    

      body: Column(
        children: [
          // Tabs
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: _TabButton(
                    label: 'Incoming',
                    isSelected: _showIncoming,
                    onTap: () => setState(() => _showIncoming = true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TabButton(
                    label: 'My Requests',
                    isSelected: !_showIncoming,
                    onTap: () => setState(() => _showIncoming = false),
                  ),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                _RequestCard(
                  imageUrl: 'https://images.unsplash.com/photo-1572981779307-38b8cabb2407?w=400',
                  title: 'Electric Drill Set',
                  sender: 'Alice Johnson',
                  dateRange: 'Jul 10 - Jul 12',
                  status: RequestStatus.pending,
                ),
                SizedBox(height: 12),
                _RequestCard(
                  imageUrl: 'https://m.media-amazon.com/images/I/61qzcUy7S8L._AC_SL1500_.jpg',
                  title: 'High-Pressure Washer',
                  sender: 'Bob Smith',
                  dateRange: 'Aug 01 - Aug 05',
                  status: RequestStatus.accepted,
                ),
                SizedBox(height: 12),
                _RequestCard(
                  imageUrl: 'https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?w=400',
                  title: 'Camping Tent (4-person)',
                  sender: 'Charlie Brown',
                  dateRange: 'Aug 15 - Aug 17',
                  status: RequestStatus.declined,
                ),
                SizedBox(height: 12),
                _RequestCard(
                  imageUrl: 'https://m.media-amazon.com/images/I/71EzghTdyKL.jpg',
                  title: 'Stand Mixer',
                  sender: 'Diana Prince',
                  dateRange: 'Sep 01 - Sep 03',
                  status: RequestStatus.pending,
                ),
              ],
            ),
          ),
        ],
      ),

      bottomNavigationBar: AnimatedBottomNav(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
      ),
    );
  }
}

// ------------------ TABS ------------------

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
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
            color: isSelected ? Colors.transparent : AppColors.border,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
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
              color: isSelected ? Colors.white : AppColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// ------------------ REQUEST CARD ------------------

enum RequestStatus { pending, accepted, declined }

class _RequestCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String sender;
  final String dateRange;
  final RequestStatus status;

  const _RequestCard({
    required this.imageUrl,
    required this.title,
    required this.sender,
    required this.dateRange,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.subtitle),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.person_outline, size: 14, color: AppColors.muted),
                        const SizedBox(width: 4),
                        Text('From $sender', style: AppTextStyles.caption),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.muted),
                        const SizedBox(width: 4),
                        Text(dateRange, style: AppTextStyles.caption),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              _buildStatusBadge(status), // badge

              const Spacer(),

              SizedBox(
                width: 90,
                child: AdvancedButton(
                  label: 'Accept',
                  onPressed: () {},
                  fullWidth: true,
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              SizedBox(
                width: 90,
                child: AdvancedButton(
                  label: 'Decline',
                  onPressed: () {},
                  fullWidth: true,
                  gradient: const LinearGradient(
                    colors: [AppColors.danger, Color(0xFFB63A2D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return const ChipBadge(label: 'Pending', type: ChipType.ghost);
      case RequestStatus.accepted:
        return const ChipBadge(label: 'Accepted', type: ChipType.primary);
      case RequestStatus.declined:
        return const ChipBadge(label: 'Declined', type: ChipType.danger);
    }
  }
}
