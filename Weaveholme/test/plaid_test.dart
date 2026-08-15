import 'package:flutter_test/flutter_test.dart';
import 'package:weaveholme/plaid/levels.dart';
import 'package:weaveholme/plaid/play.dart';
import 'package:weaveholme/plaid/rules.dart';

/// The law of the plaid, held to.
void main() {
  group('the rules', () {
    test('rows agree square by square', () {
      const r = Rules(4);
      expect(r.agree(0, 0), 4);
      expect(r.agree(0, 15), 0);
      expect(r.agree(0, 10), 2);
      expect(r.even(0, 10), isTrue);
      expect(r.even(0, 8), isFalse);
      expect(r.uneven([0, 10, 12, 6]), isEmpty);
      expect(r.uneven([0, 10, 12, 8]), [(0, 3), (1, 3), (2, 3)]);
      expect(r.lands([0, 10, 12, 6]), isTrue);
      expect(r.lands([0, 10, 12]), isFalse);
      expect(Rules.dark(10, 1), isTrue);
      expect(Rules.dark(10, 0), isFalse);
    });

    test('Sylvester\'s plaids land', () {
      expect(Rules.sylvester(2), [0, 2]);
      expect(Rules.sylvester(4), [0, 10, 12, 6]);
      expect(Rules.sylvester(8), [0, 170, 204, 102, 240, 90, 60, 150]);
      for (final n in [2, 4, 8]) {
        expect(Rules(n).lands(Rules.sylvester(n)), isTrue, reason: '$n');
      }
    });

    test('the sweep, the walk and the triples', () {
      expect(const Rules(2).sweep(), (8, 16));
      expect(const Rules(4).sweep(), (768, 65536));
      expect(const Rules(4).walk(const []).$1, 768);
      expect(const Rules(8).walk(Rules.sylvester(8).sublist(0, 6)).$1, 8);
      expect(const Rules(8).walk(Rules.sylvester(8).sublist(0, 4)).$1, 768);
      expect(const Rules(6).triples(), (0, 262144));
      expect(const Rules(4).triples().$1, greaterThan(0));
    });

    test('every label\'s ways is what the sweep or the walk finds', () {
      for (final level in Levels.all) {
        if (level.size <= 4) {
          expect(level.rules.sweep(), (level.ways, level.fillings), reason: level.name);
        } else if (level.size == 8) {
          expect(level.rules.walk(level.given).$1, level.ways, reason: level.name);
        } else {
          expect(level.rules.triples().$1, 0, reason: level.name);
        }
      }
    });
  });

  group('the play', () {
    test('opens with the given rows and the rest light', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.rows.length, level.size, reason: level.name);
        expect(play.rows.sublist(0, level.given.length), level.given);
        expect(play.isDone, isFalse);
      }
    });

    test('a flip turns a square, a given row stays; back undoes', () {
      var play = Play.of(Levels.at(1));
      play = play.flip(1, 1);
      expect(play.dark(1, 1), isTrue);
      expect(play.moves, 1);
      play = play.flip(1, 1);
      expect(play.dark(1, 1), isFalse);
      expect(play.back.dark(1, 1), isTrue);
      final eight = Play.of(Levels.at(2));
      expect(eight.flip(0, 0), same(eight));
      expect(eight.flip(6, 0).dark(6, 0), isTrue);
      expect(play.flip(4, 0), same(play));
    });

    test('the four by hand, Sylvester\'s way', () {
      var play = Play.of(Levels.at(1));
      for (final (r, c) in [(1, 1), (1, 3), (2, 2), (2, 3), (3, 1), (3, 2)]) {
        play = play.flip(r, c);
      }
      expect(play.rows, [0, 10, 12, 6]);
      expect(play.isDone, isTrue);
      expect(play.moves, 6);
      expect(play.flip(0, 0), same(play));
    });

    test('the pointer weaves every winnable plaid', () {
      for (final number in [0, 1, 2, 3]) {
        var play = Play.of(Levels.at(number));
        var guard = 0;
        while (!play.isDone && guard++ < 40) {
          final (r, c) = play.next!;
          play = play.flip(r, c);
        }
        expect(play.isDone, isTrue, reason: '$number');
      }
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('the hopeless plaid admits it at thirty flips', () {
      var play = Play.of(Levels.at(4));
      for (var k = 0; k < 30; k++) {
        play = play.flip(k % 6, (k ~/ 6) % 6);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.uneven, isNotEmpty);
      expect(play.flip(0, 0), same(play));
    });

    test('a winnable plaid never gives up', () {
      var play = Play.of(Levels.at(1));
      for (var k = 0; k < 32; k++) {
        play = play.flip(1, 0);
      }
      expect(play.moves, 32);
      expect(play.gaveUp, isFalse);
    });

    test('the mark stands woven', () {
      final mark = Play.standing(Levels.at(3), Rules.sylvester(8));
      expect(mark.isDone, isTrue);
    });
  });
}
