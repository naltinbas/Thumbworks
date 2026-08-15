import 'package:flutter_test/flutter_test.dart';
import 'package:turnwick/pack/levels.dart';
import 'package:turnwick/pack/play.dart';
import 'package:turnwick/pack/rules.dart';

/// The law of the pack, held to.
void main() {
  group('the rules', () {
    test('a cut and a turn', () {
      const r = Rules(4);
      expect(r.start, [(0, false), (1, false), (2, false), (3, false)]);
      expect(Rules.cut(r.start), [(1, false), (2, false), (3, false), (0, false)]);
      expect(Rules.turn(r.start), [(1, true), (0, true), (2, false), (3, false)]);
      final t = Rules.turn(r.start);
      expect(Rules.turn(t), r.start);
      expect(Rules.faces(t), [true, true, false, false]);
      expect(Rules.upAtEven([true, true, false, false]), 1);
      expect(Rules.upAtOdd([true, true, false, false]), 1);
      expect(Rules.balanced([true, false, false, false]), isFalse);
      expect(Rules.balanced([true, false, false, true]), isTrue);
    });

    test('the walk of four, and the patterns', () {
      const r = Rules(4);
      expect(r.walk(), hasLength(48));
      expect(r.patterns(), hasLength(6));
      expect(r.fewest([true, true, false, false]), 1);
      expect(r.fewest([true, false, false, true]), 2);
      expect(r.fewest([false, true, true, false]), 4);
      expect(r.fewest([true, true, true, true]), 4);
      expect(r.fewest([true, false, false, false]), isNull);
      expect(r.balancedPatterns(), (6, 16));
      expect(const Rules(6).walk(), hasLength(1440));
      expect(const Rules(6).balancedPatterns(), (20, 64));
    });

    test('every pack reached keeps the count, on four and six', () {
      for (final n in [4, 6]) {
        final r = Rules(n);
        for (final k in r.walk().keys) {
          expect(Rules.balanced(k.split(',').map((c) => c.endsWith('u')).toList()), isTrue, reason: k);
        }
        expect(r.patterns().length, r.balancedPatterns().$1, reason: '$n');
      }
    });

    test('the sweeps of the sequences', () {
      const r = Rules(4);
      expect(r.sweep([true, true, false, false], 1), (1, 2));
      expect(r.sweep([true, false, false, true], 2), (1, 4));
      expect(r.sweep([false, true, true, false], 4), (1, 16));
      expect(r.sweep([true, true, true, true], 4), (1, 16));
      expect(r.sweep([true, false, false, false], 6), (0, 64));
    });

    test('a road, and no road', () {
      const r = Rules(4);
      expect(Rules.road(r.start, [true, true, false, false]), [true]);
      expect(Rules.road(r.start, [true, false, false, true]), [true, false]);
      expect(Rules.road(r.start, [true, false, false, false]), isNull);
      expect(Rules.road(Rules.turn(r.start), [true, true, false, false]), isEmpty);
    });

    test('every label\'s ways is what the sweep finds', () {
      for (final level in Levels.all) {
        expect(level.rules.sweep(level.pattern, level.moves), (level.ways, level.sequences), reason: level.name);
        expect(level.rules.fewest(level.pattern), level.winnable ? level.moves : isNull, reason: level.name);
      }
    });
  });

  group('the play', () {
    test('opens all face down', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.faces, everyElement(isFalse), reason: level.name);
        expect(play.moves, 0);
        expect(play.isDone, isFalse);
      }
    });

    test('cuts and turns are counted; back undoes', () {
      var play = Play.of(Levels.at(3));
      play = play.turn;
      expect(play.faces, [true, true, false, false]);
      expect(play.moves, 1);
      play = play.cut;
      expect(play.faces, [true, false, false, true]);
      expect(play.back.faces, [true, true, false, false]);
      play = play.cut.turn;
      expect(play.faces, [true, true, true, true]);
      expect(play.isDone, isTrue);
      expect(play.moves, 4);
      expect(play.cut, same(play));
    });

    test('the patterns by hand', () {
      expect(Play.of(Levels.at(0)).turn.isDone, isTrue);
      expect(Play.of(Levels.at(1)).turn.cut.isDone, isTrue);
      expect(Play.of(Levels.at(2)).turn.cut.cut.cut.isDone, isTrue);
      expect(Play.of(Levels.at(3)).turn.cut.cut.turn.isDone, isTrue);
      final counts = Play.of(Levels.at(3)).turn.cut;
      expect(counts.upAtEven, 1);
      expect(counts.upAtOdd, 1);
    });

    test('the pointer reaches every winnable pattern', () {
      for (final number in [0, 1, 2, 3]) {
        var play = Play.of(Levels.at(number));
        var guard = 0;
        while (!play.isDone && guard++ < 12) {
          play = play.next! ? play.turn : play.cut;
        }
        expect(play.isDone, isTrue, reason: '$number');
        expect(play.moves, Levels.at(number).moves, reason: '$number');
      }
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('the pointer says turn, then cut', () {
      final play = Play.of(Levels.at(1));
      expect(play.next, isTrue);
      expect(play.turn.next, isFalse);
    });

    test('the hopeless pattern admits it at twelve moves', () {
      var play = Play.of(Levels.at(4));
      for (var k = 0; k < 12; k++) {
        play = k.isEven ? play.turn : play.cut;
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.upAtEven, play.upAtOdd);
      expect(play.turn, same(play));
    });

    test('a winnable pattern never gives up', () {
      var play = Play.of(Levels.at(2));
      for (var k = 0; k < 14; k++) {
        play = play.cut;
      }
      expect(play.moves, 14);
      expect(play.gaveUp, isFalse);
    });

    test('the mark stands as asked', () {
      final mark = Play.of(Levels.at(3)).turn.cut.cut.turn;
      expect(mark.isDone, isTrue);
    });
  });
}
