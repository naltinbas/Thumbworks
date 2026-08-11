import 'package:bannford/banns/parties.dart';
import 'package:bannford/banns/play.dart';
import 'package:bannford/banns/rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('the rankings', () {
    test('stand best first, and strangers lose to anyone ranked', () {
      final rules = Rules(Parties.at(2).prefs);
      expect(rules.standing(0, 1), 0);
      expect(rules.standing(0, 3), 2);
      expect(rules.prefers(0, 1, 2), isTrue);
      expect(rules.prefers(0, 3, 1), isFalse);
      expect(rules.prefers(0, 1, null), isTrue);
    });

    test('an unranked stranger is never preferred', () {
      // Two-sided: askers rank no askers.
      final rules = Rules(Parties.at(0).prefs);
      expect(rules.standing(0, 1), isNull);
      expect(rules.prefers(0, 1, null), isFalse);
    });
  });

  group('the eloping pairs', () {
    test('are found the moment both would rather', () {
      final rules = Rules(Parties.at(4).prefs);
      // Ada-Bea and Cy-Dot: Bea wants Cy over Ada, Cy wants Bea over
      // Dot.
      expect(rules.eloping([1, 0, 3, 2]), [(1, 2)]);
    });

    test('singles are left in peace: an empty hall has no red', () {
      final rules = Rules(Parties.at(2).prefs);
      expect(rules.eloping([null, null, null, null]), isEmpty);
      // And a lone standing couple cannot elope with the unwedded.
      expect(rules.eloping([2, null, 0, null]), isEmpty);
    });

    test('a two-sided party wedded across its sides always breaks', () {
      final rules = Rules(Parties.at(0).prefs);
      // Ada with Bea, Kit with Lou, Cy with Mo: the mixed-up couples
      // leave somebody eloping, whatever the arrangement.
      expect(rules.eloping([1, 0, 5, 4, 3, 2]), isNotEmpty);
    });
  });

  group('the sweep and the asking-round', () {
    test('agree the three couples settle one way', () {
      // The anchor. The sweep judges all fifteen pairings knowing
      // nothing of asking; the round asks knowing nothing of sweeping.
      final rules = Rules(Parties.at(0).prefs);
      final settled = rules.settledPairings();
      expect(settled, [
        [3, 4, 5, 0, 1, 2]
      ]);
      expect(rules.askingRound(), settled.first);
    });

    test('the latin party settles four ways, the round finding one', () {
      final rules = Rules(Parties.at(1).prefs);
      final settled = rules.settledPairings();
      expect(settled, hasLength(4));
      expect(settled, contains(equals(rules.askingRound())));
    });

    test('every settled pairing really has nobody eloping', () {
      for (var number = 0; number < Parties.count; number++) {
        final rules = Rules(Parties.at(number).prefs);
        for (final pairing in rules.settledPairings()) {
          expect(rules.eloping(pairing), isEmpty,
              reason: Parties.at(number).name);
        }
      }
    });
  });

  group('every party that ships', () {
    for (var number = 0; number < Parties.count; number++) {
      final party = Parties.at(number);

      test('${party.name} is what it says it is', () {
        final rules = Rules(party.prefs);
        expect(rules.settledPairings(), hasLength(party.settles));
      });
    }

    test('the odd house breaks all three ways, by the one holding Dot',
        () {
      final rules = Rules(Parties.at(4).prefs);
      var pairings = 0;
      for (final pairing in rules.allPairings()) {
        pairings++;
        final holdsDot = pairing.indexOf(3);
        var first = -1;
        for (var who = 0; who < 3; who++) {
          if (rules.prefs[who].first == holdsDot) first = who;
        }
        final low = holdsDot < first ? holdsDot : first;
        final high = holdsDot < first ? first : holdsDot;
        expect(rules.eloping(pairing), contains((low, high)),
            reason: '$pairing');
      }
      expect(pairings, 3);
    });
  });

  group('a party in play', () {
    test('starts unwedded, with everyone single', () {
      final play = Play.of(Parties.at(2));
      expect(play.unwedded, 4);
      expect(play.weddings, 0);
      expect(play.isSettled, isFalse);
    });

    test('a wedding parts whoever the two were with', () {
      var play = Play.of(Parties.at(2));
      play = play.wed(0, 1).wed(2, 3);
      expect(play.wedded, [1, 0, 3, 2]);
      play = play.wed(0, 2);
      expect(play.wedded, [2, null, 0, null]);
      expect(play.weddings, 3);
    });

    test('wedding a couple to itself parts it, and nothing else counts',
        () {
      var play = Play.of(Parties.at(2)).wed(0, 1);
      play = play.wed(0, 1);
      expect(play.wedded, [null, null, null, null]);
      expect(identical(play.wed(0, 0), play), isTrue);
    });

    test('take back returns the party as it stood', () {
      final start = Play.of(Parties.at(2));
      final wedded = start.wed(0, 1);
      expect(wedded.back.wedded, start.wedded);
      expect(identical(start.back, start), isTrue);
    });

    test('following next settles every winnable party', () {
      for (var number = 0; number < Parties.count; number++) {
        final party = Parties.at(number);
        if (!party.winnable) continue;
        var play = Play.of(party);
        var guard = 0;
        while (!play.isSettled) {
          if (guard++ > 12) fail('${party.name} never settled');
          final couple = play.next;
          expect(couple, isNotNull, reason: party.name);
          play = play.wed(couple!.$1, couple.$2);
        }
        expect(play.isSettled, isTrue, reason: party.name);
      }
    });

    test('the odd house offers nothing to follow', () {
      final play = Play.of(Parties.at(4));
      expect(play.next, isNull);
      expect(play.wed(0, 1).wed(2, 3).isSettled, isFalse);
    });
  });
}
