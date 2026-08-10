import 'package:flutter_test/flutter_test.dart';
import 'package:lampwath/wath/bridge.dart';
import 'package:lampwath/wath/bridges.dart';
import 'package:lampwath/wath/fewest.dart';
import 'package:lampwath/wath/play.dart';

/// Tries every night of up to the bound crossings, the slow honest way.
int _byTrying(Bridge bridge) {
  var best = 1 << 20;

  void go(int over, bool lampFar, int spent, int crossings) {
    if (spent >= best) return;
    if (over == bridge.everyone) {
      best = spent;
      return;
    }
    if (crossings > bridge.count * 2 + 1) return;
    for (var one = 0; one < bridge.count; one++) {
      if (((over >> one) & 1 != 0) != lampFar) continue;
      for (var other = one; other < bridge.count; other++) {
        if (((over >> other) & 1 != 0) != lampFar) continue;
        final party = (1 << one) | (1 << other);
        final slower =
            bridge.walkers[one].minutes > bridge.walkers[other].minutes
                ? bridge.walkers[one].minutes
                : bridge.walkers[other].minutes;
        go(lampFar ? over & ~party : over | party, !lampFar, spent + slower,
            crossings + 1);
      }
    }
  }

  go(0, false, 0, 0);
  return best;
}

void main() {
  group('the settling against trying everything', () {
    for (var number = 0; number < Bridges.count; number++) {
      final bridge = Bridges.at(number);

      test('${bridge.name} comes out the same both ways', () {
        expect(Crossings(bridge).from(0, false), _byTrying(bridge));
      });
    }

    test('and on a hundred nights made up at random', () {
      var seed = 20260810;
      for (var go = 0; go < 100; go++) {
        final walkers = <Walker>[];
        final count = 2 + (seed = _next(seed)) % 4;
        for (var walker = 0; walker < count; walker++) {
          walkers.add(Walker('W$walker', 1 + (seed = _next(seed)) % 12));
        }
        final bridge = Bridge(name: 'made up', walkers: walkers, fewest: 0);
        expect(Crossings(bridge).from(0, false), _byTrying(bridge),
            reason: walkers.map((walker) => walker.minutes).toList().toString());
      }
    });
  });

  group('the famous two minutes', () {
    test('pairing the slow pair beats ferrying by two', () {
      final bridge = Bridges.at(2);
      final crossings = Crossings(bridge);
      expect(crossings.from(0, false), 17);
      expect(crossings.byFerrying(), 19);
    });

    test('and on the even pace it buys nothing at all', () {
      final bridge = Bridges.at(3);
      final crossings = Crossings(bridge);
      expect(crossings.from(0, false), crossings.byFerrying());
    });
  });

  group('every bridge that ships', () {
    for (var number = 0; number < Bridges.count; number++) {
      final bridge = Bridges.at(number);

      test('${bridge.name} says the number the settling says', () {
        expect(Crossings(bridge).from(0, false), bridge.fewest);
      });

      test('${bridge.name} wears the right ferry label', () {
        final crossings = Crossings(bridge);
        expect(crossings.byFerrying() == bridge.fewest, bridge.ferryDoes);
      });
    }
  });

  group('a night at the bridge', () {
    late Play play;

    setUp(() => play = Play.of(Bridges.at(2), Crossings(Bridges.at(2))));

    test('starts with everybody near and the lantern with them', () {
      expect(play.over, 0);
      expect(play.lampFar, isFalse);
      expect(play.spent, 0);
      expect(play.couldFinishIn, 17);
    });

    test('two are picked, cross at the slower pace, and the lantern goes '
        'with them', () {
      play = play.pick(0).pick(1).cross();
      expect(play.spent, 2);
      expect(play.onFar(0), isTrue);
      expect(play.onFar(1), isTrue);
      expect(play.lampFar, isTrue);
    });

    test('no more than two can be picked', () {
      play = play.pick(0).pick(1);
      expect(identical(play.pick(2), play), isTrue);
    });

    test('a walker across the water cannot be picked', () {
      play = play.pick(0).pick(1).cross();
      expect(identical(play.pick(2), play), isTrue);
      expect(play.pick(0).isChosen(0), isTrue);
    });

    test('crossing with nobody picked does nothing', () {
      expect(identical(play.cross(), play), isTrue);
    });

    test('sending the slow pair first costs, and the game knows at once', () {
      play = play.pick(2).pick(3).cross();
      expect(play.couldFinishIn, greaterThan(17));
    });

    test('take back undoes a crossing, again empties the night', () {
      play = play.pick(0).pick(1).cross();
      expect(play.back.spent, 0);
      play = play.pick(0).pick(1).cross().again;
      expect(play.done, isEmpty);
    });

    test('following the settling finishes every bridge at par', () {
      for (var number = 0; number < Bridges.count; number++) {
        final bridge = Bridges.at(number);
        var walk = Play.of(bridge, Crossings(bridge));
        var guard = 0;
        while (!walk.isDone) {
          if (guard++ > 16) fail('${bridge.name} never crossed');
          var party = walk.next!;
          for (var walker = 0; walker < bridge.count; walker++) {
            if ((party & (1 << walker)) != 0) walk = walk.pick(walker);
          }
          walk = walk.cross();
        }
        expect(walk.spent, bridge.fewest, reason: bridge.name);
        expect(walk.isFewest, isTrue, reason: bridge.name);
      }
    });
  });
}

int _next(int seed) => (seed * 1103515245 + 12345) & 0x7fffffff;
