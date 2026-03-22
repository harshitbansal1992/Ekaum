import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_pa.dart';
import 'app_localizations_te.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('en'),
    Locale('gu'),
    Locale('hi'),
    Locale('pa'),
    Locale('te')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'BSLND'**
  String get appTitle;

  /// No description provided for @namoNarayan.
  ///
  /// In en, this message translates to:
  /// **'NAMO NARAYAN'**
  String get namoNarayan;

  /// No description provided for @devotee.
  ///
  /// In en, this message translates to:
  /// **'Devotee'**
  String get devotee;

  /// No description provided for @quickTools.
  ///
  /// In en, this message translates to:
  /// **'Quick Tools'**
  String get quickTools;

  /// No description provided for @nadiDosh.
  ///
  /// In en, this message translates to:
  /// **'Nadi Dosh'**
  String get nadiDosh;

  /// No description provided for @rahuKaal.
  ///
  /// In en, this message translates to:
  /// **'Rahu Kaal'**
  String get rahuKaal;

  /// No description provided for @avdhan.
  ///
  /// In en, this message translates to:
  /// **'Avdhan'**
  String get avdhan;

  /// No description provided for @samagam.
  ///
  /// In en, this message translates to:
  /// **'Samagam'**
  String get samagam;

  /// No description provided for @events.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get events;

  /// No description provided for @upcomingEvents.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Events'**
  String get upcomingEvents;

  /// No description provided for @viewAllEvents.
  ///
  /// In en, this message translates to:
  /// **'View all events'**
  String get viewAllEvents;

  /// No description provided for @openInMaps.
  ///
  /// In en, this message translates to:
  /// **'Open in Maps'**
  String get openInMaps;

  /// No description provided for @visheshSandesh.
  ///
  /// In en, this message translates to:
  /// **'Vishesh Sandesh'**
  String get visheshSandesh;

  /// No description provided for @readMore.
  ///
  /// In en, this message translates to:
  /// **'Read more'**
  String get readMore;

  /// No description provided for @readLess.
  ///
  /// In en, this message translates to:
  /// **'Read less'**
  String get readLess;

  /// No description provided for @patrika.
  ///
  /// In en, this message translates to:
  /// **'Patrika'**
  String get patrika;

  /// No description provided for @monthlyRead.
  ///
  /// In en, this message translates to:
  /// **'Monthly Read'**
  String get monthlyRead;

  /// No description provided for @poojaItems.
  ///
  /// In en, this message translates to:
  /// **'Pooja Items'**
  String get poojaItems;

  /// No description provided for @shop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get shop;

  /// No description provided for @paath.
  ///
  /// In en, this message translates to:
  /// **'Paath'**
  String get paath;

  /// No description provided for @services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get services;

  /// No description provided for @donation.
  ///
  /// In en, this message translates to:
  /// **'Donation'**
  String get donation;

  /// No description provided for @supportUs.
  ///
  /// In en, this message translates to:
  /// **'Support Us'**
  String get supportUs;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @viewPaathDetails.
  ///
  /// In en, this message translates to:
  /// **'View Paath Details'**
  String get viewPaathDetails;

  /// No description provided for @appTheme.
  ///
  /// In en, this message translates to:
  /// **'App Theme'**
  String get appTheme;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @selectTheme.
  ///
  /// In en, this message translates to:
  /// **'Select Theme'**
  String get selectTheme;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name *'**
  String get fullName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailCannotChange.
  ///
  /// In en, this message translates to:
  /// **'Email cannot be changed'**
  String get emailCannotChange;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @detailsForPaathForms.
  ///
  /// In en, this message translates to:
  /// **'Details for Paath Forms'**
  String get detailsForPaathForms;

  /// No description provided for @saveToPrepopulate.
  ///
  /// In en, this message translates to:
  /// **'Save these to prepopulate when filling paath service forms'**
  String get saveToPrepopulate;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth *'**
  String get dateOfBirth;

  /// No description provided for @timeOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Time of Birth (HH:MM) *'**
  String get timeOfBirth;

  /// No description provided for @timeOfBirthHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 14:30'**
  String get timeOfBirthHint;

  /// No description provided for @placeOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Place of Birth *'**
  String get placeOfBirth;

  /// No description provided for @fathersHusbandsName.
  ///
  /// In en, this message translates to:
  /// **'Father\'s/Husband\'s Name *'**
  String get fathersHusbandsName;

  /// No description provided for @gotra.
  ///
  /// In en, this message translates to:
  /// **'Gotra *'**
  String get gotra;

  /// No description provided for @caste.
  ///
  /// In en, this message translates to:
  /// **'Caste *'**
  String get caste;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @profileUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccess;

  /// No description provided for @failedToUpdate.
  ///
  /// In en, this message translates to:
  /// **'Failed to update'**
  String get failedToUpdate;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @validPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid 10-digit phone number'**
  String get validPhoneNumber;

  /// No description provided for @shreeMykhanaJi.
  ///
  /// In en, this message translates to:
  /// **'Shree Mykhana ji'**
  String get shreeMykhanaJi;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'हिंदी'**
  String get hindi;

  /// No description provided for @punjabi.
  ///
  /// In en, this message translates to:
  /// **'ਪੰਜਾਬੀ'**
  String get punjabi;

  /// No description provided for @telugu.
  ///
  /// In en, this message translates to:
  /// **'తెలుగు'**
  String get telugu;

  /// No description provided for @gujarati.
  ///
  /// In en, this message translates to:
  /// **'ગુજરાતી'**
  String get gujarati;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @goToLogin.
  ///
  /// In en, this message translates to:
  /// **'Go to Login'**
  String get goToLogin;

  /// No description provided for @useDeviceLanguage.
  ///
  /// In en, this message translates to:
  /// **'Use device language'**
  String get useDeviceLanguage;

  /// No description provided for @watchOurYouTube.
  ///
  /// In en, this message translates to:
  /// **'Watch our YouTube Channel'**
  String get watchOurYouTube;

  /// No description provided for @subscribeForContent.
  ///
  /// In en, this message translates to:
  /// **'Subscribe for satsangs, kirtans & more'**
  String get subscribeForContent;

  /// No description provided for @getDailyEkaumPassword.
  ///
  /// In en, this message translates to:
  /// **'Get Daily Ekaum Password'**
  String get getDailyEkaumPassword;

  /// No description provided for @tapToReveal.
  ///
  /// In en, this message translates to:
  /// **'Tap to reveal today\'s mantra'**
  String get tapToReveal;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @loadingDailyPassword.
  ///
  /// In en, this message translates to:
  /// **'Loading today\'s password...'**
  String get loadingDailyPassword;

  /// No description provided for @emailForQueries.
  ///
  /// In en, this message translates to:
  /// **'Email for any queries'**
  String get emailForQueries;

  /// No description provided for @mantraNotes.
  ///
  /// In en, this message translates to:
  /// **'Mantra Notes'**
  String get mantraNotes;

  /// No description provided for @storeMantras.
  ///
  /// In en, this message translates to:
  /// **'Store mantras'**
  String get storeMantras;

  /// No description provided for @noMantraNotesYet.
  ///
  /// In en, this message translates to:
  /// **'No mantra notes yet'**
  String get noMantraNotesYet;

  /// No description provided for @addMantraToStore.
  ///
  /// In en, this message translates to:
  /// **'Add mantras to store and access them anytime'**
  String get addMantraToStore;

  /// No description provided for @addMantraNote.
  ///
  /// In en, this message translates to:
  /// **'Add Mantra Note'**
  String get addMantraNote;

  /// No description provided for @editMantraNote.
  ///
  /// In en, this message translates to:
  /// **'Edit Mantra Note'**
  String get editMantraNote;

  /// No description provided for @addMantra.
  ///
  /// In en, this message translates to:
  /// **'Add Mantra'**
  String get addMantra;

  /// No description provided for @mantraHeading.
  ///
  /// In en, this message translates to:
  /// **'Heading'**
  String get mantraHeading;

  /// No description provided for @mantraHeadingHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Gayatri Mantra'**
  String get mantraHeadingHint;

  /// No description provided for @mantraDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get mantraDescription;

  /// No description provided for @mantraDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Write the mantra or notes here...'**
  String get mantraDescriptionHint;

  /// No description provided for @headingRequired.
  ///
  /// In en, this message translates to:
  /// **'Heading is required'**
  String get headingRequired;

  /// No description provided for @mantraNoteSaved.
  ///
  /// In en, this message translates to:
  /// **'Mantra note saved'**
  String get mantraNoteSaved;

  /// No description provided for @mantraNoteUpdated.
  ///
  /// In en, this message translates to:
  /// **'Mantra note updated'**
  String get mantraNoteUpdated;

  /// No description provided for @mantraNoteDeleted.
  ///
  /// In en, this message translates to:
  /// **'Mantra note deleted'**
  String get mantraNoteDeleted;

  /// No description provided for @deleteMantraNote.
  ///
  /// In en, this message translates to:
  /// **'Delete Mantra Note'**
  String get deleteMantraNote;

  /// No description provided for @deleteMantraNoteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this mantra note?'**
  String get deleteMantraNoteConfirm;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @getNotifications.
  ///
  /// In en, this message translates to:
  /// **'Get Notifications'**
  String get getNotifications;

  /// No description provided for @getNotificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'Get daily reminders for Rahu Kaal and Sandhya Kaal periods'**
  String get getNotificationsDescription;

  /// No description provided for @notifyRahuKaal.
  ///
  /// In en, this message translates to:
  /// **'Rahu Kaal'**
  String get notifyRahuKaal;

  /// No description provided for @notifyRahuKaalDesc.
  ///
  /// In en, this message translates to:
  /// **'Notify at the start of Rahu Kaal (avoid paath during this time)'**
  String get notifyRahuKaalDesc;

  /// No description provided for @notifySandhyaKaal.
  ///
  /// In en, this message translates to:
  /// **'Sandhya Kaal'**
  String get notifySandhyaKaal;

  /// No description provided for @notifySandhyaKaalDesc.
  ///
  /// In en, this message translates to:
  /// **'Notify at the start of Pratah, Madhya and Sayahna Sandhya periods'**
  String get notifySandhyaKaalDesc;

  /// No description provided for @rahuKaalNotificationsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Rahu Kaal notifications enabled'**
  String get rahuKaalNotificationsEnabled;

  /// No description provided for @rahuKaalNotificationsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Rahu Kaal notifications disabled'**
  String get rahuKaalNotificationsDisabled;

  /// No description provided for @sandhyaKaalNotificationsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Sandhya Kaal notifications enabled'**
  String get sandhyaKaalNotificationsEnabled;

  /// No description provided for @sandhyaKaalNotificationsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Sandhya Kaal notifications disabled'**
  String get sandhyaKaalNotificationsDisabled;

  /// No description provided for @hinduCalendar.
  ///
  /// In en, this message translates to:
  /// **'Hindu Calendar'**
  String get hinduCalendar;

  /// No description provided for @todaysPanchang.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Panchang'**
  String get todaysPanchang;

  /// No description provided for @tithi.
  ///
  /// In en, this message translates to:
  /// **'Tithi'**
  String get tithi;

  /// No description provided for @nakshatra.
  ///
  /// In en, this message translates to:
  /// **'Nakshatra'**
  String get nakshatra;

  /// No description provided for @vara.
  ///
  /// In en, this message translates to:
  /// **'Vara'**
  String get vara;

  /// No description provided for @paksha.
  ///
  /// In en, this message translates to:
  /// **'Paksha'**
  String get paksha;

  /// No description provided for @loadingPanchang.
  ///
  /// In en, this message translates to:
  /// **'Loading panchang...'**
  String get loadingPanchang;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search Avdhan, Patrika, Samagam...'**
  String get searchHint;

  /// No description provided for @searchPrompt.
  ///
  /// In en, this message translates to:
  /// **'Search across Avdhan, Patrika, Samagam, Mantra Notes and announcements'**
  String get searchPrompt;

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No results found. Try different keywords.'**
  String get noSearchResults;

  /// No description provided for @videoSatsang.
  ///
  /// In en, this message translates to:
  /// **'Video Satsang'**
  String get videoSatsang;

  /// No description provided for @noVideoSatsangYet.
  ///
  /// In en, this message translates to:
  /// **'No video satsangs available yet'**
  String get noVideoSatsangYet;

  /// No description provided for @myRecurringDonations.
  ///
  /// In en, this message translates to:
  /// **'My Recurring Donations'**
  String get myRecurringDonations;

  /// No description provided for @noRecurringDonations.
  ///
  /// In en, this message translates to:
  /// **'No recurring donations'**
  String get noRecurringDonations;

  /// No description provided for @cancelSubscription.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelSubscription;

  /// No description provided for @recurringDonationCancelled.
  ///
  /// In en, this message translates to:
  /// **'Recurring donation cancelled'**
  String get recurringDonationCancelled;

  /// No description provided for @kundliLite.
  ///
  /// In en, this message translates to:
  /// **'Kundli Lite'**
  String get kundliLite;

  /// No description provided for @kundliLiteDescription.
  ///
  /// In en, this message translates to:
  /// **'A simple birth chart view with Nadi based on your birth details'**
  String get kundliLiteDescription;

  /// No description provided for @addBirthDetailsForKundli.
  ///
  /// In en, this message translates to:
  /// **'Add birth details to view your Kundli'**
  String get addBirthDetailsForKundli;

  /// No description provided for @addBirthDetailsHint.
  ///
  /// In en, this message translates to:
  /// **'Save your date of birth, time of birth, and place of birth in Edit Profile'**
  String get addBirthDetailsHint;

  /// No description provided for @birthDetails.
  ///
  /// In en, this message translates to:
  /// **'Birth Details'**
  String get birthDetails;

  /// No description provided for @nadi.
  ///
  /// In en, this message translates to:
  /// **'Nadi'**
  String get nadi;

  /// No description provided for @nadiKundliHint.
  ///
  /// In en, this message translates to:
  /// **'Nadi is one of the Ashtakoot factors in Vedic astrology, derived from birth time.'**
  String get nadiKundliHint;

  /// No description provided for @socialActivities.
  ///
  /// In en, this message translates to:
  /// **'Social Activities'**
  String get socialActivities;

  /// No description provided for @socialActivitiesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Compassionate initiatives'**
  String get socialActivitiesSubtitle;

  /// No description provided for @charitableHospitals.
  ///
  /// In en, this message translates to:
  /// **'Charitable Hospitals'**
  String get charitableHospitals;

  /// No description provided for @charitableHospitalsDesc.
  ///
  /// In en, this message translates to:
  /// **'Providing free medical care and healing services to those in need through our dedicated healthcare facilities.'**
  String get charitableHospitalsDesc;

  /// No description provided for @langarDistribution.
  ///
  /// In en, this message translates to:
  /// **'Langar Distribution'**
  String get langarDistribution;

  /// No description provided for @langarDistributionDesc.
  ///
  /// In en, this message translates to:
  /// **'Free food distribution to nourish bodies and souls, following the sacred tradition of community service.'**
  String get langarDistributionDesc;

  /// No description provided for @spiritualSamagams.
  ///
  /// In en, this message translates to:
  /// **'Spiritual Samagams'**
  String get spiritualSamagams;

  /// No description provided for @spiritualSamagamsDesc.
  ///
  /// In en, this message translates to:
  /// **'Sacred gatherings and Vedic discourse sessions to deepen spiritual understanding and connection.'**
  String get spiritualSamagamsDesc;

  /// No description provided for @educationalSupport.
  ///
  /// In en, this message translates to:
  /// **'Educational Support'**
  String get educationalSupport;

  /// No description provided for @educationalSupportDesc.
  ///
  /// In en, this message translates to:
  /// **'Educational initiatives and school support programs to empower future generations with knowledge.'**
  String get educationalSupportDesc;

  /// No description provided for @templeDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Temple Development'**
  String get templeDevelopment;

  /// No description provided for @templeDevelopmentDesc.
  ///
  /// In en, this message translates to:
  /// **'Creating sacred spaces and worship centers for community spiritual practice and devotion.'**
  String get templeDevelopmentDesc;

  /// No description provided for @globalOutreach.
  ///
  /// In en, this message translates to:
  /// **'Global Outreach'**
  String get globalOutreach;

  /// No description provided for @globalOutreachDesc.
  ///
  /// In en, this message translates to:
  /// **'Extending our spiritual and charitable work to communities worldwide through the World Humanity Parliament.'**
  String get globalOutreachDesc;

  /// No description provided for @learnMore.
  ///
  /// In en, this message translates to:
  /// **'Learn More →'**
  String get learnMore;

  /// No description provided for @readBlog.
  ///
  /// In en, this message translates to:
  /// **'Read Blog'**
  String get readBlog;

  /// No description provided for @readBlogDesc.
  ///
  /// In en, this message translates to:
  /// **'Latest blogs about Gurudev\'s samagam and activities'**
  String get readBlogDesc;

  /// No description provided for @bslndCenters.
  ///
  /// In en, this message translates to:
  /// **'BSLND Centers'**
  String get bslndCenters;

  /// No description provided for @bslndCentersDesc.
  ///
  /// In en, this message translates to:
  /// **'Find BSLND centers near you'**
  String get bslndCentersDesc;

  /// No description provided for @openInBrowser.
  ///
  /// In en, this message translates to:
  /// **'Open in Browser'**
  String get openInBrowser;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @favourites.
  ///
  /// In en, this message translates to:
  /// **'Favourites'**
  String get favourites;

  /// No description provided for @addToFavourites.
  ///
  /// In en, this message translates to:
  /// **'Add to Favourites'**
  String get addToFavourites;

  /// No description provided for @removeFromFavourites.
  ///
  /// In en, this message translates to:
  /// **'Remove from Favourites'**
  String get removeFromFavourites;

  /// No description provided for @noFavouritesYet.
  ///
  /// In en, this message translates to:
  /// **'No favourites yet'**
  String get noFavouritesYet;

  /// No description provided for @addFavouritesHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the star icon on any content to add it here'**
  String get addFavouritesHint;
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
      <String>['en', 'gu', 'hi', 'pa', 'te'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'gu':
      return AppLocalizationsGu();
    case 'hi':
      return AppLocalizationsHi();
    case 'pa':
      return AppLocalizationsPa();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
