import 'package:flutter_test/flutter_test.dart';
import 'package:sortlow/mill/loads.dart';
import 'package:sortlow/mill/play.dart';
import 'package:sortlow/mill/rules.dart';

/// The law of the mill, held to.
void main() {
  group('the rules', () {
    test('every label\'s ways is what the sweep finds', () {
      for (final load in Loads.all) {
        expect(Rules.waysTo(load.asked), load.ways,
            reason: load.name);
      }
    });

    test('the laws hold over every load', () {
      expect(Rules.lawsHold(), isTrue);
    });

    test('one turn grinds the classic road', () {
      expect(Rules.road(3524), [3524, 3087, 8352, 6174]);
      expect(Rules.stepsByWalk(3524), 3);
      expect(Rules.stepsByTable(3524), 3);
    });

    test('the smallest one-turn load wears leading noughts', () {
      expect(Rules.turn(26), Rules.stone);
      expect(Rules.stepsByWalk(26), 1);
    });

    test('the stone stands still and the repdigits collapse', () {
      expect(Rules.turn(Rules.stone), Rules.stone);
      expect(Rules.stepsByWalk(Rules.stone), 0);
      expect(Rules.repdigit(7777), isTrue);
      expect(Rules.turn(7777), 0);
    });

    test('no load opens landed', () {
      for (final load in Loads.all) {
        final lands = !Rules.repdigit(load.opens) &&
            Rules.stepsByWalk(load.opens) == load.asked;
        expect(lands, isFalse, reason: load.name);
      }
    });
  });

  group('the play', () {
    test('opens on its load\'s number, unsettled', () {
      for (final load in Loads.all) {
        final play = Play.of(load);
        expect(play.number, load.opens, reason: load.name);
        expect(play.isDone, isFalse, reason: load.name);
        expect(play.isOver, isFalse, reason: load.name);
      }
    });

    test('a tap turns one dial and wraps past nine', () {
      var play = Play.of(Loads.at(4));
      play = play.tapAt(3);
      expect(play.number, 1001);
      expect(play.moves, 1);
      for (var turn = 0; turn < 9; turn++) {
        play = play.tapAt(3);
      }
      expect(play.number, 1000);
      expect(play.moves, 10);
    });

    test('back takes back one tap', () {
      final play = Play.of(Loads.at(4)).tapAt(0).tapAt(2);
      expect(play.back.moves, 1);
      expect(play.back.number, 2000);
      expect(play.back.back.back, same(play.back.back));
    });

    test('the standstill lands on the stone itself', () {
      var play = Play.of(Loads.at(3));
      // From 1000 to 6174.
      for (var turn = 0; turn < 5; turn++) {
        play = play.tapAt(0);
      }
      play = play.tapAt(1);
      for (var turn = 0; turn < 7; turn++) {
        play = play.tapAt(2);
      }
      for (var turn = 0; turn < 4; turn++) {
        play = play.tapAt(3);
      }
      expect(play.number, 6174);
      expect(play.isDone, isTrue);
      expect(play.steps, 0);
      expect(play.tapAt(0), same(play));
    });

    test('a repdigit dial is barred, never landed', () {
      var play = Play.of(Loads.at(4));
      // 1000 to 1111.
      play = play.tapAt(1).tapAt(2).tapAt(3);
      expect(play.barred, isTrue);
      expect(play.isDone, isFalse);
    });

    test('the pointer grinds the one turn home', () {
      var play = Play.of(Loads.at(0));
      var guard = 0;
      while (!play.isDone && guard++ < 40) {
        play = play.tapAt(play.next!);
      }
      expect(play.isDone, isTrue);
      expect(play.steps, 1);
    });

    test('the hopeless load admits it at sixteen taps', () {
      var play = Play.of(Loads.at(4));
      for (var dither = 0; dither < 16; dither++) {
        play = play.tapAt(dither % 4);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.isDone, isFalse);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.next, isNull);
    });

    test('a winnable load never gives up', () {
      // Only the stone itself lands the standstill, so the
      // dither can never freeze the play.
      var play = Play.of(Loads.at(3));
      for (var dither = 0; dither < 16; dither++) {
        play = play.tapAt(0);
      }
      expect(play.moves, 16);
      expect(play.gaveUp, isFalse);
      expect(play.isOver, isFalse);
    });

    test('the mark stands on the classic road', () {
      final mark = Play.standing(Loads.at(1), 3524);
      expect(mark.isDone, isTrue);
      expect(mark.road, [3524, 3087, 8352, 6174]);
    });
  });
}
