import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:wickfell/lamps/grid.dart';
import 'package:wickfell/lamps/levels.dart';
import 'package:wickfell/lamps/play.dart';
import 'package:wickfell/lamps/solve.dart';

void main() {
  group('a grid', () {
    final grid = Grid(3, 3);

    test('turns a lamp and the ones it touches', () {
      // The middle lamp changes five: itself and four neighbours.
      expect(grid.litOn(grid.presses[4]), 5);
      // A corner changes three, because two of its neighbours are off the
      // board and nothing off the board is a lamp.
      expect(grid.litOn(grid.presses[0]), 3);
      expect(grid.litOn(grid.presses[1]), 4);
    });

    test('and pressing the same lamp twice changes nothing', () {
      final dice = Random(3);
      for (var i = 0; i < 200; i++) {
        final board = dice.nextInt(1 << 9);
        final at = dice.nextInt(9);
        expect(grid.pressed(grid.pressed(board, at), at), board);
      }
    });

    test('and the order of the presses makes no difference', () {
      // Which is the fact the whole game rests on: a set of presses is a
      // choice for each lamp, not a sequence.
      final dice = Random(7);
      for (var i = 0; i < 200; i++) {
        final board = dice.nextInt(1 << 9);
        final presses = [
          for (var at = 0; at < 9; at++)
            if (dice.nextBool()) at,
        ];
        final shuffled = [...presses]..shuffle(dice);
        expect(grid.afterAll(board, presses), grid.afterAll(board, shuffled));
      }
    });
  });

  group('the sums', () {
    test('agree with what is known about each size', () {
      // Facts about this game that were worked out long before this code was:
      // on a five by five two sets of presses change nothing, so only one
      // board in four can be turned off; on a four by four it is four sets
      // and one board in sixteen; and on three by three, five by four and six
      // by six every board can be turned off.
      expect(Sums(Grid(5, 5)).spare, 2);
      expect(Sums(Grid(4, 4)).spare, 4);
      expect(Sums(Grid(3, 3)).spare, 0);
      expect(Sums(Grid(5, 4)).spare, 0);
      expect(Sums(Grid(6, 6)).spare, 0);
    });

    test('and a set of presses that changes nothing really changes nothing',
        () {
      for (final size in const [(4, 4), (5, 5)]) {
        final grid = Grid(size.$1, size.$2);
        final sums = Sums(grid);
        expect(sums.nothings, isNotEmpty);

        for (final nothing in sums.nothings) {
          final which = [
            for (var at = 0; at < grid.lamps; at++)
              if (nothing >> at & 1 == 1) at,
          ];
          expect(which, isNotEmpty);
          expect(grid.afterAll(grid.all, which), grid.all,
              reason: 'that set of presses changed the board');
          expect(grid.afterAll(0, which), 0);
        }
      }
    });

    test('turn off every board they say they can, and no others', () {
      // Checked by doing it: the presses the sums give are made, one at a
      // time, and the board has to come out dark.
      final grid = Grid(5, 5);
      final sums = Sums(grid);
      final dice = Random(11);
      var could = 0;

      for (var i = 0; i < 2000; i++) {
        final board = dice.nextInt(1 << 25);
        final answer = sums.answer(board);
        if (!answer.canBeDone) continue;
        could++;
        expect(grid.afterAll(board, answer.presses), 0,
            reason: 'the presses did not put the lamps out');
        expect(answer.presses, hasLength(answer.fewest));
      }
      expect(could, greaterThan(300), reason: 'about a quarter of them');
    });

    test('and nothing shorter turns them off, checked the slow way', () {
      // The claim behind every number in the game. On a board small enough to
      // try every set of presses there is, the fewest the sums give is the
      // fewest there are.
      final grid = Grid(3, 3);
      final sums = Sums(grid);
      final dice = Random(19);

      for (var i = 0; i < 60; i++) {
        final board = dice.nextInt(1 << 9);
        final answer = sums.answer(board);
        expect(answer.canBeDone, isTrue, reason: 'every three by three can be');

        var fewest = 10;
        for (var set = 0; set < 1 << 9; set++) {
          final which = [
            for (var at = 0; at < 9; at++)
              if (set >> at & 1 == 1) at,
          ];
          if (grid.afterAll(board, which) != 0) continue;
          if (which.length < fewest) fewest = which.length;
        }
        expect(answer.fewest, fewest, reason: 'board $board');
      }
    });

    test('and say so when a board cannot be turned off at all', () {
      final grid = Grid(5, 5);
      final sums = Sums(grid);
      final dice = Random(23);
      var couldNot = 0;

      for (var i = 0; i < 400; i++) {
        final board = dice.nextInt(1 << 25);
        final answer = sums.answer(board);
        if (answer.canBeDone) continue;
        couldNot++;
        expect(answer.fewest, -1);
        expect(answer.presses, isEmpty);

        // And it really cannot: a thousand random sets of presses leave it
        // lit. Not a proof — the sums are that — but a check on the sums.
        for (var go = 0; go < 200; go++) {
          final which = [
            for (var at = 0; at < 25; at++)
              if (dice.nextBool()) at,
          ];
          expect(grid.afterAll(board, which), isNot(0));
        }
      }
      expect(couldNot, greaterThan(200), reason: 'about three in four');
    });
  });

  group('every level', () {
    test('can be turned off, in the presses it says', () {
      for (var i = 0; i < Levels.count; i++) {
        final level = Levels.at(i);
        final answer = Sums(level.grid).answer(level.lit);

        expect(answer.canBeDone, isTrue,
            reason: '${level.name} cannot be turned off at all');
        expect(answer.fewest, level.presses,
            reason: '${level.name} says ${level.presses} and takes '
                '${answer.fewest}');
      }
    });

    test('and the presses it gives really put the lamps out', () {
      for (var i = 0; i < Levels.count; i++) {
        final level = Levels.at(i);
        final answer = Sums(level.grid).answer(level.lit);
        expect(level.grid.afterAll(level.lit, answer.presses), 0,
            reason: level.name);
      }
    });

    test('starts with some of them lit and not all', () {
      for (var i = 0; i < Levels.count; i++) {
        final level = Levels.at(i);
        expect(level.lit, isNot(0), reason: '${level.name} starts finished');
        expect(level.rows.every((row) => row.length == level.across), isTrue,
            reason: '${level.name} is not square with itself');
      }
    });
  });

  group('playing one', () {
    late Sums sums;

    setUpAll(() => sums = Sums(Levels.at(0).grid));

    Play start() => Play.of(Levels.at(0), sums);

    test('starts lit, with nothing pressed', () {
      final play = start();
      expect(play.board, Levels.at(0).lit);
      expect(play.pressed, 0);
      expect(play.left, Levels.at(0).presses);
      expect(play.onShortest, isTrue);
      expect(play.isDone, isFalse);
    });

    test('presses a lamp and the ones it touches', () {
      final play = start().press(4);
      expect(play.pressed, 1);
      expect(play.board, Levels.at(0).grid.pressed(Levels.at(0).lit, 4));
    });

    test('takes a press back, and starts over', () {
      final play = start().press(0).press(4);
      expect(play.back.pressed, 1);
      expect(play.back.back.pressed, 0);
      expect(play.back.back.back.pressed, 0, reason: 'and stops at the start');
      expect(play.again.board, Levels.at(0).lit);
    });

    test('knows when a press has gone nowhere', () {
      // Every level has presses that are on a shortest way and presses that
      // are not, and the game can tell them apart at once.
      final wanted = sums.answer(Levels.at(0).lit).presses.toSet();
      final wrong = List.generate(Levels.at(0).lamps, (at) => at)
          .firstWhere((at) => !wanted.contains(at));

      expect(start().press(wanted.first).onShortest, isTrue);
      expect(start().press(wrong).onShortest, isFalse);
      expect(start().press(wrong).wasted, greaterThan(0));
    });

    test('is done when every lamp is out', () {
      var play = start();
      for (final at in sums.answer(Levels.at(0).lit).presses) {
        play = play.press(at);
      }
      expect(play.isDone, isTrue);
      expect(play.lit, 0);
      expect(play.pressed, Levels.at(0).presses);
      expect(play.press(0).pressed, Levels.at(0).presses,
          reason: 'nothing happens after that');
    });

    test('and following what it says puts every level out in its own number',
        () {
      for (var which = 0; which < Levels.count; which++) {
        final level = Levels.at(which);
        var play = Play.of(level, Sums(level.grid));
        var guard = 0;
        while (!play.isDone && guard++ < 40) {
          final next = play.nextPress;
          expect(next, isNotNull, reason: '${level.name} ran out');
          final was = play.left;
          play = play.press(next!);
          expect(play.left, was - 1,
              reason: 'a press that did not get any nearer');
        }
        expect(play.isDone, isTrue);
        expect(play.pressed, level.presses, reason: level.name);
      }
    });
  });
}
