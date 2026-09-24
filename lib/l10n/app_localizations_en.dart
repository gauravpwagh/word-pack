// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'WordPack';

  @override
  String get navLearn => 'Learn';

  @override
  String get navExplore => 'Explore';

  @override
  String get navImport => 'Import';

  @override
  String get navSettings => 'Settings';

  @override
  String get treeOpen => 'Open word tree';

  @override
  String get treeCollapse => 'Hide word tree';

  @override
  String get treeExpand => 'Show word tree';

  @override
  String get treeResize => 'Resize word tree';

  @override
  String get treeSearchHint => 'Search words';

  @override
  String get treeEmpty => 'No wordlists yet. Import a CSV to start.';

  @override
  String get welcomeTitle => 'Learn words one small pack at a time';

  @override
  String get welcomeBody =>
      'Import a list of words and definitions. WordPack splits it into packs of 30 and you study each pack until you can get through it without peeking.';

  @override
  String get welcomeImport => 'Import CSV';

  @override
  String get welcomeFormats =>
      'Accepted: a CSV with word, part of speech and definition columns, or plain lines like “abbey - n. a monastery ruled by an abbot”.';

  @override
  String get importTitle => 'Import preview';

  @override
  String get wordlistTitle => 'Wordlist';

  @override
  String get learnTitle => 'Learn';

  @override
  String get exploreTitle => 'Explore';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get importChooseFile => 'Choose a file';

  @override
  String importReading(String file) {
    return 'Reading $file…';
  }

  @override
  String importFile(String file) {
    return 'File: $file';
  }

  @override
  String get importDetectedDash =>
      'Detected: dash lines (word - pos. definition)';

  @override
  String get importDetectedColumns => 'Detected: CSV columns';

  @override
  String get importNameLabel => 'Wordlist name';

  @override
  String importWordsReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count words ready',
      one: '1 word ready',
    );
    return '$_temp0';
  }

  @override
  String importSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lines skipped',
      one: '1 line skipped',
      zero: 'No lines skipped',
    );
    return '$_temp0';
  }

  @override
  String importDuplicates(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count duplicates removed',
      one: '1 duplicate removed',
      zero: 'No duplicates',
    );
    return '$_temp0';
  }

  @override
  String importPacks(int count, int size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count packs of $size',
      one: '1 pack of $size',
    );
    return '$_temp0';
  }

  @override
  String importPacksLast(int count, int size, int last) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count packs of $size',
      one: '1 pack of $size',
    );
    return '$_temp0 (last pack $last)';
  }

  @override
  String get importFirstWords => 'First 10 words';

  @override
  String importSkippedLine(int line, String text, String reason) {
    return 'Line $line: “$text” — $reason';
  }

  @override
  String get skipNoSeparator => 'no “ - ” separator found';

  @override
  String get skipEmptyTerm => 'no word';

  @override
  String get skipEmptyDefinition => 'no definition';

  @override
  String get importCancel => 'Cancel';

  @override
  String importConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Import $count words',
      one: 'Import 1 word',
    );
    return '$_temp0';
  }

  @override
  String get importErrorTooLarge =>
      'This file is larger than 5 MB. Split it into smaller files and import them one by one.';

  @override
  String get importErrorUnreadable =>
      'This file can’t be read. Save it as a UTF-8 text or CSV file and try again.';

  @override
  String get importErrorNoWords =>
      'No words found. Each line needs a word, “ - ” and a definition, or use word and definition columns.';

  @override
  String get importChooseAnother => 'Choose another file';

  @override
  String get importFailed => 'Import failed. Please try again.';

  @override
  String homeProgress(int learned, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total packs',
      one: '1 pack',
    );
    return '$learned of $_temp0 learned';
  }

  @override
  String homeWords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count words',
      one: '1 word',
    );
    return '$_temp0';
  }

  @override
  String get homePacks => 'Packs';

  @override
  String continueLabel(int number, String direction) {
    return 'Continue · Pack $number · $direction';
  }

  @override
  String resumeLabel(int number, String direction, int card, int total) {
    return 'Resume Pack $number · $direction · card $card / $total';
  }

  @override
  String get allLearned => 'All packs learned 🎉';

  @override
  String reviewPack(int number) {
    return 'Review pack $number';
  }

  @override
  String get directionWd => 'Word → Definition';

  @override
  String get directionDw => 'Definition → Word';

  @override
  String get statusNew => 'New';

  @override
  String get statusLearning => 'Learning';

  @override
  String get statusLearned => 'Learned';

  @override
  String packTitle(int number) {
    return 'Pack $number';
  }

  @override
  String packRange(String first, String last) {
    return '$first – $last';
  }

  @override
  String packSemantics(int number, String first, String last, String status) {
    return 'Pack $number, $first to $last, $status';
  }

  @override
  String get switchWordlist => 'Switch wordlist';

  @override
  String get cancel => 'Cancel';

  @override
  String learnPackTitle(int number, String first, String last) {
    return 'Pack $number · $first – $last';
  }

  @override
  String learnPosition(int current, int total) {
    return '$current / $total';
  }

  @override
  String learnPositionSemantics(int current, int total) {
    return 'Card $current of $total';
  }

  @override
  String learnPeeks(int count) {
    return 'Peeks this pass: $count';
  }

  @override
  String get learnPeekNote =>
      'This pass won’t count — finish it, then repeat the pack.';

  @override
  String get learnShow => 'Show';

  @override
  String get learnShown => 'Shown';

  @override
  String get learnNext => 'Next';

  @override
  String get learnPrevious => 'Previous';

  @override
  String get learnTapToShow => 'Tap to show';

  @override
  String get reviewBadge => 'Review';

  @override
  String get masteryMastered => 'mastered';

  @override
  String get masteryLearning => 'learning';

  @override
  String get masteryUnseen => 'not started';

  @override
  String directionStatus(String direction, String status) {
    return '$direction: $status';
  }

  @override
  String get directionShortWd => 'Word → Def';

  @override
  String get directionShortDw => 'Def → Word';

  @override
  String switchDirectionTitle(String direction) {
    return 'Switch to $direction?';
  }

  @override
  String get switchDirectionBody => 'This pass will restart.';

  @override
  String get switchDirectionConfirm => 'Switch';

  @override
  String summaryClean(int number, String direction) {
    return 'Clean pass — Pack $number · $direction mastered.';
  }

  @override
  String summaryLearned(int number) {
    return 'Pack $number learned!';
  }

  @override
  String summaryPeeks(int count, String words) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Pass finished with $count peeks: $words',
      one: 'Pass finished with 1 peek: $words',
    );
    return '$_temp0';
  }

  @override
  String summaryCleanReview(int number, String direction) {
    return 'Clean pass — Pack $number · $direction.';
  }

  @override
  String summaryStart(String direction) {
    return 'Start $direction';
  }

  @override
  String get summaryNextPack => 'Next pack';

  @override
  String get summaryReview => 'Review this pack';

  @override
  String get summaryBack => 'Back to wordlist';

  @override
  String get summaryRepeat => 'Repeat pack';

  @override
  String get summarySwitch => 'Switch direction';

  @override
  String get tonePositive => 'Positive';

  @override
  String get toneNegative => 'Negative';

  @override
  String get toneNeutral => 'Neutral';

  @override
  String get traitCounterIntuitive => 'Counter-intuitive';

  @override
  String get traitMultipleMeanings => 'Multiple meanings';

  @override
  String get categoryLabel => 'Category';

  @override
  String get subcategoryLabel => 'Subcategory';

  @override
  String categoryCreate(String name) {
    return 'Create “$name”';
  }

  @override
  String get categoryClear => 'Clear category';

  @override
  String get subcategoryClear => 'Clear subcategory';

  @override
  String get categorySaved => 'Saved';

  @override
  String categoryPath(String category, String subcategory) {
    return '$category › $subcategory';
  }

  @override
  String get tagSaveFailed => 'Couldn’t save that change. Please try again.';

  @override
  String get categoryNameInvalid =>
      'Category names must be 1 to 80 characters.';

  @override
  String get treePacks => 'Packs';

  @override
  String get treeCategories => 'Categories';

  @override
  String get treeTags => 'Tags';

  @override
  String get treeUncategorised => 'Uncategorised';

  @override
  String get treeNoSubcategory => '(no subcategory)';

  @override
  String get tagUntagged => 'Untagged';

  @override
  String treeLearnedOfTotal(int learned, int total) {
    return '$learned / $total';
  }

  @override
  String treeRowSemantics(String title, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count words',
      one: '1 word',
    );
    return '$title, $_temp0';
  }

  @override
  String treeStudyPack(int number) {
    return 'Study pack $number';
  }

  @override
  String treeCollapseNode(String title) {
    return 'Collapse $title';
  }

  @override
  String get exploreChooseNode =>
      'Choose a group in the word tree to browse its words.';

  @override
  String get exploreEmpty => 'No words here yet.';

  @override
  String get exploreCardMode => 'Card';

  @override
  String get exploreListMode => 'List';

  @override
  String get exploreWordFirst => 'Word first';

  @override
  String get exploreDefinitionFirst => 'Definition first';

  @override
  String exploreSearchTitle(String query) {
    return 'Search: “$query”';
  }

  @override
  String treeExpandNode(String title) {
    return 'Expand $title';
  }

  @override
  String get settingsLearning => 'Learning';

  @override
  String get settingsPackSize => 'Pack size';

  @override
  String settingsPackSizeValue(int count) {
    return '$count words per pack';
  }

  @override
  String get settingsPackSizeHint => '5 to 100 words';

  @override
  String get settingsDefaultDirection => 'Default direction';

  @override
  String get settingsLearnedRule => 'Pack counts as learned after';

  @override
  String get ruleBoth => 'A clean pass in both directions';

  @override
  String get ruleEither => 'A clean pass in either direction';

  @override
  String get ruleWdOnly => 'A clean Word → Definition pass';

  @override
  String get ruleDwOnly => 'A clean Definition → Word pass';

  @override
  String get settingsShowPos => 'Show part of speech';

  @override
  String get settingsDemote => 'Peeks during review demote the pack';

  @override
  String get settingsDemoteHint =>
      'A peek on a learned pack makes it Learning again.';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get settingsOrganise => 'Organise';

  @override
  String get settingsManageCategories => 'Manage categories';

  @override
  String get settingsWordlists => 'Wordlists';

  @override
  String get settingsBackup => 'Backup';

  @override
  String get settingsExport => 'Export backup';

  @override
  String get settingsExportHint =>
      'Save everything to one file, e.g. to move to another device.';

  @override
  String get settingsRestore => 'Restore backup';

  @override
  String get settingsRestoreHint =>
      'Replace everything on this device with a backup file.';

  @override
  String get settingsKeyboard => 'Keyboard shortcuts';

  @override
  String packSizeTitle(int size) {
    return 'Change pack size to $size?';
  }

  @override
  String packSizeList(String name, int before, int after) {
    return '$name: $before → $after packs';
  }

  @override
  String packSizeBody(int size) {
    return 'All packs will be rebuilt with $size words each. Word progress is kept, and packs whose words were all learned stay Learned.';
  }

  @override
  String packSizeOpenPasses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count passes in progress will be discarded.',
      one: '1 pass in progress will be discarded.',
      zero: '',
    );
    return '$_temp0';
  }

  @override
  String get packSizeConfirm => 'Rebuild packs';

  @override
  String get save => 'Save';

  @override
  String get rename => 'Rename';

  @override
  String get delete => 'Delete';

  @override
  String get mergeInto => 'Merge into…';

  @override
  String get renameWordlist => 'Rename wordlist';

  @override
  String deleteWordlistTitle(String name) {
    return 'Delete “$name”?';
  }

  @override
  String deleteWordlistBody(int words, int packs) {
    return '$words words, $packs packs, all progress, and the tags on these words will be removed from this device. Categories stay. This can’t be undone.';
  }

  @override
  String get deleteWordlistConfirm => 'Delete list';

  @override
  String get manageCategoriesEmpty =>
      'No categories yet. Add them while reviewing a learned pack.';

  @override
  String get renameCategory => 'Rename category';

  @override
  String categoryNameTaken(String name) {
    return '“$name” already exists here. Use Merge instead.';
  }

  @override
  String mergeCategoryTitle(String name) {
    return 'Merge “$name” into…';
  }

  @override
  String get mergeNoTargets =>
      'There is nothing at the same level to merge into.';

  @override
  String deleteCategoryTitle(String name) {
    return 'Delete “$name”?';
  }

  @override
  String deleteCategoryBody(int subs, int words) {
    String _temp0 = intl.Intl.pluralLogic(
      subs,
      locale: localeName,
      other: 'Its $subs subcategories go with it. ',
      one: 'Its 1 subcategory goes with it. ',
      zero: '',
    );
    String _temp1 = intl.Intl.pluralLogic(
      words,
      locale: localeName,
      other:
          '$words words become uncategorised; their tone and trait tags stay.',
      one: '1 word becomes uncategorised; its tone and trait tags stay.',
      zero: 'No words use it.',
    );
    return '$_temp0$_temp1';
  }

  @override
  String deleteSubcategoryBody(int words) {
    String _temp0 = intl.Intl.pluralLogic(
      words,
      locale: localeName,
      other: '$words words keep their category but lose this subcategory.',
      one: '1 word keeps its category but loses this subcategory.',
      zero: 'No words use it.',
    );
    return '$_temp0';
  }

  @override
  String get deleteCategoryConfirm => 'Delete category';

  @override
  String get restoreTitle => 'Restore this backup?';

  @override
  String restoreBody(int wordlists, int words, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      wordlists,
      locale: localeName,
      other: '$wordlists wordlists',
      one: '1 wordlist',
    );
    return '$_temp0 · $words words · saved $date. Everything on this device will be replaced by the backup.';
  }

  @override
  String get restoreConfirm => 'Replace and restore';

  @override
  String get restoreDone => 'Backup restored.';

  @override
  String get restoreInvalid =>
      'This file isn’t a WordPack backup, or it’s damaged.';

  @override
  String get exportDone => 'Backup saved.';

  @override
  String get exportFailed => 'The backup couldn’t be saved.';

  @override
  String get shortcutsTitle => 'Keyboard shortcuts';

  @override
  String get shortcutShow => 'Show / reveal';

  @override
  String get shortcutNext => 'Next card';

  @override
  String get shortcutPrevious => 'Previous card';

  @override
  String get shortcutDirection => 'Switch direction';

  @override
  String get shortcutTags =>
      'Positive, Negative, Neutral, Counter-intuitive, Multiple meanings (review)';

  @override
  String get shortcutCategory => 'Category field (review)';

  @override
  String get shortcutHelp => 'This list';

  @override
  String get close => 'Close';

  @override
  String get learnPackMissing => 'This pack no longer exists.';

  @override
  String get backToStart => 'Back to start';
}
