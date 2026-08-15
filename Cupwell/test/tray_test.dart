import 'package:flutter_test/flutter_test.dart';
import 'package:cupwell/tray/levels.dart';
import 'package:cupwell/tray/play.dart';
import 'package:cupwell/tray/rules.dart';

/// The law of the tray, held to.
void main() {
  group('the rules', () {
    test('turns are the sets of the count, and a turn flips them', () {
      const r = Rules(3, 2);
      expect(r.turns, [3, 5, 6]);
      expect(Rules.turned(0x3, 0x3), 0);
      expect(Rules.turned(0x1, 0x3), 0x2);
      expect(Rules.downCount(0x7), 3);
    });

    test('the fewest by search, and the reach', () {
      expect(const Rules(3, 2).fewest(0x3), 1);
      expect(const Rules(3, 2).fewest(0x1), isNull);
      expect(const Rules(4, 3).fewest(0xF), 4);
      expect(const Rules(5, 3).fewest(0x1F), 3);
      expect(const Rules(6, 4).fewest(0x3F), 3);
      expect(const Rules(3, 2).reachable(0x1), hasLength(4));
      expect(const Rules(4, 3).reachable(0xF), hasLength(16));
      expect(const Rules(3, 3).reachable(0x1), hasLength(2));
    });

    test('the parity law holds short of the whole tray', () {
      for (var cups = 2; cups <= 5; cups++) {
        for (var each = 1; each < cups; each++) {
          final r = Rules(cups, each);
          for (var from = 0; from < (1 << cups); from++) {
            expect(r.fewest(from) == null, r.barredByParity(from), reason: '$cups $each $from');
          }
        }
      }
    });

    test('the sequences count as told', () {
      expect(const Rules(3, 2).sequences(0x3, 1), (1, 3));
      expect(const Rules(4, 3).sequences(0xF, 4), (24, 256));
      expect(const Rules(5, 3).sequences(0x1F, 3), (60, 1000));
      expect(const Rules(6, 4).sequences(0x3F, 3), (120, 3375));
      expect(const Rules(3, 2).sequences(0x1, 6), (0, 729));
    });

    test('every label\'s ways is what the sweep finds', () {
      for (final level in Levels.all) {
        final r = Rules(level.cups, level.each);
        final (righting, all) = r.sequences(level.down, level.turns);
        expect(righting, level.ways, reason: level.name);
        expect(all, level.sequences, reason: level.name);
      }
    });
  });

  group('the play', () {
    test('opens as dealt', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.tray, level.down, reason: level.name);
        expect(play.marked, isEmpty);
        expect(play.isDone, isFalse);
      }
    });

    test('marks gather, and the last mark turns them; back undoes', () {
      var play = Play.of(Levels.at(1));
      play = play.tap(0);
      expect(play.marked, {0});
      expect(play.moves, 0);
      play = play.tap(0);
      expect(play.marked, isEmpty);
      play = play.tap(0).tap(1).tap(2);
      expect(play.marked, isEmpty);
      expect(play.moves, 1);
      expect(play.tray, 0x8);
      expect(play.back.tray, 0xF);
      expect(play.tap(4), same(play));
    });

    test('the trays by hand', () {
      final two = Play.of(Levels.at(0)).tap(0).tap(1);
      expect(two.isDone, isTrue);
      expect(two.moves, 1);
      final wasted = Play.of(Levels.at(0)).tap(1).tap(2);
      expect(wasted.missed, isTrue);
      expect(wasted.gaveUp, isFalse);
      expect(wasted.tap(0), same(wasted));
      final four = Play.of(Levels.at(1)).tap(0).tap(1).tap(2).tap(0).tap(1).tap(3).tap(0).tap(2).tap(3).tap(1).tap(2).tap(3);
      expect(four.isDone, isTrue);
      expect(four.moves, 4);
    });

    test('the pointer rights every winnable tray', () {
      for (final number in [0, 1, 2, 3]) {
        var play = Play.of(Levels.at(number));
        var guard = 0;
        while (!play.isDone && guard++ < 30) {
          final (_, cup) = play.next!;
          play = play.tap(cup);
        }
        expect(play.isDone, isTrue, reason: '$number');
        expect(play.moves, Levels.at(number).turns, reason: '$number');
      }
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('the pointer unmarks a cup off the turn, and goes quiet after a wasted turn', () {
      final r = Rules(4, 3);
      final set = r.nextTurn(0xF)!;
      var off = -1;
      for (var c = 0; c < 4; c++) {
        if ((set >> c) & 1 == 0) off = c;
      }
      final play = Play.of(Levels.at(1)).tap(off);
      expect(play.next, ('unmark', off));
      final wasted = Play.of(Levels.at(0)).tap(1).tap(2);
      expect(wasted.next, isNull);
    });

    test('the hopeless tray cracks at six turns', () {
      var play = Play.of(Levels.at(4));
      for (var k = 0; k < 6; k++) {
        play = play.tap(0).tap(1);
      }
      expect(play.moves, 6);
      expect(play.downCount.isOdd, isTrue);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.tap(0), same(play));
    });

    test('the mark stands one down of three', () {
      final mark = Play.standing(Levels.at(4), 0x2, 0);
      expect(mark.downCount, 1);
      expect(mark.isDone, isFalse);
    });
  });
}
