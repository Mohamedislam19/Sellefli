// ignore_for_file: prefer_const_constructors_in_immutables, use_super_parameters, use_build_context_synchronously, deprecated_member_use, unused_element_parameter, unused_local_variable

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sellefli/src/core/theme/app_theme.dart';
import 'package:sellefli/src/core/widgets/animated_return_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sellefli/src/features/auth/logic/auth_cubit.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sellefli/src/data/models/item_model.dart';
import 'package:sellefli/src/data/models/booking_model.dart';
import '../../core/widgets/avatar/avatar.dart';
import '../../core/widgets/nav/bottom_nav.dart';
import 'logic/profile_cubit.dart';
import 'logic/profile_state.dart';
import 'package:sellefli/l10n/app_localizations.dart';
import '../../core/l10n/language_cubit.dart';

class ProfilePage extends StatelessWidget {
  final String? userId;

  const ProfilePage({super.key, this.userId});

  @override
  Widget build(BuildContext context) {
    // Get userId from arguments if not provided
    final String? id =
        userId ?? (ModalRoute.of(context)?.settings.arguments as String?);

    return _ProfileView(userId: id);
  }
}

class _ProfileView extends StatefulWidget {
  final String? userId;

  _ProfileView({Key? key, this.userId}) : super(key: key);

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  int _currentIndex = 3;

  @override
  void initState() {
    super.initState();
    // If viewing another user's profile, refresh with their ID
    if (widget.userId != null) {
      Future.microtask(() {
        context.read<ProfileCubit>().refreshById(widget.userId!);
      });
    } else {
      Future.microtask(() {
        context.read<ProfileCubit>().loadMyProfile();
      });
    }
  }

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
        Navigator.pushReplacementNamed(context, '/listings');
        break;
      case 3:
        // Already on Profile
        break;
    }
  }

  void _showLanguageDialog(AppLocalizations l10n) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            l10n.languageDialogTitle,
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBlue,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              _LanguageOptionTile(
                labelKey: 'languageEnglish',
                locale: Locale('en'),
                flagPath: 'assets/images/us_flag.png',
              ),
              SizedBox(height: 8),
              _LanguageOptionTile(
                labelKey: 'languageArabic',
                locale: Locale('ar'),
                flagPath: 'assets/images/algeria_flag.png',
              ),
              SizedBox(height: 8),
              _LanguageOptionTile(
                labelKey: 'languageFrench',
                locale: Locale('fr'),
                flagPath: 'assets/images/france_flag.png',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final l10n = AppLocalizations.of(context);
    // Scale factor between 0.7 (at 245px) and 1 (at 350px or higher)
    final scale = (screenWidth / 350).clamp(0.7, 1.0);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 207, 225, 255),
        elevation: 1,
        centerTitle: true,
        leading: const AnimatedReturnButton(),
        title: Padding(
          padding: EdgeInsets.symmetric(vertical: 12 * scale),
          child: Text(
            l10n.profileTitle,
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
            onPressed: () {
              if (widget.userId != null) {
                context.read<ProfileCubit>().refreshById(widget.userId!);
              } else {
                context.read<ProfileCubit>().loadMyProfile();
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return Center(
                child: CircularProgressIndicator(color: AppColors.primaryBlue),
              );
            }

            if (state is ProfileError) {
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
                      onPressed: () {
                        if (widget.userId != null) {
                          context.read<ProfileCubit>().refreshById(
                            widget.userId!,
                          );
                        } else {
                          context.read<ProfileCubit>().loadMyProfile();
                        }
                      },
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              );
            }

            if (state is ProfileLoaded) {
              final user = state.profile;
              final isRtl = Directionality.of(context) == TextDirection.rtl;

              return ListView(
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
                          color: Colors.black12.withAlpha(
                            ((0.05) * 255).toInt(),
                          ),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Avatar(
                          imageUrl: user.avatarUrl,
                          initials: user.username?.isNotEmpty == true
                              ? user.username![0].toUpperCase()
                              : '?',
                          size: 80,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          user.username ?? l10n.userFallback,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (user.phone != null)
                          Text(
                            user.phone!,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        if (user.email != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              user.email!,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ...List.generate(5, (index) {
                              final rating = user.ratingCount > 0
                                  ? user.ratingSum / user.ratingCount
                                  : 0.0;
                              return Icon(
                                index < rating.round()
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 20,
                              );
                            }),
                            const SizedBox(width: 8),
                            Text(
                              user.ratingCount > 0
                                  ? '${(user.ratingSum / user.ratingCount).toStringAsFixed(1)} (${user.ratingCount})'
                                  : l10n.noRatingsYet,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        if (widget.userId == null) ...[
                          const SizedBox(height: 12),
                          
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Show edit/settings only for own profile
                  if (widget.userId == null) ...[
                    // Edit Profile
                    _buildActionCard(
                      icon: Icons.edit_rounded,
                      iconColor: AppColors.primary,
                      title: l10n.editProfile,
                      onTap: () async {
                        await Navigator.pushNamed(context, '/edit-profile');
                        if (context.mounted) {
                          context.read<ProfileCubit>().loadMyProfile();
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    // Language selection
                    _buildActionCard(
                      icon: Icons.language_rounded,
                      iconColor: const Color(0xFF4CAF50),
                      title: l10n.language,
                      onTap: () => _showLanguageDialog(l10n),
                    ),
                    const SizedBox(height: 12),
                    // Settings
                    _buildActionCard(
                      icon: Icons.settings_rounded,
                      iconColor: const Color(0xFFFF9800),
                      title: l10n.settingsHelp,
                      onTap: () {
                        Navigator.pushNamed(context, '/settings');
                      },
                    ),
                    const SizedBox(height: 12),
                    // Logout
                    _buildActionCard(
                      icon: Icons.logout_rounded,
                      iconColor: const Color(0xFFF44336),
                      title: l10n.logout,
                      onTap: () {
                        context.read<AuthCubit>().logout();
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/auth',
                          (route) => false,
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    Text(
                      l10n.recentTransactions,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (state.transactions.isEmpty)
                      Padding(
                        padding: EdgeInsets.only(bottom: 20),
                        child: Text(
                          l10n.noRecentTransactions,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      )
                    else
                      ...state.transactions.map((t) {
                        final item = t['item'] as Item?;
                        final booking = t['booking'] as Booking;
                        final isBorrower = t['isBorrower'] as bool;
                        final imageUrl = t['imageUrl'] as String?;

                        return TransactionCard(
                          title: item?.title ?? l10n.unknownItem,
                          imageUrl: imageUrl,
                          status: isBorrower
                              ? l10n.borrowedStatus
                              : l10n.lentStatus,
                          date:
                              '${booking.createdAt.day}/${booking.createdAt.month}/${booking.createdAt.year}',
                          price: booking.totalCost ?? 0.0,
                        );
                      }),
                  ],
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
    );
  }
}

class TransactionCard extends StatelessWidget {
  final String title;
  final String? imageUrl;
  final String status;
  final String date;
  final double price;

  const TransactionCard({
    super.key,
    required this.title,
    this.imageUrl,
    required this.status,
    required this.date,
    required this.price,
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
            color: Colors.black12.withAlpha(((0.05) * 255).toInt()),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageUrl != null && imageUrl!.isNotEmpty
                ? Image.network(
                    imageUrl!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  )
                : Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image, color: Colors.grey),
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: getStatusColor(status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: getStatusColor(status),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'DA ${price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
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

class _LanguageOptionTile extends StatelessWidget {
  final String labelKey;
  final Locale locale;
  final String flagPath;

  const _LanguageOptionTile({
    super.key,
    required this.labelKey,
    required this.locale,
    required this.flagPath,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final languageCubit = context.read<LanguageCubit>();

    String label;
    switch (labelKey) {
      case 'languageArabic':
        label = l10n.languageArabic;
        break;
      case 'languageFrench':
        label = l10n.languageFrench;
        break;
      case 'languageEnglish':
      default:
        label = l10n.languageEnglish;
        break;
    }

    return InkWell(
      onTap: () {
        languageCubit.changeLocale(locale);
        Navigator.of(context).pop();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.asset(
                flagPath,
                width: 32,
                height: 24,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 32,
                    height: 24,
                    color: Colors.grey[300],
                    child: Icon(Icons.flag, size: 16, color: Colors.grey[600]),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
