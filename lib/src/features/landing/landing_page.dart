// lib/src/features/landing/landing_page.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/buttons/advanced_button.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Avatar / Logo + Tagline
                Column(
                  children: [
                    const CircleAvatar(
                      radius: 35,
                      backgroundColor: Color(0xFFD6E4FF),
                      child: Icon(Icons.handshake, color: Colors.blue, size: 40),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Borrow nearby · Share simply",
                      style: AppTextStyles.subtitle,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

                // Feature Cards
                Column(
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
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ],
            ),
          ),
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
    return SizedBox(
      width: double.infinity,
      child: Card(
        color: AppColors.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,  // allow height to grow as needed
            children: [
              Icon(icon, color: AppColors.primary, size: 30),
              const SizedBox(height: 8),
              Text(
                title,
                style: AppTextStyles.subtitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                textAlign: TextAlign.center,
                style: AppTextStyles.body,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
