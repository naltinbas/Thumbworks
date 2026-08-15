import 'package:flutter_test/flutter_test.dart';
import 'package:studwell/court/courts.dart';
import 'package:studwell/court/play.dart';
import 'package:studwell/court/rules.dart';

/// The law of the court, held to.
void main() {
  group('the rules', () {
    test('every label\'s ways is what the sweep finds', () {
      for (final court in Courts.all) {
        expect(
          Rules(court.side, court.well).waysBySweep(),
          court.ways,
          reason: court.name,
        );
      }
    });

    test('the four-court paves once round every well', () {
      for (var well = 0; well < 16; well++) {
        expect(Rules(4, well).waysBySweep(), 1, reason: 'well $well');
      }
    });

    test('the quartering lays the sweep\'s own paving', () {
      for (var well = 0; well < 16; well++) {
        final rules = Rules(4, well);
        final swept = rules.landing()!.map((e) => e.join(',')).toList()
          ..sort();
        final built = rules.quartering()!.map((e) => e.join(',')).toList()
          ..sort();
        expect(built, swept, reason: 'well $well');
        expect(rules.lands(rules.quartering()!), isTrue);
      }
      expect(Rules(5, 12).quartering(), isNull);
    });

    test('the five-court lands only on its studs', () {
      final spread = <int, int>{};
      for (var well = 0; well < 25; well++) {
        final rules = Rules(5, well);
        spread[well] = rules.waysBySweep();
        expect(spread[well]! > 0, rules.isStud(well), reason: 'well $well');
      }
      expect(spread[0], 8);
      expect(spread[2], 16);
      expect(spread[12], 32);
      expect(spread[11], 0);
      expect(spread.values.where((ways) => ways > 0), hasLength(9));
    });

    test('an elbow covers one stud at most, and studs are nine', () {
      final rules = Rules(5, 11);
      expect(rules.studs, hasLength(9));
      expect(rules.elbowsNeeded, 8);
      for (final elbow in rules.elbows()) {
        expect(rules.studsUnder(elbow), lessThanOrEqualTo(1));
      }
    });

    test('three flags make an elbow only in a block', () {
      final rules = Rules(4, 0);
      expect(rules.isElbow([1, 2, 5]), isTrue);
      expect(rules.isElbow([5, 1, 6]), isTrue);
      expect(rules.isElbow([1, 2, 3]), isFalse);
      expect(rules.isElbow([1, 5, 9]), isFalse);
      expect(rules.isElbow([1, 2, 7]), isFalse);
      expect(rules.isElbow([1, 1, 2]), isFalse);
      // The well is never in an elbow the court offers.
      for (final elbow in rules.elbows()) {
        expect(elbow, isNot(contains(0)));
      }
      expect(rules.elbows(), hasLength(36 - 3));
    });
  });

  group('the play', () {
    test('opens bare, unpaved', () {
      for (final court in Courts.all) {
        final play = Play.of(court);
        expect(play.laid, isEmpty, reason: court.name);
        expect(play.bare, hasLength(court.side * court.side - 1));
        expect(play.isDone, isFalse, reason: court.name);
      }
    });

    test('three taps in an L lay an elbow, counted once', () {
      var play = Play.of(Courts.at(0));
      play = play.tap(1);
      expect(play.pending, [1]);
      expect(play.moves, 0);
      play = play.tap(2);
      expect(play.pending, [1, 2]);
      play = play.tap(6);
      expect(play.laid, [
        [1, 2, 6]
      ]);
      expect(play.pending, isEmpty);
      expect(play.moves, 1);
    });

    test('a third flag off the block starts over on itself', () {
      final play = Play.of(Courts.at(0)).tap(1).tap(2).tap(3);
      expect(play.laid, isEmpty);
      expect(play.pending, [3]);
      expect(play.moves, 0);
    });

    test('a picked flag unpicks on a second tap', () {
      final play = Play.of(Courts.at(0)).tap(1).tap(2).tap(1);
      expect(play.pending, [2]);
    });

    test('tapping a laid elbow lifts it whole', () {
      var play = Play.of(Courts.at(0)).tap(1).tap(2).tap(6);
      play = play.tap(2);
      expect(play.laid, isEmpty);
      expect(play.moves, 2);
      expect(play.back.laid, hasLength(1));
    });

    test('the well is never touched', () {
      final play = Play.of(Courts.at(0));
      expect(play.touches(0), isFalse);
      expect(play.tap(0), same(play));
      final stray = Play.of(Courts.at(4));
      expect(stray.tap(11), same(stray));
    });

    test('back takes back one laying', () {
      final play =
          Play.of(Courts.at(0)).tap(1).tap(2).tap(6).tap(8).tap(9).tap(12);
      expect(play.moves, 2);
      expect(play.back.laid, hasLength(1));
      expect(play.back.back.laid, isEmpty);
      expect(play.back.back.back, same(play.back.back));
    });

    test('the corner well paves by hand with the quartering', () {
      var play = Play.of(Courts.at(0));
      for (final elbow in Rules(4, 0).quartering()!) {
        for (final cell in elbow) {
          play = play.tap(cell);
        }
      }
      expect(play.isDone, isTrue);
      expect(play.moves, 5);
      expect(play.bare, isEmpty);
      expect(play.tap(1), same(play));
    });

    test('the pointer paves the middle well', () {
      var play = Play.of(Courts.at(3));
      var guard = 0;
      while (!play.isDone && guard++ < 20) {
        final (what, elbow) = play.next!;
        if (what == 'lift') {
          play = play.tap(elbow.first);
        } else {
          for (final cell in elbow) {
            play = play.tap(cell);
          }
        }
      }
      expect(play.isDone, isTrue);
      expect(play.moves, 8);
    });

    test('the pointer lifts an elbow off the paving first', () {
      // The corner well's one paving has no elbow at 1,2,6.
      final play = Play.of(Courts.at(0)).tap(1).tap(2).tap(6);
      final (what, elbow) = play.next!;
      expect(what, 'lift');
      expect(elbow, [1, 2, 6]);
    });

    test('the hopeless court admits it at thirteen moves', () {
      var play = Play.of(Courts.at(4));
      const seven = [
        [0, 5, 6],
        [1, 2, 7],
        [3, 8, 9],
        [10, 15, 16],
        [12, 13, 18],
        [17, 21, 22],
        [19, 23, 24],
      ];
      for (final elbow in seven) {
        for (final cell in elbow) {
          play = play.tap(cell);
        }
      }
      expect(play.laid, hasLength(7));
      expect(play.moves, 7);
      expect(play.bare, [4, 14, 20]);
      expect(play.bareStuds, [4, 14, 20]);
      for (var dither = 0; dither < 3; dither++) {
        play = play.tap(0);
        play = play.tap(0).tap(5).tap(6);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.laid, hasLength(7));
      expect(play.isDone, isFalse);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.next, isNull);
    });

    test('a winnable court never gives up', () {
      var play = Play.of(Courts.at(0));
      for (var dither = 0; dither < 7; dither++) {
        play = play.tap(1).tap(2).tap(6);
        play = play.tap(1);
      }
      expect(play.moves, 14);
      expect(play.gaveUp, isFalse);
      expect(play.isOver, isFalse);
    });

    test('the mark stands paved', () {
      final mark = Play.standing(Courts.at(0), Rules(4, 0).quartering()!);
      expect(mark.isDone, isTrue);
      expect(mark.laid, hasLength(5));
    });
  });
}
