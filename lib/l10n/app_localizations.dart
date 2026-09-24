import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

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
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'WordPack'**
  String get appTitle;

  /// No description provided for @navLearn.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get navLearn;

  /// No description provided for @navExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get navExplore;

  /// No description provided for @navImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get navImport;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @treeOpen.
  ///
  /// In en, this message translates to:
  /// **'Open word tree'**
  String get treeOpen;

  /// No description provided for @treeCollapse.
  ///
  /// In en, this message translates to:
  /// **'Hide word tree'**
  String get treeCollapse;

  /// No description provided for @treeExpand.
  ///
  /// In en, this message translates to:
  /// **'Show word tree'**
  String get treeExpand;

  /// No description provided for @treeResize.
  ///
  /// In en, this message translates to:
  /// **'Resize word tree'**
  String get treeResize;

  /// No description provided for @treeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search words'**
  String get treeSearchHint;

  /// No description provided for @treeEmpty.
  ///
  /// In en, this message translates to:
  /// **'No wordlists yet. Import a CSV to start.'**
  String get treeEmpty;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Learn words one small pack at a time'**
  String get welcomeTitle;

  /// No description provided for @welcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Import a list of words and definitions. WordPack splits it into packs of 30 and you study each pack until you can get through it without peeking.'**
  String get welcomeBody;

  /// No description provided for @welcomeImport.
  ///
  /// In en, this message translates to:
  /// **'Import CSV'**
  String get welcomeImport;

  /// No description provided for @welcomeFormats.
  ///
  /// In en, this message translates to:
  /// **'Accepted: a CSV with word, part of speech and definition columns, or plain lines like “abbey - n. a monastery ruled by an abbot”.'**
  String get welcomeFormats;

  /// No description provided for @importTitle.
  ///
  /// In en, this message translates to:
  /// **'Import preview'**
  String get importTitle;

  /// No description provided for @wordlistTitle.
  ///
  /// In en, this message translates to:
  /// **'Wordlist'**
  String get wordlistTitle;

  /// No description provided for @learnTitle.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get learnTitle;

  /// No description provided for @exploreTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get exploreTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @importChooseFile.
  ///
  /// In en, this message translates to:
  /// **'Choose a file'**
  String get importChooseFile;

  /// No description provided for @importReading.
  ///
  /// In en, this message translates to:
  /// **'Reading {file}…'**
  String importReading(String file);

  /// No description provided for @importFile.
  ///
  /// In en, this message translates to:
  /// **'File: {file}'**
  String importFile(String file);

  /// No description provided for @importDetectedDash.
  ///
  /// In en, this message translates to:
  /// **'Detected: dash lines (word - pos. definition)'**
  String get importDetectedDash;

  /// No description provided for @importDetectedColumns.
  ///
  /// In en, this message translates to:
  /// **'Detected: CSV columns'**
  String get importDetectedColumns;

  /// No description provided for @importNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Wordlist name'**
  String get importNameLabel;

  /// No description provided for @importWordsReady.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 word ready} other{{count} words ready}}'**
  String importWordsReady(int count);

  /// No description provided for @importSkipped.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No lines skipped} =1{1 line skipped} other{{count} lines skipped}}'**
  String importSkipped(int count);

  /// No description provided for @importDuplicates.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No duplicates} =1{1 duplicate removed} other{{count} duplicates removed}}'**
  String importDuplicates(int count);

  /// No description provided for @importPacks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 pack of {size}} other{{count} packs of {size}}}'**
  String importPacks(int count, int size);

  /// No description provided for @importPacksLast.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 pack of {size}} other{{count} packs of {size}}} (last pack {last})'**
  String importPacksLast(int count, int size, int last);

  /// No description provided for @importFirstWords.
  ///
  /// In en, this message translates to:
  /// **'First 10 words'**
  String get importFirstWords;

  /// No description provided for @importSkippedLine.
  ///
  /// In en, this message translates to:
  /// **'Line {line}: “{text}” — {reason}'**
  String importSkippedLine(int line, String text, String reason);

  /// No description provided for @skipNoSeparator.
  ///
  /// In en, this message translates to:
  /// **'no “ - ” separator found'**
  String get skipNoSeparator;

  /// No description provided for @skipEmptyTerm.
  ///
  /// In en, this message translates to:
  /// **'no word'**
  String get skipEmptyTerm;

  /// No description provided for @skipEmptyDefinition.
  ///
  /// In en, this message translates to:
  /// **'no definition'**
  String get skipEmptyDefinition;

  /// No description provided for @importCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get importCancel;

  /// No description provided for @importConfirm.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Import 1 word} other{Import {count} words}}'**
  String importConfirm(int count);

  /// No description provided for @importErrorTooLarge.
  ///
  /// In en, this message translates to:
  /// **'This file is larger than 5 MB. Split it into smaller files and import them one by one.'**
  String get importErrorTooLarge;

  /// No description provided for @importErrorUnreadable.
  ///
  /// In en, this message translates to:
  /// **'This file can’t be read. Save it as a UTF-8 text or CSV file and try again.'**
  String get importErrorUnreadable;

  /// No description provided for @importErrorNoWords.
  ///
  /// In en, this message translates to:
  /// **'No words found. Each line needs a word, “ - ” and a definition, or use word and definition columns.'**
  String get importErrorNoWords;

  /// No description provided for @importChooseAnother.
  ///
  /// In en, this message translates to:
  /// **'Choose another file'**
  String get importChooseAnother;

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed. Please try again.'**
  String get importFailed;

  /// No description provided for @homeProgress.
  ///
  /// In en, this message translates to:
  /// **'{learned} of {total, plural, =1{1 pack} other{{total} packs}} learned'**
  String homeProgress(int learned, int total);

  /// No description provided for @homeWords.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 word} other{{count} words}}'**
  String homeWords(int count);

  /// No description provided for @homePacks.
  ///
  /// In en, this message translates to:
  /// **'Packs'**
  String get homePacks;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue · Pack {number} · {direction}'**
  String continueLabel(int number, String direction);

  /// No description provided for @resumeLabel.
  ///
  /// In en, this message translates to:
  /// **'Resume Pack {number} · {direction} · card {card} / {total}'**
  String resumeLabel(int number, String direction, int card, int total);

  /// No description provided for @allLearned.
  ///
  /// In en, this message translates to:
  /// **'All packs learned 🎉'**
  String get allLearned;

  /// No description provided for @reviewPack.
  ///
  /// In en, this message translates to:
  /// **'Review pack {number}'**
  String reviewPack(int number);

  /// No description provided for @directionWd.
  ///
  /// In en, this message translates to:
  /// **'Word → Definition'**
  String get directionWd;

  /// No description provided for @directionDw.
  ///
  /// In en, this message translates to:
  /// **'Definition → Word'**
  String get directionDw;

  /// No description provided for @statusNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get statusNew;

  /// No description provided for @statusLearning.
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get statusLearning;

  /// No description provided for @statusLearned.
  ///
  /// In en, this message translates to:
  /// **'Learned'**
  String get statusLearned;

  /// No description provided for @packTitle.
  ///
  /// In en, this message translates to:
  /// **'Pack {number}'**
  String packTitle(int number);

  /// No description provided for @packRange.
  ///
  /// In en, this message translates to:
  /// **'{first} – {last}'**
  String packRange(String first, String last);

  /// No description provided for @packSemantics.
  ///
  /// In en, this message translates to:
  /// **'Pack {number}, {first} to {last}, {status}'**
  String packSemantics(int number, String first, String last, String status);

  /// No description provided for @switchWordlist.
  ///
  /// In en, this message translates to:
  /// **'Switch wordlist'**
  String get switchWordlist;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @learnPackTitle.
  ///
  /// In en, this message translates to:
  /// **'Pack {number} · {first} – {last}'**
  String learnPackTitle(int number, String first, String last);

  /// No description provided for @learnPosition.
  ///
  /// In en, this message translates to:
  /// **'{current} / {total}'**
  String learnPosition(int current, int total);

  /// No description provided for @learnPositionSemantics.
  ///
  /// In en, this message translates to:
  /// **'Card {current} of {total}'**
  String learnPositionSemantics(int current, int total);

  /// No description provided for @learnPeeks.
  ///
  /// In en, this message translates to:
  /// **'Peeks this pass: {count}'**
  String learnPeeks(int count);

  /// No description provided for @learnPeekNote.
  ///
  /// In en, this message translates to:
  /// **'This pass won’t count — finish it, then repeat the pack.'**
  String get learnPeekNote;

  /// No description provided for @learnShow.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get learnShow;

  /// No description provided for @learnShown.
  ///
  /// In en, this message translates to:
  /// **'Shown'**
  String get learnShown;

  /// No description provided for @learnNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get learnNext;

  /// No description provided for @learnPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get learnPrevious;

  /// No description provided for @learnTapToShow.
  ///
  /// In en, this message translates to:
  /// **'Tap to show'**
  String get learnTapToShow;

  /// No description provided for @reviewBadge.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get reviewBadge;

  /// No description provided for @masteryMastered.
  ///
  /// In en, this message translates to:
  /// **'mastered'**
  String get masteryMastered;

  /// No description provided for @masteryLearning.
  ///
  /// In en, this message translates to:
  /// **'learning'**
  String get masteryLearning;

  /// No description provided for @masteryUnseen.
  ///
  /// In en, this message translates to:
  /// **'not started'**
  String get masteryUnseen;

  /// No description provided for @directionStatus.
  ///
  /// In en, this message translates to:
  /// **'{direction}: {status}'**
  String directionStatus(String direction, String status);

  /// No description provided for @directionShortWd.
  ///
  /// In en, this message translates to:
  /// **'Word → Def'**
  String get directionShortWd;

  /// No description provided for @directionShortDw.
  ///
  /// In en, this message translates to:
  /// **'Def → Word'**
  String get directionShortDw;

  /// No description provided for @switchDirectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Switch to {direction}?'**
  String switchDirectionTitle(String direction);

  /// No description provided for @switchDirectionBody.
  ///
  /// In en, this message translates to:
  /// **'This pass will restart.'**
  String get switchDirectionBody;

  /// No description provided for @switchDirectionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Switch'**
  String get switchDirectionConfirm;

  /// No description provided for @summaryClean.
  ///
  /// In en, this message translates to:
  /// **'Clean pass — Pack {number} · {direction} mastered.'**
  String summaryClean(int number, String direction);

  /// No description provided for @summaryLearned.
  ///
  /// In en, this message translates to:
  /// **'Pack {number} learned!'**
  String summaryLearned(int number);

  /// No description provided for @summaryPeeks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Pass finished with 1 peek: {words}} other{Pass finished with {count} peeks: {words}}}'**
  String summaryPeeks(int count, String words);

  /// No description provided for @summaryCleanReview.
  ///
  /// In en, this message translates to:
  /// **'Clean pass — Pack {number} · {direction}.'**
  String summaryCleanReview(int number, String direction);

  /// No description provided for @summaryStart.
  ///
  /// In en, this message translates to:
  /// **'Start {direction}'**
  String summaryStart(String direction);

  /// No description provided for @summaryNextPack.
  ///
  /// In en, this message translates to:
  /// **'Next pack'**
  String get summaryNextPack;

  /// No description provided for @summaryReview.
  ///
  /// In en, this message translates to:
  /// **'Review this pack'**
  String get summaryReview;

  /// No description provided for @summaryBack.
  ///
  /// In en, this message translates to:
  /// **'Back to wordlist'**
  String get summaryBack;

  /// No description provided for @summaryRepeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat pack'**
  String get summaryRepeat;

  /// No description provided for @summarySwitch.
  ///
  /// In en, this message translates to:
  /// **'Switch direction'**
  String get summarySwitch;

  /// No description provided for @tonePositive.
  ///
  /// In en, this message translates to:
  /// **'Positive'**
  String get tonePositive;

  /// No description provided for @toneNegative.
  ///
  /// In en, this message translates to:
  /// **'Negative'**
  String get toneNegative;

  /// No description provided for @toneNeutral.
  ///
  /// In en, this message translates to:
  /// **'Neutral'**
  String get toneNeutral;

  /// No description provided for @traitCounterIntuitive.
  ///
  /// In en, this message translates to:
  /// **'Counter-intuitive'**
  String get traitCounterIntuitive;

  /// No description provided for @traitMultipleMeanings.
  ///
  /// In en, this message translates to:
  /// **'Multiple meanings'**
  String get traitMultipleMeanings;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @subcategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Subcategory'**
  String get subcategoryLabel;

  /// No description provided for @categoryCreate.
  ///
  /// In en, this message translates to:
  /// **'Create “{name}”'**
  String categoryCreate(String name);

  /// No description provided for @categoryClear.
  ///
  /// In en, this message translates to:
  /// **'Clear category'**
  String get categoryClear;

  /// No description provided for @subcategoryClear.
  ///
  /// In en, this message translates to:
  /// **'Clear subcategory'**
  String get subcategoryClear;

  /// No description provided for @categorySaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get categorySaved;

  /// No description provided for @categoryPath.
  ///
  /// In en, this message translates to:
  /// **'{category} › {subcategory}'**
  String categoryPath(String category, String subcategory);

  /// No description provided for @tagSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t save that change. Please try again.'**
  String get tagSaveFailed;

  /// No description provided for @categoryNameInvalid.
  ///
  /// In en, this message translates to:
  /// **'Category names must be 1 to 80 characters.'**
  String get categoryNameInvalid;

  /// No description provided for @treePacks.
  ///
  /// In en, this message translates to:
  /// **'Packs'**
  String get treePacks;

  /// No description provided for @treeCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get treeCategories;

  /// No description provided for @treeTags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get treeTags;

  /// No description provided for @treeUncategorised.
  ///
  /// In en, this message translates to:
  /// **'Uncategorised'**
  String get treeUncategorised;

  /// No description provided for @treeNoSubcategory.
  ///
  /// In en, this message translates to:
  /// **'(no subcategory)'**
  String get treeNoSubcategory;

  /// No description provided for @tagUntagged.
  ///
  /// In en, this message translates to:
  /// **'Untagged'**
  String get tagUntagged;

  /// No description provided for @treeLearnedOfTotal.
  ///
  /// In en, this message translates to:
  /// **'{learned} / {total}'**
  String treeLearnedOfTotal(int learned, int total);

  /// No description provided for @treeRowSemantics.
  ///
  /// In en, this message translates to:
  /// **'{title}, {count, plural, =1{1 word} other{{count} words}}'**
  String treeRowSemantics(String title, int count);

  /// No description provided for @treeStudyPack.
  ///
  /// In en, this message translates to:
  /// **'Study pack {number}'**
  String treeStudyPack(int number);

  /// No description provided for @treeCollapseNode.
  ///
  /// In en, this message translates to:
  /// **'Collapse {title}'**
  String treeCollapseNode(String title);

  /// No description provided for @exploreChooseNode.
  ///
  /// In en, this message translates to:
  /// **'Choose a group in the word tree to browse its words.'**
  String get exploreChooseNode;

  /// No description provided for @exploreEmpty.
  ///
  /// In en, this message translates to:
  /// **'No words here yet.'**
  String get exploreEmpty;

  /// No description provided for @exploreCardMode.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get exploreCardMode;

  /// No description provided for @exploreListMode.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get exploreListMode;

  /// No description provided for @exploreWordFirst.
  ///
  /// In en, this message translates to:
  /// **'Word first'**
  String get exploreWordFirst;

  /// No description provided for @exploreDefinitionFirst.
  ///
  /// In en, this message translates to:
  /// **'Definition first'**
  String get exploreDefinitionFirst;

  /// No description provided for @exploreSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search: “{query}”'**
  String exploreSearchTitle(String query);

  /// No description provided for @treeExpandNode.
  ///
  /// In en, this message translates to:
  /// **'Expand {title}'**
  String treeExpandNode(String title);

  /// No description provided for @settingsLearning.
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get settingsLearning;

  /// No description provided for @settingsPackSize.
  ///
  /// In en, this message translates to:
  /// **'Pack size'**
  String get settingsPackSize;

  /// No description provided for @settingsPackSizeValue.
  ///
  /// In en, this message translates to:
  /// **'{count} words per pack'**
  String settingsPackSizeValue(int count);

  /// No description provided for @settingsPackSizeHint.
  ///
  /// In en, this message translates to:
  /// **'5 to 100 words'**
  String get settingsPackSizeHint;

  /// No description provided for @settingsDefaultDirection.
  ///
  /// In en, this message translates to:
  /// **'Default direction'**
  String get settingsDefaultDirection;

  /// No description provided for @settingsLearnedRule.
  ///
  /// In en, this message translates to:
  /// **'Pack counts as learned after'**
  String get settingsLearnedRule;

  /// No description provided for @ruleBoth.
  ///
  /// In en, this message translates to:
  /// **'A clean pass in both directions'**
  String get ruleBoth;

  /// No description provided for @ruleEither.
  ///
  /// In en, this message translates to:
  /// **'A clean pass in either direction'**
  String get ruleEither;

  /// No description provided for @ruleWdOnly.
  ///
  /// In en, this message translates to:
  /// **'A clean Word → Definition pass'**
  String get ruleWdOnly;

  /// No description provided for @ruleDwOnly.
  ///
  /// In en, this message translates to:
  /// **'A clean Definition → Word pass'**
  String get ruleDwOnly;

  /// No description provided for @settingsShowPos.
  ///
  /// In en, this message translates to:
  /// **'Show part of speech'**
  String get settingsShowPos;

  /// No description provided for @settingsDemote.
  ///
  /// In en, this message translates to:
  /// **'Peeks during review demote the pack'**
  String get settingsDemote;

  /// No description provided for @settingsDemoteHint.
  ///
  /// In en, this message translates to:
  /// **'A peek on a learned pack makes it Learning again.'**
  String get settingsDemoteHint;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @settingsOrganise.
  ///
  /// In en, this message translates to:
  /// **'Organise'**
  String get settingsOrganise;

  /// No description provided for @settingsManageCategories.
  ///
  /// In en, this message translates to:
  /// **'Manage categories'**
  String get settingsManageCategories;

  /// No description provided for @settingsWordlists.
  ///
  /// In en, this message translates to:
  /// **'Wordlists'**
  String get settingsWordlists;

  /// No description provided for @settingsBackup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get settingsBackup;

  /// No description provided for @settingsExport.
  ///
  /// In en, this message translates to:
  /// **'Export backup'**
  String get settingsExport;

  /// No description provided for @settingsExportHint.
  ///
  /// In en, this message translates to:
  /// **'Save everything to one file, e.g. to move to another device.'**
  String get settingsExportHint;

  /// No description provided for @settingsRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore backup'**
  String get settingsRestore;

  /// No description provided for @settingsRestoreHint.
  ///
  /// In en, this message translates to:
  /// **'Replace everything on this device with a backup file.'**
  String get settingsRestoreHint;

  /// No description provided for @settingsKeyboard.
  ///
  /// In en, this message translates to:
  /// **'Keyboard shortcuts'**
  String get settingsKeyboard;

  /// No description provided for @packSizeTitle.
  ///
  /// In en, this message translates to:
  /// **'Change pack size to {size}?'**
  String packSizeTitle(int size);

  /// No description provided for @packSizeList.
  ///
  /// In en, this message translates to:
  /// **'{name}: {before} → {after} packs'**
  String packSizeList(String name, int before, int after);

  /// No description provided for @packSizeBody.
  ///
  /// In en, this message translates to:
  /// **'All packs will be rebuilt with {size} words each. Word progress is kept, and packs whose words were all learned stay Learned.'**
  String packSizeBody(int size);

  /// No description provided for @packSizeOpenPasses.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{} =1{1 pass in progress will be discarded.} other{{count} passes in progress will be discarded.}}'**
  String packSizeOpenPasses(int count);

  /// No description provided for @packSizeConfirm.
  ///
  /// In en, this message translates to:
  /// **'Rebuild packs'**
  String get packSizeConfirm;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @mergeInto.
  ///
  /// In en, this message translates to:
  /// **'Merge into…'**
  String get mergeInto;

  /// No description provided for @renameWordlist.
  ///
  /// In en, this message translates to:
  /// **'Rename wordlist'**
  String get renameWordlist;

  /// No description provided for @deleteWordlistTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete “{name}”?'**
  String deleteWordlistTitle(String name);

  /// No description provided for @deleteWordlistBody.
  ///
  /// In en, this message translates to:
  /// **'{words} words, {packs} packs, all progress, and the tags on these words will be removed from this device. Categories stay. This can’t be undone.'**
  String deleteWordlistBody(int words, int packs);

  /// No description provided for @deleteWordlistConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete list'**
  String get deleteWordlistConfirm;

  /// No description provided for @manageCategoriesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No categories yet. Add them while reviewing a learned pack.'**
  String get manageCategoriesEmpty;

  /// No description provided for @renameCategory.
  ///
  /// In en, this message translates to:
  /// **'Rename category'**
  String get renameCategory;

  /// No description provided for @categoryNameTaken.
  ///
  /// In en, this message translates to:
  /// **'“{name}” already exists here. Use Merge instead.'**
  String categoryNameTaken(String name);

  /// No description provided for @mergeCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Merge “{name}” into…'**
  String mergeCategoryTitle(String name);

  /// No description provided for @mergeNoTargets.
  ///
  /// In en, this message translates to:
  /// **'There is nothing at the same level to merge into.'**
  String get mergeNoTargets;

  /// No description provided for @deleteCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete “{name}”?'**
  String deleteCategoryTitle(String name);

  /// No description provided for @deleteCategoryBody.
  ///
  /// In en, this message translates to:
  /// **'{subs, plural, =0{} =1{Its 1 subcategory goes with it. } other{Its {subs} subcategories go with it. }}{words, plural, =0{No words use it.} =1{1 word becomes uncategorised; its tone and trait tags stay.} other{{words} words become uncategorised; their tone and trait tags stay.}}'**
  String deleteCategoryBody(int subs, int words);

  /// No description provided for @deleteSubcategoryBody.
  ///
  /// In en, this message translates to:
  /// **'{words, plural, =0{No words use it.} =1{1 word keeps its category but loses this subcategory.} other{{words} words keep their category but lose this subcategory.}}'**
  String deleteSubcategoryBody(int words);

  /// No description provided for @deleteCategoryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete category'**
  String get deleteCategoryConfirm;

  /// No description provided for @restoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore this backup?'**
  String get restoreTitle;

  /// No description provided for @restoreBody.
  ///
  /// In en, this message translates to:
  /// **'{wordlists, plural, =1{1 wordlist} other{{wordlists} wordlists}} · {words} words · saved {date}. Everything on this device will be replaced by the backup.'**
  String restoreBody(int wordlists, int words, String date);

  /// No description provided for @restoreConfirm.
  ///
  /// In en, this message translates to:
  /// **'Replace and restore'**
  String get restoreConfirm;

  /// No description provided for @restoreDone.
  ///
  /// In en, this message translates to:
  /// **'Backup restored.'**
  String get restoreDone;

  /// No description provided for @restoreInvalid.
  ///
  /// In en, this message translates to:
  /// **'This file isn’t a WordPack backup, or it’s damaged.'**
  String get restoreInvalid;

  /// No description provided for @exportDone.
  ///
  /// In en, this message translates to:
  /// **'Backup saved.'**
  String get exportDone;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'The backup couldn’t be saved.'**
  String get exportFailed;

  /// No description provided for @shortcutsTitle.
  ///
  /// In en, this message translates to:
  /// **'Keyboard shortcuts'**
  String get shortcutsTitle;

  /// No description provided for @shortcutShow.
  ///
  /// In en, this message translates to:
  /// **'Show / reveal'**
  String get shortcutShow;

  /// No description provided for @shortcutNext.
  ///
  /// In en, this message translates to:
  /// **'Next card'**
  String get shortcutNext;

  /// No description provided for @shortcutPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous card'**
  String get shortcutPrevious;

  /// No description provided for @shortcutDirection.
  ///
  /// In en, this message translates to:
  /// **'Switch direction'**
  String get shortcutDirection;

  /// No description provided for @shortcutTags.
  ///
  /// In en, this message translates to:
  /// **'Positive, Negative, Neutral, Counter-intuitive, Multiple meanings (review)'**
  String get shortcutTags;

  /// No description provided for @shortcutCategory.
  ///
  /// In en, this message translates to:
  /// **'Category field (review)'**
  String get shortcutCategory;

  /// No description provided for @shortcutHelp.
  ///
  /// In en, this message translates to:
  /// **'This list'**
  String get shortcutHelp;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @learnPackMissing.
  ///
  /// In en, this message translates to:
  /// **'This pack no longer exists.'**
  String get learnPackMissing;

  /// No description provided for @backToStart.
  ///
  /// In en, this message translates to:
  /// **'Back to start'**
  String get backToStart;
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
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
