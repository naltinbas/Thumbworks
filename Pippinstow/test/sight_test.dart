import 'package:flutter_test/flutter_test.dart';
import 'package:pippinstow/sight/levels.dart';
import 'package:pippinstow/sight/play.dart';
import 'package:pippinstow/sight/rules.dart';

/// The orchard, the sweep, the asks and the play, checked at the domain:
/// nothing here touches a widget.
void main() {
  group('the orchard', () {
    test('a hundred trees, the factor, the line, the front and the shadow', () {
      expect(Rules.trees, hasLength(100));
      expect(Rules.trees.first, (1, 1));
      expect(Rules.trees.last, (10, 10));
      expect(Rules.gcd(6, 9), 3);
      expect(Rules.gcd(7, 10), 1);
      expect(Rules.seenByFactor((3, 10)), isTrue);
      expect(Rules.seenByFactor((6, 9)), isFalse);
      expect(Rules.seenByLine((3, 10)), isTrue);
      expect(Rules.seenByLine((6, 9)), isFalse);
      expect(Rules.between((6, 9)), [(2, 3), (4, 6)]);
      expect(Rules.between((3, 10)), isEmpty);
      expect(Rules.front((6, 9)), (2, 3));
      expect(Rules.front((3, 10)), isNull);
      expect(Rules.hides((1, 2)), [(2, 4), (3, 6), (4, 8), (5, 10)]);
      expect(Rules.hides((1, 1)), hasLength(9));
      expect(Rules.hides((3, 10)), isEmpty);
      expect(Rules.hides((2, 2)), isEmpty);
      expect(Rules.inOrchard((0, 5)), isFalse);
      expect(Rules.inOrchard((10, 10)), isTrue);
      expect(Rules.tell((6, 9)), '(6, 9)');
      expect(Rules.tellAll([(2, 3), (4, 6)]), '(2, 3) and (4, 6)');
      expect(Rules.tellAll([(2, 3)]), '(2, 3)');
      expect(Rules.tellAll([]), 'none');
    });

    test('the sweep: the factor and the line agree on every tree, 63 in sight, and the edges all in sight', () {
      var seen = 0;
      final behind = <int, int>{};
      for (final t in Rules.trees) {
        expect(Rules.seenByLine(t), Rules.seenByFactor(t), reason: Rules.tell(t));
        if (Rules.seenByFactor(t)) {
          seen++;
        } else {
          behind[Rules.between(t).length] = (behind[Rules.between(t).length] ?? 0) + 1;
          expect(Rules.between(t).length, Rules.gcd(t.$1, t.$2) - 1, reason: Rules.tell(t));
        }
        if (t.$1 == 1 || t.$2 == 1) expect(Rules.seenByFactor(t), isTrue, reason: Rules.tell(t));
      }
      expect(seen, 63);
      expect(behind, {1: 19, 2: 7, 3: 3, 4: 3, 5: 1, 6: 1, 7: 1, 8: 1, 9: 1});
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The Hidden Edge']);
      for (final level in Levels.all) {
        expect(Rules.trees.where(level.meets).length, level.ways, reason: level.name);
        final aim = level.aim;
        if (aim != null) expect(level.meets(aim), isTrue, reason: level.name);
        if (!level.winnable) expect(aim, isNull);
      }
      expect(Levels.at(0).aim, (1, 10));
      expect(Levels.at(1).aim, (3, 3));
      expect(Levels.at(2).aim, (2, 1));
      expect(Levels.at(3).aim, (8, 7));
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'pick a tree in sight in the tenth row');
      expect(Levels.at(1).task, 'pick a tree hidden behind exactly two others');
      expect(Levels.at(2).task, 'pick a tree in sight that hides four others');
      expect(Levels.at(3).task, 'pick a tree in sight in the far corner, file and row seven or more');
      expect(Levels.at(4).task, 'pick a hidden tree in the first row or the first file');
    });

    test('an ask is met by the tree', () {
      expect(Levels.at(0).meets((3, 10)), isTrue);
      expect(Levels.at(0).meets((2, 10)), isFalse);
      expect(Levels.at(0).meets((3, 9)), isFalse);
      expect(Levels.at(1).meets((6, 9)), isTrue);
      expect(Levels.at(1).meets((4, 6)), isFalse);
      expect(Levels.at(2).meets((1, 2)), isTrue);
      expect(Levels.at(2).meets((1, 1)), isFalse);
      expect(Levels.at(3).meets((9, 10)), isTrue);
      expect(Levels.at(3).meets((8, 8)), isFalse);
      expect(Levels.at(3).meets((6, 7)), isFalse);
      expect(Levels.at(4).meets((1, 5)), isFalse);
      expect(Levels.at(0).meets((0, 10)), isFalse);
    });
  });

  group('the play', () {
    test('opens with no tree picked', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.picked, isNull);
        expect((play.moves, play.seen), (0, false));
        expect(play.isOver, isFalse, reason: level.name);
      }
    });

    test('a tap picks a tree, another moves the pick, and the same again unpicks', () {
      var play = Play.of(Levels.at(4)).tap((6, 9));
      expect(play.picked, (6, 9));
      expect(play.seen, isFalse);
      expect(play.between, [(2, 3), (4, 6)]);
      expect(play.front, (2, 3));
      play = play.tap((1, 2));
      expect(play.picked, (1, 2));
      expect(play.seen, isTrue);
      expect(play.hides, [(2, 4), (3, 6), (4, 8), (5, 10)]);
      expect(play.onEdge, isTrue);
      play = play.tap((1, 2));
      expect(play.picked, isNull);
      expect(play.moves, 3);
      expect(play.tap((0, 3)), same(play));
    });

    test('back undoes one tap', () {
      final play = Play.of(Levels.at(0)).tap((2, 3)).tap((4, 5));
      expect(play.back.picked, (2, 3));
      expect(play.back.back.picked, isNull);
    });

    test('the pointer names the aim', () {
      expect(Play.of(Levels.at(0)).next, (1, 10));
      expect(Play.pointed((1, 10)), 'Tap the tree at (1, 10).');
      expect(Play.of(Levels.at(2)).tap((5, 5)).next, (2, 1));
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('following the pointer lands every winnable ask in one tap', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        final play = Play.of(level).tap(Play.of(level).next!);
        expect(play.isDone, isTrue, reason: level.name);
        expect(play.moves, 1);
      }
    });

    test('the hidden edge admits it after three edge trees, or twelve taps', () {
      var play = Play.of(Levels.at(4)).tap((1, 5));
      expect(play.edgeTries, 1);
      expect(play.gaveUp, isFalse);
      play = play.tap((3, 1)).tap((1, 1));
      expect(play.edgeTries, 3);
      expect(play.gaveUp, isTrue);
      expect(play.next, isNull);
      var wander = Play.of(Levels.at(4));
      for (var k = 0; k < 12; k++) {
        wander = wander.tap((5, 5));
      }
      expect(wander.gaveUp, isTrue);
      expect(wander.moves, 12);
    });

    test('the why tells Euclid and the sweep', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('Euclid\'s orchard'));
      expect(words, contains('63 in sight and 37 hidden'));
      expect(words, contains('This is ask 5, The Hidden Edge.'));
      expect(words, contains('looked at in full'));
    });
  });
}
