import 'package:flutter_test/flutter_test.dart';
import 'package:frogmere/mere/gold.dart';
import 'package:frogmere/mere/play.dart';
import 'package:frogmere/mere/reaches.dart';
import 'package:frogmere/mere/rules.dart';

/// The law of the mere, held to.
void main() {
  group('the gold', () {
    test('phi squared is phi plus one, and one over phi is phi less one', () {
      expect(Gold.phi * Gold.phi, const Gold(1, 1));
      expect(Gold.phi * Gold.overPhi, Gold.one);
      expect(Gold.phiToMinus(1) + Gold.phiToMinus(2), Gold.one);
      expect(Gold.phiToMinus(2), const Gold(2, -1));
      expect(Gold.phiToMinus(3), const Gold(-3, 2));
      expect(Gold.phiToMinus(3).toDouble, closeTo(0.2360679, 1e-6));
    });
  });

  group('the rules', () {
    test('every label\'s roads and leaps are what the count finds', () {
      for (final reach in Reaches.all) {
        final rules = Rules(reach.reach, reach.army);
        expect(rules.roads(reach.army.toSet()), reach.roads,
            reason: reach.name);
        expect(rules.fewest(reach.army.toSet()) ?? 0, reach.leaps,
            reason: reach.name);
      }
    });

    test('a leap toward the aim keeps the weight, exactly', () {
      expect(Rules.leapTowardKeeps(30), isTrue);
      final rules = Rules(3, const []);
      final before = rules.weightOf({(0, 0), (0, -1)});
      final after = rules.weightOf({(0, 1)});
      expect(after, closeTo(before, 1e-12));
    });

    test('a leap away or across loses', () {
      final rules = Rules(3, const []);
      expect(
        rules.weightOf({(0, -2)}),
        lessThan(rules.weightOf({(0, 0), (0, -1)})),
      );
      expect(
        rules.weightOf({(2, 0)}),
        lessThan(rules.weightOf({(0, 0), (1, 0)})),
      );
    });

    test('the four armies that land weigh exactly one', () {
      for (var number = 0; number < 4; number++) {
        final reach = Reaches.at(number);
        expect(Rules(reach.reach, reach.army).exactWeightOf(reach.army),
            Gold.one,
            reason: reach.name);
      }
      final fifth = Reaches.at(4);
      expect(Rules(5, fifth.army).weightOf(fifth.army), closeTo(0.679, 5e-4));
    });

    test('the heaviest pads bound the armies', () {
      expect(Rules(2, const []).heaviest(3), closeTo(0.854, 5e-4));
      expect(Rules(3, const []).heaviest(7), closeTo(0.944, 5e-4));
      expect(Rules(4, const []).heaviestExact(19), Gold.one);
      expect(Rules(4, const []).heaviestExact(20), isNot(Gold.one));
    });

    test('the whole pond weighs one against the fifth reach', () {
      expect(Rules.seriesHolds(), isTrue);
      expect(Rules.wholePond(5), Gold.one);
      expect(Rules.wholePond(4), Gold.phi);
      expect(Rules.pondOut(5, 40), closeTo(1, 1e-6));
      expect(Rules.pondOut(5, 40), lessThan(1));
    });

    test('leaps are read off the standing', () {
      final rules = Rules(1, const [(0, 0), (0, -1)]);
      final open = rules.leaps({(0, 0), (0, -1)});
      expect(open, hasLength(2));
      expect(open.map((l) => l.to), containsAll([(0, 1), (0, -2)]));
      expect(rules.after({(0, 0), (0, -1)}, open.first),
          {open.first.to});
    });
  });

  group('the play', () {
    test('opens with the army down and nothing picked', () {
      for (final reach in Reaches.all) {
        final play = Play.of(reach);
        expect(play.frogs, hasLength(reach.army.length), reason: reach.name);
        expect(play.picked, isNull);
        expect(play.isDone, isFalse, reason: reach.name);
      }
    });

    test('a pick, an unpick, and a leap', () {
      var play = Play.of(Reaches.at(0));
      play = play.tap((0, -1));
      expect(play.picked, (0, -1));
      expect(play.openToPicked.map((l) => l.to), [(0, 1)]);
      play = play.tap((0, -1));
      expect(play.picked, isNull);
      play = play.tap((0, -1)).tap((0, 1));
      expect(play.frogs, {(0, 1)});
      expect(play.moves, 1);
      expect(play.isDone, isTrue);
      expect(play.tap((0, 1)), same(play));
    });

    test('a tap on an empty pad with nothing picked does nothing', () {
      final play = Play.of(Reaches.at(1));
      expect(play.tap((0, 2)), same(play));
      expect(play.tap((0, 0)).tap((3, 3)), isNot(same(play)));
      expect(play.tap((0, 0)).tap((3, 3)).moves, 0);
    });

    test('back takes back one leap', () {
      final play = Play.of(Reaches.at(1)).tap((0, -1)).tap((0, 1));
      expect(play.moves, 1);
      expect(play.back.moves, 0);
      expect(play.back.frogs, hasLength(4));
      expect(play.back.back, same(play.back));
    });

    test('the second reach lands by hand in three leaps', () {
      var play = Play.of(Reaches.at(1));
      play = play.tap((0, -1)).tap((0, 1));
      play = play.tap((2, 0)).tap((0, 0));
      play = play.tap((0, 0)).tap((0, 2));
      expect(play.isDone, isTrue);
      expect(play.moves, 3);
    });

    test('the pointer lands the third and fourth reaches', () {
      for (final number in [2, 3]) {
        var play = Play.of(Reaches.at(number));
        var guard = 0;
        while (!play.isDone && guard++ < 25) {
          final aim = play.next!;
          play = play.tap(aim.from).tap(aim.to);
        }
        expect(play.isDone, isTrue, reason: '$number');
        expect(play.moves, Reaches.at(number).leaps);
      }
    });

    test('a wasted leap leaves no road, and back mends it', () {
      // Leaping down and away drops the weight below one.
      final play = Play.of(Reaches.at(1)).tap((0, 0)).tap((0, -2));
      expect(play.moves, 1);
      expect(play.weight, lessThan(1));
      expect(play.lands, isFalse);
      expect(play.next, isNull);
      expect(play.back.lands, isTrue);
    });

    test('the hopeless reach admits it at twelve leaps', () {
      var play = Play.of(Reaches.at(4));
      // Twelve leaps that never leave the water: one down at the
      // right end to open a pad, then along the two lower rows
      // from the middle outward and back, then three more down.
      const leaps = [
        ((4, -1), (4, -3)),
        ((2, -2), (4, -2)), ((2, -1), (4, -1)),
        ((0, -2), (2, -2)), ((0, -1), (2, -1)),
        ((-2, -2), (0, -2)), ((-2, -1), (0, -1)),
        ((-4, -2), (-2, -2)), ((-4, -1), (-2, -1)),
        ((2, -1), (2, -3)), ((0, -1), (0, -3)), ((-2, -1), (-2, -3)),
      ];
      for (final (from, to) in leaps) {
        final before = play.moves;
        play = play.tap(from).tap(to);
        expect(play.moves, before + 1, reason: '$from to $to');
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.next, isNull);
    });

    test('a winnable reach never gives up', () {
      var play = Play.of(Reaches.at(3));
      // Leap and never land: down and away, twelve times.
      var count = 0;
      while (count < 12) {
        final open = play.open;
        final away = open.where((l) => l.to.$2 < 0 && !play.rules.reached({l.to})).toList();
        if (away.isEmpty) break;
        play = play.tap(away.first.from).tap(away.first.to);
        count++;
      }
      expect(play.moves, greaterThanOrEqualTo(Play.gaveUpAt));
      expect(play.gaveUp, isFalse);
      expect(play.isOver, isFalse);
    });

    test('the mark stands two leaps into the third reach', () {
      final mark = Play.standing(Reaches.at(2), Reaches.at(2).army.toSet());
      expect(mark.frogs, hasLength(8));
      expect(mark.weight, closeTo(1, 1e-12));
    });
  });
}
