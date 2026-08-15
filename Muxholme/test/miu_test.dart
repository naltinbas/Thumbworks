import 'package:flutter_test/flutter_test.dart';
import 'package:muxholme/miu/levels.dart';
import 'package:muxholme/miu/play.dart';
import 'package:muxholme/miu/rules.dart';

/// The law of the letters, held to.
void main() {
  group('the rules', () {
    test('the four rules apply where they may', () {
      expect(Rules.moves('MI'), [(1, 0), (2, 0)]);
      expect(Rules.apply('MI', (1, 0)), 'MIU');
      expect(Rules.apply('MI', (2, 0)), 'MII');
      expect(Rules.apply('MIU', (1, 0)), isNull);
      expect(Rules.moves('MIIII'), [(1, 0), (2, 0), (3, 1), (3, 2)]);
      expect(Rules.apply('MIIII', (3, 1)), 'MUI');
      expect(Rules.apply('MIIII', (3, 2)), 'MIU');
      expect(Rules.moves('MUUI'), [(1, 0), (2, 0), (4, 1)]);
      expect(Rules.apply('MUUI', (4, 1)), 'MI');
      expect(Rules.iCount('MUIIU'), 2);
      expect(Rules.keepsFaith('MU'), isFalse);
      expect(Rules.keepsFaith('MI'), isTrue);
    });

    test('the sheet keeps the strings short', () {
      final long = 'M${'I' * 13}';
      expect(Rules.moves(long).contains((2, 0)), isFalse);
      expect(Rules.moves(long).contains((1, 0)), isTrue);
    });

    test('the walk from MI', () {
      expect(Rules.fewest('MIU'), 1);
      expect(Rules.fewest('MIIU'), 2);
      expect(Rules.fewest('MUI'), 3);
      expect(Rules.fewest('MUIIU'), 5);
      expect(Rules.fewest('MU'), isNull);
      expect(Rules.derivation('MUI'), [(2, 0), (2, 0), (3, 1)]);
      final walked = Rules.walk();
      expect(walked.length, 106389);
      expect(walked.keys.every(Rules.keepsFaith), isTrue);
      expect(Rules.shaped('MUUI'), isTrue);
      expect(Rules.shaped('MU'), isFalse);
      expect(Rules.shaped('MIM'), isFalse);
      expect(walked.containsKey('MUUI'), isTrue);
    });

    test('the sweeps of the derivations', () {
      expect(Rules.sweep('MIU', 1), (1, 2));
      expect(Rules.sweep('MIIU', 2), (1, 3));
      expect(Rules.sweep('MUI', 3), (1, 6));
      expect(Rules.sweep('MUIIU', 5), (2, 57));
      expect(Rules.sweep('MU', 6), (0, 299));
    });

    test('every label\'s ways is what the sweep finds', () {
      for (final level in Levels.all) {
        expect(Rules.sweep(level.target, level.steps), (level.ways, level.derivations), reason: level.name);
      }
    });
  });

  group('the play', () {
    test('opens at MI', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.string, 'MI', reason: level.name);
        expect(play.steps, 0);
        expect(play.isDone, isFalse);
      }
    });

    test('moves are made and counted; back undoes', () {
      var play = Play.of(Levels.at(2));
      play = play.make((2, 0));
      expect(play.string, 'MII');
      expect(play.steps, 1);
      play = play.make((2, 0));
      expect(play.string, 'MIIII');
      expect(play.tap(0), same(play));
      expect(play.tap(4), same(play));
      final done = play.tap(1);
      expect(done.string, 'MUI');
      expect(done.isDone, isTrue);
      expect(done.steps, 3);
      expect(done.back.string, 'MIIII');
      expect(done.make((1, 0)), same(done));
    });

    test('the strings by hand', () {
      expect(Play.of(Levels.at(0)).make((1, 0)).isDone, isTrue);
      expect(Play.of(Levels.at(1)).make((2, 0)).make((1, 0)).isDone, isTrue);
      final muiiu = Play.of(Levels.at(3)).make((2, 0)).make((2, 0)).make((2, 0)).tap(1).tap(4);
      expect(muiiu.string, 'MUIIU');
      expect(muiiu.isDone, isTrue);
      final other = Play.of(Levels.at(3)).make((2, 0)).make((2, 0)).make((2, 0)).tap(6).tap(1);
      expect(other.string, 'MUIIU');
    });

    test('the steps spent is a miss', () {
      final play = Play.of(Levels.at(0)).make((2, 0));
      expect(play.spent, isTrue);
      expect(play.missed, isTrue);
      expect(play.isOver, isTrue);
      expect(play.make((1, 0)), same(play));
    });

    test('the pointer derives every winnable string', () {
      for (final number in [0, 1, 2, 3]) {
        var play = Play.of(Levels.at(number));
        var guard = 0;
        while (!play.isDone && guard++ < 12) {
          play = play.make(play.next!);
        }
        expect(play.isDone, isTrue, reason: '$number');
        expect(play.steps, Levels.at(number).steps, reason: '$number');
      }
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('the pointer finds a way, and knows a dead end', () {
      final play = Play.of(Levels.at(3)).make((2, 0));
      expect(play.string, 'MII');
      expect(play.next, isNotNull);
      expect(Play.pathFrom('MII', 'MUIIU'), hasLength(4));
      // From MIU the I are parted by U for good: MUIIU is out of reach.
      expect(Play.pathFrom('MIU', 'MUIIU'), isNull);
      expect(Play.of(Levels.at(3)).make((1, 0)).next, isNull);
      expect(Play.pathFrom('MI', 'MU'), isNull);
    });

    test('the hopeless string admits it at twelve steps', () {
      var play = Play.of(Levels.at(4));
      while (!play.isOver) {
        final ms = play.moves;
        play = play.make(ms.contains((2, 0)) ? (2, 0) : ms.contains((1, 0)) ? (1, 0) : ms.first);
      }
      expect(play.steps, Play.gaveUpAt);
      expect(play.gaveUp, isTrue);
      // A dead end admits it too: MI, MIU, then doubling till the sheet
      // is full leaves no rule to apply.
      var stuck = Play.of(Levels.at(4));
      while (!stuck.isOver) {
        stuck = stuck.make(stuck.moves.first);
      }
      expect(stuck.stuck, isTrue);
      expect(stuck.gaveUp, isTrue);
      expect(stuck.steps, 4);
      expect(play.isOver, isTrue);
      expect(Rules.keepsFaith(play.string), isTrue);
      expect(play.make((1, 0)), same(play));
    });

    test('the mark stands derived', () {
      final mark = Play.standing(Levels.at(3), 'MUIIU', 5);
      expect(mark.isDone, isTrue);
    });
  });
}
