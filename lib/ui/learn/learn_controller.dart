import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/database.dart';
import '../../domain/learning.dart';
import '../../domain/models.dart';
import '../../domain/tags.dart' show WordTags;
import '../../providers/providers.dart';
import '../../services/learning_service.dart';

/// Which pack, and the direction asked for by the route (`?dir=`); null =
/// the pack's last direction, else the one the learned rule still needs.
typedef LearnArgs = ({String packId, Direction? direction});

/// Everything the learn screen shows.
class LearnView {
  const LearnView({
    required this.pack,
    required this.words,
    required this.packs,
    required this.settings,
    required this.direction,
    required this.pass,
    required this.result,
    required this.categories,
  });

  final Pack pack;

  /// The pack's words in source order.
  final List<Word> words;

  /// All packs of the wordlist, in number order (for "Next pack").
  final List<Pack> packs;
  final AppSetting settings;
  final Direction direction;

  /// The running pass; null once it ended ([result] is then set).
  final PassState? pass;
  final PassResult? result;

  /// All categories (shared across wordlists), for the category fields and
  /// the path shown on the card.
  final List<Category> categories;

  PackProgress get progress =>
      PackProgress(wd: pack.masteryWd, dw: pack.masteryDw);

  PackStatus get status =>
      progress.status(settings.learnedRule, hasOpenPass: pass != null);

  /// Studying a Learned pack (LRN-11).
  bool get isReview =>
      progress.status(settings.learnedRule, hasOpenPass: false) ==
      PackStatus.learned;

  Word? get current => pass == null ? null : words[pass!.index];

  Word wordById(String id) => words.firstWhere((w) => w.id == id);

  /// "Emotions › Anger", "Emotions", or null.
  String? categoryPath(Word w, String Function(String, String) join) {
    String? name(String? id) =>
        categories.where((c) => c.id == id).firstOrNull?.name;
    final cat = name(w.categoryId);
    final sub = name(w.subcategoryId);
    if (cat == null) return null;
    return sub == null ? cat : join(cat, sub);
  }

  Pack? get nextPack {
    final i = packs.indexWhere((p) => p.id == pack.id);
    return i >= 0 && i + 1 < packs.length ? packs[i + 1] : null;
  }

  LearnView copyWith({
    Pack? pack,
    Direction? direction,
    required PassState? pass,
    required PassResult? result,
    List<Word>? words,
    List<Category>? categories,
  }) => LearnView(
    pack: pack ?? this.pack,
    words: words ?? this.words,
    packs: packs,
    settings: settings,
    direction: direction ?? this.direction,
    pass: pass,
    result: result,
    categories: categories ?? this.categories,
  );
}

class LearnController extends AsyncNotifier<LearnView> {
  LearnController(this.args);

  final LearnArgs args;

  /// Actions run one after another, never interleaved.
  Future<void> _queue = Future.value();

  LearningService get _service => ref.read(learningServiceProvider);

  @override
  Future<LearnView> build() async {
    final settings = await ref.read(settingsRepoProvider).get();
    final packRepo = ref.read(packRepoProvider);
    final pack = await packRepo.get(args.packId);
    if (pack == null) throw PackNotFoundException(args.packId);
    final progress = PackProgress(wd: pack.masteryWd, dw: pack.masteryDw);
    final direction =
        args.direction ??
        pack.lastDirection ??
        neededDirection(progress, settings.learnedRule) ??
        settings.defaultDirection;
    final pass = await _service.open(pack.id, direction);
    return LearnView(
      pack: (await packRepo.get(pack.id))!,
      words: await ref.read(wordRepoProvider).forPack(pack.id),
      packs: await packRepo.forWordlist(pack.wordlistId),
      settings: settings,
      direction: direction,
      pass: pass,
      result: null,
      categories: await ref.read(categoryRepoProvider).all(),
    );
  }

  Future<void> show() => _step((v) => _service.show(v.pack.id, v.direction));

  Future<void> next() => _step((v) => _service.next(v.pack.id, v.direction));

  Future<void> previous() =>
      _step((v) => _service.previous(v.pack.id, v.direction));

  /// Mid-pass switch (after the screen confirmed it) or starting the other
  /// direction from the summary.
  Future<void> switchTo(Direction to) => _run((v) async {
    final pass = await _service.switchDirection(
      v.pack.id,
      from: v.direction,
      to: to,
    );
    return v.copyWith(
      pack: await ref.read(packRepoProvider).get(v.pack.id),
      direction: to,
      pass: pass,
      result: null,
    );
  });

  /// Repeat pack / Review this pack: a fresh pass in [direction].
  Future<void> restart(Direction direction) => _run((v) async {
    final pass = await _service.restart(v.pack.id, direction);
    return v.copyWith(
      pack: await ref.read(packRepoProvider).get(v.pack.id),
      direction: direction,
      pass: pass,
      result: null,
    );
  });

  // Tagging: tone and traits on any word (D-32); categories in review only
  // (the service enforces the learned-only rule, D-9).

  Future<void> setTone(Word word, Tone? tone) =>
      _tag(word, () => ref.read(taggingServiceProvider).setTone(word.id, tone));

  Future<void> toggleTrait(Word word, Trait trait) => _tag(
    word,
    () => ref.read(taggingServiceProvider).toggleTrait(word.id, trait),
  );

  Future<void> assignCategory(
    Word word,
    String? category,
    String? subcategory,
  ) => _tag(
    word,
    () => ref
        .read(taggingServiceProvider)
        .assign(word.id, category: category, subcategory: subcategory),
  );

  /// Tapping the tone buttons 1–3 from the keyboard.
  Future<void> tapTone(Word word, Tone tone) =>
      setTone(word, WordTags(tone: word.tone).tapTone(tone).tone);

  Future<void> _tag(Word word, Future<void> Function() action) =>
      _run((v) async {
        await action();
        final fresh = (await ref.read(wordRepoProvider).forPack(v.pack.id));
        return v.copyWith(
          pass: v.pass,
          result: v.result,
          words: fresh,
          categories: await ref.read(categoryRepoProvider).all(),
        );
      });

  Future<void> _step(Future<PassUpdate> Function(LearnView) action) =>
      _run((v) async {
        final update = await action(v);
        return v.copyWith(
          pack: await ref.read(packRepoProvider).get(v.pack.id),
          pass: update.pass,
          result: update.result,
        );
      });

  Future<void> _run(Future<LearnView> Function(LearnView) action) {
    final done = _queue.then((_) async {
      final view = state.value;
      if (view == null || !ref.mounted) return;
      final next = await action(view);
      if (ref.mounted) state = AsyncData(next);
    });
    _queue = done.catchError((Object _) {});
    return done;
  }
}

final learnControllerProvider = AsyncNotifierProvider.autoDispose
    .family<LearnController, LearnView, LearnArgs>(
      LearnController.new,
      retry: (_, _) => null,
    );
