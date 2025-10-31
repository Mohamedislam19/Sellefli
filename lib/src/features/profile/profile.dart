import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final Map<String, String> userInfo = {
    "name": "Alex Johnson",
    "phone": "+1 (555) 123-4567",
    "avatar":
        "https://cdn-icons-png.flaticon.com/512/149/149071.png", // Default profile image
  };

  final List<Map<String, dynamic>> recentTransactions = [
    {
      "title": "Power Drill",
      "date": "2024-07-28",
      "status": "Returned",
      "image": "https://cdn-icons-png.flaticon.com/512/1048/1048943.png",
    },
    {
      "title": "Camping",
      "date": "2024-07-25",
      "status": "Borrowed",
      "image": "https://cdn-icons-png.flaticon.com/512/1048/1048867.png",
    },
    {
      "title": "Electric Guitar",
      "date": "2024-07-20",
      "status": "Lent",
      "image": "https://cdn-icons-png.flaticon.com/512/1048/1048899.png",
    },
    {
      "title": "Pressure",
      "date": "2024-07-15",
      "status": "Returned",
      "image": "https://cdn-icons-png.flaticon.com/512/1048/1048898.png",
    },
  ];

  Color _getStatusColor(String status) {
    switch (status) {
      case "Returned":
        return Colors.grey;
      case "Borrowed":
        return Colors.blue;
      case "Lent":
        return Colors.green;
      default:
        return Colors.black54;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile card
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 16,
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(userInfo["avatar"]!),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      userInfo["name"]!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userInfo["phone"]!,
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        5,
                        (index) => const Icon(
                          Icons.star_border,
                          color: Colors.amber,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Edit Profile / Settings
            _buildActionRow(
              icon: Icons.edit,
              text: "Edit Profile",
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Edit Profile tapped")),
                );
              },
            ),
            _buildActionRow(
              icon: Icons.settings,
              text: "Settings / Help",
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Settings tapped")),
                );
              },
            ),

            const SizedBox(height: 24),

            // Recent Transactions Section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Recent Transactions",
                style: Theme.of(
                  context,
                ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),

            Column(
              children: recentTransactions
                  .map(
                    (item) => _buildTransactionCard(
                      title: item["title"],
                      date: item["date"],
                      status: item["status"],
                      imageUrl: item["image"],
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionRow({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: Colors.black87),
            const SizedBox(width: 12),
            Text(text, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard({
    required String title,
    required String date,
    required String status,
    required String imageUrl,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0.5,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                width: 50,
                height: 50,
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
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 4),
                      Text(date, style: const TextStyle(color: Colors.black54)),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
          ],
        ),
      ),
    );
  }
}
