import 'package:flutter_test/flutter_test.dart';
import 'package:gablewick/gable/levels.dart';
import 'package:gablewick/gable/play.dart';
import 'package:gablewick/gable/rules.dart';

/// Heron, the height, the asks and the play, checked at the domain:
/// nothing here touches a widget.
void main() {
  group('the gable', () {
    test('closing, Heron and the height', () {
      expect(Rules.closes(3, 4, 5), isTrue);
      expect(Rules.closes(1, 2, 3), isFalse);
      expect(Rules.sixteenAreaSquared(3, 4, 5), 16 * 36);
      expect(Rules.sixteenAreaSquared(13, 14, 15), 16 * 84 * 84);
      expect(Rules.sixteenAreaSquared(3, 4, 6), 455);
      for (final (a, b, c) in Rules.triangles) {
        expect(Rules.sixteenAreaSquaredByHeight(a, b, c), Rules.sixteenAreaSquared(a, b, c), reason: '$a-$b-$c');
      }
      expect(Rules.triangles, hasLength(372));
    });

    test('whole areas', () {
      expect(Rules.wholeArea(3, 4, 5), 6);
      expect(Rules.wholeArea(5, 4, 3), 6);
      expect(Rules.wholeArea(13, 14, 15), 84);
      expect(Rules.wholeArea(5, 5, 6), 12);
      expect(Rules.wholeArea(3, 4, 6), isNull);
      expect(Rules.wholeArea(1, 1, 1), isNull);
      expect(Rules.wholeArea(1, 2, 3), isNull);
      expect(Rules.area(3, 4, 6), closeTo(5.33, 0.01));
      final whole = Rules.triangles.where((t) => Rules.wholeArea(t.$1, t.$2, t.$3) != null).toList();
      expect(whole, hasLength(10));
      expect(whole.every((t) => Rules.wholeArea(t.$1, t.$2, t.$3)! % 6 == 0), isTrue);
      expect(whole.any((t) => Rules.allOdd(t.$1, t.$2, t.$3)), isFalse);
      expect(Rules.isRight(3, 4, 5), isTrue);
      expect(Rules.isRight(5, 5, 6), isFalse);
      expect(Rules.isIsosceles(5, 5, 6), isTrue);
      expect(Rules.sorted(15, 13, 14), (13, 14, 15));
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The Three Odds']);
      for (final level in Levels.all) {
        expect(Rules.triangles.where((t) => level.meets(t.$1, t.$2, t.$3)).length, level.ways, reason: level.name);
        final aim = level.aim;
        if (aim != null) expect(level.meets(aim.$1, aim.$2, aim.$3), isTrue, reason: level.name);
        if (!level.winnable) expect(aim, isNull);
      }
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'set the sides so the area is a whole number and one corner is a right angle');
      expect(Levels.at(1).task, 'set the sides so the area is exactly 12');
      expect(Levels.at(4).task, 'set the sides so the area is a whole number and all three sides are odd');
    });

    test('an ask is met in any order of the sides', () {
      expect(Levels.at(0).meets(5, 3, 4), isTrue);
      expect(Levels.at(0).meets(5, 5, 6), isFalse);
      expect(Levels.at(1).meets(8, 5, 5), isTrue);
      expect(Levels.at(2).meets(13, 10, 13), isTrue);
      expect(Levels.at(2).meets(3, 4, 5), isFalse);
      expect(Levels.at(3).meets(15, 14, 13), isTrue);
      expect(Levels.at(3).meets(6, 8, 10), isFalse);
      expect(Levels.at(4).meets(3, 5, 7), isFalse);
    });
  });

  group('the play', () {
    test('opens on 3, 4, 6, landing nothing', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.sides, [3, 4, 6]);
        expect(play.wholeArea, isNull);
        expect(play.isOver, isFalse, reason: level.name);
      }
    });

    test('a tap turns a side a step, and a dial at its end stays', () {
      var play = Play.of(Levels.at(0)).set(2, -1);
      expect(play.sides, [3, 4, 5]);
      expect(play.moves, 1);
      expect(play.isDone, isTrue);
      expect(play.set(0, 1), same(play));
      final low = Play.standing(Levels.at(1), 1, 1, 1);
      expect(low.set(0, -1), same(low));
      final high = Play.standing(Levels.at(1), 15, 15, 15);
      expect(high.set(2, 1), same(high));
      expect(high.set(2, -1).c, 14);
      expect(high.set(0, 0), same(high));
    });

    test('back undoes one tap', () {
      final play = Play.of(Levels.at(1)).set(0, 1).set(1, 1);
      expect(play.back.sides, [4, 4, 6]);
      expect(play.back.back.sides, [3, 4, 6]);
    });

    test('the pointer walks side by side to the aim', () {
      var play = Play.of(Levels.at(3));
      expect(play.next, (0, 1));
      var steps = 0;
      while (!play.isDone && steps < 40) {
        play = play.set(play.next!.$1, play.next!.$2);
        steps++;
      }
      expect(play.sides, [13, 14, 15]);
      expect(play.isDone, isTrue);
      expect(play.next, isNull);
      expect(Play.pointed((1, -1)), 'Shorten the second side.');
      expect(Play.pointed((2, 1)), 'Lengthen the third side.');
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('following the pointer frames every winnable ask', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var steps = 0;
        while (!play.isDone && steps < 40) {
          play = play.set(play.next!.$1, play.next!.$2);
          steps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
      }
    });

    test('the three odds admit it once three odd sides close, or after thirty taps', () {
      var play = Play.of(Levels.at(4)).set(1, 1);
      expect(play.sides, [3, 5, 6]);
      expect(play.gaveUp, isFalse);
      play = play.set(2, 1);
      expect(play.sides, [3, 5, 7]);
      expect(play.closes, isTrue);
      expect(play.gaveUp, isTrue);
      expect(play.sixteenAreaSquared.isOdd, isTrue);
      expect(play.next, isNull);
      var wander = Play.of(Levels.at(4));
      for (var k = 0; k < 30; k++) {
        wander = wander.set(0, k.isEven ? 1 : -1);
      }
      expect((wander.moves, wander.gaveUp), (30, true));
    });

    test('the why tells Heron and the sweep', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('Heron of Alexandria'));
      expect(words, contains('This is ask 5, The Three Odds.'));
      expect(words, contains('372 of them, tried in full'));
    });
  });
}
