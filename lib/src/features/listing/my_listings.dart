import 'package:flutter/material.dart';

class MyListingsPage extends StatefulWidget {
  const MyListingsPage({Key? key}) : super(key: key);

  @override
  State<MyListingsPage> createState() => _MyListingsPageState();
}

class _MyListingsPageState extends State<MyListingsPage> {
  final List<Map<String, dynamic>> listings = [
    {
      "title": "Cordless Power Drill Set",
      "status": "Active",
      "image": "https://cdn-icons-png.flaticon.com/512/1048/1048943.png",
    },
    {
      "title": "4-Person Camping Tent",
      "status": "Rented",
      "image": "https://cdn-icons-png.flaticon.com/512/1048/1048867.png",
    },
    {
      "title": "Stand Mixer - KitchenAid",
      "status": "Pending Approval",
      "image": "https://cdn-icons-png.flaticon.com/512/1048/1048903.png",
    },
    {
      "title": "Mountain Bike - Size L",
      "status": "Active",
      "image": "https://cdn-icons-png.flaticon.com/512/1048/1048890.png",
    },
    {
      "title": "Digital Camera - Canon EOS",
      "status": "Unavailable",
      "image": "https://cdn-icons-png.flaticon.com/512/1048/1048888.png",
    },
    {
      "title": "Robotic Vacuum Cleaner",
      "status": "Active",
      "image": "https://cdn-icons-png.flaticon.com/512/1048/1048859.png",
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
              child: Image.network(
                imageUrl,
                height: 60,
                width: 60,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),

            // Info + Buttons
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
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
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Edit $title"),
                              duration: const Duration(seconds: 1)));
                        },
                      ),
                      const SizedBox(width: 8),
                      _actionButton(
                        label: "View Bookings",
                        color: Colors.blue,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("View bookings for $title"),
                              duration: const Duration(seconds: 1)));
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
