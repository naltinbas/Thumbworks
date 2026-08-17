import 'package:flutter_test/flutter_test.dart';
import 'package:bondwell/bond/levels.dart';
import 'package:bondwell/bond/play.dart';
import 'package:bondwell/bond/rules.dart';

/// The garment rule, the estates and the play, checked at the domain:
/// nothing here touches a widget.
void main() {
  group('the garment', () {
    test('the Mishnah\'s own case, and the rule around it', () {
      // A garment claimed whole by one and half by the other.
      expect(Rules.garmentParts(4, 2, 4), (36, 12));
      expect(Rules.garmentParts(2, 2, 2), (12, 12));
      expect(Rules.garmentParts(10, 4, 12), (108, 36));
      // Nothing on the table, nothing to divide.
      expect(Rules.garmentParts(10, 4, 0), (0, 0));
      // More on the table than either can claim: capped at the claims.
      expect(Rules.garmentParts(3, 2, 99), Rules.garmentParts(3, 2, 5));
      expect(Rules.tellParts(36), '3');
      expect(Rules.tellParts(30), '2 1/2');
      expect(Rules.tellParts(4), '1/3');
    });

    test('the recipe and the half-claims rule agree, garment by garment', () {
      var pairs = 0, halves = 0;
      for (var a = 1; a <= 24; a++) {
        for (var b = 1; b <= 24; b++) {
          for (var estate = 0; estate <= a + b; estate++) {
            pairs++;
            final byRule = Rules.garmentParts(a, b, estate);
            expect(byRule, Rules.halfClaimsPairParts(a, b, estate),
                reason: '$a and $b over $estate');
            expect(byRule.$1 + byRule.$2, Rules.parts * estate,
                reason: '$a and $b over $estate');
            if (byRule.$1 % Rules.parts != 0) halves++;
            if (a <= 6 && b <= 6) {
              expect(byRule, Rules.nucleolusBySearch(a, b, estate),
                  reason: 'the nucleolus of $a and $b over $estate');
            }
          }
        }
      }
      expect(pairs, 14976);
      expect(halves, greaterThan(0));
    });
  });

  group('the estates', () {
    test('every estate lands one division, or none at all', () {
      final total = Rules.bonds.reduce((a, b) => a + b);
      var whole = 0, between = 0;
      for (var estate = 0; estate <= total; estate++) {
        final winners = [
          for (final split in Rules.divisions(estate))
            if (Rules.allLevel(split)) split,
        ];
        final byRule = Rules.division(estate);
        if (byRule == null) {
          between++;
          expect(winners, isEmpty, reason: 'estate $estate');
        } else {
          whole++;
          expect(winners, hasLength(1), reason: 'estate $estate');
          expect(winners.first, byRule, reason: 'estate $estate');
        }
      }
      expect((whole, between), (37, 36));
      expect(Rules.division(12), [4, 4, 4]);
      expect(Rules.division(24), [6, 9, 9]);
      expect(Rules.division(36), [6, 12, 18]);
      expect(Rules.division(48), [6, 15, 27]);
      expect(Rules.division(72), [12, 24, 36]);
    });

    test('the Talmud\'s rows, at twenty-five zuz to three coins', () {
      expect(Rules.tellZuz(4), '33 1/3');
      expect(Rules.division(12)!.map(Rules.tellZuz).toList(),
          ['33 1/3', '33 1/3', '33 1/3']);
      expect(Rules.division(24)!.map(Rules.tellZuz).toList(), ['50', '75', '75']);
      expect(Rules.division(36)!.map(Rules.tellZuz).toList(),
          ['50', '100', '150']);
    });

    test('the scales tilt by how far a pair is out', () {
      expect(Rules.tilt([4, 4, 4], 0, 1), 0);
      expect(Rules.allLevel([4, 4, 4]), isTrue);
      expect(Rules.allLevel([5, 4, 3]), isFalse);
      expect(Rules.tilt([5, 3, 4], 0, 1), 12);
      expect(Rules.tilt([3, 5, 4], 0, 1), -12);
      expect(Rules.levelPair([6, 12, 18], 1, 2), isTrue);
      expect(Rules.howManyDivisions(12), 91);
      expect(Rules.taps(15), 5 + 0);
      expect(Rules.taps(4), 2);
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name),
          ['Reward the Long Bond']);
      for (final level in Levels.all) {
        var n = 0;
        for (final split in Rules.divisions(level.estate)) {
          if (level.meets(split)) n++;
        }
        expect(n, level.ways, reason: level.name);
      }
      expect(Levels.all.map((l) => l.estate), [12, 24, 36, 48, 12]);
      expect(Levels.all.map((l) => l.fewest), [6, 8, 12, 16, null]);
      expect(Levels.all.map((l) => l.aim),
          [[4, 4, 4], [6, 9, 9], [6, 12, 18], [6, 15, 27], null]);
      expect(Levels.all.map((l) => l.divisions), [91, 325, 703, 1225, 91]);
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'divide 12 coins so that every scale hangs level');
      expect(Levels.at(4).task,
          'divide 12 coins with every scale level and the longest bond ahead of the shortest');
    });
  });

  group('the play', () {
    test('opens with the coins all in the chest', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.purses, [0, 0, 0]);
        expect((play.moves, play.chest, play.isOver), (0, level.estate, false));
        expect(play.allLevel, isTrue, reason: 'nothing to split yet');
      }
    });

    test('coins go in and come out, and the chest holds the rest', () {
      var play = Play.of(Levels.at(0));
      play = play.step(0, 3);
      expect(play.purses, [3, 0, 0]);
      expect(play.chest, 9);
      expect(play.step(0, -1).purses, [2, 0, 0]);
      expect(play.step(0, 13), same(play));
      expect(play.step(0, -9), same(play));
      expect(play.step(5, 1), same(play));
      expect(play.back.purses, [0, 0, 0]);
      expect(Play.of(Levels.at(0)).step(0, 1).moves, 1);
    });

    test('the pointer lands every ask it can, in the fewest taps', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var steps = 0;
        while (!play.isDone && steps < 30) {
          final aim = play.next;
          expect(aim, isNotNull, reason: level.name);
          play = play.step(aim!.$1, aim.$2);
          steps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
        expect(play.moves, level.fewest, reason: level.name);
        expect(play.purses, level.aim, reason: level.name);
      }
      expect(Play.pointed((0, 3)), 'Put 3 coins in A\'s purse.');
      expect(Play.pointed((2, -1)), 'Take a coin out of C\'s purse.');
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('the long bond ask admits it after three tries', () {
      var play = Play.of(Levels.at(4));
      play = play.step(2, 3).step(2, 3).step(2, 3).step(2, 3);
      expect(play.purses, [0, 0, 12]);
      expect(play.chest, 0);
      expect(play.seen, hasLength(1));
      expect(play.gaveUp, isFalse);
      play = play.step(2, -3).step(1, 3);
      expect(play.seen, hasLength(2));
      play = play.step(2, -3).step(0, 3);
      expect(play.purses, [3, 3, 6]);
      expect(play.seen, hasLength(3));
      expect(play.gaveUp, isTrue);
      expect(play.step(0, 1), same(play));
      // A wanderer runs out of taps instead.
      var wander = Play.of(Levels.at(4));
      for (var k = 0; k < Play.gaveUpAt && !wander.gaveUp; k++) {
        wander = wander.step(0, k.isEven ? 1 : -1);
      }
      expect(wander.gaveUp, isTrue);
      expect(wander.moves, Play.gaveUpAt);
    });

    test('the why tells the Mishnah and Aumann and Maschler', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('Bava Metzia 1:1'));
      expect(words, contains('Ketubot 93a'));
      expect(words, contains('Aumann'));
      expect(words, contains('This is ask 5, Reward the Long Bond.'));
      expect(words, contains('tried in full'));
    });
  });
}
