import 'package:flutter_test/flutter_test.dart';
import 'package:suppermere/hall/levels.dart';
import 'package:suppermere/hall/play.dart';
import 'package:suppermere/hall/rules.dart';

/// The law of the hall, held to.
void main() {
  group('the rules', () {
    test('clashes are quarrels at one table', () {
      final r = Rules(4, const [(0, 1), (1, 2), (2, 3), (0, 3)]);
      expect(r.clashes([0, 0, -1, -1]), [(0, 1)]);
      expect(r.clashes([0, 1, 0, 1]), isEmpty);
      expect(r.lands([0, 1, 0, 1]), isTrue);
      expect(r.lands([0, 1, 0, -1]), isFalse);
      expect(r.sweep(), (2, 16));
    });

    test('the walk seats, or finds an odd ring', () {
      final four = Levels.at(0).rules;
      expect(four.byWalking(), [0, 1, 0, 1]);
      expect(four.oddRing(), isNull);
      final five = Levels.at(4).rules;
      expect(five.byWalking(), isNull);
      final ring = five.oddRing()!;
      expect(ring.length.isOdd, isTrue);
      expect(ring.toSet(), hasLength(ring.length));
      expect(Levels.at(2).rules.parties, 2);
    });

    test('every quarrel map of four guests: sweep, walk and ring agree', () {
      final pairs = <Quarrel>[for (var a = 0; a < 4; a++) for (var b = a + 1; b < 4; b++) (a, b)];
      for (var mask = 0; mask < (1 << pairs.length); mask++) {
        final quarrels = [for (var i = 0; i < pairs.length; i++) if ((mask >> i) & 1 == 1) pairs[i]];
        final r = Rules(4, quarrels);
        final (landing, _) = r.sweep();
        final walk = r.byWalking();
        expect(walk == null, landing == 0, reason: '$quarrels');
        expect(r.oddRing() == null, walk != null, reason: '$quarrels');
        if (walk != null) expect(landing, 1 << r.parties, reason: '$quarrels');
      }
    });

    test('every label\'s ways is what the sweep finds', () {
      for (final level in Levels.all) {
        expect(level.rules.sweep(), (level.ways, level.seatings), reason: level.name);
      }
    });
  });

  group('the play', () {
    test('opens with every guest standing', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.tables, everyElement(-1), reason: level.name);
        expect(play.isDone, isFalse);
      }
    });

    test('a tap seats left, then right, then stands; back undoes', () {
      var play = Play.of(Levels.at(0));
      play = play.tap(0);
      expect(play.tables[0], Rules.left);
      play = play.tap(0);
      expect(play.tables[0], Rules.right);
      play = play.tap(0);
      expect(play.tables[0], -1);
      expect(play.moves, 3);
      expect(play.back.tables[0], Rules.right);
      expect(play.tap(9), same(play));
    });

    test('the suppers by hand', () {
      final four = Play.of(Levels.at(0)).tap(0).tap(1).tap(1).tap(2).tap(3).tap(3);
      expect(four.tables, [0, 1, 0, 1]);
      expect(four.isDone, isTrue);
      expect(four.tap(0), same(four));
      final clash = Play.of(Levels.at(0)).tap(0).tap(1);
      expect(clash.clashes, [(0, 1)]);
      final family = Play.of(Levels.at(1)).tap(0).tap(1).tap(1).tap(2).tap(2).tap(3).tap(4).tap(5);
      expect(family.isDone, isTrue);
    });

    test('the pointer seats every winnable supper', () {
      for (final number in [0, 1, 2, 3]) {
        var play = Play.of(Levels.at(number));
        var guard = 0;
        while (!play.isDone && guard++ < 30) {
          final (_, g) = play.next!;
          play = play.tap(g);
        }
        expect(play.isDone, isTrue, reason: '$number');
      }
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('the pointer says which table', () {
      final play = Play.of(Levels.at(0));
      expect(play.next, ('left', 0));
      expect(play.tap(0).next, ('right', 1));
      expect(play.tap(0).tap(0).next, ('left', 0));
    });

    test('the hopeless supper admits it at thirteen taps', () {
      var play = Play.of(Levels.at(4)).tap(0).tap(1).tap(1).tap(2).tap(3).tap(3).tap(4);
      expect(play.seated, isTrue);
      expect(play.clashes, [(0, 4)]);
      for (var k = 0; k < 6; k++) {
        play = play.tap(4);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.tap(0), same(play));
    });

    test('a winnable supper never gives up', () {
      var play = Play.of(Levels.at(0));
      for (var k = 0; k < 14; k++) {
        play = play.tap(0);
      }
      expect(play.moves, 14);
      expect(play.gaveUp, isFalse);
    });

    test('the mark stands seated', () {
      final mark = Play.standing(Levels.at(3), Play.aimFor(Levels.at(3))!);
      expect(mark.isDone, isTrue);
    });
  });
}
