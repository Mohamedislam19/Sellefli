import 'package:flutter/material.dart';
import 'package:sellefli/src/core/theme/app_theme.dart';
import 'package:sellefli/src/core/widgets/nav/bottom_nav.dart';
import 'package:sellefli/src/core/widgets/nav/bottom_nav.dart'; // ✅ Update to your real import path
// ignore: depend_on_referenced_packages
import 'package:sellefli/src/core/theme/app_theme.dart'; // ✅ Update if your theme is elsewhere

class ItemDetailsPage extends StatefulWidget {
  const ItemDetailsPage({super.key});

  @override
  State<ItemDetailsPage> createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  int _currentIndex = 0;

  // Simulated navigation handler
  void _onNavTap(int index) {
    setState(() => _currentIndex = index);

    // Example navigation logic (replace with your routes/pages)
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home');
        break;
      case 1:
        Navigator.pushNamed(context, '/requests');
        break;
      case 2:
        Navigator.pushNamed(context, '/my_listings');
        break;
      case 3:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> item = {
      'title': 'Professional Camera Kit',
      'description':
          'High-quality DSLR camera with a versatile zoom lens (24-70mm) and a sturdy tripod. Perfect for events, portraits, and landscape photography. Fully charged and ready for your next shoot.',
      'image':
          'https://cdn.pixabay.com/photo/2016/03/05/19/02/camera-1239384_1280.jpg',
      'value': '€1200',
      'deposit': '€300',
      'availableFrom': '2023-11-20',
      'availableUntil': '2023-11-27',
      'ownerName': 'Sarah Jansen',
      'ownerImage':
          'https://cdn.pixabay.com/photo/2017/09/12/13/18/woman-2745228_1280.jpg',
    };

    const double ownerRating = 4.8;
    const int ownerReviews = 75;

    return Scaffold(
      backgroundColor: AppColors.background, // uses your app theme
      appBar: AppBar(
        title: const Text(
          'Item Details',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Image section
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              item['image']!,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),

          // Details Card
          _buildDetailsCard(item),

          const SizedBox(height: 16),

          // Owner Info
          _buildOwnerInfo(item, ownerRating, ownerReviews),

          const SizedBox(height: 24),

          // Action Buttons
          _buildActionButtons(),

          const SizedBox(height: 20),
          const Text(
            'Please refer to the Deposit Policy for more information on item rentals and returns.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),

      // ✅ Include your animated bottom navigation bar
      bottomNavigationBar: AnimatedBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }

  // --- Helper widgets ---

  Widget _buildDetailsCard(Map<String, String> item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item['title']!,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item['description']!,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          _buildDetailRow('Item Value', item['value']!),
          _buildDetailRow('Deposit Required', item['deposit']!),
          _buildDetailRow('Available From', item['availableFrom']!),
          _buildDetailRow('Available Until', item['availableUntil']!),
        ],
      ),
    );
  }

  Widget _buildOwnerInfo(
      Map<String, String> item, double ownerRating, int ownerReviews) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(item['ownerImage']!),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['ownerName']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '$ownerRating ',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '($ownerReviews reviews)',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
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

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Book Now',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Contact Owner',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
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
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
