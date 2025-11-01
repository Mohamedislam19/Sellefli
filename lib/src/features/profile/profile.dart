import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> transactions = [
      {
        'title': 'Power Drill',
        'image':
            'https://cdn.pixabay.com/photo/2017/09/04/18/15/drill-2718930_1280.jpg',
        'status': 'Returned',
        'date': '2024-07-28',
      },
      {
        'title': 'Camping',
        'image':
            'https://cdn.pixabay.com/photo/2016/11/29/02/22/camping-1869139_1280.jpg',
        'status': 'Borrowed',
        'date': '2024-07-25',
      },
      {
        'title': 'Electric Guitar',
        'image':
            'https://cdn.pixabay.com/photo/2016/11/23/14/45/guitar-1859462_1280.jpg',
        'status': 'Lent',
        'date': '2024-07-20',
      },
      {
        'title': 'Pressure',
        'image':
            'https://cdn.pixabay.com/photo/2015/03/26/09/39/wash-690274_1280.jpg',
        'status': 'Returned',
        'date': '2024-07-15',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Card
          Container(
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
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(
                    'https://cdn.pixabay.com/photo/2016/03/27/22/22/woman-1284411_1280.jpg',
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Alex Johnson',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '+1 (555) 123-4567',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (index) => const Icon(
                      Icons.star_border,
                      color: Colors.blueAccent,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Edit Profile
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.edit_outlined, color: Colors.black87),
            title: const Text('Edit Profile'),
            onTap: () {},
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.settings_outlined, color: Colors.black87),
            title: const Text('Settings / Help'),
            onTap: () {},
          ),
          const SizedBox(height: 16),

          const Text(
            'Recent Transactions',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),

          // Recent Transactions List
          Column(
            children: transactions
                .map((t) => TransactionCard(
                      title: t['title'],
                      imageUrl: t['image'],
                      status: t['status'],
                      date: t['date'],
                    ))
                .toList(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
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

class TransactionCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String status;
  final String date;

  const TransactionCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.status,
    required this.date,
  });

  Color getStatusColor(String status) {
    switch (status) {
      case 'Returned':
        return Colors.grey;
      case 'Borrowed':
        return const Color(0xFF2563EB);
      case 'Lent':
        return const Color(0xFF22C55E);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              width: 60,
              height: 60,
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
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: getStatusColor(status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: getStatusColor(status),
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
