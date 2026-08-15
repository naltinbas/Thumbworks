import 'package:flutter_test/flutter_test.dart';
import 'package:pursebury/duel/levels.dart';
import 'package:pursebury/duel/play.dart';
import 'package:pursebury/duel/rules.dart';

/// The fractions, the chain, the asks and the play, checked at the
/// domain: nothing here touches a widget.
void main() {
  group('the fractions', () {
    test('lowest terms, arithmetic and order', () {
      expect(Frac.of(2, 4), Frac.of(1, 2));
      expect(Frac.of(-2, -4), Frac.of(1, 2));
      expect(Frac.of(1, 3) + Frac.of(1, 6), Frac.of(1, 2));
      expect(Frac.of(1, 2) - Frac.of(2, 3), Frac.of(-1, 6));
      expect(Frac.of(2, 3) * Frac.of(3, 4), Frac.of(1, 2));
      expect(Frac.of(1, 2) / Frac.of(1, 4), Frac.of(2));
      expect(Frac.of(1, 2).pow(3), Frac.of(1, 8));
      expect(Frac.of(1, 3).compareTo(Frac.of(1, 2)), lessThan(0));
      expect(Frac.of(6, 3).isWhole, isTrue);
      expect(Frac.of(6, 3).toString(), '2');
      expect(Frac.of(63, 127).toString(), '63/127');
      expect(Frac.of(1, 4).toDouble, 0.25);
    });
  });

  group('the duel', () {
    test('the fair coin gives the share, and the purses multiplied', () {
      expect(Rules.chanceByFormula(3, 2, 1), Frac.of(3, 5));
      expect(Rules.lastsByFormula(3, 2, 1), Frac.of(6));
      expect(Rules.chanceByFormula(1, 3, 1), Frac.of(1, 4));
      expect(Rules.lastsByFormula(3, 3, 1), Frac.of(9));
    });

    test('the crooked coins bend the chance', () {
      expect(Rules.chanceByFormula(1, 1, 0), Frac.of(1, 3));
      expect(Rules.chanceByFormula(1, 1, 2), Frac.of(2, 3));
      expect(Rules.chanceByFormula(6, 1, 0), Frac.of(63, 127));
      expect(Rules.chanceByFormula(1, 2, 2), Frac.of(4, 7));
      expect(Rules.lastsByFormula(2, 2, 2), Frac.of(18, 5));
      expect(Rules.lastsByFormula(3, 1, 0), Frac.of(17, 5));
    });

    test('the chain solved agrees with the formula, and runs from nothing to everything', () {
      for (final (ash, birch, coin) in [(3, 2, 1), (6, 1, 0), (1, 1, 2), (4, 5, 2), (2, 6, 0)]) {
        expect(Rules.chainSolved(ash, birch, coin), Rules.chanceByFormula(ash, birch, coin), reason: '$ash v $birch coin $coin');
        expect(Rules.chainSolved(ash, birch, coin, tosses: true), Rules.lastsByFormula(ash, birch, coin), reason: '$ash v $birch coin $coin');
      }
      final chain = Rules.solveChain(5, Frac.of(1, 2));
      expect(chain, [Frac.zero, Frac.of(1, 5), Frac.of(2, 5), Frac.of(3, 5), Frac.of(4, 5), Frac.one]);
      final lasting = Rules.solveChain(4, Frac.of(1, 2), tosses: true);
      expect(lasting, [Frac.zero, Frac.of(3), Frac.of(4), Frac.of(3), Frac.zero]);
      expect(Rules.settings, 108);
    });

    test('the words', () {
      expect(Rules.chanceTold(Frac.of(1, 4)), 'one time in four');
      expect(Rules.chanceTold(Frac.of(2, 3)), 'two times in three');
      expect(Rules.chanceTold(Frac.of(1, 2)), 'one time in two');
      expect(Rules.chanceTold(Frac.of(9, 20)), 'nine times in twenty');
      expect(Rules.coinNames, ['against Ash', 'fair', 'for Ash']);
    });

    test('the sweep', () {
      expect(Rules.sweep((a, b, c) => Rules.chanceByFormula(a, b, c) == Frac.of(1, 4)), (2, 108, (1, 3, 1)));
      expect(Rules.sweep((a, b, c) => c == 0 && Rules.chanceByFormula(a, b, c) == Frac.of(1, 2)), (0, 108, null));
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The Even Duel Against the Coin']);
      for (final level in Levels.all) {
        final (met, all, _) = Rules.sweep(level.meets);
        expect((met, all), (level.ways, 108), reason: level.name);
        final aim = level.aim;
        if (aim != null) expect(level.meets(aim.$1, aim.$2, aim.$3), isTrue, reason: level.name);
      }
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'set the purses and the coin so Ash takes the pot one time in four exactly');
      expect(Levels.at(2).task, 'set the purses and the coin so the duel lasts nine tosses on average exactly');
      expect(Levels.at(3).task, 'set the purses so Ash takes the pot nine times in twenty or better, the coin against Ash');
      expect(Levels.at(4).task, 'set the purses and the coin so Ash takes the pot one time in two exactly, the coin against Ash');
    });

    test('an ask is met by the chance, the length, or the floor', () {
      expect(Levels.at(0).meets(2, 6, 1), isTrue);
      expect(Levels.at(0).meets(2, 6, 0), isFalse);
      expect(Levels.at(1).meets(1, 1, 2), isTrue);
      expect(Levels.at(1).meets(1, 1, 1), isFalse);
      expect(Levels.at(2).meets(3, 3, 1), isTrue);
      expect(Levels.at(3).meets(3, 1, 0), isTrue);
      expect(Levels.at(3).meets(2, 1, 0), isFalse);
      expect(Levels.at(3).meets(3, 1, 1), isFalse);
      expect(Levels.at(4).meets(6, 1, 0), isFalse);
      expect(Levels.at(4).meets(1, 1, 1), isFalse);
    });
  });

  group('the play', () {
    test('opens on three coins to two with the fair coin, landing nothing', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect((play.ash, play.birch, play.coin, play.moves), (3, 2, 1, 0));
        expect(play.chance, Frac.of(3, 5));
        expect(play.lasts, Frac.of(6));
        expect(play.isOver, isFalse, reason: level.name);
      }
    });

    test('a tap fills or empties a purse a coin, a purse at its end stays, and the coin turns round', () {
      var play = Play.of(Levels.at(0)).set(0, 1);
      expect((play.ash, play.birch, play.moves), (4, 2, 1));
      play = play.set(1, -1);
      expect((play.ash, play.birch, play.moves), (4, 1, 2));
      expect(play.set(1, -1), same(play));
      play = play.turnCoin();
      expect((play.coin, play.moves), (2, 3));
      play = play.turnCoin();
      expect(play.coin, 0);
      final full = Play.standing(Levels.at(0), 6, 6, 1);
      expect(full.set(0, 1), same(full));
      expect(full.set(1, 1), same(full));
      expect(full.set(0, -1).ash, 5);
    });

    test('back undoes one tap', () {
      final play = Play.of(Levels.at(0)).set(0, 1).turnCoin();
      expect(play.back.coin, 1);
      expect(play.back.back.ash, 3);
    });

    test('the quarter lands, and it takes no more taps', () {
      final play = Play.of(Levels.at(0)).set(0, -1).set(0, -1).set(1, 1);
      expect((play.ash, play.birch, play.coin), (1, 3, 1));
      expect(play.chance, Frac.of(1, 4));
      expect(play.isDone, isTrue);
      expect(play.set(1, 1), same(play));
      expect(play.turnCoin(), same(play));
    });

    test('the pointer names the coin, the purse and the way', () {
      var play = Play.of(Levels.at(3));
      expect(play.next, (2, 0));
      play = play.turnCoin();
      expect(play.next, (2, 0));
      play = play.turnCoin();
      expect(play.coin, 0);
      expect(play.next, (1, -1));
      play = play.set(1, -1);
      expect(play.isDone, isTrue);
      expect(play.next, isNull);
      expect(Play.pointed((2, 0)), 'Turn the coin over.');
      expect(Play.pointed((0, 1)), 'Give Ash a coin.');
      expect(Play.pointed((1, -1)), 'Take Birch a coin.');
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('following the pointer stakes every winnable ask', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var steps = 0;
        while (!play.isDone && steps < 20) {
          final (which, by) = play.next!;
          play = which == 2 ? play.turnCoin() : play.set(which, by);
          steps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
      }
    });

    test('the even duel against the coin admits it at six to one, or after thirty taps', () {
      var play = Play.of(Levels.at(4)).turnCoin().turnCoin();
      expect(play.coin, 0);
      play = play.set(1, -1);
      for (var k = 0; k < 2; k++) {
        play = play.set(0, 1);
      }
      expect((play.ash, play.birch), (5, 1));
      expect(play.gaveUp, isFalse);
      play = play.set(0, 1);
      expect(play.gaveUp, isTrue);
      expect(play.chance, Frac.of(63, 127));
      expect(play.moves, 6);
      expect(play.next, isNull);
      var wander = Play.of(Levels.at(4));
      for (var k = 0; k < 30; k++) {
        wander = wander.set(0, k.isEven ? 1 : -1);
      }
      expect((wander.moves, wander.gaveUp), (30, true));
    });

    test('the why tells the share and the sweep', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('as often as his share of it'));
      expect(words, contains('This is ask 5, The Even Duel Against the Coin.'));
      expect(words, contains('108 settings, tried in full'));
    });
  });
}
