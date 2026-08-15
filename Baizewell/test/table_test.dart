import 'package:flutter_test/flutter_test.dart';
import 'package:baizewell/table/levels.dart';
import 'package:baizewell/table/play.dart';
import 'package:baizewell/table/rules.dart';

/// The roll, the rule and the play, checked at the domain: nothing here
/// touches a widget.
void main() {
  group('the roll', () {
    test('the two by three: three bounces in six steps to the right pocket', () {
      final (corners, bounces, steps) = Rules.roll(2, 3);
      expect(corners, [(0, 0), (2, 2), (1, 3), (0, 2), (2, 0)]);
      expect(bounces, 3);
      expect(steps, 6);
      expect(Rules.pocketName(2, 3, corners.last), 'the right pocket');
    });

    test('a square runs straight to the far pocket', () {
      final (corners, bounces, steps) = Rules.roll(4, 4);
      expect(corners, [(0, 0), (4, 4)]);
      expect(bounces, 0);
      expect(steps, 4);
    });

    test('the two by four: one bounce to the top pocket', () {
      final (corners, bounces, steps) = Rules.roll(2, 4);
      expect(corners, [(0, 0), (2, 2), (0, 4)]);
      expect((bounces, steps), (1, 4));
      expect(Rules.pocketName(2, 4, corners.last), 'the top pocket');
    });
  });

  group('the rule', () {
    test('pocket, bounces and steps by parity and the lcm', () {
      expect(Rules.pocketByParity(2, 3), (2, 0));
      expect(Rules.pocketByParity(3, 5), (3, 5));
      expect(Rules.pocketByParity(6, 4), (0, 4));
      expect(Rules.bouncesByFormula(5, 7), 10);
      expect(Rules.stepsByFormula(5, 7), 35);
      expect(Rules.bouncesByFormula(12, 11), 21);
      expect(Rules.stepsByFormula(4, 6), 12);
    });

    test('agrees with the roll on every table of the sham and beyond', () {
      for (var p = 2; p <= 20; p++) {
        for (var q = 2; q <= 20; q++) {
          final (corners, bounces, steps) = Rules.roll(p, q);
          expect(corners.last, Rules.pocketByParity(p, q), reason: '$p by $q');
          expect(bounces, Rules.bouncesByFormula(p, q), reason: '$p by $q');
          expect(steps, Rules.stepsByFormula(p, q), reason: '$p by $q');
          expect(corners.last, isNot((0, 0)), reason: '$p by $q');
        }
      }
    });

    test('the sweep\'s counts', () {
      expect(Rules.sweep((p, q) => true), (121, 121));
      expect(Rules.sweep(Levels.at(0).meets), (39, 121));
      expect(Rules.sweep(Levels.at(1).meets), (41, 121));
      expect(Rules.sweep(Levels.at(2).meets), (10, 121));
      expect(Rules.sweep(Levels.at(3).meets), (2, 121));
      expect(Rules.sweep(Levels.at(4).meets), (0, 121));
      expect(Rules.sweep((p, q) => Rules.pocketByParity(p, q) == (0, q)), (41, 121));
    });

    test('the first tables', () {
      expect(Rules.first(Levels.at(0).meets), (2, 2));
      expect(Rules.first(Levels.at(1).meets), (2, 3));
      expect(Rules.first(Levels.at(2).meets), (2, 4));
      expect(Rules.first(Levels.at(3).meets), (11, 12));
      expect(Rules.first(Levels.at(4).meets), isNull);
    });
  });

  group('the levels', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The Home Pocket']);
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'set the table so the ball drops in the far pocket');
      expect(Levels.at(2).task, 'set the table so the ball bounces once on the way');
      expect(Levels.at(3).task, 'set the table where the ball bounces the most it does on the sham');
      expect(Levels.at(4).task, 'set the table so the ball comes back to the pocket it left');
    });

    test('an ask is met by the table it names', () {
      expect(Levels.at(0).meets(3, 5), isTrue);
      expect(Levels.at(0).meets(2, 3), isFalse);
      expect(Levels.at(1).meets(2, 3), isTrue);
      expect(Levels.at(2).meets(6, 12), isTrue);
      expect(Levels.at(3).meets(12, 11), isTrue);
      expect(Levels.at(3).meets(10, 11), isFalse);
      expect(Levels.at(4).meets(4, 4), isFalse);
    });
  });

  group('the play', () {
    test('opens on three by two', () {
      final play = Play.of(Levels.at(0));
      expect((play.along, play.up), (3, 2));
      expect(play.pocketName, 'the top pocket');
      expect(play.bounces, 3);
      expect(play.isDone, isFalse);
    });

    test('the sides turn within two and twelve', () {
      var play = Play.of(Levels.at(0));
      play = play.moreUp(1);
      expect((play.along, play.up), (3, 3));
      expect(play.isDone, isTrue);
      play = Play.of(Levels.at(1)).moreAlong(-1).moreAlong(-1);
      expect(play.along, 2);
      expect(play.moves, 1);
      play = play.moreUp(1);
      expect((play.along, play.up), (2, 3));
      expect(play.isDone, isTrue);
    });

    test('back undoes one setting', () {
      final play = Play.of(Levels.at(0)).moreUp(1);
      expect(play.back.up, 2);
    });

    test('the home pocket gives up after twenty-four settings', () {
      var play = Play.of(Levels.at(4));
      for (var k = 0; k < 24; k++) {
        expect(play.isOver, isFalse);
        play = k.isEven ? play.moreUp(1) : play.moreUp(-1);
      }
      expect(play.gaveUp, isTrue);
      expect(play.next, isNull);
    });

    test('the pointer names the side toward the first table', () {
      var play = Play.of(Levels.at(3));
      expect(play.next, 'along+');
      for (var i = 0; i < 8; i++) {
        play = play.moreAlong(1);
      }
      expect(play.along, 11);
      expect(play.next, 'up+');
    });

    test('following the pointer lands every winnable ask', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var presses = 0;
        while (!play.isDone && presses < 40) {
          play = switch (play.next!) {
            'along+' => play.moreAlong(1),
            'along-' => play.moreAlong(-1),
            'up+' => play.moreUp(1),
            _ => play.moreUp(-1),
          };
          presses++;
        }
        expect(play.isDone, isTrue, reason: level.name);
      }
    });
  });
}
