// lib/src/features/settings/settings_help_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/expansion/animated_expansion_card.dart';
import '../../core/widgets/animated_return_button.dart';

class SettingsHelpPage extends StatelessWidget {
  SettingsHelpPage({Key? key}) : super(key: key);

  final List<Map<String, String>> faqData = [
    {
      'question': 'Is Sellefli free to use?',
      'answer':
          'Yes, creating an account and browsing listings are completely free. Later versions may introduce optional premium features for frequent users.',
    },
    {
      'question': 'What kind of items can be listed?',
      'answer':
          'Everyday personal items such as tools, books, games, sports gear, electronics, small furniture, and other safe, non-prohibited objects.',
    },
    {
      'question': 'How do I know if a user is trustworthy?',
      'answer':
          'Each user profile includes ratings from past exchanges. We also encourage communication before confirming a request.',
    },
    {
      'question': 'What happens if an item is damaged or lost?',
      'answer':
          'Sellefli promotes trust-based exchanges. For now, users should discuss conditions before borrowing. Future updates will include optional protection plans and verified user systems.',
    },
    {
      'question': 'Can I cancel a request after sending it?',
      'answer':
          'Yes, requests can be canceled as long as they haven’t been accepted by the owner. Once accepted, both users should communicate directly to agree on changes.',
    },
    {
      'question': 'Is payment handled inside the app?',
      'answer':
          'During the first versions, payments and returns are handled manually between users. A secure in-app payment system will be added in future updates.',
    },
    {
      'question': 'How do I contact the Sellefli team?',
      'answer':
          'You can reach us directly from the “Contact Support” section below.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Scale factor between 0.7 (at 245px) and 1 (at 350px or higher)
    final scale = (screenWidth / 350).clamp(0.7, 1.0);

    return 
    Scaffold(
      // backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 207, 225, 255),
        elevation: 1,
        centerTitle: true,
        leading: const AnimatedReturnButton(),
        title: Padding(
          padding: EdgeInsets.symmetric(vertical: 12 * scale),
          child: Text(
            'Settings & Help',
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
      body: 
      Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient
        ),
        child: ListView(
          padding: EdgeInsets.only(
            bottom: 9 * scale,
            top: 9 * scale,
            left: 18 * scale,
            right: 18 * scale,
          ),
          children: [
            sectionTitle('About Us', scale),
            AnimatedExpansionCard(
              icon: Icons.info_outline_rounded,
              title: 'About Sellefli',
              scale: scale,
              descriptionWidget: buildStyledDescription([
                normalText(
                  "Sellefli is a community-based mobile platform that helps neighbors and campus users rent or borrow everyday items from people nearby.",
                  scale,
                ),
                TextSpan(text: '\n\n'), // spacing
                normalText("Instead of buying new things, you can ", scale),
                boldText("share", scale),
                normalText(" what you already own and ", scale),
                boldText("earn money", scale),
                normalText(
                  " while helping others. Sellefli makes local exchanges ",
                  scale,
                ),
                boldText("simple, safe, and trustworthy.", scale),
              ]),
            ),
            AnimatedExpansionCard(
              icon: Icons.location_city_outlined,
              title: 'Our Mission',
              scale: scale,
              descriptionWidget: buildStyledDescription([
                normalText("Our mission is to ", scale),
                boldText("make sharing a normal part of everyday life.", scale),
                TextSpan(text: '\n\n'),
                normalText("Sellefli empowers people to save ", scale),
                boldText(
                  "money, reduce waste, and strengthen community connections",
                  scale,
                ),
                normalText(" through a trusted local rental network.", scale),
              ]),
            ),
            AnimatedExpansionCard(
              icon: Icons.help_outline_rounded,
              title: 'How It Works',
              scale: scale,
              descriptionWidget: buildStyledDescription([
                subtitleText("Browse:", scale),
                normalText(
                  " Discover items available for rent near you—from tools and electronics to books and household items.",
                  scale,
                ),
                TextSpan(text: '\n\n'),
                subtitleText("Request:", scale),
                normalText(
                  " Choose what you need and send a booking request with your preferred dates.",
                  scale,
                ),
                TextSpan(text: '\n\n'),
                subtitleText("Confirm:", scale),
                normalText(
                  " The owner reviews your request and approves it.",
                  scale,
                ),
                TextSpan(text: '\n\n'),
                subtitleText("Meet & Exchange:", scale),
                normalText(
                  " Arrange a safe meeting point to borrow or rent the item.",
                  scale,
                ),
                TextSpan(text: '\n\n'),
                subtitleText("Return:", scale),
                normalText(
                  " Bring the item back on time and rate your experience to build trust in the community.",
                  scale,
                ),
              ]),
            ),
            sectionTitle('Support', scale),
            AnimatedExpansionCard(
              icon: Icons.question_answer_outlined,
              title: 'FAQ',
              scale: scale,
              descriptionWidget: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: faqData
                    .map(
                      (faq) => SubExpansionCard(
                        title: faq['question']!,
                        description: faq['answer']!,
                        scale: scale,
                      ),
                    )
                    .toList(),
              ),
            ),
            AnimatedExpansionCard(
              icon: Icons.support_agent_rounded,
              title: 'Contact & Support',
              scale: scale,
              descriptionWidget: buildStyledDescription([
                normalText("📧 Email: support@sellefli.com\n\n", scale),
                normalText("🌐 Website: www.sellefli.dz\n", scale),
                TextSpan(text: '\n'),
                normalText(
                  "If you encounter any issue or wish to share feedback, please reach out via email or social media. We respond within 24–48 hours.",
                  scale,
                ),
              ]),
            ),
            sectionTitle('Legal & Community', scale),
            AnimatedExpansionCard(
              icon: Icons.groups_2_outlined,
              title: 'Community Guidelines',
              scale: scale,
              descriptionWidget: buildStyledDescription([
                normalText(
                  "Sellefli is built on trust and respect. Every user contributes to a safe and friendly environment.",
                  scale,
                ),
                TextSpan(text: '\n\n'),
                bulletPoint("Be respectful and reliable.", scale),
                bulletPoint("Communicate clearly.", scale),
                bulletPoint("Avoid last-minute cancellations.", scale),
                bulletPoint(
                  "Keep your items clean and in good condition.",
                  scale,
                ),
              ]),
            ),
            AnimatedExpansionCard(
              icon: Icons.library_books_outlined,
              title: 'Terms and Conditions',
              scale: scale,
              descriptionWidget: buildStyledDescription([
                normalText("By using Sellefli, you agree to:\n", scale),
                bulletPoint(
                  "Share only items that you own or have the right to lend.",
                  scale,
                ),
                bulletPoint(
                  "Treat borrowed items with care and return them on time.",
                  scale,
                ),
                bulletPoint(
                  "Communicate honestly and respectfully with other users.",
                  scale,
                ),
                bulletPoint("Avoid prohibited, unsafe, or illegal items.", scale),
                bulletPoint(
                  "Report any suspicious or inappropriate behavior to the support team.",
                  scale,
                ),
                TextSpan(text: '\n'),
                normalText(
                  "Sellefli is not responsible for lost or damaged items but provides guidance and tools to help users resolve issues responsibly. Full Terms and Conditions will be available at launch on the official website.",
                  scale,
                ),
              ]),
            ),
            AnimatedExpansionCard(
              icon: Icons.privacy_tip_rounded,
              title: 'Privacy Policy',
              scale: scale,
              descriptionWidget: buildStyledDescription([
                normalText(
                  "Sellefli respects your privacy as described in our full policy, available on the official website.",
                  scale,
                ),
              ]),
            ),
            SizedBox(height: 32 * scale),
            Center(
              child: Text(
                'App Version 1.0.0 (Beta)\n© 2025 Sellefli. All rights reserved.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 13 * scale,
                  color: Colors.grey[500],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget sectionTitle(String text, double scale) => Padding(
    padding: EdgeInsets.only(
      top: 5 * scale,
      bottom: 5 * scale,
      left: 2 * scale,
    ),
    child: Text(
      text,
      style: GoogleFonts.outfit(
        color: AppColors.primaryBlue,
        fontWeight: FontWeight.w700,
        fontSize: 17 * scale,
        letterSpacing: 0.3,
      ),
    ),
  );

  Widget buildStyledDescription(List<InlineSpan> children) {
    return RichText(text: TextSpan(children: children));
  }

  InlineSpan normalText(String text, double scale) {
    return TextSpan(
      text: text,
      style: GoogleFonts.outfit(
        fontSize: 15.5 * scale,
        color: Colors.blueGrey[900],
        height: 1.5,
        letterSpacing: 0.04,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  InlineSpan boldText(String text, double scale) {
    return TextSpan(
      text: text,
      style: GoogleFonts.outfit(
        fontSize: 15.5 * scale,
        color: const Color.fromARGB(255, 0, 0, 0),
        fontWeight: FontWeight.w700,
        height: 1.5,
        letterSpacing: 0.04,
      ),
    );
  }

  InlineSpan subtitleText(String text, double scale) {
    return TextSpan(
      text: text + " ",
      style: GoogleFonts.outfit(
        fontSize: 16 * scale,
        color: AppColors.primaryBlue,
        fontWeight: FontWeight.w800,
        height: 1.4,
        letterSpacing: 0.08,
      ),
    );
  }

  InlineSpan bulletPoint(String text, double scale) {
    return TextSpan(
      text: "\u2022 $text\n",
      style: GoogleFonts.outfit(
        fontSize: 15 * scale,
        color: Colors.grey[850],
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
