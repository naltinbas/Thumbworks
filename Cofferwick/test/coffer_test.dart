import 'package:flutter_test/flutter_test.dart';
import 'package:cofferwick/coffer/frac.dart';
import 'package:cofferwick/coffer/levels.dart';
import 'package:cofferwick/coffer/play.dart';
import 'package:cofferwick/coffer/rules.dart';

/// The layings, the two chances, the asks and the play, checked at the
/// domain: nothing here touches a widget.
void main() {
  const bertrand = [true, true, true, false, false, false];

  group('the coffers', () {
    test('Bertrand\'s laying: two in three by the draws and by Bayes', () {
      expect(Rules.chanceByDraws(bertrand), Frac.of(2, 3));
      expect(Rules.chanceByBayes(bertrand), Frac.of(2, 3));
      expect(Rules.sorts(bertrand), (1, 1, 1));
      expect(Rules.golds(bertrand), 3);
      expect(Rules.tellCoffer(bertrand, 0), 'gold and gold');
      expect(Rules.tellCoffer(bertrand, 1), 'gold and silver');
      expect(Rules.tellCoffer(bertrand, 2), 'silver and silver');
      expect(Rules.tellChance(Frac.of(2, 3)), '2/3');
      expect(Rules.tellChance(Frac.one), '1, certain');
      expect(Rules.tellChance(Frac.zero), '0, never');
      expect(Rules.tellChance(null), 'none, no gold coin to draw');
    });

    test('the two voices agree on every laying, and only five chances come', () {
      final seen = <String>{};
      for (var n = 0; n < Rules.settings; n++) {
        final coins = Rules.laying(n);
        expect(Rules.chanceByBayes(coins), Rules.chanceByDraws(coins), reason: '$n');
        seen.add(Rules.tellChance(Rules.chanceByDraws(coins)));
      }
      expect(Rules.settings, 64);
      expect(seen, {'none, no gold coin to draw', '0, never', '1/2', '2/3', '4/5', '1, certain'});
      expect(Rules.laying(0), everyElement(isFalse));
      expect(Rules.laying(7), bertrand);
      expect(Rules.chanceByDraws(Rules.laying(0)), isNull);
      expect(Rules.chanceByDraws([true, false, true, false, true, false]), Frac.zero);
      expect(Rules.chanceByDraws([true, true, true, true, true, false]), Frac.of(4, 5));
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The Half of Three']);
      for (final level in Levels.all) {
        var n = 0;
        for (var k = 0; k < Rules.settings; k++) {
          if (level.meets(Rules.laying(k))) n++;
        }
        expect(n, level.ways, reason: level.name);
        final aim = level.aim;
        if (aim != null) expect(level.meets(aim), isTrue, reason: level.name);
        if (!level.winnable) expect(aim, isNull);
      }
      expect(Levels.at(0).aim, bertrand);
      expect(Levels.at(4).settings, 20);
      expect(Levels.at(0).settings, 64);
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'lay the coins so that a gold coin drawn at random has a gold mate with chance 2 in 3');
      expect(Levels.at(3).task, 'lay the coins so that a gold coin drawn at random has a gold mate for certain');
      expect(Levels.at(4).task, 'lay the coins so that a gold coin drawn at random has a gold mate with chance 1 in 2, with three gold coins and three silver');
    });

    test('an ask is met by the chance, and by the gold count where it insists', () {
      expect(Levels.at(0).meets(bertrand), isTrue);
      expect(Levels.at(0).meets([false, false, true, true, true, false]), isTrue);
      expect(Levels.at(0).meets([true, true, false, false, false, false]), isFalse);
      expect(Levels.at(1).meets([true, true, true, false, true, false]), isTrue);
      expect(Levels.at(1).meets(bertrand), isFalse);
      expect(Levels.at(2).meets([true, true, true, true, true, false]), isTrue);
      expect(Levels.at(3).meets([true, true, false, false, false, false]), isTrue);
      expect(Levels.at(3).meets([true, true, true, true, true, true]), isTrue);
      expect(Levels.at(3).meets(bertrand), isFalse);
      expect(Levels.at(4).meets([true, true, true, false, true, false]), isFalse);
      expect(Levels.at(4).meets(bertrand), isFalse);
    });
  });

  group('the play', () {
    test('opens all silver', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.coins, everyElement(isFalse));
        expect((play.golds, play.moves), (0, 0));
        expect(play.chance, isNull);
        expect(play.isOver, isFalse, reason: level.name);
      }
    });

    test('a tap turns a coin over, and back undoes it', () {
      var play = Play.of(Levels.at(0)).tap(0);
      expect(play.coins[0], isTrue);
      expect(play.chance, Frac.zero);
      play = play.tap(1);
      expect(play.chance, Frac.one);
      expect(play.moves, 2);
      expect(play.tap(1).coins[1], isFalse);
      expect(play.back.coins[1], isFalse);
      expect(play.tap(6), same(play));
    });

    test('the pointer names the first coin astray, and lands every winnable ask', () {
      expect(Play.of(Levels.at(0)).next, 0);
      expect(Play.pointed(0), 'Turn the left coin of the first coffer.');
      expect(Play.pointed(5), 'Turn the right coin of the third coffer.');
      expect(Play.of(Levels.at(4)).next, isNull);
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var steps = 0;
        while (!play.isDone && steps < 8) {
          play = play.tap(play.next!);
          steps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
      }
      final play = Play.of(Levels.at(1)).tap(3);
      expect(play.next, 0);
    });

    test('the half of three admits it at three gold coins, or after twelve taps', () {
      var play = Play.of(Levels.at(4)).tap(0).tap(2);
      expect(play.gaveUp, isFalse);
      play = play.tap(4);
      expect(play.golds, 3);
      expect(play.chance, Frac.zero);
      expect(play.gaveUp, isTrue);
      expect(play.next, isNull);
      var pair = Play.of(Levels.at(4)).tap(0).tap(1).tap(2);
      expect(pair.chance, Frac.of(2, 3));
      expect(pair.gaveUp, isTrue);
      var wander = Play.of(Levels.at(4));
      for (var k = 0; k < 12; k++) {
        wander = wander.tap(0);
      }
      expect(wander.golds, 0);
      expect(wander.gaveUp, isTrue);
    });

    test('the why tells Bertrand and the sweep', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('Bertrand set the puzzle in 1889'));
      expect(words, contains('64 layings'));
      expect(words, contains('This is ask 5, The Half of Three.'));
      expect(words, contains('drawn out in full'));
    });
  });
}
