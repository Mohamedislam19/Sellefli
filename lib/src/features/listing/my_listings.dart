import 'package:flutter/material.dart';

class MyListingsPage extends StatelessWidget {
  const MyListingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> listings = [
      {
        'title': 'Cordless Power Drill Set',
        'image':
            'https://cdn.pixabay.com/photo/2017/09/04/18/15/drill-2718930_1280.jpg',
        'status': 'Active',
      },
      {
        'title': '4-Person Camping Tent',
        'image':
            'https://cdn.pixabay.com/photo/2016/11/29/02/22/camping-1869139_1280.jpg',
        'status': 'Rented',
      },
      {
        'title': 'Stand Mixer - KitchenAid',
        'image':
            'https://cdn.pixabay.com/photo/2017/09/04/18/20/mixer-2718957_1280.jpg',
        'status': 'Pending Approval',
      },
      {
        'title': 'Mountain Bike - Size L',
        'image':
            'https://cdn.pixabay.com/photo/2014/12/03/12/20/bicycle-555645_1280.jpg',
        'status': 'Active',
      },
      {
        'title': 'Digital Camera - Canon EOS',
        'image':
            'https://cdn.pixabay.com/photo/2016/03/27/19/52/camera-1283860_1280.jpg',
        'status': 'Unavailable',
      },
      {
        'title': 'Robotic Vacuum Cleaner',
        'image':
            'https://cdn.pixabay.com/photo/2020/07/01/12/58/robot-vacuum-5359689_1280.jpg',
        'status': 'Active',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Listings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: listings.length,
        itemBuilder: (context, index) {
          final item = listings[index];
          return ListingCard(
            title: item['title'],
            imageUrl: item['image'],
            status: item['status'],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: const Color(0xFF2563EB),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.request_page_outlined),
            label: 'Requests & Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            label: 'My Listings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class ListingCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String status;

  const ListingCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.status,
  });

  Color getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return const Color(0xFF22C55E);
      case 'Rented':
        return const Color(0xFF0EA5E9);
      case 'Pending Approval':
        return const Color(0xFF06B6D4);
      case 'Unavailable':
        return const Color(0xFF9CA3AF);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: getStatusColor(status),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Edit',
                          style: TextStyle(color: Colors.black87),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('View Bookings'),
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
}
