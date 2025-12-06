// ignore_for_file: prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sellefli/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/expansion/animated_expansion_card.dart';
import '../../core/widgets/animated_return_button.dart';

class SettingsHelpPage extends StatelessWidget {
  SettingsHelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final List<Map<String, String>> faqData = [
      {'question': l10n.settingsFaqQ1, 'answer': l10n.settingsFaqA1},
      {'question': l10n.settingsFaqQ2, 'answer': l10n.settingsFaqA2},
      {'question': l10n.settingsFaqQ3, 'answer': l10n.settingsFaqA3},
      {'question': l10n.settingsFaqQ4, 'answer': l10n.settingsFaqA4},
      {'question': l10n.settingsFaqQ5, 'answer': l10n.settingsFaqA5},
      {'question': l10n.settingsFaqQ6, 'answer': l10n.settingsFaqA6},
      {'question': l10n.settingsFaqQ7, 'answer': l10n.settingsFaqA7},
    ];

    final screenWidth = MediaQuery.of(context).size.width;
    // Scale factor between 0.7 (at 245px) and 1 (at 350px or higher)
    final scale = (screenWidth / 350).clamp(0.7, 1.0);

    return Scaffold(
      // backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 207, 225, 255),
        elevation: 1,
        centerTitle: true,
        leading: const AnimatedReturnButton(),
        title: Padding(
          padding: EdgeInsets.symmetric(vertical: 12 * scale),
          child: Text(
            l10n.settingsHelp,
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
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: ListView(
          padding: EdgeInsets.only(
            bottom: 9 * scale,
            top: 9 * scale,
            left: 18 * scale,
            right: 18 * scale,
          ),
          children: [
            sectionTitle(l10n.settingsAboutUs, scale),
            AnimatedExpansionCard(
              icon: Icons.info_outline_rounded,
              title: l10n.settingsAboutSellefliTitle,
              scale: scale,
              descriptionWidget: buildStyledDescription([
                normalText(l10n.settingsAboutSellefliDesc, scale),
              ]),
            ),
            AnimatedExpansionCard(
              icon: Icons.location_city_outlined,
              title: l10n.settingsMissionTitle,
              scale: scale,
              descriptionWidget: buildStyledDescription([
                normalText(l10n.settingsMissionDesc, scale),
              ]),
            ),
            AnimatedExpansionCard(
              icon: Icons.help_outline_rounded,
              title: l10n.settingsHowTitle,
              scale: scale,
              descriptionWidget: buildStyledDescription([
                subtitleText(l10n.settingsHowBrowseTitle, scale),
                normalText(l10n.settingsHowBrowseDesc, scale),
                TextSpan(text: '\n\n'),
                subtitleText(l10n.settingsHowRequestTitle, scale),
                normalText(l10n.settingsHowRequestDesc, scale),
                TextSpan(text: '\n\n'),
                subtitleText(l10n.settingsHowConfirmTitle, scale),
                normalText(l10n.settingsHowConfirmDesc, scale),
                TextSpan(text: '\n\n'),
                subtitleText(l10n.settingsHowMeetTitle, scale),
                normalText(l10n.settingsHowMeetDesc, scale),
                TextSpan(text: '\n\n'),
                subtitleText(l10n.settingsHowReturnTitle, scale),
                normalText(l10n.settingsHowReturnDesc, scale),
              ]),
            ),
            sectionTitle(l10n.settingsSupportTitle, scale),
            AnimatedExpansionCard(
              icon: Icons.question_answer_outlined,
              title: l10n.settingsFaqTitle,
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
              title: l10n.settingsContactTitle,
              scale: scale,
              descriptionWidget: buildStyledDescription([
                normalText(l10n.settingsContactDesc, scale),
              ]),
            ),
            sectionTitle(l10n.settingsLegalTitle, scale),
            AnimatedExpansionCard(
              icon: Icons.groups_2_outlined,
              title: l10n.settingsCommunityTitle,
              scale: scale,
              descriptionWidget: buildStyledDescription([
                normalText(l10n.settingsCommunityDesc, scale),
                TextSpan(text: '\n\n'),
                bulletPoint(l10n.settingsCommunityBullet1, scale),
                bulletPoint(l10n.settingsCommunityBullet2, scale),
                bulletPoint(l10n.settingsCommunityBullet3, scale),
                bulletPoint(l10n.settingsCommunityBullet4, scale),
              ]),
            ),
            AnimatedExpansionCard(
              icon: Icons.library_books_outlined,
              title: l10n.settingsTermsTitle,
              scale: scale,
              descriptionWidget: buildStyledDescription([
                normalText(l10n.settingsTermsIntro, scale),
                bulletPoint(l10n.settingsTermsBullet1, scale),
                bulletPoint(l10n.settingsTermsBullet2, scale),
                bulletPoint(l10n.settingsTermsBullet3, scale),
                bulletPoint(l10n.settingsTermsBullet4, scale),
                bulletPoint(l10n.settingsTermsBullet5, scale),
                TextSpan(text: '\n'),
                normalText(l10n.settingsTermsOutro, scale),
              ]),
            ),
            AnimatedExpansionCard(
              icon: Icons.privacy_tip_rounded,
              title: l10n.settingsPrivacyTitle,
              scale: scale,
              descriptionWidget: buildStyledDescription([
                normalText(l10n.settingsPrivacyDesc, scale),
              ]),
            ),
            SizedBox(height: 32 * scale),
            Center(
              child: Text(
                l10n.settingsFooter,
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
      text: "$text ",
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


