// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'سلفلي';

  @override
  String get profileTitle => 'الملف الشخصي';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get settingsHelp => 'الإعدادات / المساعدة';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get recentTransactions => 'المعاملات الأخيرة';

  @override
  String get noRecentTransactions => 'لا توجد معاملات حديثة';

  @override
  String get unknownItem => 'عنصر غير معروف';

  @override
  String get borrowedStatus => 'مستعار';

  @override
  String get lentStatus => 'معار';

  @override
  String get noRatingsYet => 'لا توجد تقييمات بعد';

  @override
  String get userFallback => 'مستخدم';

  @override
  String currencyDa(Object amount) {
    return 'دج $amount';
  }

  @override
  String get language => 'اللغة';

  @override
  String get languageEnglish => 'الإنجليزية';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageFrench => 'الفرنسية';

  @override
  String get languageDialogTitle => 'اختر اللغة';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navRequests => 'الطلبات';

  @override
  String get navListings => 'عروضي';

  @override
  String get navProfile => 'الملف';

  @override
  String get editProfileSuccess => 'تم تحديث الملف الشخصي بنجاح.';

  @override
  String editProfileImagePickFail(Object error) {
    return 'فشل اختيار الصورة: $error';
  }

  @override
  String get editProfileFullName => 'الاسم الكامل';

  @override
  String get editProfilePhoneNumber => 'رقم الهاتف';

  @override
  String get editProfileSave => 'حفظ التغييرات';

  @override
  String editProfileFieldRequired(Object field) {
    return 'يرجى إدخال $field';
  }

  @override
  String get settingsAboutUs => 'من نحن';

  @override
  String get settingsAboutSellefliTitle => 'حول سلفلي';

  @override
  String get settingsAboutSellefliDesc =>
      'سلفلي منصة مجتمعية تساعد الجيران وطلاب الجامعات على استئجار أو استعارة الأشياء اليومية من الأشخاص القريبين. بدلاً من شراء أشياء جديدة، يمكنك مشاركة ما تملكه وكسب المال مع مساعدة الآخرين. سلفلي تجعل التبادل المحلي بسيطًا وآمنًا وموثوقًا.';

  @override
  String get settingsMissionTitle => 'مهمتنا';

  @override
  String get settingsMissionDesc =>
      'مهمتنا جعل المشاركة جزءًا طبيعيًا من الحياة اليومية. سلفلي تمكّن الناس من توفير المال وتقليل الهدر وتقوية الروابط المجتمعية عبر شبكة تأجير محلية موثوقة.';

  @override
  String get settingsHowTitle => 'كيف يعمل';

  @override
  String get settingsHowBrowseTitle => 'تصفح:';

  @override
  String get settingsHowBrowseDesc =>
      'اكتشف العناصر المتاحة للإيجار بالقرب منك — من الأدوات والإلكترونيات إلى الكتب والأغراض المنزلية.';

  @override
  String get settingsHowRequestTitle => 'اطلب:';

  @override
  String get settingsHowRequestDesc =>
      'اختر ما تحتاجه وأرسل طلب حجز بالتواريخ التي تفضلها.';

  @override
  String get settingsHowConfirmTitle => 'تأكيد:';

  @override
  String get settingsHowConfirmDesc =>
      'يقوم المالك بمراجعة طلبك والموافقة عليه.';

  @override
  String get settingsHowMeetTitle => 'التقِ وتسلم:';

  @override
  String get settingsHowMeetDesc =>
      'نسّق نقطة لقاء آمنة لاستعارة أو استئجار العنصر.';

  @override
  String get settingsHowReturnTitle => 'الإرجاع:';

  @override
  String get settingsHowReturnDesc =>
      'أعد العنصر في الوقت المحدد وقم بتقييم تجربتك لبناء الثقة في المجتمع.';

  @override
  String get settingsSupportTitle => 'الدعم';

  @override
  String get settingsFaqTitle => 'الأسئلة الشائعة';

  @override
  String get settingsFaqQ1 => 'هل استخدام سلفلي مجاني؟';

  @override
  String get settingsFaqA1 =>
      'نعم، إنشاء حساب وتصفح القوائم مجاني تمامًا. قد نضيف مزايا مدفوعة اختيارية للمستخدمين الدائمين لاحقًا.';

  @override
  String get settingsFaqQ2 => 'ما أنواع العناصر التي يمكن إدراجها؟';

  @override
  String get settingsFaqA2 =>
      'العناصر الشخصية اليومية مثل الأدوات والكتب والألعاب والمعدات الرياضية والإلكترونيات والأثاث الصغير والأشياء الآمنة غير المحظورة.';

  @override
  String get settingsFaqQ3 => 'كيف أعرف أن المستخدم موثوق؟';

  @override
  String get settingsFaqA3 =>
      'يحتوي ملف كل مستخدم على تقييمات من التبادلات السابقة. نشجع أيضًا على التواصل قبل تأكيد الطلب.';

  @override
  String get settingsFaqQ4 => 'ماذا لو تلف العنصر أو فُقد؟';

  @override
  String get settingsFaqA4 =>
      'سلفلي تعزز التبادل القائم على الثقة. حاليًا ينبغي للمستخدمين مناقشة الشروط قبل الاستعارة. سنضيف خطط حماية اختيارية وأنظمة تحقق في التحديثات القادمة.';

  @override
  String get settingsFaqQ5 => 'هل يمكنني إلغاء الطلب بعد إرساله؟';

  @override
  String get settingsFaqA5 =>
      'نعم، يمكن إلغاء الطلبات ما لم يتم قبولها من المالك. بعد القبول، ينبغي للطرفين التواصل مباشرة للاتفاق على أي تغيير.';

  @override
  String get settingsFaqQ6 => 'هل يتم الدفع داخل التطبيق؟';

  @override
  String get settingsFaqA6 =>
      'في الإصدارات الأولى، يتم الدفع والإرجاع يدويًا بين المستخدمين. سنضيف نظام دفع آمن داخل التطبيق في التحديثات المستقبلية.';

  @override
  String get settingsFaqQ7 => 'كيف أتواصل مع فريق سلفلي؟';

  @override
  String get settingsFaqA7 =>
      'يمكنك الوصول إلينا من قسم \"اتصل بالدعم\" أدناه.';

  @override
  String get settingsContactTitle => 'اتصل بالدعم';

  @override
  String get settingsContactDesc =>
      '📧 البريد: support@sellefli.com\n\n🌐 الموقع: www.sellefli.dz\n\nإذا واجهت أي مشكلة أو رغبت في مشاركة ملاحظاتك، راسلنا عبر البريد أو وسائل التواصل. نرد خلال 24–48 ساعة.';

  @override
  String get settingsLegalTitle => 'القانون والمجتمع';

  @override
  String get settingsCommunityTitle => 'إرشادات المجتمع';

  @override
  String get settingsCommunityDesc =>
      'سلفلي مبنية على الثقة والاحترام. كل مستخدم يساهم في بيئة آمنة وودية.';

  @override
  String get settingsCommunityBullet1 => 'كن محترمًا وموثوقًا.';

  @override
  String get settingsCommunityBullet2 => 'تواصل بوضوح.';

  @override
  String get settingsCommunityBullet3 => 'تجنب الإلغاءات في اللحظة الأخيرة.';

  @override
  String get settingsCommunityBullet4 =>
      'حافظ على نظافة العناصر وحالتها الجيدة.';

  @override
  String get settingsTermsTitle => 'الشروط والأحكام';

  @override
  String get settingsTermsIntro => 'باستخدام سلفلي، أنت توافق على:';

  @override
  String get settingsTermsBullet1 =>
      'شارك فقط العناصر التي تملكها أو لديك الحق في إعارتها.';

  @override
  String get settingsTermsBullet2 =>
      'عامل العناصر المستعارة بعناية وأعدها في الوقت المحدد.';

  @override
  String get settingsTermsBullet3 =>
      'تواصل بصدق واحترام مع المستخدمين الآخرين.';

  @override
  String get settingsTermsBullet4 =>
      'تجنب العناصر المحظورة أو غير الآمنة أو غير القانونية.';

  @override
  String get settingsTermsBullet5 =>
      'أبلغ عن أي سلوك مريب أو غير لائق لفريق الدعم.';

  @override
  String get settingsTermsOutro =>
      'سلفلي غير مسؤولة عن العناصر المفقودة أو التالفة لكنها توفر إرشادات وأدوات لمساعدة المستخدمين على حل المشكلات بمسؤولية. ستتوفر الشروط الكاملة عند الإطلاق على الموقع الرسمي.';

  @override
  String get settingsPrivacyTitle => 'سياسة الخصوصية';

  @override
  String get settingsPrivacyDesc =>
      'سلفلي تحترم خصوصيتك كما هو موضح في سياستنا الكاملة المتاحة على الموقع الرسمي.';

  @override
  String get settingsFooter =>
      'إصدار التطبيق 1.0.0 (بيتا)\n© 2025 سلفلي. جميع الحقوق محفوظة.';

  @override
  String get landingTagline => 'استعر من القريب · وشارك ببساطة';

  @override
  String get landingGetStarted => 'ابدأ الآن';

  @override
  String get landingSignIn => 'تسجيل الدخول';

  @override
  String get landingTerms => 'الشروط والأحكام';

  @override
  String get landingFeatureBrowseTitle => 'تصفح العناصر القريبة';

  @override
  String get landingFeatureBrowseDescription =>
      'اكتشف مجموعة واسعة من الأدوات والمعدات والعناصر المميزة المتاحة للإيجار في حيك.';

  @override
  String get landingFeatureLendTitle => 'إعارة بدون مجهود';

  @override
  String get landingFeatureLendDescription =>
      'أضف العناصر التي لا تستخدمها في دقائق واربح بينما تساهم في اقتصاد محلي مستدام.';

  @override
  String get landingFeatureConnectTitle => 'التواصل مع الجيران';

  @override
  String get landingFeatureConnectDescription =>
      'ابنِ الثقة وعزز الروابط المحلية من خلال تقاسم الموارد والتعاملات الودية.';

  @override
  String get authSignupSuccess => 'تم إنشاء الحساب بنجاح! مرحبًا بك في سلفلي.';

  @override
  String get authLoginSuccess => 'مرحبًا بعودتك! تم تسجيل الدخول بنجاح.';

  @override
  String get authEmailLabel => 'البريد الإلكتروني';

  @override
  String get authEmailHint => 'example@email.com';

  @override
  String get authPasswordLabel => 'كلمة المرور';

  @override
  String get authPasswordHint => 'أدخل كلمة المرور';

  @override
  String get authFullNameLabel => 'الاسم الكامل';

  @override
  String get authFullNameHint => 'محمد أحمد';

  @override
  String get authPhoneLabel => 'رقم الهاتف';

  @override
  String get authPhoneHint => '05 12 34 56 78';

  @override
  String get authForgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get authLoginButton => 'تسجيل الدخول';

  @override
  String get authNoAccount => 'ليس لديك حساب؟';

  @override
  String get authRegister => 'إنشاء حساب';

  @override
  String get authLoginTitle => 'مرحبًا مجددًا!';

  @override
  String get authLoginSubtitle => 'الرجاء تسجيل الدخول للمتابعة';

  @override
  String get authSignupTitle => 'أنشئ حسابًا';

  @override
  String get authSignupSubtitle => 'انضم إلينا اليوم';

  @override
  String get authAlreadyAccount => 'لديك حساب بالفعل؟';

  @override
  String get authRememberPassword => 'هل تتذكر كلمة المرور؟';

  @override
  String get authSendResetLink => 'إرسال رابط إعادة التعيين';

  @override
  String get authOr => 'أو';

  @override
  String get authResetTitle => 'إعادة تعيين كلمة المرور';

  @override
  String get authResetSubtitle =>
      'أدخل بريدك الإلكتروني لتلقي\nرابط إعادة التعيين';

  @override
  String get validateFullNameEmpty => 'يرجى إدخال الاسم الكامل';

  @override
  String get validateFullNameMin => 'يجب أن يكون الاسم 3 أحرف على الأقل';

  @override
  String get validateFullNameMax => 'يجب ألا يتجاوز الاسم 50 حرفاً';

  @override
  String get validateFullNameChars =>
      'يمكن أن يحتوي الاسم فقط على أحرف ومسافات وشرطات وأبوسروفات';

  @override
  String get validatePhoneEmpty => 'يرجى إدخال رقم الهاتف';

  @override
  String get validatePhoneDigits => 'رقم الهاتف يمكن أن يحتوي على أرقام فقط';

  @override
  String get validatePhoneMin =>
      'يجب أن يحتوي رقم الهاتف على 8 أرقام على الأقل';

  @override
  String get validateEmailEmpty => 'يرجى إدخال البريد الإلكتروني';

  @override
  String get validateEmailInvalid => 'يرجى إدخال بريد إلكتروني صالح';

  @override
  String get validatePasswordEmpty => 'يرجى إدخال كلمة المرور';

  @override
  String get validatePasswordNoSpaces => 'المسافات غير مسموحة';

  @override
  String get validatePasswordMin => 'مطلوب 8 أحرف على الأقل';

  @override
  String get validatePasswordUpper => 'أضف حرفاً كبيراً واحداً على الأقل';

  @override
  String get validatePasswordLower => 'أضف حرفاً صغيراً واحداً على الأقل';

  @override
  String get validatePasswordNumber => 'أضف رقماً واحداً على الأقل';

  @override
  String get validatePasswordSpecial => 'أضف رمزاً خاصاً واحداً على الأقل';

  @override
  String get validateLoginPasswordEmpty => 'يرجى إدخال كلمة المرور';

  @override
  String get homeExploreTitle => 'استكشف';

  @override
  String get homeError => 'خطأ في تحميل العناصر';

  @override
  String get homeEmpty => 'لا توجد عناصر';

  @override
  String get homeOfflineTitle => 'أنت غير متصل حالياً';

  @override
  String get homeOfflineSubtitle => 'اتصل بالإنترنت لرؤية المزيد من العناصر';

  @override
  String get homeLocationPlaceholder => 'الموقع';

  @override
  String distanceKm(Object distance) {
    return '$distance كم';
  }

  @override
  String get homeRadiusLabel => 'نطاق';

  @override
  String get homeSearchHint => 'ابحث عن عناصر...';

  @override
  String get homeUseLocation => 'استخدم موقعي';

  @override
  String get categoryAll => 'الكل';

  @override
  String get categoryElectronicsTech => 'الإلكترونيات والتقنية';

  @override
  String get categoryHomeAppliances => 'المنزل والأجهزة';

  @override
  String get categoryFurnitureDecor => 'الأثاث والديكور';

  @override
  String get categoryToolsEquipment => 'الأدوات والمعدات';

  @override
  String get categoryVehiclesMobility => 'المركبات والتنقل';

  @override
  String get categorySportsOutdoors => 'الرياضة والهواء الطلق';

  @override
  String get categoryBooksStudy => 'الكتب والدراسة';

  @override
  String get categoryFashionAccessories => 'الموضة والإكسسوارات';

  @override
  String get categoryEventsCelebrations => 'الفعاليات والمناسبات';

  @override
  String get categoryBabyKids => 'الأطفال والرضع';

  @override
  String get categoryHealthPersonal => 'الصحة والعناية الشخصية';

  @override
  String get categoryMusicalInstruments => 'الآلات الموسيقية';

  @override
  String get categoryHobbiesCrafts => 'الهوايات والحرف';

  @override
  String get categoryPetSupplies => 'مستلزمات الحيوانات';

  @override
  String get categoryOther => 'عناصر أخرى';

  @override
  String get itemCreateTitle => 'إنشاء عنصر';

  @override
  String get itemEditTitle => 'تعديل العنصر';

  @override
  String get itemPhotos => 'صور العنصر';

  @override
  String get itemGallery => 'المعرض';

  @override
  String get itemCamera => 'الكاميرا';

  @override
  String itemImageLimit(Object max) {
    return 'يمكنك رفع ما يصل إلى $max صور.';
  }

  @override
  String get itemImageRequired => 'يجب إضافة صورة واحدة على الأقل.';

  @override
  String get itemTitleLabel => 'العنوان';

  @override
  String get itemTitleHint => 'مثال: مثقاب كهربائي، دراجة';

  @override
  String get itemCategoryLabel => 'الفئة';

  @override
  String get itemDescriptionLabel => 'الوصف';

  @override
  String get itemDescriptionHint => 'صف العنصر بالتفصيل...';

  @override
  String get itemValuePerDayLabel => 'القيمة التقديرية في اليوم';

  @override
  String get itemValueLabel => 'القيمة التقديرية';

  @override
  String get itemValueHint => 'مثال: 150 دج';

  @override
  String get itemDepositLabel => 'مبلغ التأمين';

  @override
  String get itemDepositHint => 'مثال: 50 دج (قابل للاسترداد)';

  @override
  String get itemAvailableFrom => 'متاح من';

  @override
  String get itemAvailableUntil => 'متاح حتى';

  @override
  String get itemDateHint => 'يوم/شهر/سنة';

  @override
  String get itemLocationLabel => 'الموقع';

  @override
  String get itemLocationHint => 'اختر من الخريطة';

  @override
  String get itemLocationRequired => 'الموقع مطلوب.';

  @override
  String get itemPublishButton => 'نشر العنصر';

  @override
  String get itemEditButton => 'تعديل العنصر';

  @override
  String get itemCreateSuccess => 'تم نشر العنصر بنجاح.';

  @override
  String itemCreateError(Object error) {
    return 'خطأ: تعذر نشر العنصر. $error';
  }

  @override
  String get itemEditSuccess => 'تم تحديث العنصر بنجاح.';

  @override
  String get itemLoadError => 'لم يتم تحميل العنصر بعد.';

  @override
  String get itemSignInRequired => 'يجب تسجيل الدخول لإنشاء العناصر.';

  @override
  String get itemRequiredField => 'إلزامي';

  @override
  String get itemDetailsTitle => 'تفاصيل العنصر';

  @override
  String get itemDetailsNoId => 'خطأ: لم يتم تقديم معرف العنصر';

  @override
  String get itemDetailsGoBack => 'عودة';

  @override
  String get itemDetailsNoDescription => 'لا يوجد وصف';

  @override
  String get itemDetailsCategory => 'الفئة';

  @override
  String get itemDetailsValue => 'قيمة العنصر';

  @override
  String get itemDetailsDeposit => 'مبلغ التأمين';

  @override
  String get itemDetailsAvailableFrom => 'متاح من';

  @override
  String get itemDetailsAvailableUntil => 'متاح حتى';

  @override
  String get itemDetailsStatus => 'الحالة';

  @override
  String get itemStatusAvailable => 'متاح';

  @override
  String get itemStatusUnavailable => 'غير متاح';

  @override
  String get itemDetailsOwner => 'المالك';

  @override
  String itemDetailsOwnerReviews(Object count) {
    return '($count تقييم)';
  }

  @override
  String get itemDetailsDepositNote =>
      'يرجى الرجوع إلى سياسة التأمين لمزيد من المعلومات حول الإيجار والإرجاع.';

  @override
  String get itemDetailsBookNow => 'احجز الآن';

  @override
  String get itemDetailsNotAvailable => 'غير متاح';

  @override
  String get bookingDialogTitle => 'تفاصيل الحجز';

  @override
  String get bookingDialogStartDate => 'تاريخ البدء';

  @override
  String get bookingDialogEndDate => 'تاريخ الانتهاء';

  @override
  String get bookingDialogTotalCost => 'التكلفة الإجمالية';

  @override
  String get bookingDialogDays => 'الأيام';

  @override
  String get bookingDialogSelectDate => 'اختر تاريخًا';

  @override
  String get bookingDialogCancel => 'إلغاء';

  @override
  String get bookingDialogConfirm => 'تأكيد';

  @override
  String bookingDialogSuccess(Object days) {
    return 'تم تأكيد الحجز لمدة $days يومًا!';
  }

  @override
  String bookingDialogFail(Object error) {
    return 'فشل إنشاء الحجز: $error';
  }

  @override
  String get bookingDialogAuthRequired => 'المستخدم غير مصدق';

  @override
  String get requestsTitle => 'الطلبات والطلبيات';

  @override
  String get requestsIncomingTab => 'الواردة';

  @override
  String get requestsMyRequestsTab => 'طلباتي';

  @override
  String requestsError(Object error) {
    return 'خطأ: $error';
  }

  @override
  String get requestsNoIncoming => 'لا توجد طلبات واردة';

  @override
  String get requestsNoSent => 'لا توجد طلبات مرسلة';

  @override
  String requestsFromSender(Object sender) {
    return 'من $sender';
  }

  @override
  String get requestsAccept => 'قبول';

  @override
  String get requestsDecline => 'رفض';

  @override
  String get bookingDetailsTitle => 'تفاصيل الحجز';

  @override
  String bookingDetailsError(Object error) {
    return 'خطأ: $error';
  }

  @override
  String get bookingDetailsNoData => 'لا توجد بيانات حجز';

  @override
  String get bookingSummaryTitle => 'ملخص العنصر والحجز';

  @override
  String bookingBorrowedBy(Object user) {
    return 'مستعار من: $user';
  }

  @override
  String get bookingTotalCostLabel => 'التكلفة الإجمالية:';

  @override
  String get bookingDepositLabel => 'التأمين:';

  @override
  String get bookingStatusLabel => 'حالة الحجز';

  @override
  String get bookingCodeLabel => 'رمز الحجز:';

  @override
  String get bookingOwnerActions => 'إجراءات المالك';

  @override
  String get bookingOwnerInformation => 'معلومات المالك';

  @override
  String get bookingUnknownOwner => 'مالك غير معروف';

  @override
  String get bookingMarkDepositReceived => 'تحديد التأمين كمستلم';

  @override
  String get bookingMarkDepositReturned => 'تحديد التأمين كمُعاد';

  @override
  String get bookingKeepDeposit => 'الاحتفاظ بالتأمين';

  @override
  String get bookingAlreadyRated => 'لقد قمت بتقييم هذا الحجز مسبقًا';

  @override
  String get bookingRateExperience => 'قيّم تجربتك';

  @override
  String get bookingRateQuestion => 'كيف كانت تجربتك مع هذا المستخدم؟';

  @override
  String get bookingCancel => 'إلغاء';

  @override
  String get bookingSubmit => 'إرسال';

  @override
  String get bookingDaysLabel => 'الأيام';

  @override
  String bookingTotalCostValue(Object amount) {
    return 'دج $amount';
  }

  @override
  String get statusPending => 'قيد الانتظار';

  @override
  String get statusAccepted => 'مقبول';

  @override
  String get statusDeclined => 'مرفوض';

  @override
  String get statusActive => 'نشط';

  @override
  String get statusCompleted => 'مكتمل';

  @override
  String get statusClosed => 'مغلق';

  @override
  String get depositStatusNone => 'لا شيء';

  @override
  String get depositStatusReceived => 'تم الاستلام';

  @override
  String get depositStatusReturned => 'تم الإرجاع';

  @override
  String get depositStatusKept => 'تم الاحتفاظ به';

  @override
  String get mapTitle => 'الخريطة';

  @override
  String get mapServicesDisabled => 'خدمات الموقع معطلة.';

  @override
  String get mapPermissionDenied => 'تم رفض إذن الموقع.';

  @override
  String get mapPermissionDeniedForever => 'تم رفض إذن الموقع بشكل دائم.';

  @override
  String get mapCurrentLocationSet => 'تم تعيين الموقع على موقعك الحالي!';

  @override
  String get mapLocationFailed => 'فشل الحصول على الموقع. حاول مرة أخرى.';

  @override
  String get mapLocalizeCurrent => 'تحديد موقعي الحالي';

  @override
  String get mapConfirmLocation => 'تأكيد الموقع';

  @override
  String get myListingsTitle => 'قوائم عروضى';

  @override
  String get myListingsNoItems => 'لا توجد عروض بعد';

  @override
  String get myListingsOffline => '(وضع عدم الاتصال)';

  @override
  String get myListingsOfflineBanner =>
      '📡 وضع عدم الاتصال - عرض القوائم المحفوظة';

  @override
  String get myListingsStatusActive => 'نشط';

  @override
  String get myListingsStatusRented => 'مؤجَّر';

  @override
  String get myListingsStatusPending => 'بانتظار الموافقة';

  @override
  String get myListingsStatusUnavailable => 'غير متاح';

  @override
  String get myListingsEdit => 'تعديل';

  @override
  String get myListingsView => 'عرض';
}
