import 'package:flutter_test/flutter_test.dart';
import 'package:sharewick/trio/levels.dart';
import 'package:sharewick/trio/play.dart';
import 'package:sharewick/trio/rules.dart';

/// The trios, the sweep, the asks and the play, checked at the domain:
/// nothing here touches a widget.
void main() {
  group('the trios', () {
    test('six friends, twenty trios, and a family told and read back', () {
      expect(Rules.friends, 6);
      expect(Rules.trios, hasLength(20));
      expect(Rules.families, 1048576);
      expect(Rules.nameOf(Rules.trios.first), 'ABC');
      expect(Rules.nameOf(Rules.trios.last), 'DEF');
      expect(Rules.trioOf('ACE'), Rules.trios[5]);
      expect(Rules.nameOf(Rules.otherThree(Rules.trioOf('ABC'))), 'DEF');
      expect(Rules.share(Rules.trioOf('ABC'), Rules.trioOf('CDE')), isTrue);
      expect(Rules.share(Rules.trioOf('ABC'), Rules.trioOf('DEF')), isFalse);
      final fam = Rules.familyOf('ABC, DEF, ABD');
      expect(Rules.tell(fam), 'ABC, ABD, DEF');
      expect(Rules.size(fam), 3);
      expect(Rules.apart(fam), [(Rules.trioOf('ABC'), Rules.trioOf('DEF'))]);
      expect(Rules.sharing(fam), isFalse);
      expect(Rules.oneOfEachPair(fam), isFalse);
      expect(Rules.tell(Rules.toggled(fam, Rules.trioOf('DEF'))), 'ABC, ABD');
      expect(Rules.hands(fam), [2, 2, 1, 2, 1, 1]);
      expect(Rules.star(fam), isNull);
      expect(Rules.star(Rules.familyOf('ABC, ABD')), 0);
      expect(Rules.star(0), isNull);
      expect(Rules.missingPairs, hasLength(10));
      for (final (t, u) in Rules.missingPairs) {
        expect(t | u, Rules.all);
      }
    });

    test('the sweep: the two voices agree on every family, and the sharing families run three to the ten', () {
      var sharing = 0;
      final tens = <int>[];
      for (var family = 0; family < Rules.families; family++) {
        final s = Rules.sharing(family);
        expect(Rules.oneOfEachPair(family), s, reason: Rules.tell(family));
        if (s) {
          sharing++;
          final n = Rules.size(family);
          expect(n, lessThanOrEqualTo(10), reason: Rules.tell(family));
          if (n == 10) tens.add(family);
        }
      }
      expect(sharing, 59049);
      expect(tens, hasLength(1024));
      expect(tens.where((f) => Rules.star(f) != null).length, 6);
      expect(tens.where((f) => Rules.hands(f).every((h) => h == 5)).length, 12);
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The Eleven']);
      for (final level in Levels.all) {
        var ways = 0;
        for (var family = 0; family < Rules.families; family++) {
          if (level.meets(family)) ways++;
        }
        expect(ways, level.ways, reason: level.name);
        final aim = level.aim;
        if (aim != null) expect(level.meets(aim), isTrue, reason: level.name);
        if (!level.winnable) expect(aim, isNull);
      }
      expect(Rules.tell(Levels.at(0).aim!), 'ABC, ABD, ABE, ABF, ACD, ACE, ACF, ADE, ADF, AEF');
      expect(Rules.tell(Levels.at(1).aim!), 'ABC, ABD, ABE, ABF, ACD, ACE, ACF, ADE, ADF, AEF');
      expect(Rules.tell(Levels.at(2).aim!), 'ABC, ABD, ACE, ADF, AEF, BCF, BDE, BEF, CDE, CDF');
      expect(Rules.tell(Levels.at(3).aim!), 'ABC, ABD, ABE, ABF, ACD, ACE, ACF, ADE, ADF, AEF, BCD, BCE, BCF, BDE, BDF');
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'pick ten trios so that every two share a friend');
      expect(Levels.at(1).task, 'pick ten trios all holding one friend');
      expect(Levels.at(2).task, 'pick ten trios so that every two share a friend and every friend is in five');
      expect(Levels.at(3).task, 'pick fifteen trios with only five pairs apart');
      expect(Levels.at(4).task, 'pick eleven trios so that every two share a friend');
    });

    test('an ask is met by the family', () {
      final star = Rules.familyOf('ABC, ABD, ABE, ABF, ACD, ACE, ACF, ADE, ADF, AEF');
      final even = Rules.familyOf('ABC, ABD, ACE, ADF, AEF, BCF, BDE, BEF, CDE, CDF');
      expect(Levels.at(0).meets(star), isTrue);
      expect(Levels.at(0).meets(even), isTrue);
      expect(Levels.at(0).meets(Rules.toggled(star, Rules.trioOf('AEF'))), isFalse);
      expect(Levels.at(1).meets(star), isTrue);
      expect(Levels.at(1).meets(even), isFalse);
      expect(Levels.at(2).meets(even), isTrue);
      expect(Levels.at(2).meets(star), isFalse);
      expect(Levels.at(3).meets(Levels.at(3).aim!), isTrue);
      expect(Levels.at(3).meets(star), isFalse);
      expect(Levels.at(4).meets(Rules.toggled(star, Rules.trioOf('BCD'))), isFalse);
    });
  });

  group('the play', () {
    test('opens with nothing picked', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect((play.family, play.size, play.moves), (0, 0, 0));
        expect(play.sharing, isTrue);
        expect(play.isOver, isFalse, reason: level.name);
      }
    });

    test('taps pick and unpick, and pairs apart are named', () {
      var play = Play.of(Levels.at(4)).tap(Rules.trioOf('ABC'));
      expect(Rules.tell(play.family), 'ABC');
      play = play.tap(Rules.trioOf('DEF'));
      expect(play.sharing, isFalse);
      expect(play.apart, [(Rules.trioOf('ABC'), Rules.trioOf('DEF'))]);
      expect(play.oneOfEachPair, isFalse);
      play = play.tap(Rules.trioOf('DEF'));
      expect(Rules.tell(play.family), 'ABC');
      expect(play.moves, 3);
      expect(play.tap(0), same(play));
      expect(play.tap(63), same(play));
    });

    test('back undoes one tap', () {
      final play = Play.of(Levels.at(0)).tap(Rules.trioOf('ABC')).tap(Rules.trioOf('ABD'));
      expect(Rules.tell(play.back.family), 'ABC');
      expect(play.back.back.family, 0);
    });

    test('the pointer picks the aim in order, and unpicks a stray trio first', () {
      var play = Play.of(Levels.at(2));
      expect(play.next, (Rules.trioOf('ABC'), false));
      expect(Play.pointed((Rules.trioOf('ABC'), false)), 'Pick ABC.');
      play = play.tap(Rules.trioOf('DEF'));
      expect(play.next, (Rules.trioOf('DEF'), true));
      expect(Play.pointed(play.next!), 'Unpick DEF.');
      play = play.tap(Rules.trioOf('DEF')).tap(Rules.trioOf('ABC'));
      expect(play.next, (Rules.trioOf('ABD'), false));
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('following the pointer lands every winnable ask in as many taps as the aim has trios', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var steps = 0;
        while (!play.isDone && steps < 30) {
          final (trio, _) = play.next!;
          play = play.tap(trio);
          steps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
        expect(play.moves, Rules.size(level.aim!), reason: level.name);
      }
    });

    test('the eleven admits it after three families of eleven, or thirty taps', () {
      var play = Play.of(Levels.at(4));
      for (final t in Rules.trios.take(11)) {
        play = play.tap(t);
      }
      expect(play.size, 11);
      expect(play.apart, hasLength(1));
      expect(play.seen, hasLength(1));
      expect(play.gaveUp, isFalse);
      play = play.tap(Rules.trios[10]).tap(Rules.trios[11]);
      expect(play.seen, hasLength(2));
      expect(play.gaveUp, isFalse);
      play = play.tap(Rules.trios[11]).tap(Rules.trios[12]);
      expect(play.seen, hasLength(3));
      expect(play.gaveUp, isTrue);
      expect(play.moves, 15);
      expect(play.next, isNull);
      var wander = Play.of(Levels.at(4));
      for (var k = 0; k < 30; k++) {
        wander = wander.tap(Rules.trios[k % 2]);
      }
      expect(wander.gaveUp, isTrue);
      expect(wander.moves, 30);
    });

    test('the why tells Erdos, Ko and Rado and the sweep', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('Erdos, Ko and Rado proved'));
      expect(words, contains('1,048,576'));
      expect(words, contains('This is ask 5, The Eleven.'));
      expect(words, contains('looked at in full'));
    });
  });
}
