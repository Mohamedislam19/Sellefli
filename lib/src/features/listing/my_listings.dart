import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sellefli/src/core/widgets/animated_return_button.dart';
import '../../core/widgets/nav/bottom_nav.dart';
import '../../core/theme/app_theme.dart';

class MyListingsPage extends StatefulWidget {
  const MyListingsPage({Key? key}) : super(key: key);

  @override
  State<MyListingsPage> createState() => _MyListingsPageState();
}

class _MyListingsPageState extends State<MyListingsPage> {
  int _currentIndex = 2;

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/request-order');
        break;
      case 2:
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/profile-page');
        break;
    }
  }

  final List<Map<String, dynamic>> listings = [
    {
      "title": "Cordless Power Drill Set",
      "status": "Active",
      "image": 'assets/images/powerdrill.jpg',
    },
    {
      "title": "4-Person Camping Tent",
      "status": "Rented",
      "image": 'assets/images/powerdrill.jpg',
    },
    {
      "title": "Stand Mixer - KitchenAid",
      "status": "Pending Approval",
      "image": 'assets/images/powerdrill.jpg',
    },
    {
      "title": "Mountain Bike - Size L",
      "status": "Active",
      "image": 'assets/images/powerdrill.jpg',
    },
    {
      "title": "Digital Camera - Canon EOS",
      "status": "Unavailable",
      "image": 'assets/images/powerdrill.jpg',
    },
    {
      "title": "Robotic Vacuum Cleaner",
      "status": "Active",
      "image": 'assets/images/powerdrill.jpg',
    },
  ];

  Color _getStatusColor(String status) {
    switch (status) {
      case "Active":
        return Colors.green;
      case "Rented":
        return Colors.blue;
      case "Pending Approval":
        return Colors.orange;
      case "Unavailable":
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Scale factor between 0.7 (at 245px) and 1 (at 350px or higher)
    final scale = (screenWidth / 350).clamp(0.7, 1.0);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 207, 225, 255),
        elevation: 1,
        centerTitle: true,
        leading: const AnimatedReturnButton(),
        title: Padding(
          padding: EdgeInsets.symmetric(vertical: 12 * scale),
          child: Text(
            'My Listings',
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
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: listings.length,
          itemBuilder: (context, index) {
            final item = listings[index];
            return _buildListingCard(
              title: item["title"],
              status: item["status"],
              imageUrl: item["image"],
            );
          },
        ),
      ),
      bottomNavigationBar: AnimatedBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildListingCard({
    required String title,
    required String status,
    required String imageUrl,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _buildImage(imageUrl),
          ),
          const SizedBox(width: 12),

          // Info + Buttons
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),

                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(
                      status,
                    ).withAlpha(((0.1) * 255).toInt()),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: GoogleFonts.outfit(
                      color: _getStatusColor(status),
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: _actionButton(
                        label: "Edit",
                        color: Colors.grey.shade700,
                        icon: Icons.edit_outlined,
                        onPressed: () {
                          Navigator.pushNamed(context, '/edit-item');
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _actionButton(
                        label: "View",
                        color: AppColors.primaryBlue,
                        icon: Icons.visibility_outlined,
                        isPrimary: true,
                        onPressed: () {
                          Navigator.pushNamed(context, '/item-details');
                        },
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

  Widget _buildImage(String imageUrl) {
    // Detect if image is a network URL or local asset
    if (imageUrl.startsWith('http') || imageUrl.startsWith('https')) {
      return Image.network(
        imageUrl,
        height: 80,
        width: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image, size: 60, color: Colors.grey),
      );
    } else {
      return Image.asset(
        imageUrl,
        height: 80,
        width: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image, size: 60, color: Colors.grey),
      );
    }
  }

  Widget _actionButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
    required IconData icon,
    bool isPrimary = false,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? color : Colors.white,
        foregroundColor: isPrimary ? Colors.white : color,
        padding: const EdgeInsets.symmetric(vertical: 8),
        elevation: isPrimary ? 2 : 0,
        side: isPrimary ? null : BorderSide(color: color.withOpacity(0.3)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
