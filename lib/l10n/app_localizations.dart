import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Sellefli'**
  String get appTitle;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @settingsHelp.
  ///
  /// In en, this message translates to:
  /// **'Settings / Help'**
  String get settingsHelp;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// No description provided for @noRecentTransactions.
  ///
  /// In en, this message translates to:
  /// **'No recent transactions'**
  String get noRecentTransactions;

  /// No description provided for @unknownItem.
  ///
  /// In en, this message translates to:
  /// **'Unknown Item'**
  String get unknownItem;

  /// No description provided for @borrowedStatus.
  ///
  /// In en, this message translates to:
  /// **'Borrowed'**
  String get borrowedStatus;

  /// No description provided for @lentStatus.
  ///
  /// In en, this message translates to:
  /// **'Lent'**
  String get lentStatus;

  /// No description provided for @noRatingsYet.
  ///
  /// In en, this message translates to:
  /// **'No ratings yet'**
  String get noRatingsYet;

  /// No description provided for @userFallback.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get userFallback;

  /// No description provided for @currencyDa.
  ///
  /// In en, this message translates to:
  /// **'DA {amount}'**
  String currencyDa(Object amount);

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get languageArabic;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get languageFrench;

  /// No description provided for @languageDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get languageDialogTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navRequests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get navRequests;

  /// No description provided for @navListings.
  ///
  /// In en, this message translates to:
  /// **'My Listings'**
  String get navListings;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @editProfileSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully.'**
  String get editProfileSuccess;

  /// No description provided for @editProfileImagePickFail.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick image: {error}'**
  String editProfileImagePickFail(Object error);

  /// No description provided for @editProfileFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get editProfileFullName;

  /// No description provided for @editProfilePhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get editProfilePhoneNumber;

  /// No description provided for @editProfileSave.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get editProfileSave;

  /// No description provided for @editProfileFieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your {field}'**
  String editProfileFieldRequired(Object field);

  /// No description provided for @settingsAboutUs.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get settingsAboutUs;

  /// No description provided for @settingsAboutSellefliTitle.
  ///
  /// In en, this message translates to:
  /// **'About Sellefli'**
  String get settingsAboutSellefliTitle;

  /// No description provided for @settingsAboutSellefliDesc.
  ///
  /// In en, this message translates to:
  /// **'Sellefli is a community-based mobile platform that helps neighbors and campus users rent or borrow everyday items from people nearby. Instead of buying new things, you can share what you already own and earn money while helping others. Sellefli makes local exchanges simple, safe, and trustworthy.'**
  String get settingsAboutSellefliDesc;

  /// No description provided for @settingsMissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Our Mission'**
  String get settingsMissionTitle;

  /// No description provided for @settingsMissionDesc.
  ///
  /// In en, this message translates to:
  /// **'Our mission is to make sharing a normal part of everyday life. Sellefli empowers people to save money, reduce waste, and strengthen community connections through a trusted local rental network.'**
  String get settingsMissionDesc;

  /// No description provided for @settingsHowTitle.
  ///
  /// In en, this message translates to:
  /// **'How It Works'**
  String get settingsHowTitle;

  /// No description provided for @settingsHowBrowseTitle.
  ///
  /// In en, this message translates to:
  /// **'Browse:'**
  String get settingsHowBrowseTitle;

  /// No description provided for @settingsHowBrowseDesc.
  ///
  /// In en, this message translates to:
  /// **'Discover items available for rent near you—from tools and electronics to books and household items.'**
  String get settingsHowBrowseDesc;

  /// No description provided for @settingsHowRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Request:'**
  String get settingsHowRequestTitle;

  /// No description provided for @settingsHowRequestDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose what you need and send a booking request with your preferred dates.'**
  String get settingsHowRequestDesc;

  /// No description provided for @settingsHowConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm:'**
  String get settingsHowConfirmTitle;

  /// No description provided for @settingsHowConfirmDesc.
  ///
  /// In en, this message translates to:
  /// **'The owner reviews your request and approves it.'**
  String get settingsHowConfirmDesc;

  /// No description provided for @settingsHowMeetTitle.
  ///
  /// In en, this message translates to:
  /// **'Meet & Exchange:'**
  String get settingsHowMeetTitle;

  /// No description provided for @settingsHowMeetDesc.
  ///
  /// In en, this message translates to:
  /// **'Arrange a safe meeting point to borrow or rent the item.'**
  String get settingsHowMeetDesc;

  /// No description provided for @settingsHowReturnTitle.
  ///
  /// In en, this message translates to:
  /// **'Return:'**
  String get settingsHowReturnTitle;

  /// No description provided for @settingsHowReturnDesc.
  ///
  /// In en, this message translates to:
  /// **'Bring the item back on time and rate your experience to build trust in the community.'**
  String get settingsHowReturnDesc;

  /// No description provided for @settingsSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get settingsSupportTitle;

  /// No description provided for @settingsFaqTitle.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get settingsFaqTitle;

  /// No description provided for @settingsFaqQ1.
  ///
  /// In en, this message translates to:
  /// **'Is Sellefli free to use?'**
  String get settingsFaqQ1;

  /// No description provided for @settingsFaqA1.
  ///
  /// In en, this message translates to:
  /// **'Yes, creating an account and browsing listings are completely free. Later versions may introduce optional premium features for frequent users.'**
  String get settingsFaqA1;

  /// No description provided for @settingsFaqQ2.
  ///
  /// In en, this message translates to:
  /// **'What kind of items can be listed?'**
  String get settingsFaqQ2;

  /// No description provided for @settingsFaqA2.
  ///
  /// In en, this message translates to:
  /// **'Everyday personal items such as tools, books, games, sports gear, electronics, small furniture, and other safe, non-prohibited objects.'**
  String get settingsFaqA2;

  /// No description provided for @settingsFaqQ3.
  ///
  /// In en, this message translates to:
  /// **'How do I know if a user is trustworthy?'**
  String get settingsFaqQ3;

  /// No description provided for @settingsFaqA3.
  ///
  /// In en, this message translates to:
  /// **'Each user profile includes ratings from past exchanges. We also encourage communication before confirming a request.'**
  String get settingsFaqA3;

  /// No description provided for @settingsFaqQ4.
  ///
  /// In en, this message translates to:
  /// **'What happens if an item is damaged or lost?'**
  String get settingsFaqQ4;

  /// No description provided for @settingsFaqA4.
  ///
  /// In en, this message translates to:
  /// **'Sellefli promotes trust-based exchanges. For now, users should discuss conditions before borrowing. Future updates will include optional protection plans and verified user systems.'**
  String get settingsFaqA4;

  /// No description provided for @settingsFaqQ5.
  ///
  /// In en, this message translates to:
  /// **'Can I cancel a request after sending it?'**
  String get settingsFaqQ5;

  /// No description provided for @settingsFaqA5.
  ///
  /// In en, this message translates to:
  /// **'Yes, requests can be canceled as long as they haven’t been accepted by the owner. Once accepted, both users should communicate directly to agree on changes.'**
  String get settingsFaqA5;

  /// No description provided for @settingsFaqQ6.
  ///
  /// In en, this message translates to:
  /// **'Is payment handled inside the app?'**
  String get settingsFaqQ6;

  /// No description provided for @settingsFaqA6.
  ///
  /// In en, this message translates to:
  /// **'During the first versions, payments and returns are handled manually between users. A secure in-app payment system will be added in future updates.'**
  String get settingsFaqA6;

  /// No description provided for @settingsFaqQ7.
  ///
  /// In en, this message translates to:
  /// **'How do I contact the Sellefli team?'**
  String get settingsFaqQ7;

  /// No description provided for @settingsFaqA7.
  ///
  /// In en, this message translates to:
  /// **'You can reach us directly from the “Contact Support” section below.'**
  String get settingsFaqA7;

  /// No description provided for @settingsContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact & Support'**
  String get settingsContactTitle;

  /// No description provided for @settingsContactDesc.
  ///
  /// In en, this message translates to:
  /// **'📧 Email: support@sellefli.com\n\n🌐 Website: www.sellefli.dz\n\nIf you encounter any issue or wish to share feedback, please reach out via email or social media. We respond within 24–48 hours.'**
  String get settingsContactDesc;

  /// No description provided for @settingsLegalTitle.
  ///
  /// In en, this message translates to:
  /// **'Legal & Community'**
  String get settingsLegalTitle;

  /// No description provided for @settingsCommunityTitle.
  ///
  /// In en, this message translates to:
  /// **'Community Guidelines'**
  String get settingsCommunityTitle;

  /// No description provided for @settingsCommunityDesc.
  ///
  /// In en, this message translates to:
  /// **'Sellefli is built on trust and respect. Every user contributes to a safe and friendly environment.'**
  String get settingsCommunityDesc;

  /// No description provided for @settingsCommunityBullet1.
  ///
  /// In en, this message translates to:
  /// **'Be respectful and reliable.'**
  String get settingsCommunityBullet1;

  /// No description provided for @settingsCommunityBullet2.
  ///
  /// In en, this message translates to:
  /// **'Communicate clearly.'**
  String get settingsCommunityBullet2;

  /// No description provided for @settingsCommunityBullet3.
  ///
  /// In en, this message translates to:
  /// **'Avoid last-minute cancellations.'**
  String get settingsCommunityBullet3;

  /// No description provided for @settingsCommunityBullet4.
  ///
  /// In en, this message translates to:
  /// **'Keep your items clean and in good condition.'**
  String get settingsCommunityBullet4;

  /// No description provided for @settingsTermsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get settingsTermsTitle;

  /// No description provided for @settingsTermsIntro.
  ///
  /// In en, this message translates to:
  /// **'By using Sellefli, you agree to:'**
  String get settingsTermsIntro;

  /// No description provided for @settingsTermsBullet1.
  ///
  /// In en, this message translates to:
  /// **'Share only items that you own or have the right to lend.'**
  String get settingsTermsBullet1;

  /// No description provided for @settingsTermsBullet2.
  ///
  /// In en, this message translates to:
  /// **'Treat borrowed items with care and return them on time.'**
  String get settingsTermsBullet2;

  /// No description provided for @settingsTermsBullet3.
  ///
  /// In en, this message translates to:
  /// **'Communicate honestly and respectfully with other users.'**
  String get settingsTermsBullet3;

  /// No description provided for @settingsTermsBullet4.
  ///
  /// In en, this message translates to:
  /// **'Avoid prohibited, unsafe, or illegal items.'**
  String get settingsTermsBullet4;

  /// No description provided for @settingsTermsBullet5.
  ///
  /// In en, this message translates to:
  /// **'Report any suspicious or inappropriate behavior to the support team.'**
  String get settingsTermsBullet5;

  /// No description provided for @settingsTermsOutro.
  ///
  /// In en, this message translates to:
  /// **'Sellefli is not responsible for lost or damaged items but provides guidance and tools to help users resolve issues responsibly. Full Terms and Conditions will be available at launch on the official website.'**
  String get settingsTermsOutro;

  /// No description provided for @settingsPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacyTitle;

  /// No description provided for @settingsPrivacyDesc.
  ///
  /// In en, this message translates to:
  /// **'Sellefli respects your privacy as described in our full policy, available on the official website.'**
  String get settingsPrivacyDesc;

  /// No description provided for @settingsFooter.
  ///
  /// In en, this message translates to:
  /// **'App Version 1.0.0 (Beta)\n© 2025 Sellefli. All rights reserved.'**
  String get settingsFooter;

  /// No description provided for @landingTagline.
  ///
  /// In en, this message translates to:
  /// **'Borrow nearby · Share simply'**
  String get landingTagline;

  /// No description provided for @landingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get landingGetStarted;

  /// No description provided for @landingSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get landingSignIn;

  /// No description provided for @landingTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get landingTerms;

  /// No description provided for @landingFeatureBrowseTitle.
  ///
  /// In en, this message translates to:
  /// **'Browse Local Items'**
  String get landingFeatureBrowseTitle;

  /// No description provided for @landingFeatureBrowseDescription.
  ///
  /// In en, this message translates to:
  /// **'Discover a wide array of tools, equipment, and unique items available for rent in your neighborhood.'**
  String get landingFeatureBrowseDescription;

  /// No description provided for @landingFeatureLendTitle.
  ///
  /// In en, this message translates to:
  /// **'Effortless Lending'**
  String get landingFeatureLendTitle;

  /// No description provided for @landingFeatureLendDescription.
  ///
  /// In en, this message translates to:
  /// **'List your unused items in minutes and earn while contributing to a sustainable community economy.'**
  String get landingFeatureLendDescription;

  /// No description provided for @landingFeatureConnectTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect with Neighbors'**
  String get landingFeatureConnectTitle;

  /// No description provided for @landingFeatureConnectDescription.
  ///
  /// In en, this message translates to:
  /// **'Build trust and strengthen local ties through shared resources and friendly interactions.'**
  String get landingFeatureConnectDescription;

  /// No description provided for @authSignupSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully! Welcome to Sellefli.'**
  String get authSignupSuccess;

  /// No description provided for @authLoginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Welcome back! Login successful.'**
  String get authLoginSuccess;

  /// No description provided for @authEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// No description provided for @authEmailHint.
  ///
  /// In en, this message translates to:
  /// **'example@email.com'**
  String get authEmailHint;

  /// No description provided for @authPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// No description provided for @authPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get authPasswordHint;

  /// No description provided for @authFullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get authFullNameLabel;

  /// No description provided for @authFullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Mohammed Ahmed'**
  String get authFullNameHint;

  /// No description provided for @authPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get authPhoneLabel;

  /// No description provided for @authPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'05 12 34 56 78'**
  String get authPhoneHint;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get authForgotPassword;

  /// No description provided for @authLoginButton.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get authLoginButton;

  /// No description provided for @authNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get authNoAccount;

  /// No description provided for @authRegister.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get authRegister;

  /// No description provided for @authLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Hello again!'**
  String get authLoginTitle;

  /// No description provided for @authLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please log in to continue'**
  String get authLoginSubtitle;

  /// No description provided for @authSignupTitle.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get authSignupTitle;

  /// No description provided for @authSignupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join us today'**
  String get authSignupSubtitle;

  /// No description provided for @authAlreadyAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get authAlreadyAccount;

  /// No description provided for @authRememberPassword.
  ///
  /// In en, this message translates to:
  /// **'Remember your password?'**
  String get authRememberPassword;

  /// No description provided for @authSendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get authSendResetLink;

  /// No description provided for @authOr.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get authOr;

  /// No description provided for @authResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get authResetTitle;

  /// No description provided for @authResetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to receive\na password reset link'**
  String get authResetSubtitle;

  /// No description provided for @validateFullNameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name'**
  String get validateFullNameEmpty;

  /// No description provided for @validateFullNameMin.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 3 characters'**
  String get validateFullNameMin;

  /// No description provided for @validateFullNameMax.
  ///
  /// In en, this message translates to:
  /// **'Name must not exceed 50 characters'**
  String get validateFullNameMax;

  /// No description provided for @validateFullNameChars.
  ///
  /// In en, this message translates to:
  /// **'Name can only contain letters, spaces, hyphens, and apostrophes'**
  String get validateFullNameChars;

  /// No description provided for @validatePhoneEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get validatePhoneEmpty;

  /// No description provided for @validatePhoneDigits.
  ///
  /// In en, this message translates to:
  /// **'Phone number can only contain digits'**
  String get validatePhoneDigits;

  /// No description provided for @validatePhoneMin.
  ///
  /// In en, this message translates to:
  /// **'Phone number must be at least 8 digits'**
  String get validatePhoneMin;

  /// No description provided for @validateEmailEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get validateEmailEmpty;

  /// No description provided for @validateEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get validateEmailInvalid;

  /// No description provided for @validatePasswordEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get validatePasswordEmpty;

  /// No description provided for @validatePasswordNoSpaces.
  ///
  /// In en, this message translates to:
  /// **'No spaces allowed'**
  String get validatePasswordNoSpaces;

  /// No description provided for @validatePasswordMin.
  ///
  /// In en, this message translates to:
  /// **'Min 8 characters required'**
  String get validatePasswordMin;

  /// No description provided for @validatePasswordUpper.
  ///
  /// In en, this message translates to:
  /// **'Add at least 1 uppercase letter'**
  String get validatePasswordUpper;

  /// No description provided for @validatePasswordLower.
  ///
  /// In en, this message translates to:
  /// **'Add at least 1 lowercase letter'**
  String get validatePasswordLower;

  /// No description provided for @validatePasswordNumber.
  ///
  /// In en, this message translates to:
  /// **'Add at least 1 number'**
  String get validatePasswordNumber;

  /// No description provided for @validatePasswordSpecial.
  ///
  /// In en, this message translates to:
  /// **'Add at least 1 special character'**
  String get validatePasswordSpecial;

  /// No description provided for @validateLoginPasswordEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get validateLoginPasswordEmpty;

  /// No description provided for @homeExploreTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get homeExploreTitle;

  /// No description provided for @homeError.
  ///
  /// In en, this message translates to:
  /// **'Error loading items'**
  String get homeError;

  /// No description provided for @homeEmpty.
  ///
  /// In en, this message translates to:
  /// **'No items found'**
  String get homeEmpty;

  /// No description provided for @homeOfflineTitle.
  ///
  /// In en, this message translates to:
  /// **'You are currently offline'**
  String get homeOfflineTitle;

  /// No description provided for @homeOfflineSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Connect to the internet to see more items'**
  String get homeOfflineSubtitle;

  /// No description provided for @homeLocationPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get homeLocationPlaceholder;

  /// No description provided for @distanceKm.
  ///
  /// In en, this message translates to:
  /// **'{distance} km'**
  String distanceKm(Object distance);

  /// No description provided for @homeRadiusLabel.
  ///
  /// In en, this message translates to:
  /// **'Radius'**
  String get homeRadiusLabel;

  /// No description provided for @homeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search for items...'**
  String get homeSearchHint;

  /// No description provided for @homeUseLocation.
  ///
  /// In en, this message translates to:
  /// **'Use my location'**
  String get homeUseLocation;

  /// No description provided for @categoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get categoryAll;

  /// No description provided for @categoryElectronicsTech.
  ///
  /// In en, this message translates to:
  /// **'Electronics & Tech'**
  String get categoryElectronicsTech;

  /// No description provided for @categoryHomeAppliances.
  ///
  /// In en, this message translates to:
  /// **'Home & Appliances'**
  String get categoryHomeAppliances;

  /// No description provided for @categoryFurnitureDecor.
  ///
  /// In en, this message translates to:
  /// **'Furniture & Décor'**
  String get categoryFurnitureDecor;

  /// No description provided for @categoryToolsEquipment.
  ///
  /// In en, this message translates to:
  /// **'Tools & Equipment'**
  String get categoryToolsEquipment;

  /// No description provided for @categoryVehiclesMobility.
  ///
  /// In en, this message translates to:
  /// **'Vehicles & Mobility'**
  String get categoryVehiclesMobility;

  /// No description provided for @categorySportsOutdoors.
  ///
  /// In en, this message translates to:
  /// **'Sports & Outdoors'**
  String get categorySportsOutdoors;

  /// No description provided for @categoryBooksStudy.
  ///
  /// In en, this message translates to:
  /// **'Books & Study'**
  String get categoryBooksStudy;

  /// No description provided for @categoryFashionAccessories.
  ///
  /// In en, this message translates to:
  /// **'Fashion & Accessories'**
  String get categoryFashionAccessories;

  /// No description provided for @categoryEventsCelebrations.
  ///
  /// In en, this message translates to:
  /// **'Events & Celebrations'**
  String get categoryEventsCelebrations;

  /// No description provided for @categoryBabyKids.
  ///
  /// In en, this message translates to:
  /// **'Baby & Kids'**
  String get categoryBabyKids;

  /// No description provided for @categoryHealthPersonal.
  ///
  /// In en, this message translates to:
  /// **'Health & Personal Care'**
  String get categoryHealthPersonal;

  /// No description provided for @categoryMusicalInstruments.
  ///
  /// In en, this message translates to:
  /// **'Musical Instruments'**
  String get categoryMusicalInstruments;

  /// No description provided for @categoryHobbiesCrafts.
  ///
  /// In en, this message translates to:
  /// **'Hobbies & Crafts'**
  String get categoryHobbiesCrafts;

  /// No description provided for @categoryPetSupplies.
  ///
  /// In en, this message translates to:
  /// **'Pet Supplies'**
  String get categoryPetSupplies;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other Items'**
  String get categoryOther;

  /// No description provided for @itemCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Item'**
  String get itemCreateTitle;

  /// No description provided for @itemEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Item'**
  String get itemEditTitle;

  /// No description provided for @itemPhotos.
  ///
  /// In en, this message translates to:
  /// **'Item Photos'**
  String get itemPhotos;

  /// No description provided for @itemGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get itemGallery;

  /// No description provided for @itemCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get itemCamera;

  /// No description provided for @itemImageLimit.
  ///
  /// In en, this message translates to:
  /// **'You can upload up to {max} images.'**
  String itemImageLimit(Object max);

  /// No description provided for @itemImageRequired.
  ///
  /// In en, this message translates to:
  /// **'At least one photo is required.'**
  String get itemImageRequired;

  /// No description provided for @itemTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get itemTitleLabel;

  /// No description provided for @itemTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Electric Drill, Bicycle'**
  String get itemTitleHint;

  /// No description provided for @itemCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get itemCategoryLabel;

  /// No description provided for @itemDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get itemDescriptionLabel;

  /// No description provided for @itemDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe your item in detail...'**
  String get itemDescriptionHint;

  /// No description provided for @itemValuePerDayLabel.
  ///
  /// In en, this message translates to:
  /// **'Estimated Value per Day'**
  String get itemValuePerDayLabel;

  /// No description provided for @itemValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Estimated Value'**
  String get itemValueLabel;

  /// No description provided for @itemValueHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 150 DA'**
  String get itemValueHint;

  /// No description provided for @itemDepositLabel.
  ///
  /// In en, this message translates to:
  /// **'Deposit Required'**
  String get itemDepositLabel;

  /// No description provided for @itemDepositHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 50 DA (refundable)'**
  String get itemDepositHint;

  /// No description provided for @itemAvailableFrom.
  ///
  /// In en, this message translates to:
  /// **'Available From'**
  String get itemAvailableFrom;

  /// No description provided for @itemAvailableUntil.
  ///
  /// In en, this message translates to:
  /// **'Available Until'**
  String get itemAvailableUntil;

  /// No description provided for @itemDateHint.
  ///
  /// In en, this message translates to:
  /// **'MM/DD/YYYY'**
  String get itemDateHint;

  /// No description provided for @itemLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get itemLocationLabel;

  /// No description provided for @itemLocationHint.
  ///
  /// In en, this message translates to:
  /// **'Pick on map'**
  String get itemLocationHint;

  /// No description provided for @itemLocationRequired.
  ///
  /// In en, this message translates to:
  /// **'Location is required.'**
  String get itemLocationRequired;

  /// No description provided for @itemPublishButton.
  ///
  /// In en, this message translates to:
  /// **'Publish Item'**
  String get itemPublishButton;

  /// No description provided for @itemEditButton.
  ///
  /// In en, this message translates to:
  /// **'Edit Item'**
  String get itemEditButton;

  /// No description provided for @itemCreateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Item published successfully.'**
  String get itemCreateSuccess;

  /// No description provided for @itemCreateError.
  ///
  /// In en, this message translates to:
  /// **'Error: Item could not be published. {error}'**
  String itemCreateError(Object error);

  /// No description provided for @itemEditSuccess.
  ///
  /// In en, this message translates to:
  /// **'Item updated successfully.'**
  String get itemEditSuccess;

  /// No description provided for @itemLoadError.
  ///
  /// In en, this message translates to:
  /// **'Item not loaded yet.'**
  String get itemLoadError;

  /// No description provided for @itemSignInRequired.
  ///
  /// In en, this message translates to:
  /// **'You must be signed in to create items.'**
  String get itemSignInRequired;

  /// No description provided for @itemRequiredField.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get itemRequiredField;

  /// No description provided for @itemDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Item Details'**
  String get itemDetailsTitle;

  /// No description provided for @itemDetailsNoId.
  ///
  /// In en, this message translates to:
  /// **'Error: No item ID provided'**
  String get itemDetailsNoId;

  /// No description provided for @itemDetailsGoBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get itemDetailsGoBack;

  /// No description provided for @itemDetailsNoDescription.
  ///
  /// In en, this message translates to:
  /// **'No description available'**
  String get itemDetailsNoDescription;

  /// No description provided for @itemDetailsCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get itemDetailsCategory;

  /// No description provided for @itemDetailsValue.
  ///
  /// In en, this message translates to:
  /// **'Item Value'**
  String get itemDetailsValue;

  /// No description provided for @itemDetailsDeposit.
  ///
  /// In en, this message translates to:
  /// **'Deposit Required'**
  String get itemDetailsDeposit;

  /// No description provided for @itemDetailsAvailableFrom.
  ///
  /// In en, this message translates to:
  /// **'Available From'**
  String get itemDetailsAvailableFrom;

  /// No description provided for @itemDetailsAvailableUntil.
  ///
  /// In en, this message translates to:
  /// **'Available Until'**
  String get itemDetailsAvailableUntil;

  /// No description provided for @itemDetailsStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get itemDetailsStatus;

  /// No description provided for @itemStatusAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get itemStatusAvailable;

  /// No description provided for @itemStatusUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get itemStatusUnavailable;

  /// No description provided for @itemDetailsOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get itemDetailsOwner;

  /// No description provided for @itemDetailsOwnerReviews.
  ///
  /// In en, this message translates to:
  /// **'({count} reviews)'**
  String itemDetailsOwnerReviews(Object count);

  /// No description provided for @itemDetailsDepositNote.
  ///
  /// In en, this message translates to:
  /// **'Please refer to the Deposit Policy for more information on item rentals and returns.'**
  String get itemDetailsDepositNote;

  /// No description provided for @itemDetailsBookNow.
  ///
  /// In en, this message translates to:
  /// **'Book Now'**
  String get itemDetailsBookNow;

  /// No description provided for @itemDetailsNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not Available'**
  String get itemDetailsNotAvailable;

  /// No description provided for @bookingDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking Details'**
  String get bookingDialogTitle;

  /// No description provided for @bookingDialogStartDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get bookingDialogStartDate;

  /// No description provided for @bookingDialogEndDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get bookingDialogEndDate;

  /// No description provided for @bookingDialogTotalCost.
  ///
  /// In en, this message translates to:
  /// **'Total Cost'**
  String get bookingDialogTotalCost;

  /// No description provided for @bookingDialogDays.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get bookingDialogDays;

  /// No description provided for @bookingDialogSelectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get bookingDialogSelectDate;

  /// No description provided for @bookingDialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get bookingDialogCancel;

  /// No description provided for @bookingDialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get bookingDialogConfirm;

  /// No description provided for @bookingDialogSuccess.
  ///
  /// In en, this message translates to:
  /// **'Booking confirmed for {days} days!'**
  String bookingDialogSuccess(Object days);

  /// No description provided for @bookingDialogFail.
  ///
  /// In en, this message translates to:
  /// **'Failed to create booking: {error}'**
  String bookingDialogFail(Object error);

  /// No description provided for @bookingDialogAuthRequired.
  ///
  /// In en, this message translates to:
  /// **'User not authenticated'**
  String get bookingDialogAuthRequired;

  /// No description provided for @requestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Requests & Orders'**
  String get requestsTitle;

  /// No description provided for @requestsIncomingTab.
  ///
  /// In en, this message translates to:
  /// **'Incoming'**
  String get requestsIncomingTab;

  /// No description provided for @requestsMyRequestsTab.
  ///
  /// In en, this message translates to:
  /// **'My Requests'**
  String get requestsMyRequestsTab;

  /// No description provided for @requestsError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String requestsError(Object error);

  /// No description provided for @requestsNoIncoming.
  ///
  /// In en, this message translates to:
  /// **'No incoming requests'**
  String get requestsNoIncoming;

  /// No description provided for @requestsNoSent.
  ///
  /// In en, this message translates to:
  /// **'No requests sent yet'**
  String get requestsNoSent;

  /// No description provided for @requestsFromSender.
  ///
  /// In en, this message translates to:
  /// **'From {sender}'**
  String requestsFromSender(Object sender);

  /// No description provided for @requestsAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get requestsAccept;

  /// No description provided for @requestsDecline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get requestsDecline;

  /// No description provided for @bookingDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking Details'**
  String get bookingDetailsTitle;

  /// No description provided for @bookingDetailsError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String bookingDetailsError(Object error);

  /// No description provided for @bookingDetailsNoData.
  ///
  /// In en, this message translates to:
  /// **'No booking data'**
  String get bookingDetailsNoData;

  /// No description provided for @bookingSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Item & Booking Summary'**
  String get bookingSummaryTitle;

  /// No description provided for @bookingBorrowedBy.
  ///
  /// In en, this message translates to:
  /// **'Borrowed by: {user}'**
  String bookingBorrowedBy(Object user);

  /// No description provided for @bookingTotalCostLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Cost:'**
  String get bookingTotalCostLabel;

  /// No description provided for @bookingDepositLabel.
  ///
  /// In en, this message translates to:
  /// **'Deposit:'**
  String get bookingDepositLabel;

  /// No description provided for @bookingStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Booking Status'**
  String get bookingStatusLabel;

  /// No description provided for @bookingCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Booking Code:'**
  String get bookingCodeLabel;

  /// No description provided for @bookingOwnerActions.
  ///
  /// In en, this message translates to:
  /// **'Owner Actions'**
  String get bookingOwnerActions;

  /// No description provided for @bookingOwnerInformation.
  ///
  /// In en, this message translates to:
  /// **'Owner Information'**
  String get bookingOwnerInformation;

  /// No description provided for @bookingUnknownOwner.
  ///
  /// In en, this message translates to:
  /// **'Unknown Owner'**
  String get bookingUnknownOwner;

  /// No description provided for @bookingMarkDepositReceived.
  ///
  /// In en, this message translates to:
  /// **'Mark Deposit Received'**
  String get bookingMarkDepositReceived;

  /// No description provided for @bookingMarkDepositReturned.
  ///
  /// In en, this message translates to:
  /// **'Mark Deposit as Returned'**
  String get bookingMarkDepositReturned;

  /// No description provided for @bookingKeepDeposit.
  ///
  /// In en, this message translates to:
  /// **'Keep Deposit'**
  String get bookingKeepDeposit;

  /// No description provided for @bookingAlreadyRated.
  ///
  /// In en, this message translates to:
  /// **'You have already rated this booking'**
  String get bookingAlreadyRated;

  /// No description provided for @bookingRateExperience.
  ///
  /// In en, this message translates to:
  /// **'Rate Your Experience'**
  String get bookingRateExperience;

  /// No description provided for @bookingRateQuestion.
  ///
  /// In en, this message translates to:
  /// **'How was your experience with this user?'**
  String get bookingRateQuestion;

  /// No description provided for @bookingCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get bookingCancel;

  /// No description provided for @bookingSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get bookingSubmit;

  /// No description provided for @bookingDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get bookingDaysLabel;

  /// No description provided for @bookingTotalCostValue.
  ///
  /// In en, this message translates to:
  /// **'DA {amount}'**
  String bookingTotalCostValue(Object amount);

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get statusAccepted;

  /// No description provided for @statusDeclined.
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get statusDeclined;

  /// No description provided for @statusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statusActive;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get statusClosed;

  /// No description provided for @depositStatusNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get depositStatusNone;

  /// No description provided for @depositStatusReceived.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get depositStatusReceived;

  /// No description provided for @depositStatusReturned.
  ///
  /// In en, this message translates to:
  /// **'Returned'**
  String get depositStatusReturned;

  /// No description provided for @depositStatusKept.
  ///
  /// In en, this message translates to:
  /// **'Kept'**
  String get depositStatusKept;

  /// No description provided for @mapTitle.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get mapTitle;

  /// No description provided for @mapServicesDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location services are disabled.'**
  String get mapServicesDisabled;

  /// No description provided for @mapPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied.'**
  String get mapPermissionDenied;

  /// No description provided for @mapPermissionDeniedForever.
  ///
  /// In en, this message translates to:
  /// **'Location permission permanently denied.'**
  String get mapPermissionDeniedForever;

  /// No description provided for @mapCurrentLocationSet.
  ///
  /// In en, this message translates to:
  /// **'Location set to your current position!'**
  String get mapCurrentLocationSet;

  /// No description provided for @mapLocationFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to get location. Try again.'**
  String get mapLocationFailed;

  /// No description provided for @mapLocalizeCurrent.
  ///
  /// In en, this message translates to:
  /// **'Localize to Current Location'**
  String get mapLocalizeCurrent;

  /// No description provided for @mapConfirmLocation.
  ///
  /// In en, this message translates to:
  /// **'Confirm Location'**
  String get mapConfirmLocation;

  /// No description provided for @myListingsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Listings'**
  String get myListingsTitle;

  /// No description provided for @myListingsNoItems.
  ///
  /// In en, this message translates to:
  /// **'No listings yet'**
  String get myListingsNoItems;

  /// No description provided for @myListingsOffline.
  ///
  /// In en, this message translates to:
  /// **'(Offline mode)'**
  String get myListingsOffline;

  /// No description provided for @myListingsOfflineBanner.
  ///
  /// In en, this message translates to:
  /// **'📡 Offline Mode - Showing cached listings'**
  String get myListingsOfflineBanner;

  /// No description provided for @myListingsStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get myListingsStatusActive;

  /// No description provided for @myListingsStatusRented.
  ///
  /// In en, this message translates to:
  /// **'Rented'**
  String get myListingsStatusRented;

  /// No description provided for @myListingsStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending Approval'**
  String get myListingsStatusPending;

  /// No description provided for @myListingsStatusUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get myListingsStatusUnavailable;

  /// No description provided for @myListingsEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get myListingsEdit;

  /// No description provided for @myListingsView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get myListingsView;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
