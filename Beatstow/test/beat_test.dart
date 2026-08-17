import 'package:beatstow/beat/levels.dart';
import 'package:beatstow/beat/play.dart';
import 'package:beatstow/beat/rules.dart';
import 'package:flutter_test/flutter_test.dart';

/// The ring itself, with no screen anywhere near it.
void main() {
  group('the ring', () {
    test('has five beats and counts landings round it', () {
      expect(Rules.beats, 5);
      expect(Rules.lands(0, 3), 3);
      expect(Rules.lands(3, 3), 1);
      expect(Rules.lands(2, 5), 2);
      expect(Rules.lands(4, 0), 4);
    });

    test('calls a laying juggled when the landings are all different', () {
      expect(Rules.juggles([3, 3, 3, 3, 3]), isTrue);
      expect(Rules.landings([3, 3, 3, 3, 3]), [3, 4, 0, 1, 2]);
      expect(Rules.juggles([1, 1, 3, 3, 7]), isFalse);
      expect(Rules.clashes([2, 1, 0, 0, 0]), [2]);
    });

    test('turns a laying round the ring and keeps it juggling', () {
      for (final win in Rules.ways([1, 2, 3, 4, 5])) {
        expect(Rules.juggles(Rules.turn(win)), isTrue, reason: '$win');
      }
    });
  });

  group('the two voices', () {
    test('agree on every laying of every rack of five', () {
      var layings = 0, juggled = 0;
      for (final rack in Rules.racks(5, 9)) {
        for (final laying in Rules.orderings(rack)) {
          layings++;
          expect(Rules.steady(laying), Rules.juggles(laying),
              reason: '$laying');
          if (Rules.juggles(laying)) juggled++;
        }
      }
      expect(layings, 100000);
      expect(juggled, 3840);
    });

    test('put the balls in the air at the plain average, every time', () {
      for (final rack in Rules.racks(5, 7)) {
        for (final laying in Rules.orderings(rack)) {
          if (!Rules.juggles(laying)) continue;
          final up = Rules.aloft(laying);
          expect(up.toSet().length, 1, reason: '$laying');
          expect(up.first * Rules.beats, Rules.total(laying),
              reason: '$laying');
        }
      }
    });

    test('make the count wobble on a laying that drops', () {
      expect(Rules.aloft([1, 1, 3, 3, 7]).toSet().length, greaterThan(1));
    });
  });

  group('the closed form', () {
    test('counts the patterns without laying one out', () {
      expect(Rules.byFormula(5, 0), 1);
      expect(Rules.byFormula(5, 1), 31);
      expect(Rules.byFormula(5, 2), 211);
      expect(Rules.byFormula(5, 3), 781);
    });

    test('agrees with a sweep that puts no cap on the throws', () {
      for (var balls = 0; balls <= 2; balls++) {
        final top = balls * Rules.beats;
        var counted = 0;
        void walk(List<int> so) {
          if (so.length == Rules.beats) {
            if (Rules.total(so) == balls * Rules.beats && Rules.juggles(so)) {
              counted++;
            }
            return;
          }
          for (var h = 0; h <= top; h++) {
            walk([...so, h]);
          }
        }

        walk(const []);
        expect(counted, Rules.byFormula(Rules.beats, balls));
      }
    });
  });

  group('the rack decides it first', () {
    test('juggles some way exactly when the total goes round evenly', () {
      var racks = 0, both = 0, neither = 0;
      for (final rack in Rules.racks(5, 9)) {
        racks++;
        final evens = Rules.total(rack) % Rules.beats == 0;
        final any = Rules.ways(rack).isNotEmpty;
        expect(evens, any, reason: '$rack');
        if (evens) both++;
        if (!evens) neither++;
      }
      expect(racks, 2002);
      expect(both, 402);
      expect(neither, 1600);
    });

    test('kills all seventy four racks adding to sixteen', () {
      var n = 0;
      for (final rack in Rules.racks(5, 9)) {
        if (Rules.total(rack) != 16) continue;
        n++;
        expect(Rules.ways(rack), isEmpty, reason: '$rack');
      }
      expect(n, 74);
    });

    test('counts the ways in fives, but for the racks of one height', () {
      final seen = <int>{};
      for (final rack in Rules.racks(5, 9)) {
        final n = Rules.ways(rack).length;
        seen.add(n);
        if (rack.toSet().length > 1) expect(n % Rules.beats, 0);
      }
      expect(seen, {0, 1, 5, 10, 15, 20});
    });
  });

  group('every ask', () {
    test('juggles as many layings as it claims', () {
      for (final level in Levels.all) {
        expect(Rules.ways(level.rack).length, level.ways, reason: level.name);
      }
      expect(Levels.all.map((l) => l.ways).toList(), [20, 15, 10, 5, 0]);
    });

    test('opens on an empty ring, which lands nothing', () {
      for (final level in Levels.all) {
        expect(level.meets(const [-1, -1, -1, -1, -1]), isFalse,
            reason: level.name);
      }
    });

    test('wants ten taps, two a throw', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        expect(level.fewest, Rules.beats * 2, reason: level.name);
        expect(level.total, 15, reason: level.name);
        expect(level.balls, 3, reason: level.name);
      }
    });

    test('is juggled by the pointer in the taps it promises', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        while (!play.isDone && play.taps < 24) {
          final aim = play.next!;
          play = aim.$1 == null ? play.tap(aim.$2) : play.take(aim.$1!);
        }
        expect(play.isDone, isTrue, reason: level.name);
        expect(play.taps, level.fewest, reason: level.name);
      }
    });
  });

  group('a go', () {
    test('takes a throw, lays it, and counts two taps', () {
      final play = Play.of(Levels.at(1)).take(3).tap(0);
      expect(play.laid[0], 3);
      expect(play.taps, 2);
      expect(play.held, isNull);
      expect(play.rack, [1, 2, 4, 5]);
    });

    test('puts a throw back on the rack when it is taken again', () {
      final play = Play.of(Levels.at(1)).take(3).take(3);
      expect(play.held, isNull);
      expect(play.rack, [1, 2, 3, 4, 5]);
    });

    test('refuses a throw that would come down on a taken beat', () {
      final one = Play.of(Levels.at(1)).take(3).tap(0);
      expect(one.canLay(1, 2), isFalse);
      final two = one.take(2).tap(1);
      expect(identical(two.laid, one.laid), isTrue);
    });

    test('lifts a throw off a beat again', () {
      final play = Play.of(Levels.at(1)).take(3).tap(0);
      expect(play.tap(0).laid[0], -1);
      expect(play.tap(0).rack, contains(3));
    });

    test('takes a laying back', () {
      final play = Play.of(Levels.at(1)).take(3).tap(0);
      expect(play.back.laid.every((t) => t < 0), isTrue);
    });

    test('points at a throw and then at a beat', () {
      final play = Play.of(Levels.at(1));
      final aim = play.next!;
      expect(aim.$1, isNotNull);
      expect(play.pointed(aim), contains('off the rack'));
      final held = play.take(aim.$1!);
      expect(held.pointed(held.next!), contains('Lay it on beat'));
    });
  });

  group('the hopeless ask', () {
    final dead = Levels.all.last;

    test('adds to sixteen, which will not go round five', () {
      expect(dead.total, 16);
      expect(dead.evens, isFalse);
      expect(Rules.ways(dead.rack), isEmpty);
    });

    test('keeps no pointer at all', () {
      expect(Play.of(dead).next, isNull);
    });

    test('takes four throws and refuses the fifth from every beat', () {
      var play = Play.of(dead);
      for (final step in const [(3, 0), (3, 1), (3, 2), (4, 3)]) {
        play = play.take(step.$1).tap(step.$2);
      }
      expect(play.laid.where((t) => t >= 0).length, 4);
      expect(play.rack, [3]);
      for (var b = 0; b < Rules.beats; b++) {
        if (play.laid[b] >= 0) continue;
        expect(play.canLay(b, 3), isFalse);
      }
    });

    test('admits it after enough picking up and putting down', () {
      var play = Play.of(dead);
      expect(play.gaveUp, isFalse);
      while (!play.gaveUp && play.taps < 40) {
        play = play.take(3);
      }
      expect(play.gaveUp, isTrue);
      expect(play.taps, Play.gaveUpAt);
    });
  });

  group('the why', () {
    test('names the average, the sweep and the ask it was asked from', () {
      final words = whyWords(Play.of(Levels.at(3)));
      expect(words, contains('the plain average of the throws'));
      expect(words, contains('100,000'));
      expect(words, contains('The Seven'));
    });
  });
}
