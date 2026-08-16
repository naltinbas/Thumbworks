import 'package:flutter_test/flutter_test.dart';
import 'package:threefold/green/levels.dart';
import 'package:threefold/green/play.dart';
import 'package:threefold/green/rules.dart';

/// The rungs, the areas, the asks and the play, checked at the domain:
/// nothing here touches a widget.
void main() {
  group('the green', () {
    test('points, rungs and areas', () {
      expect(Rules.points, hasLength(91));
      expect(Rules.count, 91);
      expect(Rules.wholeArea, 288);
      for (final p in Rules.points) {
        expect(Rules.rungsAdded(p), 12, reason: '$p');
        final (a, b, c) = Rules.areas(p);
        expect(a + b + c, 288, reason: '$p');
        expect(Rules.areasSayRungs(p), isTrue, reason: '$p');
      }
      expect(Rules.areas((4, 4, 4)), (96, 96, 96));
      expect(Rules.areas((0, 6, 6)), (0, 144, 144));
      expect(Rules.doubled((0, 12, 0)), (0, 0));
      expect(Rules.doubled((0, 0, 12)), (24, 0));
      expect(Rules.doubled((12, 0, 0)), (12, 12));
      expect(Rules.told((1, 2, 9)), 'floor 1, right slope 2, left slope 9');
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The Longer Walk']);
      for (final level in Levels.all) {
        expect(Rules.points.where(level.meets).length, level.ways, reason: level.name);
        final aim = level.aim;
        if (aim != null) expect(level.meets(aim), isTrue, reason: level.name);
        if (!level.winnable) expect(aim, isNull);
      }
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'stand where the three distances to the sides are all alike');
      expect(Levels.at(1).task, 'stand where the three distances are 1, 2 and 9 rungs, in any order');
      expect(Levels.at(4).task, 'stand where the three distances add up to more than the height');
    });

    test('an ask is met in any order of the rungs', () {
      expect(Levels.at(0).meets((4, 4, 4)), isTrue);
      expect(Levels.at(0).meets((3, 4, 5)), isFalse);
      expect(Levels.at(1).meets((9, 1, 2)), isTrue);
      expect(Levels.at(1).meets((9, 2, 1)), isTrue);
      expect(Levels.at(1).meets((8, 2, 2)), isFalse);
      expect(Levels.at(2).meets((6, 0, 6)), isTrue);
      expect(Levels.at(2).meets((0, 0, 12)), isFalse);
      expect(Levels.at(3).meets((6, 4, 2)), isTrue);
      expect(Levels.at(3).meets((3, 3, 6)), isFalse);
      expect(Levels.at(4).meets((12, 0, 0)), isFalse);
    });
  });

  group('the play', () {
    test('opens at 3, 3 and 6, landing nothing', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.at, (3, 3, 6));
        expect(play.moves, 0);
        expect(play.isOver, isFalse, reason: level.name);
      }
    });

    test('a tap moves the walker to a point of the green, and nowhere else', () {
      var play = Play.of(Levels.at(0)).tap((5, 5, 2));
      expect((play.at, play.moves), ((5, 5, 2), 1));
      expect(play.tap((5, 5, 2)), same(play));
      expect(play.tap((5, 5, 3)), same(play));
      expect(play.tap((-1, 6, 7)), same(play));
      play = play.tap((4, 4, 4));
      expect(play.isDone, isTrue);
      expect(play.tap((1, 2, 9)), same(play));
    });

    test('back undoes one tap', () {
      final play = Play.of(Levels.at(0)).tap((5, 5, 2)).tap((6, 6, 0));
      expect(play.back.at, (5, 5, 2));
      expect(play.back.back.at, (3, 3, 6));
    });

    test('the pointer names the aim, and goes quiet once stood on', () {
      var play = Play.of(Levels.at(1));
      expect(play.next, (1, 2, 9));
      play = play.tap((1, 2, 9));
      expect(play.isDone, isTrue);
      expect(play.next, isNull);
      expect(Play.pointed((1, 2, 9)), 'Stand on the ringed point, floor 1, right slope 2, left slope 9.');
      expect(Play.of(Levels.at(4)).next, isNull);
      for (final level in Levels.all.where((l) => l.winnable)) {
        final p = Play.of(level).tap(Play.of(level).next!);
        expect(p.isDone, isTrue, reason: level.name);
      }
    });

    test('the longer walk admits it at a corner, or after twenty taps', () {
      var play = Play.of(Levels.at(4)).tap((0, 6, 6));
      expect(play.gaveUp, isFalse);
      play = play.tap((12, 0, 0));
      expect(play.gaveUp, isTrue);
      expect(play.sum, 12);
      expect(play.next, isNull);
      var wander = Play.of(Levels.at(4));
      for (var k = 0; k < 20; k++) {
        wander = wander.tap(k.isEven ? (1, 5, 6) : (2, 5, 5));
      }
      expect((wander.moves, wander.gaveUp), (20, true));
    });

    test('the why tells Viviani and the sweep', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('Viviani saw why in the 1600s'));
      expect(words, contains('This is ask 5, The Longer Walk.'));
      expect(words, contains('tried in full'));
    });
  });
}
