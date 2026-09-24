import 'package:flutter_test/flutter_test.dart';
import 'package:wordpack/domain/categories.dart';
import 'package:wordpack/domain/models.dart';
import 'package:wordpack/domain/tags.dart';

void main() {
  group('categories', () {
    const law = CategoryRef(id: 'c1', name: 'Law', parentId: null);
    const emotions = CategoryRef(id: 'c2', name: 'Emotions', parentId: null);
    const anger = CategoryRef(id: 's1', name: 'Anger', parentId: 'c2');
    const courtAnger = CategoryRef(id: 's2', name: 'Anger', parentId: 'c1');
    const all = [law, emotions, anger, courtAnger];

    test('U-23 "  Law " then "law" share one key; display stays "Law"', () {
      expect(validateCategoryName('  Law '), 'Law');
      expect(categoryKey('  Law '), categoryKey('law'));
      expect(findCategory(all, 'law'), same(law));
      expect(findCategory(all, 'LAW')!.name, 'Law');
      expect(normaliseName('  Road   rage '), 'Road rage');
    });

    test('U-24 the same subcategory name under two categories is allowed', () {
      expect(findCategory(all, 'anger', parentId: 'c2'), same(anger));
      expect(findCategory(all, 'anger', parentId: 'c1'), same(courtAnger));
      expect(findCategory(all, 'anger'), isNull, reason: 'not top level');
    });

    test('U-25 subcategory without category or with wrong parent', () {
      expect(
        () => checkAssignment(categoryId: null, subcategory: anger),
        throwsA(isA<InvalidSubcategoryException>()),
      );
      expect(
        () => checkAssignment(categoryId: 'c1', subcategory: anger),
        throwsA(isA<InvalidSubcategoryException>()),
      );
      checkAssignment(categoryId: 'c2', subcategory: anger);
      checkAssignment(categoryId: 'c2', subcategory: null);
      checkAssignment(categoryId: null, subcategory: null);
      expect(
        const InvalidSubcategoryException('x').toString(),
        'InvalidSubcategoryException: x',
      );
    });

    test('names must be 1–80 characters after normalising', () {
      expect(
        () => validateCategoryName('   '),
        throwsA(isA<InvalidCategoryNameException>()),
      );
      expect(
        () => validateCategoryName('x' * 81),
        throwsA(isA<InvalidCategoryNameException>()),
      );
      expect(validateCategoryName('x' * 80), hasLength(80));
      expect(
        const InvalidCategoryNameException(' ').toString(),
        'InvalidCategoryNameException(" ")',
      );
    });
  });

  group('tags', () {
    test('U-26 tone select, reselect, switch; traits unaffected', () {
      const base = WordTags(counterIntuitive: true);
      final negative = base.tapTone(Tone.negative);
      expect(
        negative,
        const WordTags(tone: Tone.negative, counterIntuitive: true),
      );

      expect(negative.tapTone(Tone.negative), base, reason: 'reselect clears');
      expect(
        negative.tapTone(Tone.positive),
        const WordTags(tone: Tone.positive, counterIntuitive: true),
      );
    });

    test('traits toggle independently and keep the tone', () {
      const t = WordTags(tone: Tone.neutral);
      final both = t
          .toggle(Trait.counterIntuitive)
          .toggle(Trait.multipleMeanings);
      expect(both.has(Trait.counterIntuitive), isTrue);
      expect(both.has(Trait.multipleMeanings), isTrue);
      expect(both.tone, Tone.neutral);
      expect(
        both.toggle(Trait.counterIntuitive),
        const WordTags(tone: Tone.neutral, multipleMeanings: true),
      );
      expect(const WordTags().isEmpty, isTrue);
      expect(t.isEmpty, isFalse);
      expect(both.hashCode, isNot(t.hashCode));
      expect(t.toString(), 'WordTags(neutral, ci: false, mm: false)');
    });

    test('tree keys', () {
      expect(toneKey(Tone.positive), 'positive');
      expect(traitKey(Trait.counterIntuitive), 'counterIntuitive');
      expect(untaggedKey, 'untagged');
    });
  });
}
