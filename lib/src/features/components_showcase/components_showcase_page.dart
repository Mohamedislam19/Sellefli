// lib/src/features/components_showcase/components_showcase_page.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/buttons/advanced_button.dart';
import '../../core/widgets/inputs/custom_text_field.dart';
import '../../core/widgets/chips/chip_badge.dart';
import '../../core/widgets/stars/rating_stars.dart';
import '../../core/widgets/avatar/avatar.dart';
import '../../core/widgets/nav/bottom_nav.dart';
import '../../core/widgets/shimmer/shimmer_placeholder.dart';
import '../../core/widgets/flags/svg_flag.dart';

class ComponentsShowcasePage extends StatefulWidget {
  const ComponentsShowcasePage({Key? key}) : super(key: key);

  @override
  State<ComponentsShowcasePage> createState() => _ComponentsShowcasePageState();
}

class _ComponentsShowcasePageState extends State<ComponentsShowcasePage> {
  int _navIndex = 2;
  bool _loadingButton = false;
  final TextEditingController _textController = TextEditingController();

  void _simulateLoading() async {
    setState(() => _loadingButton = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _loadingButton = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sellefli UI Showcase'),
        backgroundColor: AppColors.surface,
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Animated Buttons',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AdvancedButton(
                    label: 'Buy now',
                    onPressed: () {
                      _simulateLoading();
                    },
                    loading: _loadingButton,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AdvancedButton(
                    label: 'Sell',
                    onPressed: () {},
                    gradient: const LinearGradient(
                      colors: [Color(0xFF67D6B7), Color(0xFF2FBF9F)],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            Text('Inputs', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            CustomTextField(
              hint: 'Search for crafts',
              controller: _textController,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              hint: 'Message seller',
              prefix: const Icon(Icons.message_outlined),
            ),

            const SizedBox(height: 18),
            Text(
              'Chips & Flags',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: const [
                ChipBadge(label: 'Category', type: ChipType.primary),
                ChipBadge(label: 'New', type: ChipType.ghost),
                ChipBadge(label: 'Draft', type: ChipType.muted),
                ChipBadge(label: 'Error', type: ChipType.danger),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                SvgFlag(countryCode: 'us', size: 28),
                SizedBox(width: 8),
                SvgFlag(countryCode: 'dz', size: 28),
                SizedBox(width: 8),
                SvgFlag(
                  countryCode: '',
                  size: 28,
                  labelFallback: 'EU',
                ), // fallback demo
              ],
            ),

            const SizedBox(height: 18),
            Text(
              'Shimmer skeleton',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                ShimmerBox(
                  height: 64,
                  width: 64,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(
                        height: 16,
                        width: double.infinity,
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                      ),
                      SizedBox(height: 8),
                      ShimmerBox(
                        height: 12,
                        width: 120,
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),
            Text(
              'Avatar & Ratings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                Avatar(
                  imageUrl: 'https://i.pravatar.cc/150?img=12',
                  size: 56,
                  showOnline: true,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('John Doe', style: AppTextStyles.subtitle),
                      SizedBox(height: 6),
                      RatingStars(rating: 4.2),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: AnimatedBottomNav(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
      ),
    );
  }
}
