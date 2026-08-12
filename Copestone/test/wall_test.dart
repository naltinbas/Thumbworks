import 'package:flutter_test/flutter_test.dart';
import 'package:copestone/wall/pitches.dart';
import 'package:copestone/wall/play.dart';
import 'package:copestone/wall/rules.dart';

void main() {
  group('the rule', () {
    test('a doubled run of any length is found, lowest first', () {
      expect(Rules.doubledRun([0, 0]), (0, 1));
      expect(Rules.doubledRun([0, 1, 0, 1]), (0, 2));
      expect(Rules.doubledRun([2, 0, 1, 0, 1]), (1, 2));
      expect(Rules.doubledRun([0, 1, 2, 0, 1]), isNull);
      expect(Rules.sound([0, 1, 0, 2, 0, 1, 0]), isTrue);
    });

    test('two kinds die at the third course', () {
      expect(Rules.soundWalls(2, 3), 2);
      expect(Rules.soundWalls(2, 4), 0);
      expect(Rules.tallest(2, 10), 3);
    });

    test('the sweep counts the sound walls at every asked height',
        () {
      expect(Rules.soundWalls(3, 8), 78);
      expect(Rules.soundWalls(3, 10), 144);
      expect(Rules.soundWalls(3, 12), 264);
    });

    test('the palindrome stands sound and pens itself in', () {
      const penned = [0, 1, 0, 2, 0, 1, 0];
      expect(Rules.sound(penned), isTrue);
      for (var kind = 0; kind < 3; kind++) {
        expect(Rules.sound([...penned, kind]), isFalse,
            reason: 'kind $kind');
      }
      expect(Rules.canClimb(penned, 3, 8), isFalse);
    });

    test('a sound wall never limps: it climbs or is penned '
        'outright', () {
      for (final pitch in Pitches.all.where((pitch) => pitch.winnable)) {
        expect(Rules.neverLimps(pitch.kinds, pitch.height), isTrue,
            reason: pitch.name);
      }
    });

    test('every pitch label matches the sweep', () {
      for (final pitch in Pitches.all) {
        expect(
          Rules.soundWalls(pitch.kinds, pitch.height) > 0,
          pitch.reachable,
          reason: pitch.name,
        );
      }
    });
  });

  group('a wall', () {
    test('courses lay and refuse by the rule', () {
      var play = Play.of(Pitches.at(1));
      play = play.lay(0).lay(1);
      expect(play.courses, [0, 1]);
      expect(play.mayLay(1), isFalse);
      expect(play.doubledBy(1), (1, 1));
      expect(play.lay(1), same(play));
      expect(play.back.courses, [0]);
    });

    test('the walk keeps the height in reach', () {
      var play = Play.of(Pitches.at(1));
      expect(play.climbs, isTrue);
      // Lay the palindrome by hand: sound at every course, penned
      // at the seventh.
      for (final kind in const [0, 1, 0, 2, 0, 1, 0]) {
        expect(play.mayLay(kind), isTrue);
        play = play.lay(kind);
      }
      expect(play.pennedIn, isTrue);
      expect(play.climbs, isFalse);
      expect(play.next, isNull);
    });

    test('the walk warns before the wall does', () {
      // After a-b-a-c-a-b the wall still stands but only some
      // courses keep eight in reach; the walk knows which.
      var play = Play.of(Pitches.at(1));
      for (final kind in const [0, 1, 0, 2, 0, 1]) {
        play = play.lay(kind);
      }
      expect(play.mayLay(0), isTrue);
      final walledIn = play.lay(0);
      expect(walledIn.climbs, isFalse,
          reason: 'the seventh a pens the wall');
      expect(play.next, isNot(0));
    });

    test('following the walk raises every winnable pitch', () {
      for (final pitch in Pitches.all.where((pitch) => pitch.winnable)) {
        var play = Play.of(pitch);
        var guard = 0;
        while (!play.isDone) {
          if (guard++ > 14) fail('${pitch.name} never stood');
          play = play.lay(play.next!);
        }
        expect(play.courses, hasLength(pitch.height),
            reason: pitch.name);
        expect(Rules.sound(play.courses), isTrue);
      }
    });

    test('the fourth course never comes', () {
      var play = Play.of(Pitches.at(4));
      expect(play.climbs, isFalse);
      expect(play.next, isNull);
      // The best wall two kinds allow, laid by hand.
      play = play.lay(0).lay(1).lay(0);
      expect(play.courses, hasLength(3));
      expect(play.pennedIn, isTrue);
    });
  });
}
