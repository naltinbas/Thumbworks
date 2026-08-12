import 'package:flutter_test/flutter_test.dart';
import 'package:hamperfen/basket/fens.dart';
import 'package:hamperfen/basket/play.dart';
import 'package:hamperfen/basket/rules.dart';

/// The law of the fen, held to.
void main() {
  group('the rules', () {
    test('swallowing runs by containment, either way round', () {
      expect(Rules.swallows(1, 3), isTrue);
      expect(Rules.swallows(3, 1), isTrue);
      expect(Rules.swallows(1, 2), isFalse);
      expect(Rules.swallows(5, 5), isFalse);
      expect(Rules.swallows(0, 9), isTrue);
    });

    test('every label\'s ways is what the sweep finds', () {
      for (final fen in Fens.all) {
        expect(Rules.waysTo(fen.take), fen.ways,
            reason: fen.name);
      }
    });

    test('the six is the middle shelf and stands alone', () {
      final six = Rules.family(6)!;
      expect(six.every((basket) => Rules.herbs(basket) == 2),
          isTrue);
      expect(Rules.waysTo(6), 1);
      expect(Rules.family(7), isNull);
    });

    test('every free five is the middle shelf less one', () {
      Rules.families(5, (family) {
        if (!Rules.free(family)) return;
        expect(
          family.every((basket) => Rules.herbs(basket) == 2),
          isTrue,
        );
      });
    });

    test('the weighing holds and tops out at whole shelves', () {
      expect(Rules.lymHolds(), isTrue);
      expect(Rules.weighed([0]), 12);
      expect(Rules.weighed([3, 5, 6, 9, 10, 12]), 12);
      expect(Rules.weighed([1, 2, 4, 8]), 12);
    });
  });

  group('the play', () {
    test('taps take and hand back', () {
      var play = Play.of(Fens.at(0));
      play = play.tapAt(3);
      expect(play.taken, [3]);
      expect(play.moves, 1);
      play = play.tapAt(3);
      expect(play.taken, isEmpty);
      expect(play.moves, 2);
    });

    test('a full picking refuses another basket', () {
      var play = Play.of(Fens.at(0)).tapAt(1).tapAt(3);
      expect(play.taken, hasLength(2));
      expect(play.isDone, isFalse);
      expect(play.tapAt(5), same(play));
      expect(play.tapAt(1).taken, [3]);
    });

    test('a free pair lands', () {
      final play = Play.of(Fens.at(0)).tapAt(3).tapAt(5);
      expect(play.swallowings, isEmpty);
      expect(play.isDone, isTrue);
      expect(play.tapAt(6), same(play));
    });

    test('a swallowing blocks the landing', () {
      final play = Play.of(Fens.at(0)).tapAt(1).tapAt(3);
      expect(play.swallowings, [(1, 3)]);
      expect(play.isDone, isFalse);
    });

    test('back takes back a taking', () {
      var play = Play.of(Fens.at(0)).tapAt(3);
      expect(play.back.taken, isEmpty);
      expect(play.back.moves, 0);
      expect(Play.of(Fens.at(0)).back.moves, 0);
    });

    test('show me picks the fen home', () {
      var play = Play.of(Fens.at(3));
      var guard = 0;
      while (!play.isDone && guard++ < 12) {
        final aim = play.next;
        expect(aim, isNotNull);
        expect(aim!.$2, isTrue);
        play = play.tapAt(aim.$1);
      }
      expect(play.isDone, isTrue);
      expect(play.taken.toSet(), {3, 5, 6, 9, 10, 12});
    });

    test('show me hands a stray back first', () {
      final play = Play.of(Fens.at(3)).tapAt(1);
      final aim = play.next;
      expect(aim, isNotNull);
      expect(aim!.$1, 1);
      expect(aim.$2, isFalse);
    });

    test('the hopeless fen has nothing to point at', () {
      expect(Play.of(Fens.at(4)).next, isNull);
    });

    test('the hopeless fen admits it after fourteen takings', () {
      // The picking caps at seven, so the dither takes and hands
      // back one basket: every touch counts.
      var play = Play.of(Fens.at(4));
      for (var taking = 0; taking < Play.gaveUpAt; taking++) {
        expect(play.gaveUp, isFalse);
        play = play.tapAt(0);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.isDone, isFalse);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
    });

    test('a winnable fen never gives up', () {
      var play = Play.of(Fens.at(1));
      for (var taking = 0; taking < Play.gaveUpAt; taking++) {
        play = play.tapAt(0);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.gaveUp, isFalse);
    });
  });
}
