import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sellefli/src/core/theme/app_theme.dart';
import 'package:sellefli/src/core/widgets/nav/bottom_nav.dart';
import 'package:sellefli/src/core/widgets/home/home_categories.dart';
import 'package:sellefli/src/core/widgets/home/home_location_toggle.dart';
import 'package:sellefli/src/core/widgets/home/home_radius_slider.dart';
import 'package:sellefli/src/core/widgets/home/home_search_bar.dart';
import 'package:sellefli/src/core/widgets/home/product_card.dart';
import 'package:sellefli/src/data/repositories/auth_repository.dart';
import 'package:sellefli/src/data/repositories/item_repository.dart';
import 'logic/home_cubit.dart';
import 'logic/home_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(
        context.read<ItemRepository>(),
        context.read<AuthRepository>(),
      )..loadItems(),
      child: const _HomePageView(),
    );
  }
}

class _HomePageView extends StatefulWidget {
  const _HomePageView();

  @override
  State<_HomePageView> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<_HomePageView> {
  int _currentIndex = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    if (index == 0 && _currentIndex == 0) {
      // If already on home, scroll to top
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    }

    setState(() => _currentIndex = index);
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/request-order');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/listings');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/profile-page');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = (screenWidth / 350).clamp(0.7, 1.0);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 207, 225, 255),
        elevation: 1,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: EdgeInsets.symmetric(vertical: 12 * scale),
          child: Text(
            'Explore',
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
      backgroundColor: AppColors.surface,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Search Bar
              const SliverToBoxAdapter(child: HomeSearchBar()),

              // Category Chips
              const SliverToBoxAdapter(child: HomeCategories()),

              // Location & Search Controls
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Row(children: [const HomeLocationToggle()]),
                ),
              ),

              // Radius Slider
              SliverToBoxAdapter(
                child: BlocBuilder<HomeCubit, HomeState>(
                  buildWhen: (previous, current) =>
                      previous.isLocationEnabled != current.isLocationEnabled,
                  builder: (context, state) {
                    if (!state.isLocationEnabled)
                      return const SizedBox.shrink();
                    return HomeRadiusSlider(
                      initialRadius: state.radius,
                      onChanged: (value) {
                        context.read<HomeCubit>().updateRadius(value);
                      },
                    );
                  },
                ),
              ),

              // Product Grid
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: BlocBuilder<HomeCubit, HomeState>(
                  builder: (context, state) {
                    if (state.status == HomeStatus.loading &&
                        state.items.isEmpty) {
                      return const SliverToBoxAdapter(
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (state.status == HomeStatus.error) {
                      return SliverToBoxAdapter(
                        child: Center(
                          child: Text(state.errorMessage ?? 'Error'),
                        ),
                      );
                    }

                    if (state.items.isEmpty) {
                      return const SliverToBoxAdapter(
                        child: Center(child: Text('No items found')),
                      );
                    }

                    return SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1,
                            childAspectRatio: 1.25,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index >= state.items.length) {
                            if (state.isOfflineMode) {
                              return Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.wifi_off_rounded,
                                      color: AppColors.muted,
                                      size: 32,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "You are currently offline",
                                      style: AppTextStyles.body.copyWith(
                                        color: AppColors.primaryDark,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      "Connect to the internet to see more items",
                                      style: AppTextStyles.body.copyWith(
                                        color: AppColors.muted,
                                        fontSize: 12,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              );
                            }
                            // Trigger pagination
                            context.read<HomeCubit>().loadItems();
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final item = state.items[index];
                          // Calculate distance if location is enabled
                          String distance = '';
                          if (state.isLocationEnabled &&
                              item.distance != null) {
                            distance =
                                '${item.distance!.toStringAsFixed(2)} km';
                          }

                          return ProductCard(
                            title: item.title,
                            price: '${item.estimatedValue ?? 0} DA',
                            location:
                                'Location', // TODO: Reverse geocode or use item address
                            distance: distance,
                            seller: 'Seller', // TODO: Fetch seller name
                            rating: 0.0, // TODO: Fetch rating
                            imageUrl: item.images.isNotEmpty
                                ? item.images.first
                                : '',
                            onTap: () =>
                                Navigator.pushNamed(context, '/item-details'),
                          );
                        },
                        childCount: state.hasReachedMax
                            ? (state.isOfflineMode
                                  ? state.items.length + 1
                                  : state.items.length)
                            : state.items.length + 1,
                      ),
                    );
                  },
                ),
              ),

              // Bottom spacing
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),

      // Floating Action Button
      floatingActionButton: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(((0.4) * 255).toInt()),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/create-item');
            },
            borderRadius: BorderRadius.circular(20),
            child: const Icon(Icons.add, color: Colors.white, size: 32),
          ),
        ),
      ),

      // New Animated Bottom Navigation Bar
      bottomNavigationBar: AnimatedBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
