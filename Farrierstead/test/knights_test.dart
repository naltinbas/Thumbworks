import 'package:flutter_test/flutter_test.dart';
import 'package:farrierstead/knights/levels.dart';
import 'package:farrierstead/knights/play.dart';
import 'package:farrierstead/knights/rules.dart';

/// The law of the knights, held to.
void main() {
  group('the rules', () {
    test('a knight attacks two along and one across', () {
      const r = Rules(4);
      expect(r.attacks(0), [6, 9]);
      expect(r.attacks(5), unorderedEquals([3, 11, 12, 14]));
      expect(r.clashes([0, 6]), [(0, 6)]);
      expect(r.clashes([0, 5, 10, 15]), isEmpty);
      expect(r.lands([0, 2, 5, 7, 8, 10, 13, 15], 8), isTrue);
      expect(r.lands([0, 2, 5, 7, 8, 10, 13], 8), isFalse);
      expect(r.lands([0, 2, 5, 6, 8, 10, 13, 15], 8), isFalse);
    });

    test('the walk and the sweep agree on the small boards', () {
      expect(const Rules(3).walk(5), 2);
      expect(const Rules(3).sweep(5), (2, 126));
      expect(const Rules(4).walk(8), 6);
      expect(const Rules(4).sweep(8), (6, 12870));
      expect(const Rules(4).walk(9), 0);
      expect(const Rules(4).sweep(9), (0, 11440));
      expect(const Rules(4).settings(8), 12870);
      expect(Rules.choose(36, 18), 9075135300);
    });

    test('the pairing is knight\'s moves, disjoint, and bounds the board', () {
      for (var n = 3; n <= 6; n++) {
        final r = Rules(n);
        final seen = <int>{};
        for (final (a, b) in r.pairing) {
          expect(r.attacks(a), contains(b), reason: '$n by $n');
          expect(seen.add(a) && seen.add(b), isTrue, reason: '$n by $n');
        }
        expect(r.bound, (n * n + 1) ~/ 2, reason: '$n by $n');
        expect(r.walk(r.bound), greaterThan(0), reason: '$n by $n');
        expect(r.walk(r.bound + 1), 0, reason: '$n by $n');
        expect(r.oneColour, hasLength(r.bound), reason: '$n by $n');
        expect(r.clashes(r.oneColour), isEmpty, reason: '$n by $n');
      }
      expect(const Rules(3).pairing, hasLength(4));
      expect(const Rules(2).pairing, isEmpty);
    });

    test('every label\'s ways is what the walk finds', () {
      for (final level in Levels.all) {
        expect(level.rules.walk(level.knights), level.ways, reason: level.name);
        expect(level.rules.settings(level.knights), level.settings, reason: level.name);
      }
    });
  });

  group('the play', () {
    test('opens with an empty board', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.knights, isEmpty, reason: level.name);
        expect(play.isDone, isFalse);
      }
    });

    test('a tap sets, a tap lifts, counted both ways; back undoes', () {
      var play = Play.of(Levels.at(1));
      play = play.tap(0);
      expect(play.knights, [0]);
      play = play.tap(0);
      expect(play.knights, isEmpty);
      expect(play.moves, 2);
      expect(play.back.knights, [0]);
      expect(play.tap(16), same(play));
    });

    test('the boards by hand', () {
      final three = Play.of(Levels.at(0)).tap(0).tap(2).tap(4).tap(6).tap(8);
      expect(three.isDone, isTrue);
      expect(three.tap(1), same(three));
      final clash = Play.of(Levels.at(1)).tap(0).tap(6);
      expect(clash.clashes, [(0, 6)]);
      final four = Play.of(Levels.at(1)).tap(0).tap(2).tap(5).tap(7).tap(8).tap(10).tap(13).tap(15);
      expect(four.isDone, isTrue);
    });

    test('the pointer seats every winnable board', () {
      for (final number in [0, 1, 2, 3]) {
        var play = Play.of(Levels.at(number));
        var guard = 0;
        while (!play.isDone && guard++ < 40) {
          final (_, c) = play.next!;
          play = play.tap(c);
        }
        expect(play.isDone, isTrue, reason: '$number');
      }
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('the pointer says set or lift', () {
      final play = Play.of(Levels.at(2));
      expect(play.next, ('set', 0));
      expect(play.tap(0).next, ('set', 2));
      expect(play.tap(1).next, ('lift', 1));
    });

    test('the hopeless board admits it at thirteen taps', () {
      var play = Play.of(Levels.at(4));
      for (final c in [0, 2, 5, 7, 8, 10, 13, 15, 1]) {
        play = play.tap(c);
      }
      expect(play.clashes, [(1, 7), (1, 8), (1, 10)]);
      for (var k = 0; k < 4; k++) {
        play = play.tap(1);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.has(1), isTrue);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.tap(3), same(play));
    });

    test('a winnable board never gives up', () {
      var play = Play.of(Levels.at(1));
      for (var k = 0; k < 14; k++) {
        play = play.tap(0);
      }
      expect(play.moves, 14);
      expect(play.gaveUp, isFalse);
    });

    test('the mark stands seated', () {
      final mark = Play.standing(Levels.at(1), Play.aimFor(Levels.at(1)));
      expect(mark.isDone, isTrue);
    });
  });
}
