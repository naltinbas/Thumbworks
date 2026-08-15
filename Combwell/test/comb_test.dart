import 'package:flutter_test/flutter_test.dart';
import 'package:combwell/comb/levels.dart';
import 'package:combwell/comb/play.dart';
import 'package:combwell/comb/rules.dart';

/// The law of the comb, held to.
void main() {
  group('the rules', () {
    test('nineteen cells, fifteen lines, three through each cell', () {
      expect(Rules.lines, hasLength(15));
      for (var c = 0; c < Rules.cells; c++) {
        expect(Rules.linesOf(c), hasLength(3), reason: '$c');
      }
      expect(Rules.placeOf(9), (2, 2));
      expect(Rules.placeOf(16), (4, 0));
      expect(Rules.linesOf(9), [2, 7, 12]);
    });

    test('Adams\' comb is magic, and a swap spoils it', () {
      const r = Rules(38);
      expect(r.magic(Levels.adams), isTrue);
      for (var i = 0; i < Rules.lines.length; i++) {
        expect(r.lineStanding(Levels.adams, i), (38, 0), reason: '$i');
      }
      final swapped = List.of(Levels.adams);
      swapped[0] = Levels.adams[1];
      swapped[1] = Levels.adams[0];
      expect(r.magic(swapped), isFalse);
      expect(r.magic(Levels.at(0).given), isFalse);
      expect(r.lineStanding(Levels.at(0).given, 2), (25, 3));
    });

    test('the walk fills the combs', () {
      const r = Rules(38);
      expect(r.fillings(Levels.at(0).given), [Levels.adams]);
      expect(r.fillings(Levels.at(1).given), [Levels.adams]);
      final whole = r.fillings(List.filled(Rules.cells, 0));
      expect(whole, hasLength(12));
      expect(whole.map((f) => f.toString()), contains(Levels.adams.toString()));
      expect(const Rules(37).fillings(List.filled(Rules.cells, 0)), isEmpty);
      expect(r.fillings(List.filled(Rules.cells, 0), most: 1), hasLength(1));
    });

    test('the twelve symmetries carry Adams\' comb to the twelve fillings', () {
      final syms = Rules.symmetries;
      expect(syms, hasLength(12));
      expect(syms.map((s) => s.toString()).toSet(), hasLength(12));
      expect(syms.first, List.generate(Rules.cells, (c) => c));
      final images = {for (final s in syms) Rules.carry(Levels.adams, s).toString()};
      expect(images, hasLength(12));
      for (final f in const Rules(38).fillings(List.filled(Rules.cells, 0))) {
        expect(images, contains(f.toString()));
        expect(const Rules(38).magic(f), isTrue);
      }
    });

    test('every label\'s ways is what the walk finds', () {
      for (final level in Levels.all) {
        expect(level.rules.fillings(level.given), hasLength(level.ways), reason: level.name);
      }
    });
  });

  group('the play', () {
    test('opens as given, nothing picked', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.values, level.given, reason: level.name);
        expect(play.held, isNull);
        expect(play.filled, Rules.cells - level.empties);
        expect(play.isDone, isFalse);
      }
    });

    test('a cell is picked, a number put, a cell cleared; back undoes', () {
      var play = Play.of(Levels.at(0));
      expect(play.tap(0), same(play));
      play = play.tap(8);
      expect(play.held, 8);
      expect(play.tap(8).held, isNull);
      expect(play.put(3), same(play));
      play = play.put(2);
      expect(play.values[8], 2);
      expect(play.moves, 1);
      expect(play.held, isNull);
      expect(play.left, [4, 5, 6]);
      final cleared = play.tap(8);
      expect(cleared.values[8], 0);
      expect(cleared.moves, 1);
      expect(cleared.back.values[8], 2);
      expect(play.put(2), same(play));
    });

    test('lines read right and off', () {
      final play = Play.of(Levels.at(0));
      expect(play.rightLines, hasLength(7));
      expect(play.wrongLines, isEmpty);
      final off = play.tap(13).put(2);
      expect(off.wrongLines, [3]);
      expect(off.rightLines, hasLength(7));
      final right = play.tap(13).put(4);
      expect(right.rightLines, hasLength(8));
    });

    test('the last four by hand', () {
      final play = Play.of(Levels.at(0)).tap(8).put(2).tap(9).put(5).tap(10).put(6).tap(13).put(4);
      expect(play.isDone, isTrue);
      expect(play.moves, 4);
      expect(play.tap(8), same(play));
      expect(play.values, Levels.adams);
    });

    test('the pointer fills every winnable comb', () {
      for (final number in [0, 1, 2, 3]) {
        var play = Play.of(Levels.at(number));
        var guard = 0;
        while (!play.isDone && guard++ < 40) {
          final (what, c, v) = play.next!;
          play = what == 'clear' ? play.tap(c) : play.tap(c).put(v);
        }
        expect(play.isDone, isTrue, reason: '$number');
        expect(play.moves, Levels.at(number).empties, reason: '$number');
      }
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('the pointer says clear when a number is off the filling', () {
      final play = Play.of(Levels.at(1)).tap(4).put(2);
      expect(play.next, ('clear', 4, 0));
      expect(Play.of(Levels.at(1)).next, ('set', 4, 7));
    });

    test('the hopeless comb admits it when full', () {
      var play = Play.of(Levels.at(4));
      for (var c = 0; c < Rules.cells; c++) {
        play = play.tap(c).put(c + 1);
      }
      expect(play.isFull, isTrue);
      expect(play.isDone, isFalse);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.tap(0), same(play));
    });

    test('the hopeless comb also admits it at forty numbers', () {
      var play = Play.of(Levels.at(4));
      for (var k = 0; k < 40; k++) {
        play = play.tap(0).put(1).tap(0);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.gaveUp, isTrue);
    });

    test('a winnable comb never gives up', () {
      var play = Play.of(Levels.at(3));
      for (var k = 0; k < 42; k++) {
        play = play.tap(0).put(1).tap(0);
      }
      expect(play.moves, 42);
      expect(play.gaveUp, isFalse);
    });

    test('the mark stands magic', () {
      final mark = Play.standing(Levels.at(3), Levels.adams);
      expect(mark.isDone, isTrue);
      expect(mark.moves, 19);
    });
  });
}
