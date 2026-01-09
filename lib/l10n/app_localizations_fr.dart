// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Sellefli';

  @override
  String get profileTitle => 'Profile';

  @override
  String get retry => 'Réessayer';

  @override
  String get editProfile => 'Modifier le profile';

  @override
  String get settingsHelp => 'Paramètres / Aide';

  @override
  String get logout => 'Se déconnecter';

  @override
  String get recentTransactions => 'Transactions récentes';

  @override
  String get noRecentTransactions => 'Aucune transaction récente';

  @override
  String get unknownItem => 'Article inconnu';

  @override
  String get borrowedStatus => 'Emprunté';

  @override
  String get lentStatus => 'Prêté';

  @override
  String get noRatingsYet => 'Aucune évaluation';

  @override
  String get userFallback => 'Utilisateur';

  @override
  String currencyDa(Object amount) {
    return 'DA $amount';
  }

  @override
  String get language => 'Langue';

  @override
  String get languageEnglish => 'Anglais';

  @override
  String get languageArabic => 'Arabe';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageDialogTitle => 'Choisissez la langue';

  @override
  String get navHome => 'Accueil';

  @override
  String get navRequests => 'Demandes';

  @override
  String get navListings => 'Mes listes';

  @override
  String get navProfile => 'Profile';

  @override
  String get editProfileSuccess => 'Profile mis à jour avec succès.';

  @override
  String editProfileImagePickFail(Object error) {
    return 'Échec de la sélection de l\'image : $error';
  }

  @override
  String get editProfileFullName => 'Nom complet';

  @override
  String get editProfilePhoneNumber => 'Numéro de téléphone';

  @override
  String get editProfileSave => 'Enregistrer les modifications';

  @override
  String editProfileFieldRequired(Object field) {
    return 'Veuillez saisir votre $field';
  }

  @override
  String get settingsAboutUs => 'À propos de nous';

  @override
  String get settingsAboutSellefliTitle => 'À propos de Sellefli';

  @override
  String get settingsAboutSellefliDesc =>
      'Sellefli est une plateforme communautaire qui aide les voisins et les étudiants à louer ou emprunter des objets du quotidien auprès de personnes à proximité. Au lieu d\'acheter du neuf, vous pouvez partager ce que vous possédez déjà et gagner de l\'argent tout en aidant les autres. Sellefli rend les échanges locaux simples, sûrs et fiables.';

  @override
  String get settingsMissionTitle => 'Notre mission';

  @override
  String get settingsMissionDesc =>
      'Notre mission est de faire du partage un réflexe quotidien. Sellefli aide chacun à économiser, réduire le gaspillage et renforcer les liens communautaires via un réseau de location local de confiance.';

  @override
  String get settingsHowTitle => 'Comment ça marche';

  @override
  String get settingsHowBrowseTitle => 'Parcourir :';

  @override
  String get settingsHowBrowseDesc =>
      'Découvrez les articles disponibles près de chez vous — des outils et électroniques aux livres et objets du quotidien.';

  @override
  String get settingsHowRequestTitle => 'Demander :';

  @override
  String get settingsHowRequestDesc =>
      'Choisissez ce dont vous avez besoin et envoyez une demande de réservation avec vos dates.';

  @override
  String get settingsHowConfirmTitle => 'Confirmer :';

  @override
  String get settingsHowConfirmDesc =>
      'Le propriétaire examine et approuve votre demande.';

  @override
  String get settingsHowMeetTitle => 'Rencontrer & Échanger :';

  @override
  String get settingsHowMeetDesc =>
      'Fixez un point de rencontre sûr pour emprunter ou louer l\'article.';

  @override
  String get settingsHowReturnTitle => 'Retourner :';

  @override
  String get settingsHowReturnDesc =>
      'Rendez l\'article à temps et évaluez votre expérience pour renforcer la confiance.';

  @override
  String get settingsSupportTitle => 'Support';

  @override
  String get settingsFaqTitle => 'FAQ';

  @override
  String get settingsFaqQ1 => 'Sellefli est-il gratuit à utiliser ?';

  @override
  String get settingsFaqA1 =>
      'Oui, la création de compte et la navigation sont entièrement gratuites. Des options premium facultatives pour les utilisateurs réguliers pourront être ajoutées plus tard.';

  @override
  String get settingsFaqQ2 => 'Quels types d\'articles peuvent être listés ?';

  @override
  String get settingsFaqA2 =>
      'Des objets personnels du quotidien comme outils, livres, jeux, matériel de sport, électronique, petit mobilier et autres objets sûrs non interdits.';

  @override
  String get settingsFaqQ3 => 'Comment savoir si un utilisateur est fiable ?';

  @override
  String get settingsFaqA3 =>
      'Chaque profile contient des avis d\'échanges passés. Nous encourageons aussi la communication avant de confirmer une demande.';

  @override
  String get settingsFaqQ4 =>
      'Que se passe-t-il si un objet est endommagé ou perdu ?';

  @override
  String get settingsFaqA4 =>
      'Sellefli repose sur la confiance. Pour l\'instant, discutez des conditions avant l\'emprunt. Des plans de protection optionnels et des systèmes d\'utilisateurs vérifiés arriveront dans de prochaines mises à jour.';

  @override
  String get settingsFaqQ5 =>
      'Puis-je annuler une demande après l\'avoir envoyée ?';

  @override
  String get settingsFaqA5 =>
      'Oui, tant que la demande n\'a pas été acceptée par le propriétaire. Une fois acceptée, discutez directement ensemble pour convenir de changements.';

  @override
  String get settingsFaqQ6 => 'Le paiement se fait-il dans l\'application ?';

  @override
  String get settingsFaqA6 =>
      'Dans les premières versions, les paiements et retours sont gérés manuellement entre utilisateurs. Un système de paiement sécurisé in-app sera ajouté ultérieurement.';

  @override
  String get settingsFaqQ7 => 'Comment contacter l\'équipe Sellefli ?';

  @override
  String get settingsFaqA7 =>
      'Contactez-nous via la section \"Contact Support\" ci-dessous.';

  @override
  String get settingsContactTitle => 'Contact & Support';

  @override
  String get settingsContactDesc =>
      '📧 Email : support@sellefli.com\n\n🌐 Site : www.sellefli.dz\n\nSi vous rencontrez un problème ou souhaitez partager un retour, écrivez-nous par email ou sur les réseaux. Nous répondons sous 24–48h.';

  @override
  String get settingsLegalTitle => 'Légal & Communauté';

  @override
  String get settingsCommunityTitle => 'Règles de la communauté';

  @override
  String get settingsCommunityDesc =>
      'Sellefli est fondé sur la confiance et le respect. Chaque utilisateur contribue à un environnement sûr et bienveillant.';

  @override
  String get settingsCommunityBullet1 => 'Soyez respectueux et fiable.';

  @override
  String get settingsCommunityBullet2 => 'Communiquez clairement.';

  @override
  String get settingsCommunityBullet3 =>
      'Évitez les annulations de dernière minute.';

  @override
  String get settingsCommunityBullet4 =>
      'Gardez vos articles propres et en bon état.';

  @override
  String get settingsTermsTitle => 'Conditions générales';

  @override
  String get settingsTermsIntro => 'En utilisant Sellefli, vous acceptez de :';

  @override
  String get settingsTermsBullet1 =>
      'Partager uniquement les objets que vous possédez ou avez le droit de prêter.';

  @override
  String get settingsTermsBullet2 =>
      'Prendre soin des objets empruntés et les rendre à temps.';

  @override
  String get settingsTermsBullet3 =>
      'Communiquer honnêtement et respectueusement avec les autres utilisateurs.';

  @override
  String get settingsTermsBullet4 =>
      'Éviter les objets interdits, dangereux ou illégaux.';

  @override
  String get settingsTermsBullet5 =>
      'Signaler tout comportement suspect ou inapproprié à l\'équipe support.';

  @override
  String get settingsTermsOutro =>
      'Sellefli n\'est pas responsable des objets perdus ou endommagés mais fournit des conseils et outils pour aider à résoudre les problèmes de manière responsable. Les CG complètes seront disponibles au lancement sur le site officiel.';

  @override
  String get settingsPrivacyTitle => 'Politique de confidentialité';

  @override
  String get settingsPrivacyDesc =>
      'Sellefli respecte votre vie privée comme décrit dans notre politique complète, disponible sur le site officiel.';

  @override
  String get settingsFooter =>
      'Version de l\'app 1.0.0 (Beta)\n© 2025 Sellefli. Tous droits réservés.';

  @override
  String get landingTagline =>
      'Empruntez près de chez vous · Partagez simplement';

  @override
  String get landingGetStarted => 'Commencer';

  @override
  String get landingSignIn => 'Se connecter';

  @override
  String get landingTerms => 'Conditions générales';

  @override
  String get landingFeatureBrowseTitle => 'Parcourir les articles locaux';

  @override
  String get landingFeatureBrowseDescription =>
      'Découvrez une large sélection d\'outils, d\'équipements et d\'objets uniques à louer dans votre quartier.';

  @override
  String get landingFeatureLendTitle => 'Prêt simplifié';

  @override
  String get landingFeatureLendDescription =>
      'Publiez vos objets inutilisés en quelques minutes et gagnez tout en contribuant à une économie locale durable.';

  @override
  String get landingFeatureConnectTitle => 'Connectez-vous avec vos voisins';

  @override
  String get landingFeatureConnectDescription =>
      'Créez la confiance et renforcez les liens locaux grâce au partage de ressources et aux échanges conviviaux.';

  @override
  String get authSignupSuccess =>
      'Compte créé avec succès ! Bienvenue sur Sellefli.';

  @override
  String get authLoginSuccess => 'Ravi de vous revoir ! Connexion réussie.';

  @override
  String get authEmailLabel => 'E-mail';

  @override
  String get authEmailHint => 'example@email.com';

  @override
  String get authPasswordLabel => 'Mot de passe';

  @override
  String get authPasswordHint => 'Entrez votre mot de passe';

  @override
  String get authFullNameLabel => 'Nom complet';

  @override
  String get authFullNameHint => 'Mohamed Ahmed';

  @override
  String get authPhoneLabel => 'Numéro de téléphone';

  @override
  String get authPhoneHint => '05 12 34 56 78';

  @override
  String get authForgotPassword => 'Mot de passe oublié ?';

  @override
  String get authLoginButton => 'Se connecter';

  @override
  String get authNoAccount => 'Pas encore de compte ?';

  @override
  String get authRegister => 'S\'inscrire';

  @override
  String get authLoginTitle => 'Bon retour !';

  @override
  String get authLoginSubtitle => 'Veuillez vous connecter pour continuer';

  @override
  String get authSignupTitle => 'Créer un compte';

  @override
  String get authSignupSubtitle => 'Rejoignez-nous dès aujourd\'hui';

  @override
  String get authAlreadyAccount => 'Vous avez déjà un compte ?';

  @override
  String get authRememberPassword =>
      'Vous vous souvenez de votre mot de passe ?';

  @override
  String get authSendResetLink => 'Envoyer le lien de réinitialisation';

  @override
  String get authOr => 'OU';

  @override
  String get authResetTitle => 'Réinitialiser le mot de passe';

  @override
  String get authResetSubtitle =>
      'Saisissez votre email pour recevoir\nun lien de réinitialisation';

  @override
  String get validateFullNameEmpty => 'Veuillez entrer votre nom complet';

  @override
  String get validateFullNameMin =>
      'Le nom doit comporter au moins 3 caractères';

  @override
  String get validateFullNameMax => 'Le nom ne doit pas dépasser 50 caractères';

  @override
  String get validateFullNameChars =>
      'Le nom ne peut contenir que des lettres, espaces, tirets et apostrophes';

  @override
  String get validatePhoneEmpty => 'Veuillez saisir votre numéro de téléphone';

  @override
  String get validatePhoneDigits =>
      'Le numéro de téléphone ne peut contenir que des chiffres';

  @override
  String get validatePhoneMin =>
      'Le numéro de téléphone doit comporter au moins 8 chiffres';

  @override
  String get validateEmailEmpty => 'Veuillez saisir votre e-mail';

  @override
  String get validateEmailInvalid =>
      'Veuillez saisir une adresse e-mail valide';

  @override
  String get validatePasswordEmpty => 'Veuillez saisir votre mot de passe';

  @override
  String get validatePasswordNoSpaces => 'Aucun espace autorisé';

  @override
  String get validatePasswordMin => 'Minimum 8 caractères requis';

  @override
  String get validatePasswordUpper => 'Ajoutez au moins 1 lettre majuscule';

  @override
  String get validatePasswordLower => 'Ajoutez au moins 1 lettre minuscule';

  @override
  String get validatePasswordNumber => 'Ajoutez au moins 1 chiffre';

  @override
  String get validatePasswordSpecial => 'Ajoutez au moins 1 caractère spécial';

  @override
  String get validateLoginPasswordEmpty => 'Veuillez saisir votre mot de passe';

  @override
  String get homeExploreTitle => 'Explorer';

  @override
  String get homeError => 'Erreur lors du chargement des articles';

  @override
  String get homeEmpty => 'Aucun article trouvé';

  @override
  String get homeOfflineTitle => 'Vous êtes actuellement hors ligne';

  @override
  String get homeOfflineSubtitle =>
      'Connectez-vous à internet pour voir plus d\'articles';

  @override
  String get homeLocationPlaceholder => 'Localisation';

  @override
  String distanceKm(Object distance) {
    return '$distance km';
  }

  @override
  String get homeRadiusLabel => 'Rayon';

  @override
  String get homeSearchHint => 'Rechercher des articles...';

  @override
  String get homeUseLocation => 'Utiliser ma position';

  @override
  String get categoryAll => 'Tous';

  @override
  String get categoryElectronicsTech => 'Électronique & Tech';

  @override
  String get categoryHomeAppliances => 'Maison & Électroménager';

  @override
  String get categoryFurnitureDecor => 'Meubles & Décoration';

  @override
  String get categoryToolsEquipment => 'Outils & Équipements';

  @override
  String get categoryVehiclesMobility => 'Véhicules & Mobilité';

  @override
  String get categorySportsOutdoors => 'Sports & Plein air';

  @override
  String get categoryBooksStudy => 'Livres & Études';

  @override
  String get categoryFashionAccessories => 'Mode & Accessoires';

  @override
  String get categoryEventsCelebrations => 'Événements & Célébrations';

  @override
  String get categoryBabyKids => 'Bébé & Enfants';

  @override
  String get categoryHealthPersonal => 'Santé & Soins personnels';

  @override
  String get categoryMusicalInstruments => 'Instruments de musique';

  @override
  String get categoryHobbiesCrafts => 'Loisirs & Artisanat';

  @override
  String get categoryPetSupplies => 'Fournitures pour animaux';

  @override
  String get categoryOther => 'Autres articles';

  @override
  String get itemCreateTitle => 'Créer un article';

  @override
  String get itemEditTitle => 'Modifier l\'article';

  @override
  String get itemPhotos => 'Photos de l\'article';

  @override
  String get itemGallery => 'Galerie';

  @override
  String get itemCamera => 'Appareil photo';

  @override
  String itemImageLimit(Object max) {
    return 'Vous pouvez télécharger jusqu\'à $max images.';
  }

  @override
  String get itemImageRequired => 'Au moins une photo est requise.';

  @override
  String get itemTitleLabel => 'Titre';

  @override
  String get itemTitleHint => 'ex. Perceuse électrique, Vélo';

  @override
  String get itemCategoryLabel => 'Catégorie';

  @override
  String get itemDescriptionLabel => 'Description';

  @override
  String get itemDescriptionHint => 'Décrivez votre article en détail...';

  @override
  String get itemValuePerDayLabel => 'Valeur estimée par jour';

  @override
  String get itemValueLabel => 'Valeur estimée';

  @override
  String get itemValueHint => 'ex. 150 DA';

  @override
  String get itemDepositLabel => 'Dépôt requis';

  @override
  String get itemDepositHint => 'ex. 50 DA (remboursable)';

  @override
  String get itemAvailableFrom => 'Disponible à partir du';

  @override
  String get itemAvailableUntil => 'Disponible jusqu\'au';

  @override
  String get itemDateHint => 'JJ/MM/AAAA';

  @override
  String get itemLocationLabel => 'Localisation';

  @override
  String get itemLocationHint => 'Choisir sur la carte';

  @override
  String get itemLocationRequired => 'La localisation est requise.';

  @override
  String get itemPublishButton => 'Publier l\'article';

  @override
  String get itemEditButton => 'Modifier l\'article';

  @override
  String get itemCreateSuccess => 'Article publié avec succès.';

  @override
  String itemCreateError(Object error) {
    return 'Erreur : l\'article n\'a pas pu être publié. $error';
  }

  @override
  String get itemEditSuccess => 'Article mis à jour avec succès.';

  @override
  String get itemLoadError => 'Article non encore chargé.';

  @override
  String get itemSignInRequired =>
      'Vous devez être connecté pour créer des articles.';

  @override
  String get itemRequiredField => 'Obligatoire';

  @override
  String get itemDetailsTitle => 'Détails de l\'article';

  @override
  String get itemDetailsNoId => 'Erreur : aucun ID d\'article fourni';

  @override
  String get itemDetailsGoBack => 'Retour';

  @override
  String get itemDetailsNoDescription => 'Aucune description disponible';

  @override
  String get itemDetailsCategory => 'Catégorie';

  @override
  String get itemDetailsValue => 'Valeur de l\'article';

  @override
  String get itemDetailsDeposit => 'Dépôt requis';

  @override
  String get itemDetailsAvailableFrom => 'Disponible à partir du';

  @override
  String get itemDetailsAvailableUntil => 'Disponible jusqu\'au';

  @override
  String get itemDetailsStatus => 'Statut';

  @override
  String get itemStatusAvailable => 'Disponible';

  @override
  String get itemStatusUnavailable => 'Indisponible';

  @override
  String get itemDetailsOwner => 'Propriétaire';

  @override
  String itemDetailsOwnerReviews(Object count) {
    return '($count avis)';
  }

  @override
  String get itemDetailsDepositNote =>
      'Veuillez consulter la politique de dépôt pour plus d\'informations sur les locations et retours.';

  @override
  String get itemDetailsBookNow => 'Réserver';

  @override
  String get itemDetailsNotAvailable => 'Indisponible';

  @override
  String get bookingDialogTitle => 'Détails de la réservation';

  @override
  String get bookingDialogStartDate => 'Date de début';

  @override
  String get bookingDialogEndDate => 'Date de fin';

  @override
  String get bookingDialogTotalCost => 'Coût total';

  @override
  String get bookingDialogDays => 'Jours';

  @override
  String get bookingDialogSelectDate => 'Sélectionner une date';

  @override
  String get bookingDialogCancel => 'Annuler';

  @override
  String get bookingDialogConfirm => 'Confirmer';

  @override
  String bookingDialogSuccess(Object days) {
    return 'Réservation confirmée pour $days jours !';
  }

  @override
  String bookingDialogFail(Object error) {
    return 'Impossible de créer la réservation : $error';
  }

  @override
  String get bookingDialogAuthRequired => 'Utilisateur non authentifié';

  @override
  String get requestsTitle => 'Demandes & Commandes';

  @override
  String get requestsIncomingTab => 'Entrantes';

  @override
  String get requestsMyRequestsTab => 'Mes demandes';

  @override
  String requestsError(Object error) {
    return 'Erreur : $error';
  }

  @override
  String get requestsNoIncoming => 'Aucune demande entrante';

  @override
  String get requestsNoSent => 'Aucune demande envoyée';

  @override
  String requestsFromSender(Object sender) {
    return 'De $sender';
  }

  @override
  String get requestsAccept => 'Accepter';

  @override
  String get requestsDecline => 'Refuser';

  @override
  String get bookingDetailsTitle => 'Détails de la réservation';

  @override
  String bookingDetailsError(Object error) {
    return 'Erreur : $error';
  }

  @override
  String get bookingDetailsNoData => 'Aucune donnée de réservation';

  @override
  String get bookingSummaryTitle => 'Résumé de l\'article et de la réservation';

  @override
  String bookingBorrowedBy(Object user) {
    return 'Emprunté par : $user';
  }

  @override
  String get bookingTotalCostLabel => 'Coût total :';

  @override
  String get bookingDepositLabel => 'Dépôt :';

  @override
  String get bookingStatusLabel => 'Statut de la réservation';

  @override
  String get bookingCodeLabel => 'Code de réservation :';

  @override
  String get bookingOwnerActions => 'Actions du propriétaire';

  @override
  String get bookingOwnerInformation => 'Informations sur le propriétaire';

  @override
  String get bookingUnknownOwner => 'Propriétaire inconnu';

  @override
  String get bookingMarkDepositReceived => 'Marquer le dépôt reçu';

  @override
  String get bookingMarkDepositReturned => 'Marquer le dépôt retourné';

  @override
  String get bookingKeepDeposit => 'Conserver le dépôt';

  @override
  String get bookingAlreadyRated => 'Vous avez déjà noté cette réservation';

  @override
  String get bookingRateExperience => 'Notez votre expérience';

  @override
  String get bookingRateQuestion =>
      'Comment s\'est passée votre expérience avec cet utilisateur ?';

  @override
  String get bookingCancel => 'Annuler';

  @override
  String get bookingSubmit => 'Envoyer';

  @override
  String get bookingDaysLabel => 'Jours';

  @override
  String bookingTotalCostValue(Object amount) {
    return 'DA $amount';
  }

  @override
  String get statusPending => 'En attente';

  @override
  String get statusAccepted => 'Acceptée';

  @override
  String get statusDeclined => 'Refusée';

  @override
  String get statusActive => 'Active';

  @override
  String get statusCompleted => 'Terminée';

  @override
  String get statusClosed => 'Clôturée';

  @override
  String get depositStatusNone => 'Aucun';

  @override
  String get depositStatusReceived => 'Reçu';

  @override
  String get depositStatusReturned => 'Retourné';

  @override
  String get depositStatusKept => 'Conservé';

  @override
  String get mapTitle => 'Carte';

  @override
  String get mapServicesDisabled =>
      'Les services de localisation sont désactivés.';

  @override
  String get mapPermissionDenied => 'Autorisation de localisation refusée.';

  @override
  String get mapPermissionDeniedForever =>
      'Autorisation de localisation refusée de façon permanente.';

  @override
  String get mapCurrentLocationSet =>
      'Position définie sur votre localisation actuelle !';

  @override
  String get mapLocationFailed =>
      'Impossible d\'obtenir la localisation. Réessayez.';

  @override
  String get mapLocalizeCurrent => 'Me localiser actuellement';

  @override
  String get mapConfirmLocation => 'Confirmer la localisation';

  @override
  String get myListingsTitle => 'Mes listes';

  @override
  String get myListingsNoItems => 'Aucune liste pour le moment';

  @override
  String get myListingsOffline => '(Mode hors ligne)';

  @override
  String get myListingsOfflineBanner =>
      '📡 Mode hors ligne - Affichage des annonces en cache';

  @override
  String get myListingsStatusActive => 'Active';

  @override
  String get myListingsStatusRented => 'Louée';

  @override
  String get myListingsStatusPending => 'En attente d\'approbation';

  @override
  String get myListingsStatusUnavailable => 'Indisponible';

  @override
  String get myListingsEdit => 'Modifier';

  @override
  String get myListingsView => 'Voir';

  @override
  String get myListingsDelete => 'Supprimer';

  @override
  String get myListingsDeleteConfirmTitle => 'Supprimer l\'annonce';

  @override
  String myListingsDeleteConfirmMessage(Object itemTitle) {
    return 'Êtes-vous sûr de vouloir supprimer \"$itemTitle\"? Cette action ne peut pas être annulée.';
  }

  @override
  String get myListingsDeleteConfirm => 'Supprimer';

  @override
  String get myListingsCancel => 'Annuler';

  @override
  String get myListingsDeleteSuccess => 'Annonce supprimée avec succès';
}
