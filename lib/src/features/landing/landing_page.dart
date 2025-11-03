// lib/src/features/landing/landing_page.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/buttons/advanced_button.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),

                // Logo / Avatar
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Color(0xFFD6E4FF),
                  child: Icon(Icons.handshake, color: AppColors.primary, size: 45),
                ),
                const SizedBox(height: 20),

                Text(
                  "Borrow nearby · Share simply",
                  style: AppTextStyles.subtitle.copyWith(color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 35),

                // --- Feature Cards ---
                const FeatureCard(
                  icon: Icons.search,
                  title: "Browse Local Items",
                  description:
                      "Discover a wide array of tools, equipment, and unique items available for rent in your neighborhood.",
                ),
                const SizedBox(height: 16),

                const FeatureCard(
                  icon: Icons.share_outlined,
                  title: "Effortless Lending",
                  description:
                      "List your unused items in minutes and earn while contributing to a sustainable community economy.",
                ),
                const SizedBox(height: 16),

                const FeatureCard(
                  icon: Icons.people_outline,
                  title: "Connect with Neighbors",
                  description:
                      "Build trust and strengthen local ties through shared resources and friendly interactions.",
                ),
                const SizedBox(height: 40),

                // --- Buttons ---
                AdvancedButton(
                  label: "Get Started",
                  onPressed: () {
                    // TODO: Navigate to sign-up or onboarding page
                  },
                  fullWidth: true,
                ),
                const SizedBox(height: 12),

                // Secondary button with white background
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  child: AdvancedButton(
                    label: "Sign In",
                    onPressed: () {
                      // TODO: Navigate to login page
                    },
                    fullWidth: true,
                    gradient: const LinearGradient(
                      colors: [Colors.white, Colors.white],
                    ),
                    foregroundColor: Colors.black87,
                    elevation: 0,
                  ),
                ),
                const SizedBox(height: 25),

                Text(
                  "Terms & Conditions",
                  style: AppTextStyles.caption.copyWith(
                    decoration: TextDecoration.underline,
                  ),
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
    return Card(
      color: AppColors.surface,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: AppColors.border, width: 0.6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primary, size: 36),
            const SizedBox(height: 10),
            Text(
              title,
              style: AppTextStyles.subtitle.copyWith(color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              description,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
