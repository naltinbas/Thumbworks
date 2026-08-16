import 'package:flutter_test/flutter_test.dart';
import 'package:kithwell/kith/frac.dart';
import 'package:kithwell/kith/level.dart';
import 'package:kithwell/kith/levels.dart';
import 'package:kithwell/kith/play.dart';
import 'package:kithwell/kith/rules.dart';

/// The friendships, the two averages, the asks and the play, checked
/// at the domain: nothing here touches a widget.
void main() {
  group('the fair', () {
    test('six people, fifteen pairs, the counts and the two averages', () {
      expect(Rules.people, 6);
      expect(Rules.pairs, hasLength(15));
      expect(Rules.plans, 32768);
      final star = Rules.planOf('Ann-Bess, Ann-Cal, Ann-Dot, Ann-Ed, Ann-Fay');
      expect(Rules.tell(star), 'Ann-Bess, Ann-Cal, Ann-Dot, Ann-Ed, Ann-Fay');
      expect(Rules.friendships(star), 5);
      expect(Rules.degrees(star), [5, 1, 1, 1, 1, 1]);
      expect(Rules.average(star), Frac.of(5, 3));
      expect(Rules.friendsAverage(star), Frac.of(3));
      expect(Rules.friendsAverageBySquares(star), Frac.of(3));
      expect(Rules.gap(star), Frac.of(4, 3));
      expect(Rules.spread(star), Frac.of(20, 9));
      expect(Rules.friends(star, 0, 3), isTrue);
      expect(Rules.friends(star, 1, 2), isFalse);
      expect(Rules.friends(star, 2, 2), isFalse);
      expect(Rules.tell(Rules.toggled(star, 1, 2)), 'Ann-Bess, Ann-Cal, Ann-Dot, Ann-Ed, Ann-Fay, Bess-Cal');
      final one = Rules.planOf('Ann-Bess');
      expect(Rules.average(one), Frac.of(1, 3));
      expect(Rules.friendsAverage(one), Frac.one);
      expect(Rules.gap(one), Frac.of(2, 3));
      expect(Rules.friendsAverage(0), isNull);
      expect(Rules.gap(0), isNull);
      expect(Rules.personByPerson(star), Frac.of(13, 3));
      expect(tellFrac(Frac.of(5, 3)), '1 2/3');
      expect(tellFrac(Frac.of(3)), '3');
      expect(tellFrac(Frac.of(1, 2)), '1/2');
      expect(Level.widest, Frac.of(4, 3));
    });

    test('the sweep: the two averages agree on every plan, and the friends named are never behind', () {
      var even = 0, widest = 0;
      for (var mask = 1; mask < Rules.plans; mask++) {
        final f = Rules.friendsAverage(mask)!;
        expect(Rules.friendsAverageBySquares(mask), f, reason: Rules.tell(mask));
        final gap = f - Rules.average(mask);
        expect(gap.compareTo(Frac.zero) >= 0, isTrue, reason: Rules.tell(mask));
        expect(gap, Rules.spread(mask) / Rules.average(mask), reason: Rules.tell(mask));
        expect(Rules.personByPerson(mask)!.compareTo(Rules.average(mask)) >= 0, isTrue, reason: Rules.tell(mask));
        if (gap == Frac.zero) even++;
        if (gap == Level.widest) widest++;
      }
      expect((even, widest), (171, 6));
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The Popular Few']);
      for (final level in Levels.all) {
        var ways = 0;
        for (var mask = 1; mask < Rules.plans; mask++) {
          if (level.meets(mask)) ways++;
        }
        expect(ways, level.ways, reason: level.name);
        final aim = level.aim;
        if (aim != null) expect(level.meets(aim), isTrue, reason: level.name);
        if (!level.winnable) expect(aim, isNull);
      }
      expect(Rules.tell(Levels.at(0).aim!), 'Ann-Fay, Bess-Ed, Cal-Dot');
      expect(Rules.tell(Levels.at(1).aim!), 'Ann-Bess, Ann-Cal, Ann-Dot');
      expect(Rules.tell(Levels.at(2).aim!), 'Ann-Bess, Ann-Cal, Ann-Dot, Ann-Ed, Ann-Fay');
      expect(Rules.tell(Levels.at(3).aim!), 'Ann-Cal, Ann-Dot, Ann-Ed, Ann-Fay, Bess-Cal, Bess-Dot');
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'lay friendships so that everyone has the same number of friends');
      expect(Levels.at(1).task, 'lay friendships so that the friends named have one friend more, on average, than people do');
      expect(Levels.at(2).task, 'lay friendships so that the gap between the two averages is as wide as it gets');
      expect(Levels.at(3).task, 'lay friendships so that the friends named have half a friend more, on average, than people do');
      expect(Levels.at(4).task, 'lay friendships so that the friends named have fewer friends, on average, than people do');
    });

    test('an ask is met by the plan', () {
      final matching = Rules.planOf('Ann-Bess, Cal-Dot, Ed-Fay');
      final star = Rules.planOf('Ann-Bess, Ann-Cal, Ann-Dot, Ann-Ed, Ann-Fay');
      expect(Levels.at(0).meets(matching), isTrue);
      expect(Levels.at(0).meets(star), isFalse);
      expect(Levels.at(0).meets(0), isFalse);
      expect(Levels.at(1).meets(Rules.planOf('Ann-Bess, Ann-Cal, Ann-Dot')), isTrue);
      expect(Levels.at(1).meets(star), isFalse);
      expect(Levels.at(2).meets(star), isTrue);
      expect(Levels.at(2).meets(matching), isFalse);
      expect(Levels.at(3).meets(Rules.planOf('Ann-Cal, Ann-Dot, Ann-Ed, Ann-Fay, Bess-Cal, Bess-Dot')), isTrue);
      expect(Levels.at(3).meets(star), isFalse);
      expect(Levels.at(4).meets(matching), isFalse);
    });
  });

  group('the play', () {
    test('opens with no friendships and nobody held', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect((play.plan, play.held, play.moves), (0, null, 0));
        expect(play.friendsAverage, isNull);
        expect(play.isOver, isFalse, reason: level.name);
      }
    });

    test('a tap holds a person, a second makes the friendship, the same again lets go, and a friendship parts', () {
      var play = Play.of(Levels.at(4)).tap(0);
      expect(play.held, 0);
      play = play.tap(1);
      expect(play.held, isNull);
      expect(Rules.tell(play.plan), 'Ann-Bess');
      expect(play.moves, 2);
      play = play.tap(2).tap(2);
      expect(play.held, isNull);
      expect(play.moves, 4);
      play = play.tap(1).tap(0);
      expect(play.plan, 0);
      expect(play.tap(6), same(play));
    });

    test('back undoes one tap', () {
      final play = Play.of(Levels.at(0)).tap(0).tap(1);
      expect(play.back.held, 0);
      expect(play.back.back.plan, 0);
    });

    test('the pointer names the friendship, parts a stray one first, and speaks to a held person', () {
      var play = Play.of(Levels.at(2));
      expect(play.next, (0, 1, false));
      expect(Play.pointed((0, 1, false)), 'Tap Ann, then Bess, to lay their friendship.');
      play = play.tap(0);
      expect(Play.pointed(play.next!, held: play.held), 'Now tap Bess to lay Ann and Bess\'s friendship.');
      play = play.tap(1).tap(1).tap(2);
      expect(Rules.tell(play.plan), 'Ann-Bess, Bess-Cal');
      expect(play.next, (1, 2, true));
      expect(Play.pointed(play.next!), 'Tap Bess, then Cal, to lift their friendship.');
      expect(Play.pointed((2, 2, false)), 'Tap Cal again to let go.');
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('following the pointer lands every winnable ask', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var steps = 0;
        while (!play.isDone && steps < 40) {
          final (a, b, _) = play.next!;
          play = play.tap(a == b ? a : (play.held == a ? b : a));
          steps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
        expect(play.moves, 2 * Rules.friendships(level.aim!), reason: level.name);
      }
    });

    test('the popular few admits it after three even plans, or forty taps', () {
      var play = Play.of(Levels.at(4));
      for (final p in [(0, 1), (2, 3), (4, 5)]) {
        play = play.tap(p.$1).tap(p.$2);
      }
      expect(play.gap, Frac.zero);
      expect(play.seen, hasLength(1));
      expect(play.gaveUp, isFalse);
      for (final p in [(0, 1), (2, 3), (0, 2), (1, 3)]) {
        play = play.tap(p.$1).tap(p.$2);
      }
      expect(play.seen, hasLength(2));
      expect(play.gaveUp, isFalse);
      for (final p in [(0, 2), (1, 3), (0, 3), (1, 2)]) {
        play = play.tap(p.$1).tap(p.$2);
      }
      expect(play.seen, hasLength(3));
      expect(play.gaveUp, isTrue);
      expect(play.moves, 22);
      expect(play.next, isNull);
      var wander = Play.of(Levels.at(4));
      for (var k = 0; k < 40; k++) {
        wander = wander.tap(k % 2);
      }
      expect(wander.gaveUp, isTrue);
      expect(wander.moves, 40);
    });

    test('the why tells Feld and the sweep', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('Feld set down in 1991'));
      expect(words, contains('32,767'));
      expect(words, contains('This is ask 5, The Popular Few.'));
      expect(words, contains('named in full'));
    });
  });
}
