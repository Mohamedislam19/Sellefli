// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Sellefli';

  @override
  String get profileTitle => 'Profile';

  @override
  String get retry => 'Retry';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get settingsHelp => 'Settings / Help';

  @override
  String get logout => 'Logout';

  @override
  String get recentTransactions => 'Recent Transactions';

  @override
  String get noRecentTransactions => 'No recent transactions';

  @override
  String get unknownItem => 'Unknown Item';

  @override
  String get borrowedStatus => 'Borrowed';

  @override
  String get lentStatus => 'Lent';

  @override
  String get noRatingsYet => 'No ratings yet';

  @override
  String get userFallback => 'User';

  @override
  String currencyDa(Object amount) {
    return 'DA $amount';
  }

  @override
  String get language => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'Arabic';

  @override
  String get languageFrench => 'French';

  @override
  String get languageDialogTitle => 'Choose language';

  @override
  String get navHome => 'Home';

  @override
  String get navRequests => 'Requests';

  @override
  String get navListings => 'My Listings';

  @override
  String get navProfile => 'Profile';

  @override
  String get editProfileSuccess => 'Profile updated successfully.';

  @override
  String editProfileImagePickFail(Object error) {
    return 'Failed to pick image: $error';
  }

  @override
  String get editProfileFullName => 'Full Name';

  @override
  String get editProfilePhoneNumber => 'Phone Number';

  @override
  String get editProfileSave => 'Save Changes';

  @override
  String editProfileFieldRequired(Object field) {
    return 'Please enter your $field';
  }

  @override
  String get settingsAboutUs => 'About Us';

  @override
  String get settingsAboutSellefliTitle => 'About Sellefli';

  @override
  String get settingsAboutSellefliDesc =>
      'Sellefli is a community-based mobile platform that helps neighbors and campus users rent or borrow everyday items from people nearby. Instead of buying new things, you can share what you already own and earn money while helping others. Sellefli makes local exchanges simple, safe, and trustworthy.';

  @override
  String get settingsMissionTitle => 'Our Mission';

  @override
  String get settingsMissionDesc =>
      'Our mission is to make sharing a normal part of everyday life. Sellefli empowers people to save money, reduce waste, and strengthen community connections through a trusted local rental network.';

  @override
  String get settingsHowTitle => 'How It Works';

  @override
  String get settingsHowBrowseTitle => 'Browse:';

  @override
  String get settingsHowBrowseDesc =>
      'Discover items available for rent near you—from tools and electronics to books and household items.';

  @override
  String get settingsHowRequestTitle => 'Request:';

  @override
  String get settingsHowRequestDesc =>
      'Choose what you need and send a booking request with your preferred dates.';

  @override
  String get settingsHowConfirmTitle => 'Confirm:';

  @override
  String get settingsHowConfirmDesc =>
      'The owner reviews your request and approves it.';

  @override
  String get settingsHowMeetTitle => 'Meet & Exchange:';

  @override
  String get settingsHowMeetDesc =>
      'Arrange a safe meeting point to borrow or rent the item.';

  @override
  String get settingsHowReturnTitle => 'Return:';

  @override
  String get settingsHowReturnDesc =>
      'Bring the item back on time and rate your experience to build trust in the community.';

  @override
  String get settingsSupportTitle => 'Support';

  @override
  String get settingsFaqTitle => 'FAQ';

  @override
  String get settingsFaqQ1 => 'Is Sellefli free to use?';

  @override
  String get settingsFaqA1 =>
      'Yes, creating an account and browsing listings are completely free. Later versions may introduce optional premium features for frequent users.';

  @override
  String get settingsFaqQ2 => 'What kind of items can be listed?';

  @override
  String get settingsFaqA2 =>
      'Everyday personal items such as tools, books, games, sports gear, electronics, small furniture, and other safe, non-prohibited objects.';

  @override
  String get settingsFaqQ3 => 'How do I know if a user is trustworthy?';

  @override
  String get settingsFaqA3 =>
      'Each user profile includes ratings from past exchanges. We also encourage communication before confirming a request.';

  @override
  String get settingsFaqQ4 => 'What happens if an item is damaged or lost?';

  @override
  String get settingsFaqA4 =>
      'Sellefli promotes trust-based exchanges. For now, users should discuss conditions before borrowing. Future updates will include optional protection plans and verified user systems.';

  @override
  String get settingsFaqQ5 => 'Can I cancel a request after sending it?';

  @override
  String get settingsFaqA5 =>
      'Yes, requests can be canceled as long as they haven’t been accepted by the owner. Once accepted, both users should communicate directly to agree on changes.';

  @override
  String get settingsFaqQ6 => 'Is payment handled inside the app?';

  @override
  String get settingsFaqA6 =>
      'During the first versions, payments and returns are handled manually between users. A secure in-app payment system will be added in future updates.';

  @override
  String get settingsFaqQ7 => 'How do I contact the Sellefli team?';

  @override
  String get settingsFaqA7 =>
      'You can reach us directly from the “Contact Support” section below.';

  @override
  String get settingsContactTitle => 'Contact & Support';

  @override
  String get settingsContactDesc =>
      '📧 Email: support@sellefli.com\n\n🌐 Website: www.sellefli.dz\n\nIf you encounter any issue or wish to share feedback, please reach out via email or social media. We respond within 24–48 hours.';

  @override
  String get settingsLegalTitle => 'Legal & Community';

  @override
  String get settingsCommunityTitle => 'Community Guidelines';

  @override
  String get settingsCommunityDesc =>
      'Sellefli is built on trust and respect. Every user contributes to a safe and friendly environment.';

  @override
  String get settingsCommunityBullet1 => 'Be respectful and reliable.';

  @override
  String get settingsCommunityBullet2 => 'Communicate clearly.';

  @override
  String get settingsCommunityBullet3 => 'Avoid last-minute cancellations.';

  @override
  String get settingsCommunityBullet4 =>
      'Keep your items clean and in good condition.';

  @override
  String get settingsTermsTitle => 'Terms and Conditions';

  @override
  String get settingsTermsIntro => 'By using Sellefli, you agree to:';

  @override
  String get settingsTermsBullet1 =>
      'Share only items that you own or have the right to lend.';

  @override
  String get settingsTermsBullet2 =>
      'Treat borrowed items with care and return them on time.';

  @override
  String get settingsTermsBullet3 =>
      'Communicate honestly and respectfully with other users.';

  @override
  String get settingsTermsBullet4 =>
      'Avoid prohibited, unsafe, or illegal items.';

  @override
  String get settingsTermsBullet5 =>
      'Report any suspicious or inappropriate behavior to the support team.';

  @override
  String get settingsTermsOutro =>
      'Sellefli is not responsible for lost or damaged items but provides guidance and tools to help users resolve issues responsibly. Full Terms and Conditions will be available at launch on the official website.';

  @override
  String get settingsPrivacyTitle => 'Privacy Policy';

  @override
  String get settingsPrivacyDesc =>
      'Sellefli respects your privacy as described in our full policy, available on the official website.';

  @override
  String get settingsFooter =>
      'App Version 1.0.0 (Beta)\n© 2025 Sellefli. All rights reserved.';

  @override
  String get landingTagline => 'Borrow nearby · Share simply';

  @override
  String get landingGetStarted => 'Get Started';

  @override
  String get landingSignIn => 'Sign In';

  @override
  String get landingTerms => 'Terms & Conditions';

  @override
  String get landingFeatureBrowseTitle => 'Browse Local Items';

  @override
  String get landingFeatureBrowseDescription =>
      'Discover a wide array of tools, equipment, and unique items available for rent in your neighborhood.';

  @override
  String get landingFeatureLendTitle => 'Effortless Lending';

  @override
  String get landingFeatureLendDescription =>
      'List your unused items in minutes and earn while contributing to a sustainable community economy.';

  @override
  String get landingFeatureConnectTitle => 'Connect with Neighbors';

  @override
  String get landingFeatureConnectDescription =>
      'Build trust and strengthen local ties through shared resources and friendly interactions.';

  @override
  String get authSignupSuccess =>
      'Account created successfully! Welcome to Sellefli.';

  @override
  String get authLoginSuccess => 'Welcome back! Login successful.';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authEmailHint => 'example@email.com';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authPasswordHint => 'Enter your password';

  @override
  String get authFullNameLabel => 'Full Name';

  @override
  String get authFullNameHint => 'Mohammed Ahmed';

  @override
  String get authPhoneLabel => 'Phone Number';

  @override
  String get authPhoneHint => '05 12 34 56 78';

  @override
  String get authForgotPassword => 'Forgot your password?';

  @override
  String get authLoginButton => 'Log in';

  @override
  String get authNoAccount => 'Don\'t have an account?';

  @override
  String get authRegister => 'Register';

  @override
  String get authLoginTitle => 'Hello again!';

  @override
  String get authLoginSubtitle => 'Please log in to continue';

  @override
  String get authSignupTitle => 'Create an account';

  @override
  String get authSignupSubtitle => 'Join us today';

  @override
  String get authAlreadyAccount => 'Already have an account?';

  @override
  String get authRememberPassword => 'Remember your password?';

  @override
  String get authSendResetLink => 'Send Reset Link';

  @override
  String get authOr => 'OR';

  @override
  String get authResetTitle => 'Reset Password';

  @override
  String get authResetSubtitle =>
      'Enter your email to receive\na password reset link';

  @override
  String get validateFullNameEmpty => 'Please enter your full name';

  @override
  String get validateFullNameMin => 'Name must be at least 3 characters';

  @override
  String get validateFullNameMax => 'Name must not exceed 50 characters';

  @override
  String get validateFullNameChars =>
      'Name can only contain letters, spaces, hyphens, and apostrophes';

  @override
  String get validatePhoneEmpty => 'Please enter your phone number';

  @override
  String get validatePhoneDigits => 'Phone number can only contain digits';

  @override
  String get validatePhoneMin => 'Phone number must be at least 8 digits';

  @override
  String get validateEmailEmpty => 'Please enter your email';

  @override
  String get validateEmailInvalid => 'Please enter a valid email address';

  @override
  String get validatePasswordEmpty => 'Please enter your password';

  @override
  String get validatePasswordNoSpaces => 'No spaces allowed';

  @override
  String get validatePasswordMin => 'Min 8 characters required';

  @override
  String get validatePasswordUpper => 'Add at least 1 uppercase letter';

  @override
  String get validatePasswordLower => 'Add at least 1 lowercase letter';

  @override
  String get validatePasswordNumber => 'Add at least 1 number';

  @override
  String get validatePasswordSpecial => 'Add at least 1 special character';

  @override
  String get validateLoginPasswordEmpty => 'Please enter your password';

  @override
  String get homeExploreTitle => 'Explore';

  @override
  String get homeError => 'Error loading items';

  @override
  String get homeEmpty => 'No items found';

  @override
  String get homeOfflineTitle => 'You are currently offline';

  @override
  String get homeOfflineSubtitle => 'Connect to the internet to see more items';

  @override
  String get homeLocationPlaceholder => 'Location';

  @override
  String distanceKm(Object distance) {
    return '$distance km';
  }

  @override
  String get homeRadiusLabel => 'Radius';

  @override
  String get homeSearchHint => 'Search for items...';

  @override
  String get homeUseLocation => 'Use my location';

  @override
  String get categoryAll => 'All';

  @override
  String get categoryElectronicsTech => 'Electronics & Tech';

  @override
  String get categoryHomeAppliances => 'Home & Appliances';

  @override
  String get categoryFurnitureDecor => 'Furniture & Décor';

  @override
  String get categoryToolsEquipment => 'Tools & Equipment';

  @override
  String get categoryVehiclesMobility => 'Vehicles & Mobility';

  @override
  String get categorySportsOutdoors => 'Sports & Outdoors';

  @override
  String get categoryBooksStudy => 'Books & Study';

  @override
  String get categoryFashionAccessories => 'Fashion & Accessories';

  @override
  String get categoryEventsCelebrations => 'Events & Celebrations';

  @override
  String get categoryBabyKids => 'Baby & Kids';

  @override
  String get categoryHealthPersonal => 'Health & Personal Care';

  @override
  String get categoryMusicalInstruments => 'Musical Instruments';

  @override
  String get categoryHobbiesCrafts => 'Hobbies & Crafts';

  @override
  String get categoryPetSupplies => 'Pet Supplies';

  @override
  String get categoryOther => 'Other Items';

  @override
  String get itemCreateTitle => 'Create Item';

  @override
  String get itemEditTitle => 'Edit Item';

  @override
  String get itemPhotos => 'Item Photos';

  @override
  String get itemGallery => 'Gallery';

  @override
  String get itemCamera => 'Camera';

  @override
  String itemImageLimit(Object max) {
    return 'You can upload up to $max images.';
  }

  @override
  String get itemImageRequired => 'At least one photo is required.';

  @override
  String get itemTitleLabel => 'Title';

  @override
  String get itemTitleHint => 'e.g., Electric Drill, Bicycle';

  @override
  String get itemCategoryLabel => 'Category';

  @override
  String get itemDescriptionLabel => 'Description';

  @override
  String get itemDescriptionHint => 'Describe your item in detail...';

  @override
  String get itemValuePerDayLabel => 'Estimated Value per Day';

  @override
  String get itemValueLabel => 'Estimated Value';

  @override
  String get itemValueHint => 'e.g., 150 DA';

  @override
  String get itemDepositLabel => 'Deposit Required';

  @override
  String get itemDepositHint => 'e.g., 50 DA (refundable)';

  @override
  String get itemAvailableFrom => 'Available From';

  @override
  String get itemAvailableUntil => 'Available Until';

  @override
  String get itemDateHint => 'MM/DD/YYYY';

  @override
  String get itemLocationLabel => 'Location';

  @override
  String get itemLocationHint => 'Pick on map';

  @override
  String get itemLocationRequired => 'Location is required.';

  @override
  String get itemPublishButton => 'Publish Item';

  @override
  String get itemEditButton => 'Edit Item';

  @override
  String get itemCreateSuccess => 'Item published successfully.';

  @override
  String itemCreateError(Object error) {
    return 'Error: Item could not be published. $error';
  }

  @override
  String get itemEditSuccess => 'Item updated successfully.';

  @override
  String get itemLoadError => 'Item not loaded yet.';

  @override
  String get itemSignInRequired => 'You must be signed in to create items.';

  @override
  String get itemRequiredField => 'Required';

  @override
  String get itemDetailsTitle => 'Item Details';

  @override
  String get itemDetailsNoId => 'Error: No item ID provided';

  @override
  String get itemDetailsGoBack => 'Go Back';

  @override
  String get itemDetailsNoDescription => 'No description available';

  @override
  String get itemDetailsCategory => 'Category';

  @override
  String get itemDetailsValue => 'Item Value';

  @override
  String get itemDetailsDeposit => 'Deposit Required';

  @override
  String get itemDetailsAvailableFrom => 'Available From';

  @override
  String get itemDetailsAvailableUntil => 'Available Until';

  @override
  String get itemDetailsStatus => 'Status';

  @override
  String get itemStatusAvailable => 'Available';

  @override
  String get itemStatusUnavailable => 'Unavailable';

  @override
  String get itemDetailsOwner => 'Owner';

  @override
  String itemDetailsOwnerReviews(Object count) {
    return '($count reviews)';
  }

  @override
  String get itemDetailsDepositNote =>
      'Please refer to the Deposit Policy for more information on item rentals and returns.';

  @override
  String get itemDetailsBookNow => 'Book Now';

  @override
  String get itemDetailsNotAvailable => 'Not Available';

  @override
  String get bookingDialogTitle => 'Booking Details';

  @override
  String get bookingDialogStartDate => 'Start Date';

  @override
  String get bookingDialogEndDate => 'End Date';

  @override
  String get bookingDialogTotalCost => 'Total Cost';

  @override
  String get bookingDialogDays => 'Days';

  @override
  String get bookingDialogSelectDate => 'Select date';

  @override
  String get bookingDialogCancel => 'Cancel';

  @override
  String get bookingDialogConfirm => 'Confirm';

  @override
  String bookingDialogSuccess(Object days) {
    return 'Booking confirmed for $days days!';
  }

  @override
  String bookingDialogFail(Object error) {
    return 'Failed to create booking: $error';
  }

  @override
  String get bookingDialogAuthRequired => 'User not authenticated';

  @override
  String get requestsTitle => 'Requests & Orders';

  @override
  String get requestsIncomingTab => 'Incoming';

  @override
  String get requestsMyRequestsTab => 'My Requests';

  @override
  String requestsError(Object error) {
    return 'Error: $error';
  }

  @override
  String get requestsNoIncoming => 'No incoming requests';

  @override
  String get requestsNoSent => 'No requests sent yet';

  @override
  String requestsFromSender(Object sender) {
    return 'From $sender';
  }

  @override
  String get requestsAccept => 'Accept';

  @override
  String get requestsDecline => 'Decline';

  @override
  String get bookingDetailsTitle => 'Booking Details';

  @override
  String bookingDetailsError(Object error) {
    return 'Error: $error';
  }

  @override
  String get bookingDetailsNoData => 'No booking data';

  @override
  String get bookingSummaryTitle => 'Item & Booking Summary';

  @override
  String bookingBorrowedBy(Object user) {
    return 'Borrowed by: $user';
  }

  @override
  String get bookingTotalCostLabel => 'Total Cost:';

  @override
  String get bookingDepositLabel => 'Deposit:';

  @override
  String get bookingStatusLabel => 'Booking Status';

  @override
  String get bookingCodeLabel => 'Booking Code:';

  @override
  String get bookingOwnerActions => 'Owner Actions';

  @override
  String get bookingOwnerInformation => 'Owner Information';

  @override
  String get bookingUnknownOwner => 'Unknown Owner';

  @override
  String get bookingMarkDepositReceived => 'Mark Deposit Received';

  @override
  String get bookingMarkDepositReturned => 'Mark Deposit as Returned';

  @override
  String get bookingKeepDeposit => 'Keep Deposit';

  @override
  String get bookingAlreadyRated => 'You have already rated this booking';

  @override
  String get bookingRateExperience => 'Rate Your Experience';

  @override
  String get bookingRateQuestion => 'How was your experience with this user?';

  @override
  String get bookingCancel => 'Cancel';

  @override
  String get bookingSubmit => 'Submit';

  @override
  String get bookingDaysLabel => 'Days';

  @override
  String bookingTotalCostValue(Object amount) {
    return 'DA $amount';
  }

  @override
  String get statusPending => 'Pending';

  @override
  String get statusAccepted => 'Accepted';

  @override
  String get statusDeclined => 'Declined';

  @override
  String get statusActive => 'Active';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusClosed => 'Closed';

  @override
  String get depositStatusNone => 'None';

  @override
  String get depositStatusReceived => 'Received';

  @override
  String get depositStatusReturned => 'Returned';

  @override
  String get depositStatusKept => 'Kept';

  @override
  String get mapTitle => 'Map';

  @override
  String get mapServicesDisabled => 'Location services are disabled.';

  @override
  String get mapPermissionDenied => 'Location permission denied.';

  @override
  String get mapPermissionDeniedForever =>
      'Location permission permanently denied.';

  @override
  String get mapCurrentLocationSet => 'Location set to your current position!';

  @override
  String get mapLocationFailed => 'Failed to get location. Try again.';

  @override
  String get mapLocalizeCurrent => 'Localize to Current Location';

  @override
  String get mapConfirmLocation => 'Confirm Location';

  @override
  String get myListingsTitle => 'My Listings';

  @override
  String get myListingsNoItems => 'No listings yet';

  @override
  String get myListingsOffline => '(Offline mode)';

  @override
  String get myListingsOfflineBanner =>
      '📡 Offline Mode - Showing cached listings';

  @override
  String get myListingsStatusActive => 'Active';

  @override
  String get myListingsStatusRented => 'Rented';

  @override
  String get myListingsStatusPending => 'Pending Approval';

  @override
  String get myListingsStatusUnavailable => 'Unavailable';

  @override
  String get myListingsEdit => 'Edit';

  @override
  String get myListingsView => 'View';
}
