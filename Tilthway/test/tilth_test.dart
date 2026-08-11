import 'package:flutter_test/flutter_test.dart';
import 'package:tilthway/tilth/play.dart';
import 'package:tilthway/tilth/rules.dart';
import 'package:tilthway/tilth/tilths.dart';

void main() {
  group('the sowing', () {
    test('lifts a full furrow and drops one each way home', () {
      expect(Rules.sown([1, 1, 3], 1), [0, 1, 3]);
      expect(Rules.sown([1, 1, 3], 3), [2, 2]);
      expect(Rules.sowable([1, 1, 3]), [1, 3]);
      expect(Rules.sowable([0, 1, 3]), [3]);
    });
  });

  group('the unsowing and the search', () {
    test('at every size to ten, exactly one board wins, and it is the '
        'unsown one', () {
      // The anchor. The unsowing grows boards from the barn; the search
      // plays every board of the size and sees which get home.
      for (var seeds = 1; seeds <= 10; seeds++) {
        final winners = <String>[];
        for (final board in Rules.allBoards(seeds, 6)) {
          if (Rules.canWin(board)) winners.add(board.join(','));
        }
        expect(winners, hasLength(1), reason: '$seeds seeds');
        expect(winners.single, Rules.unsown(seeds).join(','),
            reason: '$seeds seeds');
      }
    });

    test('the unsown boards play home at every size to thirty', () {
      for (var seeds = 1; seeds <= 30; seeds++) {
        expect(Rules.canWin(Rules.unsown(seeds)), isTrue,
            reason: '$seeds seeds');
      }
    });

    test('an overfull furrow is death, everywhere it appears', () {
      for (var seeds = 2; seeds <= 9; seeds++) {
        for (final board in Rules.allBoards(seeds, 5)) {
          if (Rules.overfull(board).isNotEmpty) {
            expect(Rules.canWin(board), isFalse, reason: '$board');
          }
        }
      }
    });

    test('and starvation kills without overfullness too', () {
      // Nought, nought, two: nothing sowable, nothing overfull, dead.
      const starved = [0, 0, 2];
      expect(Rules.overfull(starved), isEmpty);
      expect(Rules.sowable(starved), isEmpty);
      expect(Rules.canWin(starved), isFalse);
    });
  });

  group('every tilth that ships', () {
    for (var number = 0; number < Tilths.count; number++) {
      final tilth = Tilths.at(number);

      test('${tilth.name} says what the search says', () {
        expect(Rules.canWin([...tilth.board]), tilth.winnable);
      });
    }

    test('the winning boards are the unsown ones', () {
      expect(Tilths.at(0).board, Rules.unsown(5));
      expect(Tilths.at(1).board, Rules.unsown(8));
      expect(Tilths.at(3).board, Rules.unsown(12));
      expect(Tilths.at(4).board, Rules.unsown(20));
    });
  });

  group('a tilth being sown', () {
    test('starts as the season left it', () {
      final play = Play.of(Tilths.at(0));
      expect(play.barned, 0);
      expect(play.canStill, isTrue);
      expect(play.maySow(1), isTrue);
      expect(play.maySow(2), isFalse);
    });

    test('a sowing banks one seed and feeds the nearer furrows', () {
      final play = Play.of(Tilths.at(0)).sow(1);
      expect(play.barned, 1);
      expect(play.board, [0, 1, 3]);
    });

    test('the wrong sowing traps seeds where all can see', () {
      final play = Play.of(Tilths.at(0)).sow(3);
      expect(play.board, [2, 2]);
      expect(play.trapped, [1]);
      expect(play.canStill, isFalse);
      expect(play.next, isNull);
    });

    test('following next sows every winnable tilth home', () {
      for (var number = 0; number < Tilths.count; number++) {
        final tilth = Tilths.at(number);
        if (!tilth.winnable) continue;
        var play = Play.of(tilth);
        var guard = 0;
        while (!play.isHome) {
          if (guard++ > tilth.seeds + 1) fail('${tilth.name} never home');
          play = play.sow(play.next!);
        }
        expect(play.barned, tilth.seeds, reason: tilth.name);
      }
    });

    test('the dead furrows are dead before a hand touches them', () {
      final play = Play.of(Tilths.at(2));
      expect(play.canStill, isFalse);
      expect(play.trapped, [1]);
      expect(play.next, isNull);
    });

    test('back unsows the last sowing', () {
      final start = Play.of(Tilths.at(0));
      final sownOnce = start.sow(1);
      expect(sownOnce.barned, 1);
      expect(sownOnce.back.barned, 0);
      expect(identical(start.back, start), isTrue);
    });
  });
}
