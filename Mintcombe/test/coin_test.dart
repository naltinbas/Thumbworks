import 'package:flutter_test/flutter_test.dart';
import 'package:mintcombe/coin/levels.dart';
import 'package:mintcombe/coin/play.dart';
import 'package:mintcombe/coin/rules.dart';

/// The coins, the sweep, the asks and the play, checked at the domain:
/// nothing here touches a widget.
void main() {
  group('the coins', () {
    test('ten coins, each the two before it added, and the tidy rule', () {
      expect(Rules.coins, [1, 2, 3, 5, 8, 13, 21, 34, 55, 89]);
      for (var i = 2; i < Rules.count; i++) {
        expect(Rules.coins[i], Rules.coins[i - 1] + Rules.coins[i - 2]);
      }
      expect((Rules.purse, Rules.unminted, Rules.tidyTop), (231, 144, 143));
      expect(Rules.placeOf(89), 9);
      expect(Rules.neighbours(55, 34), isTrue);
      expect(Rules.neighbours(55, 21), isFalse);
      expect(Rules.neighbourPairs([55, 34, 8, 3, 2, 1]), [(55, 34), (3, 2), (2, 1)]);
      expect(Rules.tidy([89, 8, 3]), isTrue);
      expect(Rules.tidy([55, 34]), isFalse);
      expect(Rules.tidy([]), isTrue);
      expect(Rules.sumOf([89, 8, 3]), 100);
      expect(Rules.alternate(55), [55, 21, 8, 3, 1]);
      expect(Rules.alternate(89), [89, 34, 13, 5, 2]);
      expect(Rules.pickings, hasLength(1024));
      expect(tellCoins([89, 1]), '89 and 1');
      expect(tellCoins([55, 34, 8, 3]), '55, 34, 8 and 3');
      expect(tellCoins([5]), '5');
      expect(tellCoins([]), 'no coins');
    });

    test('the greedy purse pays tidily to 143 and untidily beyond', () {
      expect(Rules.greedy(90), [89, 1]);
      expect(Rules.greedy(100), [89, 8, 3]);
      expect(Rules.greedy(143), [89, 34, 13, 5, 2]);
      expect(Rules.greedy(144), [89, 55]);
      expect(Rules.greedy(200), [89, 55, 34, 21, 1]);
      expect(Rules.greedy(0), isEmpty);
      expect(Rules.greedy(232), isNull);
    });

    test('the sweep: every price to 143 paid tidily once, and the greedy way is the tidy way with the fewest coins', () {
      final all = <int, int>{}, tidy = <int, int>{}, fewest = <int, int>{};
      final tidyWay = <int, List<int>>{};
      for (final p in Rules.pickings) {
        final s = Rules.sumOf(p);
        all[s] = (all[s] ?? 0) + 1;
        if (Rules.tidy(p)) {
          tidy[s] = (tidy[s] ?? 0) + 1;
          tidyWay[s] = p;
        }
        if (!fewest.containsKey(s) || p.length < fewest[s]!) fewest[s] = p.length;
      }
      expect(all.length, 232);
      expect(tidy.length, 144);
      for (var n = 0; n <= 231; n++) {
        expect(all[n], greaterThan(0), reason: '$n');
        if (n <= 143) {
          expect(tidy[n], 1, reason: '$n');
          final g = Rules.greedy(n)!;
          expect(g, tidyWay[n], reason: '$n');
          expect(g.length, fewest[n], reason: '$n');
        } else {
          expect(tidy.containsKey(n), isFalse, reason: '$n');
          expect(Rules.tidy(Rules.greedy(n)!), isFalse, reason: '$n');
        }
      }
      expect(all[90], 5);
      expect(all[100], 9);
      expect(all[143], 1);
      expect(all[144], 5);
      expect([for (var n = 0; n < 144; n++) if (all[n] == 1) n], [0, 1, 2, 4, 7, 12, 20, 33, 54, 88, 143]);
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The Held-Back Coin']);
      for (final level in Levels.all) {
        expect(Rules.pickings.where(level.meets).length, level.ways, reason: level.name);
        expect(Rules.pickings.where((p) => Rules.sumOf(p) == level.price).length, level.all, reason: level.name);
        final aim = level.aim;
        if (aim != null) expect(level.meets(aim), isTrue, reason: level.name);
        if (!level.winnable) expect(aim, isNull);
      }
      expect(Levels.at(0).aim, [89, 1]);
      expect(Levels.at(1).aim, [89, 34, 13, 5, 2]);
      expect(Levels.at(2).aim, [55, 34, 8, 3]);
      expect(Levels.at(3).aim, [89, 55]);
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'pay 90 with no two neighbouring coins');
      expect(Levels.at(1).task, 'pay 143 with no two neighbouring coins');
      expect(Levels.at(2).task, 'pay 100 with two neighbouring coins somewhere in it');
      expect(Levels.at(3).task, 'pay 144 with any coins of the purse');
      expect(Levels.at(4).task, 'pay 90 with no two neighbouring coins, the 89 kept back');
    });

    test('an ask is met by the picking', () {
      expect(Levels.at(0).meets([89, 1]), isTrue);
      expect(Levels.at(0).meets([1, 89]), isTrue);
      expect(Levels.at(0).meets([55, 34, 1]), isFalse);
      expect(Levels.at(0).meets([89]), isFalse);
      expect(Levels.at(2).meets([55, 34, 8, 3]), isTrue);
      expect(Levels.at(2).meets([89, 8, 3]), isFalse);
      expect(Levels.at(3).meets([89, 55]), isTrue);
      expect(Levels.at(3).meets([89, 34, 21]), isTrue);
      expect(Levels.at(4).meets([89, 1]), isFalse);
      expect(Levels.at(4).meets([55, 34, 1]), isFalse);
    });
  });

  group('the play', () {
    test('opens with nothing laid', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.picked, isEmpty);
        expect((play.moves, play.sum, play.tidy), (0, 0, true));
        expect(play.isOver, isFalse, reason: level.name);
      }
    });

    test('taps lay and take back, a coin over the price does not fit, and the held-back coin stays on the rack', () {
      var play = Play.of(Levels.at(0)).pick(89);
      expect(play.picked, [89]);
      expect(play.left, 1);
      expect(play.fits(2), isFalse);
      expect(play.pick(2), same(play));
      expect(play.pick(89), same(play));
      expect(play.pick(4), same(play));
      play = play.pick(1);
      expect(play.picked, [89, 1]);
      expect(play.isDone, isTrue);
      final untidy = Play.of(Levels.at(2)).pick(55).pick(34);
      expect(untidy.tidy, isFalse);
      expect(untidy.pairs, [(55, 34)]);
      expect(untidy.lift(34).picked, [55]);
      expect(untidy.lift(8), same(untidy));
      final held = Play.of(Levels.at(4)).pick(89);
      expect(held.picked, isEmpty);
      expect(held.moves, 0);
    });

    test('back undoes one tap', () {
      final play = Play.of(Levels.at(1)).pick(89).pick(34);
      expect(play.back.picked, [89]);
      expect(play.back.back.picked, isEmpty);
    });

    test('the pointer lays the aim dearest first, and takes back a stray coin', () {
      var play = Play.of(Levels.at(1));
      expect(play.next, (89, false));
      expect(Play.pointed((89, false)), 'Lay the 89.');
      play = play.pick(55);
      expect(play.next, (55, true));
      expect(Play.pointed((55, true)), 'Take back the 55.');
      play = play.lift(55).pick(89);
      expect(play.next, (34, false));
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('following the pointer lands every winnable ask in as many taps as the aim has coins', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var steps = 0;
        while (!play.isDone && steps < 12) {
          final (coin, lift) = play.next!;
          play = lift ? play.lift(coin) : play.pick(coin);
          steps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
        expect(play.moves, level.aim!.length, reason: level.name);
      }
    });

    test('the held-back coin admits it when nothing more fits tidily, or after sixteen taps', () {
      var play = Play.of(Levels.at(4)).pick(55).pick(21).pick(8).pick(3);
      expect(play.stuck, isFalse);
      expect(play.gaveUp, isFalse);
      play = play.pick(1);
      expect(play.sum, 88);
      expect(play.stuck, isTrue);
      expect(play.gaveUp, isTrue);
      expect(play.next, isNull);
      final small = Play.of(Levels.at(4)).pick(34).pick(13).pick(5).pick(2);
      expect(small.sum, 54);
      expect(small.gaveUp, isTrue);
      final untidy = Play.of(Levels.at(4)).pick(55).pick(34);
      expect(untidy.stuck, isFalse);
      var wander = Play.of(Levels.at(4));
      for (var k = 0; k < 16; k++) {
        wander = k.isEven ? wander.pick(55) : wander.lift(55);
      }
      expect(wander.gaveUp, isTrue);
      expect(wander.moves, 16);
    });

    test('the why tells Zeckendorf and the sweep', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('Zeckendorf'));
      expect(words, contains('1,024'));
      expect(words, contains('This is ask 5, The Held-Back Coin.'));
      expect(words, contains('summed in full'));
    });
  });
}
