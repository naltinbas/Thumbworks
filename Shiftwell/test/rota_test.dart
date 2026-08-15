import 'package:flutter_test/flutter_test.dart';
import 'package:shiftwell/rota/play.dart';
import 'package:shiftwell/rota/rotas.dart';
import 'package:shiftwell/rota/rules.dart';

/// The law of the rota, held to.
void main() {
  group('the rules', () {
    test('every label\'s ways is what the sweep finds', () {
      for (final rota in Rotas.all) {
        expect(Rules(4, rota.fixed).waysBySweep(), rota.ways, reason: rota.name);
        expect(Rules(4, rota.fixed).finishes(), rota.winnable, reason: rota.name);
      }
    });

    test('576 rotas of four, 24 from a fixed first day', () {
      expect(Rules(4, const {}).waysBySweep(), 576);
      expect(Rules(4, const {(0, 0): 1, (0, 1): 2, (0, 2): 3, (0, 3): 4}).waysBySweep(), 24);
      expect(Rules(4, const {(0, 0): 1, (1, 0): 2, (2, 0): 3, (3, 0): 4}).waysBySweep(), 24);
    });

    test('candidates, clashes and the stuck shift', () {
      final rules = Rules(4, const {});
      final fill = {(0, 0): 1, (0, 1): 2, (0, 2): 3, (1, 3): 4};
      expect(rules.candidates(fill, (0, 3)), isEmpty);
      expect(rules.stuck(fill), (0, 3));
      expect(rules.candidates(fill, (1, 0)), [2, 3]);
      expect(rules.clashes(fill), isEmpty);
      final clash = {(0, 0): 1, (0, 1): 1};
      expect(rules.clashes(clash), [(0, 0), (0, 1)]);
      expect(rules.sound(clash), isFalse);
      expect(rules.finished(Rules(4, const {}).landing()!), isTrue);
    });

    test('every fill of three finishes, in 8, 16 or 24 ways', () {
      final spread = <int, int>{};
      var seen = 0;
      Rules.fills(4, 3, (filled) {
        seen++;
        final ways = Rules(4, filled).waysBySweep();
        spread[ways] = (spread[ways] ?? 0) + 1;
      });
      expect(seen, 25920);
      expect(spread.keys.toList()..sort(), [8, 16, 24]);
      expect(spread[24], 1152);
    });

    test('the four fixed finish one way, the diagonal two ways swapped', () {
      final four = Rules(4, Rotas.at(3).fixed);
      expect(four.waysBySweep(), 1);
      final pair = <Map<Shift, int>>[];
      Rules(4, Rotas.at(2).fixed).finishings(Rotas.at(2).fixed, (g) => pair.add(Map.of(g)));
      expect(pair, hasLength(2));
      for (final shift in four.shifts) {
        expect(pair[0][shift], pair[1][(shift.$2, shift.$1)]);
      }
    });
  });

  group('the play', () {
    test('opens with the fixed shifts only', () {
      for (final rota in Rotas.all) {
        final play = Play.of(rota);
        expect(play.filled, rota.fixed, reason: rota.name);
        expect(play.isDone, isFalse);
      }
    });

    test('a tap turns a shift round, and back takes it back', () {
      var play = Play.of(Rotas.at(1));
      play = play.tap((0, 1));
      expect(play.filled[(0, 1)], 1);
      expect(play.moves, 1);
      play = play.tap((0, 1)).tap((0, 1)).tap((0, 1));
      expect(play.filled[(0, 1)], 4);
      play = play.tap((0, 1));
      expect(play.filled.containsKey((0, 1)), isFalse);
      expect(play.moves, 5);
      expect(play.back.filled[(0, 1)], 4);
    });

    test('a fixed shift takes no tap', () {
      final play = Play.of(Rotas.at(1));
      expect(play.touches((0, 0)), isFalse);
      expect(play.tap((0, 0)), same(play));
      expect(play.tap((9, 9)), same(play));
    });

    test('a clash shows, and clears', () {
      var play = Play.of(Rotas.at(1)).tap((0, 1));
      expect(play.clashes, [(0, 0), (0, 1)]);
      play = play.tap((0, 1));
      // Hand 2 clashes down the station with day 2's fixed 2.
      expect(play.clashes, [(0, 1), (1, 1)]);
      play = play.tap((0, 1));
      expect(play.filled[(0, 1)], 3);
      expect(play.clashes, isEmpty);
    });

    test('the four fixed finish by hand', () {
      final aim = Rules(4, Rotas.at(3).fixed).landing()!;
      var play = Play.of(Rotas.at(3));
      for (final entry in aim.entries) {
        if (play.isFixed(entry.key)) continue;
        for (var t = 0; t < entry.value; t++) {
          play = play.tap(entry.key);
        }
      }
      expect(play.isDone, isTrue);
      expect(play.tap((1, 1)), same(play));
    });

    test('the pointer finishes the first day and the diagonal', () {
      for (final number in [0, 2]) {
        var play = Play.of(Rotas.at(number));
        var guard = 0;
        while (!play.isDone && guard++ < 20) {
          final (shift, hand) = play.next!;
          while (play.filled[shift] != hand) {
            play = play.tap(shift);
          }
        }
        expect(play.isDone, isTrue, reason: '$number');
      }
    });

    test('the pointer keeps the sound shifts the player set', () {
      // Day 2, station 1 set to 3 is sound with the first day fixed,
      // and some finishing keeps it: the pointer aims elsewhere.
      final play = Play.of(Rotas.at(0)).tap((1, 0)).tap((1, 0)).tap((1, 0));
      expect(play.filled[(1, 0)], 3);
      expect(play.clashes, isEmpty);
      final (shift, _) = play.next!;
      expect(shift, isNot((1, 0)));
    });

    test('the hopeless rota admits it at fourteen taps', () {
      var play = Play.of(Rotas.at(4));
      for (var tap = 0; tap < 14; tap++) {
        play = play.tap((0, 3));
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.filled[(0, 3)], 4);
      expect(play.clashes, [(0, 3), (1, 3)]);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.next, isNull);
    });

    test('a winnable rota never gives up', () {
      var play = Play.of(Rotas.at(0));
      for (var tap = 0; tap < 15; tap++) {
        play = play.tap((1, 0));
      }
      expect(play.moves, 15);
      expect(play.gaveUp, isFalse);
    });

    test('the mark stands finished', () {
      final mark = Play.standing(Rotas.at(3), Rules(4, Rotas.at(3).fixed).landing()!);
      expect(mark.isDone, isTrue);
    });
  });
}
