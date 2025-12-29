// ignore_for_file: deprecated_member_use, use_super_parameters, prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:sellefli/l10n/app_localizations.dart';
import 'package:sellefli/src/core/widgets/animated_return_button.dart';
import '../../core/widgets/nav/bottom_nav.dart';
import '../../core/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'logic/my_listings_cubit.dart';
import 'logic/my_listings_state.dart';
import '../../data/repositories/item_repository.dart';
import '../../data/local/local_item_repository.dart';

class MyListingsPage extends StatelessWidget {
  const MyListingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MyListingsCubit(
        itemRepository: context.read<ItemRepository>(),
        localItemRepository: context.read<LocalItemRepository>(),
      )..loadMyListings(),
      child: _MyListingsView(),
    );
  }
}

class _MyListingsView extends StatefulWidget {
  _MyListingsView({Key? key}) : super(key: key);

  @override
  State<_MyListingsView> createState() => _MyListingsViewState();
}

class _MyListingsViewState extends State<_MyListingsView> {
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'rented':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'unavailable':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status, AppLocalizations l10n) {
    switch (status) {
      case 'active':
        return l10n.myListingsStatusActive;
      case 'rented':
        return l10n.myListingsStatusRented;
      case 'pending':
        return l10n.myListingsStatusPending;
      case 'unavailable':
      default:
        return l10n.myListingsStatusUnavailable;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    // Scale factor between 0.7 (at 245px) and 1 (at 350px or higher)
    final scale = (screenWidth / 350).clamp(0.7, 1.0);

    return BlocListener<MyListingsCubit, MyListingsState>(
      listener: (context, state) {
        if (state is MyListingsNavigateToEdit) {
          Navigator.pushNamed(context, '/edit-item', arguments: state.itemId);
        }
        if (state is MyListingsDeleteSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.myListingsDeleteSuccess),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
        if (state is MyListingsError && state.message.contains('Failed to delete')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 207, 225, 255),
          elevation: 1,
          centerTitle: true,
          leading: const AnimatedReturnButton(),
          title: Padding(
            padding: EdgeInsets.symmetric(vertical: 12 * scale),
            child: Text(
              l10n.myListingsTitle,
              style: GoogleFonts.outfit(
                fontSize: 22 * scale,
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh, color: AppColors.primaryBlue),
              onPressed: () => context.read<MyListingsCubit>().loadMyListings(),
            ),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
          child: BlocBuilder<MyListingsCubit, MyListingsState>(
            builder: (context, state) {
              if (state is MyListingsLoading) {
                return Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryBlue,
                  ),
                );
              }

              if (state is MyListingsError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () =>
                            context.read<MyListingsCubit>().loadMyListings(),
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                );
              }

              if (state is MyListingsLoaded) {
                if (state.items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.inventory_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.myListingsNoItems,
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (state.isOffline)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              l10n.myListingsOffline,
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    if (state.isOffline)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        color: Colors.orange.shade100,
                        child: Text(
                          l10n.myListingsOfflineBanner,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            color: Colors.orange.shade900,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.items.length,
                        itemBuilder: (context, index) {
                          final item = state.items[index];
                          return _buildListingCard(
                            context: context,
                            itemId: item.id,
                            title: item.title,
                            status: item.isAvailable ? 'active' : 'unavailable',
                            imageUrl: item.images.isNotEmpty
                                ? item.images.first
                                : '',
                            l10n: l10n,
                          );
                        },
                      ),
                    ),
                  ],
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
        bottomNavigationBar: AnimatedBottomNav(
          currentIndex: _currentIndex,
          onTap: _onNavTap,
        ),
      ),
    );
  }

  Widget _buildListingCard({
    required BuildContext context,
    required String itemId,
    required String title,
    required String status,
    required String imageUrl,
    required AppLocalizations l10n,
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
                    _statusLabel(status, l10n),
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
                        label: l10n.myListingsEdit,
                        color: Colors.grey.shade700,
                        icon: Icons.edit_outlined,
                        onPressed: () {
                          context.read<MyListingsCubit>().onEditItemTapped(
                            itemId,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _actionButton(
                        label: l10n.myListingsView,
                        color: AppColors.primaryBlue,
                        icon: Icons.visibility_outlined,
                        isPrimary: true,
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/item-details',
                            arguments: itemId,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _actionButton(
                        label: l10n.myListingsDelete,
                        color: Colors.red,
                        icon: Icons.delete_outlined,
                        onPressed: () {
                          _showDeleteConfirmationDialog(
                            context,
                            itemId,
                            title,
                            l10n,
                          );
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
    if (imageUrl.isEmpty) {
      return Container(
        height: 80,
        width: 80,
        color: Colors.grey[200],
        child: const Icon(
          Icons.image_not_supported,
          size: 40,
          color: Colors.grey,
        ),
      );
    }
    // Detect if image is a network URL, local file, or asset
    if (imageUrl.startsWith('http') || imageUrl.startsWith('https')) {
      return Image.network(
        imageUrl,
        height: 80,
        width: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image, size: 60, color: Colors.grey),
      );
    } else if (imageUrl.startsWith('/') ||
        imageUrl.contains('\\') ||
        imageUrl.startsWith('file://')) {
      return Image.file(
        File(imageUrl.replaceFirst('file://', '')),
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

  void _showDeleteConfirmationDialog(
    BuildContext context,
    String itemId,
    String itemTitle,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.myListingsDeleteConfirmTitle),
          content: Text(
            l10n.myListingsDeleteConfirmMessage(itemTitle),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.myListingsCancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<MyListingsCubit>().deleteItem(itemId);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: Text(l10n.myListingsDeleteConfirm),
            ),
          ],
        );
      },
    );
  }
}


