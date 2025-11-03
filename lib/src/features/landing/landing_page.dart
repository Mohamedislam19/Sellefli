// lib/src/features/landing/landing_page.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/buttons/advanced_button.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;
    const double tabletBreakpoint = 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= tabletBreakpoint;
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: 10,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Avatar / Logo + Tagline
                    Column(
                      children: [
                        CircleAvatar(
                          radius: isWide ? 50 : 35,
                          backgroundColor: const Color(0xFFD6E4FF),
                          child: Icon(
                            Icons.handshake,
                            color: Colors.blue,
                            size: isWide ? 60 : 40,
                          ),
                        ),
                        const SizedBox(height: 4),  // reduced from 8 to 4
                        Text(
                          "Borrow nearby · Share simply",
                          style: AppTextStyles.subtitle.copyWith(
                            fontSize: isWide
                                ? AppTextStyles.subtitle.fontSize! * 1.2
                                : AppTextStyles.subtitle.fontSize,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),

                    // Feature Cards
                    isWide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Expanded(
                                child: FeatureCard(
                                  icon: Icons.search,
                                  title: "Browse Local Items",
                                  description:
                                      "Discover a wide array of tools, equipment, and unique items available for rent in your neighborhood.",
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: FeatureCard(
                                  icon: Icons.share_outlined,
                                  title: "Effortless Lending",
                                  description:
                                      "List your unused items in minutes and earn while contributing to a sustainable community economy.",
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: FeatureCard(
                                  icon: Icons.people_outline,
                                  title: "Connect with Neighbors",
                                  description:
                                      "Build trust and strengthen local ties through shared resources and friendly interactions.",
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: const [
                              FeatureCard(
                                icon: Icons.search,
                                title: "Browse Local Items",
                                description:
                                    "Discover a wide array of tools, equipment, and unique items available for rent in your neighborhood.",
                              ),
                              SizedBox(height: 10),
                              FeatureCard(
                                icon: Icons.share_outlined,
                                title: "Effortless Lending",
                                description:
                                    "List your unused items in minutes and earn while contributing to a sustainable community economy.",
                              ),
                              SizedBox(height: 10),
                              FeatureCard(
                                icon: Icons.people_outline,
                                title: "Connect with Neighbors",
                                description:
                                    "Build trust and strengthen local ties through shared resources and friendly interactions.",
                              ),
                            ],
                          ),

                    // Buttons + Footer
                    Column(
                      children: [
                        AdvancedButton(
                          label: "Get Started",
                          onPressed: () {},
                          fullWidth: true,
                        ),
                        const SizedBox(height: 8),
                        AdvancedButton(
                          label: "Sign In",
                          onPressed: () {},
                          fullWidth: true,
                          gradient: const LinearGradient(
                            colors: [Colors.white, Colors.white],
                          ),
                          foregroundColor: Colors.black87,
                          borderRadius: 12,
                          elevation: 0,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Terms & Conditions",
                          style: AppTextStyles.caption.copyWith(
                            fontSize: isWide
                                ? AppTextStyles.caption.fontSize! * 1.1
                                : AppTextStyles.caption.fontSize,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
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
    final screenWidth = MediaQuery.of(context).size.width;
    const double tabletBreakpoint = 600;
    final isWide = screenWidth >= tabletBreakpoint;

    return SizedBox(
      width: double.infinity,
      child: Card(
        color: AppColors.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: EdgeInsets.all(isWide ? 20 : 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.primary, size: isWide ? 40 : 30),
              SizedBox(height: isWide ? 12 : 8),
              Text(
                title,
                style: AppTextStyles.subtitle.copyWith(
                  fontSize: isWide
                      ? AppTextStyles.subtitle.fontSize! * 1.2
                      : null,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isWide ? 6 : 4),
              Text(
                description,
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(
                  fontSize: isWide
                      ? AppTextStyles.body.fontSize! * 1.1
                      : null,
                ),
                maxLines: isWide ? 6 : 4,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
