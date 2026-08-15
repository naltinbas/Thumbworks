import 'package:flutter_test/flutter_test.dart';
import 'package:crownwick/kings/levels.dart';
import 'package:crownwick/kings/play.dart';
import 'package:crownwick/kings/rules.dart';

/// The law of the kings, held to.
void main() {
  group('the rules', () {
    test('a king attacks the eight squares round it', () {
      const r = Rules(4);
      expect(r.attacks(0), [1, 4, 5]);
      expect(r.attacks(5), [0, 1, 2, 4, 6, 8, 9, 10]);
      expect(r.clashes([0, 1]), [(0, 1)]);
      expect(r.clashes([0, 2, 8, 10]), isEmpty);
      expect(r.lands([0, 2, 8, 10], 4), isTrue);
      expect(r.lands([0, 2, 8], 4), isFalse);
      expect(r.lands([0, 1, 8, 10], 4), isFalse);
    });

    test('the walk and the sweep agree on the small boards', () {
      expect(const Rules(3).walk(4), 1);
      expect(const Rules(3).sweep(4), (1, 126));
      expect(const Rules(4).walk(4), 79);
      expect(const Rules(4).sweep(4), (79, 1820));
      expect(const Rules(4).walk(5), 0);
      expect(const Rules(4).sweep(5), (0, 4368));
      expect(const Rules(4).settings(4), 1820);
      expect(Rules.choose(36, 9), 94143280);
    });

    test('the blocks cut the board and bound it', () {
      for (var n = 2; n <= 6; n++) {
        final r = Rules(n);
        final seen = <int>{};
        for (final block in r.blocks) {
          for (final a in block) {
            expect(seen.add(a), isTrue, reason: '$n by $n');
            for (final b in block) {
              if (a != b) expect(r.attacks(a), contains(b), reason: '$n by $n');
            }
          }
        }
        expect(seen, hasLength(r.squares), reason: '$n by $n');
        final half = (n + 1) ~/ 2;
        expect(r.bound, half * half, reason: '$n by $n');
        expect(r.walk(r.bound), greaterThan(0), reason: '$n by $n');
        expect(r.walk(r.bound + 1), 0, reason: '$n by $n');
        expect(r.evens, hasLength(r.bound), reason: '$n by $n');
        expect(r.clashes(r.evens), isEmpty, reason: '$n by $n');
        if (n.isOdd) expect(r.walk(r.bound), 1, reason: '$n by $n');
      }
      expect(const Rules(3).blocks.map((b) => b.length).toList(), [4, 2, 2, 1]);
    });

    test('every label\'s ways is what the walk finds', () {
      for (final level in Levels.all) {
        expect(level.rules.walk(level.kings), level.ways, reason: level.name);
        expect(level.rules.settings(level.kings), level.settings, reason: level.name);
      }
    });
  });

  group('the play', () {
    test('opens with an empty board', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.kings, isEmpty, reason: level.name);
        expect(play.isDone, isFalse);
      }
    });

    test('a tap sets, a tap lifts, counted both ways; back undoes', () {
      var play = Play.of(Levels.at(1));
      play = play.tap(0);
      expect(play.kings, [0]);
      play = play.tap(0);
      expect(play.kings, isEmpty);
      expect(play.moves, 2);
      expect(play.back.kings, [0]);
      expect(play.tap(16), same(play));
    });

    test('the boards by hand', () {
      final three = Play.of(Levels.at(0)).tap(0).tap(2).tap(6).tap(8);
      expect(three.isDone, isTrue);
      expect(three.tap(4), same(three));
      final clash = Play.of(Levels.at(1)).tap(0).tap(1);
      expect(clash.clashes, [(0, 1)]);
      final four = Play.of(Levels.at(1)).tap(0).tap(2).tap(8).tap(10);
      expect(four.isDone, isTrue);
      final other = Play.of(Levels.at(1)).tap(0).tap(3).tap(12).tap(15);
      expect(other.isDone, isTrue);
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
      for (final c in [0, 2, 8, 10, 5]) {
        play = play.tap(c);
      }
      expect(play.clashes, [(0, 5), (2, 5), (5, 8), (5, 10)]);
      for (var k = 0; k < 8; k++) {
        play = play.tap(5);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.has(5), isTrue);
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
      final mark = Play.standing(Levels.at(2), Play.aimFor(Levels.at(2)));
      expect(mark.isDone, isTrue);
    });
  });
}
