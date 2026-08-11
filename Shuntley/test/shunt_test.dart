import 'package:flutter_test/flutter_test.dart';
import 'package:shuntley/shunt/play.dart';
import 'package:shuntley/shunt/rules.dart';
import 'package:shuntley/shunt/trays.dart';

void main() {
  group('the shunt', () {
    test('slides a tile beside the gap into it, and nothing else', () {
      final rules = Rules(3, 3);
      // Home: gap in the last cell, cells 5 and 7 beside it.
      expect(rules.shunted(rules.home, 7), [1, 2, 3, 4, 5, 6, 7, 0, 8]);
      expect(rules.shunted(rules.home, 5), [1, 2, 3, 4, 5, 0, 7, 8, 6]);
      expect(rules.shunted(rules.home, 4), rules.home);
      expect(rules.shunted(rules.home, 0), rules.home);
    });

    test('undoes itself', () {
      final rules = Rules(3, 3);
      final once = rules.shunted(rules.home, 7);
      expect(rules.shunted(once, 8), rules.home);
    });

    test('the gap knows its neighbours, corners and edges alike', () {
      final rules = Rules(3, 3);
      expect(rules.besides(0), [3, 1]);
      expect(rules.besides(4), [1, 7, 3, 5]);
      expect(rules.besides(8), [5, 7]);
    });
  });

  group('the parity', () {
    test('counts the reversed pairs with the gap left out', () {
      final rules = Rules(3, 3);
      expect(rules.even(rules.home), isTrue);
      expect(rules.even(const [1, 2, 3, 4, 5, 6, 8, 7, 0]), isFalse);
      expect(rules.reversedPairs(const [1, 2, 3, 4, 5, 6, 8, 7, 0]),
          [(8, 7)]);
      // The gap's place is no part of the count.
      expect(rules.even(const [1, 2, 3, 4, 5, 0, 7, 8, 6]), isTrue);
    });

    test('no shunt from anywhere reachable ever moves it', () {
      // The invariant argument, made flesh: a sideways shunt leaves the
      // gapless reading untouched, an up-or-down one slides a tile past
      // two others. Swept over every shunt of a walk from home.
      final rules = Rules(3, 3);
      var board = rules.home;
      for (var step = 0; step < 200; step++) {
        final besides = rules.besides(board.indexOf(0));
        final cell = besides[step % besides.length];
        final shunted = rules.shunted(board, cell);
        expect(shunted, isNot(equals(board)),
            reason: 'the walk stalled at $cell');
        expect(rules.even(shunted), rules.even(board));
        board = shunted;
      }
    });
  });

  group('the two ways of knowing', () {
    test('agree on every arrangement of the little tray', () {
      // The anchor. The walk from home knows nothing of parity, the
      // pair count nothing of walking: 720 arrangements, no parting.
      final rules = Rules(2, 3);
      var all = 0;
      for (final board in rules.allBoards()) {
        all++;
        expect(rules.solvable(board), rules.even(board),
            reason: '$board');
      }
      expect(all, 720);
      expect(rules.reached, 360);
    });

    test('and on every arrangement of the eight, all 362,880', () {
      final rules = Rules(3, 3);
      for (final board in rules.allBoards()) {
        if (rules.solvable(board) != rules.even(board)) {
          fail('the walk and the parity part at $board');
        }
      }
      expect(rules.reached, 181440);
    });

    test('the walks bottom out at twenty one and thirty one', () {
      expect(Rules(2, 3).deepest, 21);
      final rules = Rules(3, 3);
      expect(rules.deepest, 31);
      var farthest = 0;
      for (final board in rules.allBoards()) {
        if (rules.fewest(board) == 31) farthest++;
      }
      expect(farthest, 2);
    });
  });

  group('every tray that ships', () {
    for (var number = 0; number < Trays.count; number++) {
      final tray = Trays.at(number);

      test('${tray.name} is what it says it is', () {
        final rules = Rules(tray.rows, tray.cols);
        expect(rules.fewest(tray.tiles), tray.fewest);
        expect(rules.even(tray.tiles), tray.winnable);
      });
    }

    test('the swindle is one reversed pair, and the last two tiles', () {
      final rules = Rules(3, 3);
      expect(rules.reversedPairs(Trays.at(5).tiles), [(8, 7)]);
    });
  });

  group('a tray in play', () {
    test('starts as dealt, with the fewest still to be had', () {
      final play = Play.of(Trays.at(0));
      expect(play.board, [2, 3, 5, 1, 4, 0]);
      expect(play.shunts, 0);
      expect(play.isHome, isFalse);
      expect(play.fewestFromHere, 6);
    });

    test('a shunt slides and counts; a far tile is refused', () {
      final play = Play.of(Trays.at(0));
      expect(play.mayShunt(2), isTrue);
      expect(play.mayShunt(0), isFalse);
      final shunted = play.shunt(2);
      expect(shunted.board, [2, 3, 0, 1, 4, 5]);
      expect(shunted.shunts, 1);
      expect(identical(play.shunt(0), play), isTrue);
    });

    test('a wandering shunt shows in the live number at once', () {
      final play = Play.of(Trays.at(1));
      expect(play.fewestFromHere, 10);
      // Undoing nothing: the first shunt of the answer, then a shunt
      // straight back out of the way.
      final wandered = play.shunt(play.next!);
      expect(wandered.fewestFromHere, 9);
      final worse = wandered.shunt(wandered.gap == 8 ? 7 : 8);
      expect(worse.fewestFromHere, greaterThan(9));
    });

    test('take back returns the tray as it lay', () {
      final start = Play.of(Trays.at(0));
      final shunted = start.shunt(start.next!);
      expect(shunted.back.board, start.board);
      expect(identical(start.back, start), isTrue);
    });

    test('following next brings every winnable tray home at its fewest',
        () {
      for (var number = 0; number < Trays.count; number++) {
        final tray = Trays.at(number);
        if (!tray.winnable) continue;
        var play = Play.of(tray);
        var guard = 0;
        while (!play.isHome) {
          if (guard++ > 40) fail('${tray.name} never came home');
          expect(play.fewestFromHere, tray.fewest! - play.shunts,
              reason: tray.name);
          play = play.shunt(play.next!);
        }
        expect(play.shunts, tray.fewest, reason: tray.name);
      }
    });

    test('the dead tray offers nothing to shunt for', () {
      final play = Play.of(Trays.at(5));
      expect(play.fewestFromHere, isNull);
      expect(play.next, isNull);
      expect(play.even, isFalse);
    });
  });
}
