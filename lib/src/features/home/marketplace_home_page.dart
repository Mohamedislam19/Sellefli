import 'package:flutter/material.dart';
import 'package:sellefli/src/core/theme/app_theme.dart';
import 'package:sellefli/src/core/widgets/nav/bottom_nav.dart';

class MarketplaceHomePage extends StatefulWidget {
  const MarketplaceHomePage({super.key});

  @override
  State<MarketplaceHomePage> createState() => _MarketplaceHomePageState();
}

class _MarketplaceHomePageState extends State<MarketplaceHomePage> {
  double _radius = 5.0;
  bool _useLocation = false;
  int _currentNavIndex = 0; // Added for bottom nav
  final List<String> _categories = [
    'All',
    'Tools',
    'Electronics',
    'Books',
    'Sports Equipment',
    'Furniture',
    'Clothing',
  ];
  int _selectedCategory = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              floating: true,
              backgroundColor: AppColors.surface,
              elevation: 0,
              title: Text(
                'Explore',
                style: AppTextStyles.title.copyWith(
                  color: AppColors.primaryDark,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              centerTitle: true,
            ),

            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.border.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    style: AppTextStyles.body.copyWith(fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Search for items...',
                      hintStyle: TextStyle(
                        color: AppColors.muted.withOpacity(0.6),
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppColors.primary,
                        size: 22,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Category Chips
            SliverToBoxAdapter(
              child: SizedBox(
                height: 50,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final isSelected = _selectedCategory == index;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(_categories[index]),
                        labelStyle: AppTextStyles.body.copyWith(
                          color: isSelected ? Colors.white : AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        backgroundColor: AppColors.surface,
                        selectedColor: AppColors.primary,
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.primary.withOpacity(0.5),
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        onSelected: (selected) {
                          setState(() => _selectedCategory = index);
                        },
                      ),
                    );
                  },
                ),
              ),
            ),

            // Location & Search Controls
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Row(
                  children: [
                    // Use Location Toggle
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: _useLocation
                              ? AppColors.primary.withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.border.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 18,
                              color: _useLocation
                                  ? AppColors.primary
                                  : AppColors.muted,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Use my location',
                              style: AppTextStyles.body.copyWith(
                                fontSize: 14,
                                color: _useLocation
                                    ? AppColors.primary
                                    : AppColors.muted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            Switch(
                              value: _useLocation,
                              onChanged: (value) {
                                setState(() => _useLocation = value);
                              },
                              activeThumbColor: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Search Button
                    ElevatedButton(
                      onPressed: () {
                        // Handle search
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Searching within ${_radius.toStringAsFixed(0)} km...',
                            ),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Search',
                            style: AppTextStyles.body.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Radius Slider
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Radius:',
                          style: AppTextStyles.body.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        Text(
                          '${_radius.toStringAsFixed(0)} km',
                          style: AppTextStyles.body.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: AppColors.primary,
                        inactiveTrackColor: AppColors.primary.withOpacity(0.2),
                        thumbColor: AppColors.primary,
                        overlayColor: AppColors.primary.withOpacity(0.2),
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 10,
                        ),
                      ),
                      child: Slider(
                        value: _radius,
                        min: 1,
                        max: 50,
                        divisions: 49,
                        onChanged: (value) {
                          setState(() => _radius = value);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Product Grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  childAspectRatio: 1.25,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildListDelegate([
                  _buildProductCard(
                    title: 'Cordless Power Drill Set',
                    price: '500 DA',
                    location: 'Maple Street',
                    distance: '0.8 km',
                    seller: 'John Doe',
                    rating: 4.7,
                    imageUrl: 'assets/drill.jpg',
                  ),
                  _buildProductCard(
                    title: 'Electric Stand Mixer',
                    price: '520 DA',
                    location: 'Pine Lane',
                    distance: '0.5 km',
                    seller: 'Maria Garcia',
                    rating: 4.9,
                    imageUrl: 'assets/mixer.jpg',
                  ),
                  _buildProductCard(
                    title: 'Mountain Bicycle',
                    price: '890 DA',
                    location: 'River Road',
                    distance: '2.1 km',
                    seller: 'David Lee',
                    rating: 4.6,
                    imageUrl: 'assets/bike.jpg',
                  ),
                  _buildProductCard(
                    title: 'Camping Tent',
                    price: '450 DA',
                    location: 'Oak Avenue',
                    distance: '1.2 km',
                    seller: 'Sarah Johnson',
                    rating: 4.8,
                    imageUrl: 'assets/tent.jpg',
                  ),
                ]),
              ),
            ),

            // Bottom spacing
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),

      // Floating Action Button
      floatingActionButton: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.add_circle, color: Colors.white),
                      const SizedBox(width: 12),
                      const Text('Add new listing'),
                    ],
                  ),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.all(16),
                ),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: const Icon(Icons.add, color: Colors.white, size: 32),
          ),
        ),
      ),

      // New Animated Bottom Navigation Bar
      bottomNavigationBar: AnimatedBottomNav(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() => _currentNavIndex = index);
          // Handle navigation based on index
          // 0: Home, 1: Requests, 2: My Listings, 3: Profile
        },
      ),
    );
  }

  Widget _buildProductCard({
    required String title,
    required String price,
    required String location,
    required String distance,
    required String seller,
    required double rating,
    required String imageUrl,
  }) {
    return Card(
      elevation: 2,
      shadowColor: AppColors.primaryDark.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening $title...'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1504917595217-d4dc5ebe6122?w=400',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  // Price Badge
                  Positioned(
                    left: 12,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Text(
                        price,
                        style: AppTextStyles.body.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Product Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      title,
                      style: AppTextStyles.body.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: AppColors.muted,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location,
                            style: AppTextStyles.body.copyWith(
                              fontSize: 12,
                              color: AppColors.muted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Distance
                    Row(
                      children: [
                        Icon(Icons.near_me, size: 14, color: AppColors.muted),
                        const SizedBox(width: 4),
                        Text(
                          distance,
                          style: AppTextStyles.body.copyWith(
                            fontSize: 12,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),

                    // Seller & Rating
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: AppColors.primary.withOpacity(0.2),
                          child: Text(
                            seller[0],
                            style: AppTextStyles.body.copyWith(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            seller,
                            style: AppTextStyles.body.copyWith(
                              fontSize: 12,
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(Icons.star, size: 14, color: AppColors.accent),
                        const SizedBox(width: 2),
                        Text(
                          rating.toString(),
                          style: AppTextStyles.body.copyWith(
                            fontSize: 12,
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
