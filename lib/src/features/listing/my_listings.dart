import 'package:flutter/material.dart';
import '../../core/widgets/nav/bottom_nav.dart';
import '../../core/theme/app_theme.dart';

class MyListingsPage extends StatefulWidget {
  const MyListingsPage({Key? key}) : super(key: key);

  @override
  State<MyListingsPage> createState() => _MyListingsPageState();
}

class _MyListingsPageState extends State<MyListingsPage> {
  int _currentIndex = 2;

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

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/requests');
        break;
      case 2:
        // Already on My Listings
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Listings"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: ListView.builder(
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
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
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
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Status badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: _getStatusColor(status),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Action buttons
                  Row(
                    children: [
                      _actionButton(
                        label: "Edit",
                        color: Colors.grey.shade700,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Edit $title"),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      _actionButton(
                        label: "View Bookings",
                        color: Colors.blue,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("View bookings for $title"),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    // Detect if image is a network URL or local asset
    if (imageUrl.startsWith('http') || imageUrl.startsWith('https')) {
      return Image.network(
        imageUrl,
        height: 60,
        width: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image, size: 60, color: Colors.grey),
      );
    } else {
      return Image.asset(
        imageUrl,
        height: 60,
        width: 60,
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
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        elevation: 0,
        textStyle: const TextStyle(fontSize: 13),
      ),
      child: Text(label),
    );
  }
}
