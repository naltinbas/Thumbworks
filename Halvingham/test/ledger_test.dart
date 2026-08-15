import 'package:flutter_test/flutter_test.dart';
import 'package:halvingham/ledger/levels.dart';
import 'package:halvingham/ledger/play.dart';
import 'package:halvingham/ledger/rules.dart';

/// The law of the ledger, held to.
void main() {
  group('the rules', () {
    test('the rows halve and double', () {
      const r = Rules(13, 7);
      expect(r.rows, [(13, 7), (6, 14), (3, 28), (1, 56)]);
      expect(r.oddRows, [0, 2, 3]);
      expect(r.sumOf([0, 2, 3]), 91);
      expect(r.product, 91);
      expect(r.lands([0, 2, 3]), isTrue);
      expect(r.lands([0, 2, 3], exactly: 2), isFalse);
      expect(r.lands([2, 3]), isFalse);
      expect(const Rules(40, 25).rows, [(40, 25), (20, 50), (10, 100), (5, 200), (2, 400), (1, 800)]);
      expect(const Rules(1, 9).rows, [(1, 9)]);
    });

    test('the sweeps of the ledgers', () {
      expect(const Rules(13, 7).sweep(), (1, 16));
      expect(const Rules(13, 7).sweep(exactly: 2), (0, 6));
      expect(const Rules(13, 7).sweep(exactly: 3), (1, 4));
      expect(const Rules(99, 9).sweep(), (1, 128));
    });

    test('every pair to twenty by twenty: the odd rows land, alone', () {
      for (var a = 1; a <= 20; a++) {
        for (var b = 1; b <= 20; b++) {
          final r = Rules(a, b);
          expect(r.sumOf(r.oddRows), a * b, reason: '$a by $b');
          expect(r.sweep(), (1, 1 << r.rows.length), reason: '$a by $b');
          expect(r.rows.length, a.bitLength, reason: '$a by $b');
        }
      }
    });

    test('every label\'s ways is what the sweep finds', () {
      for (final level in Levels.all) {
        expect(level.rules.sweep(exactly: level.exactly), (level.ways, level.keepings), reason: level.name);
      }
    });
  });

  group('the play', () {
    test('opens with nothing kept', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.kept, isEmpty, reason: level.name);
        expect(play.sum, 0);
        expect(play.isDone, isFalse);
      }
    });

    test('a tap keeps, a tap lets go, counted; back undoes', () {
      var play = Play.of(Levels.at(0));
      play = play.tap(0);
      expect(play.kept, [0]);
      expect(play.sum, 7);
      play = play.tap(0);
      expect(play.kept, isEmpty);
      expect(play.moves, 2);
      expect(play.back.kept, [0]);
      expect(play.tap(4), same(play));
    });

    test('the ledgers by hand', () {
      final thirteen = Play.of(Levels.at(0)).tap(0).tap(2).tap(3);
      expect(thirteen.isDone, isTrue);
      expect(thirteen.tap(1), same(thirteen));
      final forty = Play.of(Levels.at(2)).tap(3).tap(5);
      expect(forty.isDone, isTrue);
      final wrong = Play.of(Levels.at(0)).tap(1).tap(3);
      expect(wrong.sum, 70);
      expect(wrong.isDone, isFalse);
    });

    test('the pointer keeps every winnable ledger', () {
      for (final number in [0, 1, 2, 3]) {
        var play = Play.of(Levels.at(number));
        var guard = 0;
        while (!play.isDone && guard++ < 20) {
          final (_, i) = play.next!;
          play = play.tap(i);
        }
        expect(play.isDone, isTrue, reason: '$number');
      }
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('the pointer says keep or let go', () {
      final play = Play.of(Levels.at(0));
      expect(play.next, ('keep', 0));
      expect(play.tap(0).next, ('keep', 2));
      expect(play.tap(1).next, ('let', 1));
    });

    test('the hopeless ledger admits it at twelve taps', () {
      var play = Play.of(Levels.at(4)).tap(2).tap(3);
      expect(play.sum, 84);
      expect(play.isDone, isFalse);
      for (var k = 0; k < 10; k++) {
        play = play.tap(k.isEven ? 0 : 0);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.tap(1), same(play));
    });

    test('a winnable ledger never gives up', () {
      var play = Play.of(Levels.at(0));
      for (var k = 0; k < 14; k++) {
        play = play.tap(1);
      }
      expect(play.moves, 14);
      expect(play.gaveUp, isFalse);
    });

    test('the mark stands kept', () {
      final mark = Play.standing(Levels.at(0), Levels.at(0).rules.oddRows);
      expect(mark.isDone, isTrue);
      expect(mark.sum, 91);
    });
  });
}
