import 'package:flutter_test/flutter_test.dart';
import 'package:tablesham/table/parties.dart';
import 'package:tablesham/table/play.dart';
import 'package:tablesham/table/rules.dart';

/// The law of the table, held to.
void main() {
  group('the rules', () {
    test('every label\'s ways is what the sweep finds', () {
      for (final party in Parties.all) {
        expect(
          Rules(party.couples).waysBySweep(given: party.given),
          party.ways,
          reason: party.name,
        );
      }
    });

    test('the sweep and Touchard agree at every size', () {
      expect(Rules.lawsHold(), isTrue);
    });

    test('the counts run nought, one, two, thirteen', () {
      expect(Rules(2).waysBySweep(), 0);
      expect(Rules(3).waysBySweep(), 1);
      expect(Rules(4).waysBySweep(), 2);
      expect(Rules(5).waysBySweep(), 13);
    });

    test('quarrels read the circle, gap by gap', () {
      final rules = Rules(3);
      // Gap g sits between wives g and g+1: husband 0 in gap 0
      // sits beside his own wife.
      expect(rules.quarrels([0, null, null]), [0]);
      expect(rules.quarrels([2, 0, 1]), isEmpty);
      expect(rules.lands([2, 0, 1]), isTrue);
      expect(rules.lands([2, 0, null]), isFalse);
    });

    test('the whole-table turns are counted two ways', () {
      for (final couples in [2, 3, 4, 5]) {
        final rules = Rules(couples);
        expect(rules.turnings(), hasLength(couples - 2));
        expect(rules.turnsBySweep(), couples - 2);
      }
      expect(Rules(5).turnings(), [1, 2, 3]);
      expect(Rules(5).turnsBySweep(given: (2, 0)), 1);
      expect(Rules(3).turnOf(Rules(3).landing()!), 1);
      expect(Rules(5).turnOf([2, 0, 4, 1, 3]), isNull);
    });

    test('the two seatings of four are mirrors', () {
      final four = <List<int>>[];
      Rules(4).seatings((seated) {
        if (Rules(4).lands([...seated])) four.add(List.of(seated));
      });
      expect(four, [
        [2, 3, 0, 1],
        [3, 0, 1, 2],
      ]);
      expect(Rules(4).mirror(four[0]), four[1]);
      expect(Rules(4).mirror(four[1]), four[0]);
    });

    test('the landing honours the given host', () {
      final held = Rules(5).landing(given: (2, 0));
      expect(held, isNotNull);
      expect(held![2], 0);
      expect(Rules(5).lands([...held]), isTrue);
    });
  });

  group('the play', () {
    test('opens with the bench full, unsettled', () {
      for (final party in Parties.all) {
        final play = Play.of(party);
        final given = party.given == null ? 0 : 1;
        expect(play.bench, hasLength(party.couples - given),
            reason: party.name);
        expect(play.isDone, isFalse, reason: party.name);
      }
    });

    test('a pick and a chair seat a husband, counted gross', () {
      var play = Play.of(Parties.at(0));
      play = play.pick(2);
      expect(play.picked, 2);
      expect(play.moves, 0);
      play = play.tapAt(0);
      expect(play.seated[0], 2);
      expect(play.moves, 1);
      // Tapping a full chair with nobody picked lifts him.
      play = play.tapAt(0);
      expect(play.seated[0], isNull);
      expect(play.moves, 2);
    });

    test('the held host never moves', () {
      final play = Play.of(Parties.at(2));
      expect(play.seated[2], 0);
      expect(play.touches(2), isFalse);
      expect(play.tapAt(2), same(play));
    });

    test('back takes back one move', () {
      final play =
          Play.of(Parties.at(0)).pick(2).tapAt(0).pick(0).tapAt(1);
      expect(play.moves, 2);
      expect(play.back.seated[1], isNull);
      expect(play.back.back.back, same(play.back.back));
    });

    test('the one seating of three lands by hand', () {
      var play = Play.of(Parties.at(0));
      play = play.pick(2).tapAt(0);
      play = play.pick(0).tapAt(1);
      play = play.pick(1).tapAt(2);
      expect(play.seated, [2, 0, 1]);
      expect(play.isDone, isTrue);
      expect(play.moves, 3);
      expect(play.tapAt(0), same(play));
    });

    test('the pointer parts the five couples', () {
      var play = Play.of(Parties.at(3));
      var guard = 0;
      while (!play.isDone && guard++ < 14) {
        final (gap, husband) = play.next!;
        if (play.bench.contains(husband)) {
          play = play.pick(husband).tapAt(gap);
        } else {
          play = play.tapAt(gap);
        }
      }
      expect(play.isDone, isTrue);
      expect(play.moves, 5);
    });

    test('the hopeless party admits it at twelve moves', () {
      var play = Play.of(Parties.at(4));
      for (var dither = 0; dither < 6; dither++) {
        play = play.pick(0).tapAt(0);
        play = play.tapAt(0);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.isDone, isFalse);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.next, isNull);
    });

    test('a winnable party never gives up', () {
      var play = Play.of(Parties.at(0));
      for (var dither = 0; dither < 6; dither++) {
        play = play.pick(0).tapAt(0);
        play = play.tapAt(0);
      }
      expect(play.moves, 12);
      expect(play.gaveUp, isFalse);
      expect(play.isOver, isFalse);
    });

    test('the mark stands parted', () {
      final mark = Play.standing(Parties.at(0), Rules(3).landing()!);
      expect(mark.isDone, isTrue);
      expect(mark.quarrels, isEmpty);
    });
  });
}
