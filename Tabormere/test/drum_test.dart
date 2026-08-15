import 'package:flutter_test/flutter_test.dart';
import 'package:tabormere/drum/levels.dart';
import 'package:tabormere/drum/play.dart';
import 'package:tabormere/drum/rules.dart';

/// The rhythms, the sweep, the asks and the play, checked at the domain:
/// nothing here touches a widget.
void main() {
  group('the rhythms', () {
    test('gaps, evenness, and Euclid', () {
      expect(Rules.gaps(8, [0, 3, 6]), [3, 3, 2]);
      expect(Rules.gaps(8, [0, 2, 3, 5, 6]), [2, 1, 2, 1, 2]);
      expect(Rules.isEven(8, [0, 3, 6]), isTrue);
      expect(Rules.isEven(8, [0, 4, 6]), isFalse);
      expect(Rules.isEven(8, [0, 1, 2]), isFalse);
      expect(Rules.isEven(8, [0]), isTrue);
      expect(Rules.isEven(8, []), isTrue);
      expect(Rules.euclid(8, 3), [0, 2, 5]);
      expect(Rules.told(8, Rules.euclid(8, 3)), 'x.x..x..');
      expect(Rules.told(16, Rules.euclid(16, 5)), 'x..x..x..x..x...');
      expect(Rules.turned(8, [0, 2, 5], 1), [1, 3, 6]);
      expect(Rules.turnings(8, [0, 2, 4, 6]), hasLength(2));
      expect(Rules.equalGaps(9, [0, 3, 6]), isTrue);
      expect(Rules.equalGaps(8, [0, 3, 6]), isFalse);
      expect(Rules.choose(8, 3), 56);
    });

    test('the sweep and Euclid agree on every ring to twelve', () {
      var rings = 0;
      for (var n = 1; n <= 12; n++) {
        for (var k = 0; k <= n; k++) {
          rings++;
          final s = Rules.evenBySweep(n, k), e = Rules.evenByEuclid(n, k);
          expect(s.length, e.length, reason: '$k in $n');
          expect(s.containsAll(e), isTrue, reason: '$k in $n');
        }
      }
      expect(rings, 90);
      expect(Rules.evenBySweep(8, 3), hasLength(8));
      expect(Rules.evenBySweep(16, 5), hasLength(16));
      expect(Rules.evenBySweep(12, 7), hasLength(12));
      expect(Rules.patterns(8, 3), hasLength(56));
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The Even Tresillo']);
      for (final level in Levels.all) {
        expect(Rules.patterns(level.steps, level.hits).where(level.meets).length, level.ways, reason: level.name);
        final aim = level.aim;
        if (aim != null) expect(level.meets(aim), isTrue, reason: level.name);
        if (!level.winnable) expect(aim, isNull);
      }
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'set three hits in eight steps as evenly as they can go');
      expect(Levels.at(2).task, 'set five hits in sixteen steps as evenly as they can go');
      expect(Levels.at(4).task, 'set three hits in eight steps with the same gap between every pair');
    });

    test('an ask is met by the count of hits and the spread', () {
      expect(Levels.at(0).meets([0, 3, 6]), isTrue);
      expect(Levels.at(0).meets([1, 4, 7]), isTrue);
      expect(Levels.at(0).meets([0, 4, 6]), isFalse);
      expect(Levels.at(0).meets([0, 3]), isFalse);
      expect(Levels.at(1).meets([0, 2, 3, 5, 6]), isTrue);
      expect(Levels.at(4).meets([0, 3, 6]), isFalse);
    });
  });

  group('the play', () {
    test('opens bare', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.hitsAt, isEmpty);
        expect(play.moves, 0);
        expect(play.isOver, isFalse, reason: level.name);
      }
    });

    test('a tap sets a hit, a second lifts it, and the hits stay sorted', () {
      var play = Play.of(Levels.at(0)).tap(5).tap(2);
      expect(play.hitsAt, [2, 5]);
      expect(play.moves, 2);
      expect(play.gaps, [3, 5]);
      play = play.tap(5);
      expect(play.hitsAt, [2]);
      expect(play.tap(99), same(play));
    });

    test('back undoes one tap', () {
      final play = Play.of(Levels.at(0)).tap(0).tap(3);
      expect(play.back.hitsAt, [0]);
      expect(play.back.back.hitsAt, isEmpty);
    });

    test('the tresillo lands, and it takes no more taps', () {
      final play = Play.of(Levels.at(0)).tap(0).tap(3).tap(6);
      expect(play.isEven, isTrue);
      expect(play.isDone, isTrue);
      expect(play.tap(1), same(play));
    });

    test('too many hits is not done, and told', () {
      final play = Play.of(Levels.at(0)).tap(0).tap(1).tap(2).tap(3);
      expect(play.hitsAt, hasLength(4));
      expect(play.isDone, isFalse);
    });

    test('the pointer lifts strays and sets Euclid\'s hits', () {
      var play = Play.of(Levels.at(0));
      expect(play.next, (Aim.set, 0));
      play = play.tap(1);
      expect(play.next, (Aim.lift, 1));
      play = play.tap(1).tap(0).tap(2);
      expect(play.next, (Aim.set, 5));
      expect(Play.pointed((Aim.set, 5)), 'Set a hit at step 6.');
      expect(Play.pointed((Aim.lift, 1)), 'Lift the hit at step 2.');
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('following the pointer drums every winnable ask', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var steps = 0;
        while (!play.isDone && steps < 30) {
          play = play.tap(play.next!.$2);
          steps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
        expect(play.moves, level.hits, reason: level.name);
      }
    });

    test('the even tresillo admits it at the tresillo, or after twenty taps', () {
      var play = Play.of(Levels.at(4)).tap(0).tap(3);
      expect(play.gaveUp, isFalse);
      play = play.tap(6);
      expect(play.gaps, [3, 3, 2]);
      expect(play.gaveUp, isTrue);
      expect(play.next, isNull);
      var wander = Play.of(Levels.at(4));
      for (var k = 0; k < 20; k++) {
        wander = wander.tap(0);
      }
      expect((wander.moves, wander.gaveUp), (20, true));
    });

    test('the why tells Euclid and the sweep', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('hit i at the floor of i n/k'));
      expect(words, contains('This is ask 5, The Even Tresillo.'));
      expect(words, contains('tried in full'));
    });
  });
}
