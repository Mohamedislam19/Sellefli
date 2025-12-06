// lib/src/features/landing/landing_page.dart
import 'package:flutter/material.dart';
import 'package:sellefli/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/buttons/advanced_button.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Responsive breakpoints
              final width = constraints.maxWidth;
              final isSmallMobile = width < 360;
              final isMobile = width < 600;
              final isTablet = width >= 600 && width < 900;
              final isDesktop = width >= 900;

              // Responsive padding
              double horizontalPadding = isMobile ? 20 : (isTablet ? 40 : 60);
              if (isSmallMobile) horizontalPadding = 16;

              // Responsive avatar size
              double avatarRadius = isSmallMobile
                  ? 30
                  : (isMobile ? 35 : (isTablet ? 45 : 55));

              // Maximum content width for large screens
              double maxContentWidth = isDesktop ? 1200 : double.infinity;

              return Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: isMobile ? 16 : 24,
                      ),
                      child: Column(
                        children: [
                          // Avatar / Logo + Tagline
                          Column(
                            children: [
                              CircleAvatar(
                                radius: avatarRadius,
                                backgroundColor: const Color(0xFFD6E4FF),
                                child: Icon(
                                  Icons.handshake,
                                  color: Colors.blue,
                                  size: avatarRadius * 1.2,
                                ),
                              ),
                              SizedBox(height: isMobile ? 4 : 8),
                              Text(
                                l10n.landingTagline,
                                style: AppTextStyles.subtitle.copyWith(
                                  fontSize: isSmallMobile
                                      ? 12
                                      : isMobile
                                      ? AppTextStyles.subtitle.fontSize
                                      : AppTextStyles.subtitle.fontSize! * 1.2,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),

                          SizedBox(height: isMobile ? 20 : 32),

                          // Feature Cards - Responsive Layout
                          _buildFeatureCards(
                            context: context,
                            isMobile: isMobile,
                            isTablet: isTablet,
                            isDesktop: isDesktop,
                          ),

                          SizedBox(height: isMobile ? 20 : 32),

                          // Buttons + Footer
                          Column(
                            children: [
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: isDesktop ? 500 : double.infinity,
                                ),
                                child: AdvancedButton(
                                  label: l10n.landingGetStarted,
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/auth',
                                      arguments: {'initialView': 1},
                                    );
                                  },
                                  fullWidth: true,
                                ),
                              ),
                              SizedBox(height: isMobile ? 8 : 12),
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: isDesktop ? 500 : double.infinity,
                                ),
                                child: AdvancedButton(
                                  label: l10n.landingSignIn,
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/auth');
                                  },
                                  fullWidth: true,
                                  gradient: const LinearGradient(
                                    colors: [Colors.white, Colors.white],
                                  ),
                                  foregroundColor: Colors.black87,
                                  borderRadius: 12,
                                  elevation: 0,
                                ),
                              ),
                              SizedBox(height: isMobile ? 8 : 12),
                              Text(
                                l10n.landingTerms,
                                style: AppTextStyles.caption.copyWith(
                                  fontSize: isDesktop
                                      ? AppTextStyles.caption.fontSize! * 1.1
                                      : AppTextStyles.caption.fontSize,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCards({
    required BuildContext context,
    required bool isMobile,
    required bool isTablet,
    required bool isDesktop,
  }) {
    final l10n = AppLocalizations.of(context);

    final features = [
      FeatureCard(
        icon: Icons.search,
        title: l10n.landingFeatureBrowseTitle,
        description: l10n.landingFeatureBrowseDescription,
      ),
      FeatureCard(
        icon: Icons.share_outlined,
        title: l10n.landingFeatureLendTitle,
        description: l10n.landingFeatureLendDescription,
      ),
      FeatureCard(
        icon: Icons.people_outline,
        title: l10n.landingFeatureConnectTitle,
        description: l10n.landingFeatureConnectDescription,
      ),
    ];

    if (isMobile) {
      // Mobile: Stack vertically
      return Column(
        children: [
          features[0],
          const SizedBox(height: 10),
          features[1],
          const SizedBox(height: 10),
          features[2],
        ],
      );
    } else if (isTablet) {
      // Tablet: 2 columns with third card spanning below
      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: features[0]),
              const SizedBox(width: 12),
              Expanded(child: features[1]),
            ],
          ),
          const SizedBox(height: 12),
          features[2],
        ],
      );
    } else {
      // Desktop: 3 columns
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: features[0]),
          const SizedBox(width: 16),
          Expanded(child: features[1]),
          const SizedBox(width: 16),
          Expanded(child: features[2]),
        ],
      );
    }
  }
}

// ---------------- Feature Card ----------------
class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isSmall = width < 360;
        final isMobile = width < 600;
        final isTablet = width >= 600 && width < 900;
        final isDesktop = width >= 900;

        // Responsive sizing
        double padding = isSmall ? 12 : (isMobile ? 14 : (isTablet ? 18 : 20));
        double iconSize = isSmall ? 28 : (isMobile ? 30 : (isTablet ? 36 : 40));
        double titleFontSize = isSmall
            ? 14
            : (isMobile ? 16 : (isTablet ? 18 : 20));
        double bodyFontSize = isSmall ? 12 : (isMobile ? 14 : 15);
        int maxLines = isDesktop ? 6 : 4;

        return SizedBox(
          width: double.infinity,
          child: Card(
            color: AppColors.surface,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isDesktop ? 16 : 15),
            ),
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: AppColors.primary, size: iconSize),
                  SizedBox(height: isMobile ? 8 : 12),
                  Text(
                    title,
                    style: AppTextStyles.subtitle.copyWith(
                      fontSize: titleFontSize,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isMobile ? 4 : 6),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body.copyWith(fontSize: bodyFontSize),
                    maxLines: maxLines,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}


