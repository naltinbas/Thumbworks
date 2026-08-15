import 'package:flutter_test/flutter_test.dart';
import 'package:weighwick/scale/levels.dart';
import 'package:weighwick/scale/play.dart';
import 'package:weighwick/scale/rules.dart';

/// The law of the scale, held to.
void main() {
  group('the rules', () {
    test('a placing weighs across less beside', () {
      expect(Rules.net([Side.against, Side.off, Side.off, Side.off]), 1);
      expect(Rules.net([Side.withLoad, Side.against, Side.off, Side.off]), 2);
      expect(Rules.net([Side.withLoad, Side.against, Side.withLoad, Side.against]), 20);
      expect(Rules.net([Side.against, Side.against, Side.against, Side.against]), 40);
      expect(Rules.balances(2, [Side.withLoad, Side.against, Side.off, Side.off]), isTrue);
    });

    test('there are 81 placings weighing 81 amounts, -40 to 40', () {
      expect(Rules.placings, hasLength(81));
      final nets = {for (final p in Rules.placings) Rules.net(p)};
      expect(nets, hasLength(81));
      expect(nets.reduce((a, b) => a < b ? a : b), -40);
      expect(nets.reduce((a, b) => a > b ? a : b), 40);
    });

    test('every load to forty balances once, as counting in threes says', () {
      for (var load = 1; load <= 40; load++) {
        final ways = Rules.balancing(load);
        expect(ways, hasLength(1), reason: '$load');
        expect(Rules.balancedTernary(load), ways.first, reason: '$load');
      }
      expect(Rules.balancing(41), isEmpty);
      expect(Rules.balancedTernary(41), isNull);
      expect(Rules.balancedTernary(2), [Side.withLoad, Side.against, Side.off, Side.off]);
      expect(Rules.balancedTernary(20), [Side.withLoad, Side.against, Side.withLoad, Side.against]);
      expect(Rules.balancedTernary(31), [Side.against, Side.against, Side.off, Side.against]);
    });

    test('without the one, only multiples of three', () {
      expect(Rules.balancing(10, barred: [1]), isEmpty);
      expect(Rules.balancing(9, barred: [1]), hasLength(1));
      final nets = {for (final p in Rules.placings) if (p[0] == Side.off) Rules.net(p)};
      expect(nets, hasLength(27));
      expect(nets.every((n) => n % 3 == 0), isTrue);
    });

    test('every label\'s ways is what the sweep finds', () {
      for (final level in Levels.all) {
        expect(Rules.balancing(level.load, barred: level.barred), hasLength(level.ways), reason: level.name);
      }
    });
  });

  group('the play', () {
    test('opens with every weight off', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.placing, everyElement(Side.off), reason: level.name);
        expect(play.tilt, level.load);
        expect(play.isDone, isFalse);
      }
    });

    test('a tap cycles a weight off, across, beside, off, and back undoes', () {
      var play = Play.of(Levels.at(0));
      play = play.tap(0);
      expect(play.placing[0], Side.against);
      expect(play.moves, 1);
      play = play.tap(0);
      expect(play.placing[0], Side.withLoad);
      play = play.tap(0);
      expect(play.placing[0], Side.off);
      expect(play.moves, 3);
      expect(play.back.placing[0], Side.withLoad);
      expect(play.tap(4), same(play));
    });

    test('a barred weight takes no tap', () {
      final play = Play.of(Levels.at(4));
      expect(play.barred(0), isTrue);
      expect(play.tap(0), same(play));
      expect(play.tap(1).placing[1], Side.against);
    });

    test('the loads by hand', () {
      final two = Play.of(Levels.at(0)).tap(1).tap(0).tap(0);
      expect(two.placing, [Side.withLoad, Side.against, Side.off, Side.off]);
      expect(two.isDone, isTrue);
      expect(two.tap(2), same(two));
      final forty = Play.of(Levels.at(3)).tap(0).tap(1).tap(2).tap(3);
      expect(forty.isDone, isTrue);
      final tipped = Play.of(Levels.at(1)).tap(3);
      expect(tipped.tilt, -7);
      expect(tipped.across, 27);
    });

    test('the pointer lands every winnable load', () {
      for (final number in [0, 1, 2, 3]) {
        var play = Play.of(Levels.at(number));
        var guard = 0;
        while (!play.isDone && guard++ < 12) {
          final (_, i) = play.next!;
          play = play.tap(i);
        }
        expect(play.isDone, isTrue, reason: '$number');
      }
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('the hopeless load admits it at twelve moves', () {
      var play = Play.of(Levels.at(4)).tap(2).tap(1);
      expect(play.tilt, -2);
      for (var dither = 0; dither < 5; dither++) {
        play = play.tap(1).tap(1);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.tap(1), same(play));
    });

    test('a winnable load never gives up', () {
      var play = Play.of(Levels.at(0));
      for (var dither = 0; dither < 14; dither++) {
        play = play.tap(2);
      }
      expect(play.moves, 14);
      expect(play.gaveUp, isFalse);
    });

    test('the mark stands level', () {
      final mark = Play.standing(Levels.at(1), const [Side.withLoad, Side.against, Side.withLoad, Side.against]);
      expect(mark.isDone, isTrue);
      expect(mark.moves, 4);
    });
  });
}
