import 'package:bridgeholm/walk/play.dart';
import 'package:bridgeholm/walk/rules.dart';
import 'package:bridgeholm/walk/towns.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('the bridges', () {
    test('touch their two grounds and nothing else', () {
      final rules = Rules(Towns.at(2));
      expect(rules.across(0, 0), 1);
      expect(rules.across(0, 1), 0);
      expect(rules.across(0, 2), isNull);
    });

    test('twin bridges are different bridges', () {
      final town = Towns.at(2);
      expect(town.bridges[0], town.bridges[1]);
      expect(town.degree(0), 3);
      expect(town.degree(1), 5);
    });
  });

  group('the two ways of knowing', () {
    for (var number = 0; number < Towns.count; number++) {
      final town = Towns.at(number);

      test('${town.name}: the search and the parity never part', () {
        // The anchor. The search tries every trail knowing nothing of
        // parity; the tallies count bridges knowing nothing of trails.
        final rules = Rules(town);
        final odd = rules.oddGrounds;
        expect(odd, town.oddGrounds);
        expect(rules.walkable, town.walkable);
        for (var ground = 0; ground < town.grounds.length; ground++) {
          final walks = rules.walksFrom(ground);
          if (!town.walkable) {
            expect(walks, 0, reason: town.grounds[ground]);
          } else if (odd.isEmpty) {
            expect(walks, greaterThan(0), reason: town.grounds[ground]);
          } else {
            expect(walks > 0, odd.contains(ground),
                reason: town.grounds[ground]);
          }
        }
      });
    }

    test('the counted walks are what the checker printed', () {
      expect(Rules(Towns.at(0)).walksFrom(0), 2);
      expect(Rules(Towns.at(1)).walksFrom(0), 44);
      expect(Rules(Towns.at(1)).walksFrom(4), 0);
      expect(Rules(Towns.at(3)).walksFrom(1), 208);
      expect(Rules(Towns.at(4)).walksFrom(2), 8);
    });
  });

  group('a walk in play', () {
    test('starts standing nowhere, and stands where it is told', () {
      final play = Play.of(Towns.at(0));
      expect(play.started, isFalse);
      expect(play.canStill, isTrue);
      final stood = play.stand(2);
      expect(stood.standing, 2);
      expect(identical(stood.stand(1), stood), isTrue);
    });

    test('a crossing moves the walk and spends the bridge', () {
      final play = Play.of(Towns.at(0)).stand(0).cross(0);
      expect(play.standing, 1);
      expect(play.crossed, 1);
      expect(play.bridgeWalked(0), isTrue);
      expect(play.mayCross(0), isFalse);
    });

    test('a far bridge may not be crossed', () {
      final play = Play.of(Towns.at(0)).stand(0);
      expect(play.mayCross(1), isFalse);
      expect(identical(play.cross(1), play), isTrue);
    });

    test('take back returns the walk as it stood', () {
      final start = Play.of(Towns.at(0)).stand(0);
      final crossed = start.cross(0);
      expect(crossed.back.standing, 0);
      expect(crossed.back.crossed, 0);
    });

    test('a doomed crossing shows in canStill at once', () {
      // Somewhere in the envelope a live walk holds a bridge that
      // strands it: the search finds the spot, and the live check
      // catches it the moment it is crossed.
      var edge = [Play.of(Towns.at(1)).stand(0)];
      Play? doomed;
      while (doomed == null && edge.isNotEmpty) {
        final next = <Play>[];
        for (final play in edge) {
          for (var bridge = 0; bridge < 8 && doomed == null; bridge++) {
            if (!play.mayCross(bridge)) continue;
            final crossed = play.cross(bridge);
            if (!crossed.canStill) {
              doomed = crossed;
            } else {
              next.add(crossed);
            }
          }
        }
        edge = next;
      }
      expect(doomed, isNotNull,
          reason: 'no crossing anywhere ever stranded the walk');
      expect(doomed!.canStill, isFalse);
      expect(doomed.back.canStill, isTrue);
    });

    test('a walk can strand itself with bridges left', () {
      // Round the mill the wrong way twice... the short way: stand on
      // the north bank, cross to the mill isle and back by the two
      // sides, and stand stuck while the far bridges wait.
      final play =
          Play.of(Towns.at(4)).stand(0).cross(0).cross(1).cross(2);
      expect(play.standing, 0);
      expect(play.stuck, isTrue);
      expect(play.isDone, isFalse);
      expect(play.canStill, isFalse);
    });

    test('following the game walks every walkable town home', () {
      for (var number = 0; number < Towns.count; number++) {
        final town = Towns.at(number);
        if (!town.walkable) continue;
        var play = Play.of(town);
        play = play.stand(play.nextStart!);
        var guard = 0;
        while (!play.isDone) {
          if (guard++ > 12) fail('${town.name} never walked');
          expect(play.canStill, isTrue, reason: town.name);
          play = play.cross(play.nextBridge!);
        }
        expect(play.crossed, town.bridges.length, reason: town.name);
      }
    });

    test('the seven bridges offer no start and no next', () {
      final play = Play.of(Towns.at(2));
      expect(play.canStill, isFalse);
      expect(play.nextStart, isNull);
      expect(play.stand(1).nextBridge, isNull);
    });
  });
}
