import 'package:flutter_test/flutter_test.dart';
import 'package:peckthorne/peck/flocks.dart';
import 'package:peckthorne/peck/play.dart';
import 'package:peckthorne/peck/rules.dart';

/// The law of the yard, held to.
void main() {
  group('the rules', () {
    test('every label\'s ways is what the sweep finds', () {
      for (final flock in Flocks.all) {
        expect(
          Rules(flock.chickens).waysTo(flock.asked),
          flock.ways,
          reason: flock.name,
        );
      }
    });

    test('the spreads stand where they were pinned', () {
      expect(Rules(3).spread(), {1: 6, 3: 2});
      expect(Rules(4).spread(), {1: 32, 3: 32});
      final fives = Rules(5).spread();
      expect(fives[1], 320);
      expect(fives[3], 520);
      expect(fives[4], 120);
      expect(fives[5], 64);
      expect(fives.length, 4);
    });

    test('every law holds over every pecking', () {
      expect(Rules(3).lawsHold(), isTrue);
      expect(Rules(4).lawsHold(), isTrue);
      expect(Rules(5).lawsHold(), isTrue);
    });

    test('the settled order crowns its emperor alone', () {
      final rules = Rules(4);
      final settled = List.filled(6, false);
      expect(rules.kings(settled), [0]);
      expect(rules.kingsBySquare(settled), [0]);
      expect(rules.emperors(settled), [0]);
      expect(rules.outPecks(settled), [3, 2, 1, 0]);
    });

    test('the round pecking of five crowns every chicken', () {
      final rules = Rules(5);
      final round = [
        for (final (a, b) in rules.pairs) !(b - a == 1 || b - a == 2),
      ];
      expect(rules.kings(round), [0, 1, 2, 3, 4]);
      expect(rules.outPecks(round), [2, 2, 2, 2, 2]);
      expect(rules.emperors(round), isEmpty);
    });

    test('no pecking of four crowns everybody', () {
      expect(Rules(4).waysTo(4), 0);
    });

    test('the road to the asking is real and shortest-first', () {
      final rules = Rules(3);
      final road = rules.flipsTo(List.filled(3, false), 3);
      expect(road, hasLength(1));
      final turned = List.filled(3, false);
      turned[road!.first] = true;
      expect(rules.kings(turned), hasLength(3));
      expect(rules.flipsTo(turned, 3), isEmpty);
      expect(Rules(4).flipsTo(List.filled(6, false), 2), isNull);
    });
  });

  group('the play', () {
    test('opens on the settled order, one crown standing', () {
      for (final flock in Flocks.all) {
        final play = Play.of(flock);
        expect(play.kings, hasLength(1), reason: flock.name);
        expect(play.isDone, isFalse, reason: flock.name);
        expect(play.isOver, isFalse, reason: flock.name);
        expect(play.busiest, [0], reason: flock.name);
      }
    });

    test('a flip turns one pair and counts, both ways', () {
      var play = Play.of(Flocks.at(1));
      play = play.flipAt(0);
      expect(play.pecking[0], isTrue);
      expect(play.moves, 1);
      play = play.flipAt(0);
      expect(play.pecking[0], isFalse);
      expect(play.moves, 2);
    });

    test('back takes back one flip', () {
      // The pair of kings never lands, so nothing freezes.
      final play = Play.of(Flocks.at(4)).flipAt(2).flipAt(4);
      expect(play.back.moves, 1);
      expect(play.back.pecking[4], isFalse);
      expect(play.back.back.back, same(play.back.back));
    });

    test('one flip crowns the round of three', () {
      var play = Play.of(Flocks.at(0));
      play = play.flipAt(1);
      expect(play.isDone, isTrue);
      expect(play.isOver, isTrue);
      expect(play.kings, hasLength(3));
      expect(play.moves, 1);
      // A landed flock refuses further flips.
      expect(play.flipAt(0), same(play));
    });

    test('the pointer crowns the full court', () {
      var play = Play.of(Flocks.at(3));
      var guard = 0;
      while (!play.isDone && guard++ < 12) {
        play = play.flipAt(play.next!);
      }
      expect(play.isDone, isTrue);
      expect(play.kings, hasLength(5));
      expect(play.moves, 2);
    });

    test('the hopeless flock admits it at twelve flips', () {
      var play = Play.of(Flocks.at(4));
      for (var dither = 0; dither < 12; dither++) {
        play = play.flipAt(0);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.isDone, isFalse);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.next, isNull);
    });

    test('a winnable flock never gives up', () {
      var play = Play.of(Flocks.at(1));
      for (var dither = 0; dither < 12; dither++) {
        play = play.flipAt(0);
      }
      expect(play.moves, 12);
      expect(play.gaveUp, isFalse);
      expect(play.isOver, isFalse);
    });

    test('the mark stands crowned whole', () {
      final rules = Rules(5);
      final court = Play.standing(Flocks.at(3), [
        for (final (a, b) in rules.pairs) !(b - a == 1 || b - a == 2),
      ]);
      expect(court.isDone, isTrue);
      expect(court.emperors, isEmpty);
    });
  });
}
