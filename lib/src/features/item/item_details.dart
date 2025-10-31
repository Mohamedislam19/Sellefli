import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ItemDetailsPage extends StatelessWidget {
  final int itemId;
  const ItemDetailsPage({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> dummyData = [
      {
        "id": 1,
        "title": "Professional Camera Kit",
        "description":
            "High-quality DSLR camera with a versatile zoom lens (24–70mm) and a sturdy tripod. Perfect for events, portraits, and landscape photography. Fully charged and ready for your next shoot.",
        "value": 1200,
        "deposit": 300,
        "availableFrom": "2023-11-20",
        "availableUntil": "2023-11-27",
        "images": [
          "https://images.unsplash.com/photo-1504203700686-0b3f64b17a5f",
          "https://images.unsplash.com/photo-1519183071298-a2962be90b8e",
        ],
        "owner": {
          "name": "Sarah Jansen",
          "profileImage": "https://randomuser.me/api/portraits/women/44.jpg",
          "rating": 4.8,
          "reviews": 75,
        },
      },
      {
        "id": 2,
        "title": "DJI Drone Combo Kit",
        "description":
            "Compact and powerful drone kit for stunning aerial shots. Includes two batteries and 4K camera.",
        "value": 1500,
        "deposit": 400,
        "availableFrom": "2023-12-01",
        "availableUntil": "2023-12-07",
        "images": [
          "https://images.unsplash.com/photo-1512820790803-83ca734da794",
          "https://images.unsplash.com/photo-1544197150-b99a580bb7a8",
        ],
        "owner": {
          "name": "David Lee",
          "profileImage": "https://randomuser.me/api/portraits/men/46.jpg",
          "rating": 4.9,
          "reviews": 58,
        },
      },
    ];

    final itemData = dummyData.firstWhere((element) => element["id"] == itemId);
    final dateFormatter = DateFormat('yyyy-MM-dd');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 200,
              child: PageView.builder(
                itemCount: itemData["images"].length,
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      itemData["images"][index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Text(
              itemData["title"],
              style: Theme.of(
                context,
              ).textTheme.headline6?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              itemData["description"],
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoRow(
                      "Item Value",
                      "€${itemData["value"].toString()}",
                    ),
                    _buildInfoRow(
                      "Deposit Required",
                      "€${itemData["deposit"].toString()}",
                    ),
                    _buildInfoRow(
                      "Available From",
                      itemData["availableFrom"].toString(),
                    ),
                    _buildInfoRow(
                      "Available Until",
                      itemData["availableUntil"].toString(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundImage: NetworkImage(
                  itemData["owner"]["profileImage"],
                ),
                radius: 24,
              ),
              title: Text(
                itemData["owner"]["name"],
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    "${itemData["owner"]["rating"]} (${itemData["owner"]["reviews"]} reviews)",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Book Now'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Contact Owner'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Please refer to the Deposit Policy for more information on item rentals and returns.",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
