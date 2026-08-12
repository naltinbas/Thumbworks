import 'package:flutter_test/flutter_test.dart';
import 'package:peckhollow/yard/play.dart';
import 'package:peckhollow/yard/rules.dart';
import 'package:peckhollow/yard/yards.dart';

void main() {
  group('the crowns', () {
    test('a king reaches every bird in one peck or two', () {
      // The pecking order of three: the top bird alone is king.
      expect(Rules.kings(3, 7), [0]);
      // The ring of three: everyone is.
      // Pairs of three birds: (0,1), (0,2), (1,2). Bits 1,0,1 make
      // 0 peck 1, 2 peck 0, 1 peck 2: the ring.
      expect(Rules.kings(3, 5), [0, 1, 2]);
    });

    test('every yard has a king and the biggest winner is one', () {
      for (final birds in const [3, 4, 5]) {
        final count = Rules.pairs(birds).length;
        for (var arrows = 0; arrows < (1 << count); arrows++) {
          final kings = Rules.kings(birds, arrows);
          expect(kings, isNotEmpty);
          expect(
            kings,
            contains(Rules.biggestWinner(birds, arrows)),
            reason: '$birds birds, arrows $arrows',
          );
        }
      }
    });

    test('no yard crowns exactly two, and four birds never crown '
        'four', () {
      expect(Rules.crownings(3), {1: 6, 3: 2});
      expect(Rules.crownings(4), {1: 32, 3: 32});
      final fives = Rules.crownings(5);
      expect(fives[2], isNull);
      expect(fives[3], 520);
      expect(fives[5], 64);
      expect(fives[1]! + fives[3]! + fives[4]! + fives[5]!, 1024);
    });

    test('any king\'s peckers hide another king', () {
      for (final birds in const [3, 4]) {
        final count = Rules.pairs(birds).length;
        for (var arrows = 0; arrows < (1 << count); arrows++) {
          final kings = Rules.kings(birds, arrows);
          final table = Rules.pecks(birds, arrows);
          for (final king in kings) {
            final peckers = [
              for (var bird = 0; bird < birds; bird++)
                if (table[bird][king]) bird,
            ];
            if (peckers.isEmpty) continue;
            expect(
              peckers.any(kings.contains),
              isTrue,
              reason: '$birds birds, arrows $arrows, king $king',
            );
          }
        }
      }
    });

    test('the walk finds the written pars', () {
      for (final yard in Yards.all) {
        final walked =
            Rules.flipsTo(yard.birds, yard.start, yard.goalMet);
        expect(walked, yard.winnable ? yard.par : -1,
            reason: yard.name);
      }
    });
  });

  group('a play', () {
    test('opens at the pecking order with the top bird crowned', () {
      final play = Play.of(Yards.at(1));
      expect(play.arrows, 63);
      expect(play.kings, [0]);
      expect(play.flips, 0);
      expect(play.pecksOf(0, 3), isTrue);
      expect(play.pecksOf(3, 0), isFalse);
    });

    test('a flip turns one arrow and counts', () {
      final play = Play.of(Yards.at(0)).flip(1);
      expect(play.flips, 1);
      expect(play.pecksOf(2, 0), isTrue);
      expect(play.isDone, isTrue);
      expect(play.kings, [0, 1, 2]);
    });

    test('back unflips', () {
      final play = Play.of(Yards.at(0)).flip(1);
      expect(play.back.arrows, Yards.at(0).start);
      expect(play.back.flips, 0);
    });

    test('following the pointer crowns every winnable yard in its '
        'par', () {
      for (final yard in Yards.all.where((yard) => yard.winnable)) {
        var play = Play.of(yard);
        var guard = 0;
        while (!play.isDone) {
          if (guard++ > 6) fail('${yard.name} never crowned');
          play = play.flip(play.next!);
        }
        expect(play.flips, yard.par, reason: yard.name);
      }
    });

    test('the two kings never come, and the yard gives up at the '
        'line', () {
      var play = Play.of(Yards.at(4));
      expect(play.toDone, -1);
      expect(play.next, isNull);
      for (var flip = 0; flip < Play.gaveUpAt; flip++) {
        expect(play.isOver, isFalse);
        play = play.flip(flip % 6);
        expect(play.kings.length, isNot(2));
      }
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
    });
  });
}
