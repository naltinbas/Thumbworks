import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:rindhope/cheese/blocks.dart';
import 'package:rindhope/cheese/fewest.dart';
import 'package:rindhope/cheese/play.dart';

void main() {
  group('a bite', () {
    test('takes the crumb and everything above and right of it', () {
      expect(Bites.bitten([3, 3, 3, 3], 1, 1), [3, 1, 1, 1]);
      expect(Bites.bitten([3, 3, 3, 3], 2, 0), [3, 3, 0, 0]);
      expect(Bites.bitten([3, 1, 1, 1], 3, 0), [3, 1, 1, 0]);
    });

    test('and the shapes it leaves never rise left to right', () {
      final random = Random(3);
      var shape = List<int>.filled(6, 5);
      for (var go = 0; go < 200; go++) {
        final legal = Bites.bites(shape).toList();
        if (legal.length <= 1) {
          shape = List<int>.filled(6, 5);
          continue;
        }
        final (x, y) = legal[random.nextInt(legal.length)];
        if (x == 0 && y == 0) continue;
        shape = Bites.bitten(shape, x, y);
        for (var column = 1; column < shape.length; column++) {
          expect(shape[column], lessThanOrEqualTo(shape[column - 1]));
        }
      }
    });
  });

  group('the first mouse wins, and the argument cannot say how', () {
    test('the search proves the theorem block by block to seven by seven',
        () {
      for (var width = 1; width <= 7; width++) {
        for (var height = 1; height <= 7; height++) {
          if (width == 1 && height == 1) continue;
          expect(Bites.isLoss(List<int>.filled(width, height)), isFalse,
              reason: '${width}x$height');
        }
      }
    });

    test('and the stealing argument holds as running code', () {
      // Bite the far corner crumb and any later bite lands the same shape
      // it would have landed from the whole block: that is the steal. So
      // either the nibble wins outright, or the answer that beats it would
      // have won played first, and the first mouse wins either way.
      for (var width = 2; width <= 6; width++) {
        for (var height = 2; height <= 6; height++) {
          final whole = List<int>.filled(width, height);
          final nibbled = Bites.bitten(whole, width - 1, height - 1);

          for (final (x, y) in Bites.bites(nibbled)) {
            expect(Bites.bitten(nibbled, x, y), Bites.bitten(whole, x, y),
                reason: '${width}x$height bite $x,$y');
          }

          if (Bites.isLoss(nibbled)) continue;
          final answer = Bites.bites(nibbled).firstWhere((bite) =>
              !(bite.$1 == 0 && bite.$2 == 0) &&
              Bites.isLoss(Bites.bitten(nibbled, bite.$1, bite.$2)));
          expect(
              Bites.isLoss(Bites.bitten(whole, answer.$1, answer.$2)), isTrue,
              reason: '${width}x$height stolen ${answer.$1},${answer.$2}');
        }
      }
    });
  });

  group('the shapes a player can hold', () {
    test('the mirror wins every square against anything', () {
      final random = Random(44);
      for (final side in const [3, 4, 5, 6]) {
        for (var go = 0; go < 30; go++) {
          var shape = Bites.bitten(List<int>.filled(side, side), 1, 1);
          var guard = 0;
          while (!Bites.poisonOnly(shape)) {
            if (guard++ > 40) fail('the ${side}x$side mirror never ended');
            // Their bite: anything but the mould.
            final theirs = [
              for (final bite in Bites.bites(shape))
                if (!(bite.$1 == 0 && bite.$2 == 0)) bite,
            ];
            if (theirs.isEmpty) break;
            final their = theirs[random.nextInt(theirs.length)];
            shape = Bites.bitten(shape, their.$1, their.$2);
            if (Bites.poisonOnly(shape)) {
              fail('the mirror mouse was handed the mould');
            }
            // The mirrored answer is always a standing crumb.
            final mine = Bites.mirrored(their);
            expect(mine.$2 < shape[mine.$1], isTrue,
                reason: '$side mirror of $their');
            shape = Bites.bitten(shape, mine.$1, mine.$2);
          }
          expect(Bites.poisonOnly(shape), isTrue);
        }
      }
    });

    test('the strip shape loses for whoever holds it, and is always there '
        'to hand over', () {
      // Two rows: bottom exactly one longer than the top. Every bite
      // breaks it, and from any other two-row shape some bite makes it.
      for (var width = 2; width <= 9; width++) {
        for (var bottom = 1; bottom <= width; bottom++) {
          for (var top = 0; top <= bottom; top++) {
            final shape = [
              for (var x = 0; x < width; x++)
                x < top
                    ? 2
                    : x < bottom
                        ? 1
                        : 0,
            ];
            if (Bites.strippedShort(shape)) {
              expect(Bites.isLoss(shape), isTrue, reason: '$shape');
              for (final (x, y) in Bites.bites(shape)) {
                expect(Bites.strippedShort(Bites.bitten(shape, x, y)),
                    isFalse,
                    reason: '$shape bite $x,$y');
              }
            } else if (!Bites.poisonOnly(shape) && shape[0] > 0) {
              final mends = Bites.bites(shape).any((bite) =>
                  !(bite.$1 == 0 && bite.$2 == 0) &&
                  Bites.strippedShort(
                      Bites.bitten(shape, bite.$1, bite.$2)));
              expect(mends, isTrue, reason: '$shape');
            }
          }
        }
      }
    });
  });

  group('every block that ships', () {
    for (var number = 0; number < Blocks.count; number++) {
      final block = Blocks.at(number);

      test('${block.name} says what the search says', () {
        if (block.mouseFirst) {
          final (x, y) = Bites.reply(block.whole);
          expect(Bites.isLoss(Bites.bitten(block.whole, x, y)), isTrue);
          expect(block.hopeless, isTrue);
        } else {
          expect(Bites.isLoss(block.whole), isFalse);
          expect(Bites.fewestWin(block.whole), block.fewest);
        }
      });
    }

    test('the square opens next to the mould, the way the mirror wants', () {
      expect(Bites.next(Blocks.at(1).whole), (1, 1));
    });
  });

  group('a block in play', () {
    test('starts whole, with the win still to be had at par', () {
      final play = Play.of(Blocks.at(0));
      expect(play.made, 0);
      expect(play.isOver, isFalse);
      expect(play.winnable, isTrue);
      expect(play.couldFinishIn, Blocks.at(0).fewest);
    });

    test('the second mouse block opens with the grey bite taken', () {
      final play = Play.of(Blocks.at(4));
      expect(play.theirBite, isNotNull);
      expect(play.winnable, isFalse);
      expect(play.couldFinishIn, isNull);
    });

    test('biting the mould loses at once', () {
      final play = Play.of(Blocks.at(0)).touch(0, 0);
      expect(play.isOver, isTrue);
      expect(play.won, isFalse);
    });

    test('a bite off the cheese changes nothing', () {
      final play = Play.of(Blocks.at(0));
      expect(identical(play.touch(0, 4), play), isTrue);
      expect(identical(play.touch(9, 0), play), isTrue);
    });

    test('following the search wins every block that can be won, at par',
        () {
      for (var number = 0; number < Blocks.count; number++) {
        final block = Blocks.at(number);
        if (block.hopeless) continue;
        var play = Play.of(block);
        var guard = 0;
        while (!play.isOver) {
          if (guard++ > 20) fail('${block.name} never ended');
          expect(play.couldFinishIn, block.fewest, reason: block.name);
          final bite = play.next!;
          play = play.touch(bite.$1, bite.$2);
        }
        expect(play.won, isTrue, reason: block.name);
        expect(play.made, block.fewest, reason: block.name);
      }
    });

    test('a wrong bite hands the block over, and the game knows at once', () {
      var play = Play.of(Blocks.at(1));
      // Anything but the corner nibble loses the square.
      play = play.touch(3, 3);
      expect(play.winnable, isFalse);
      expect(play.couldFinishIn, isNull);
    });

    test('the grey mouse never wins a winnable block played well, over '
        'thirty runs', () {
      for (var go = 0; go < 30; go++) {
        var play = Play.of(Blocks.at(2));
        var guard = 0;
        while (!play.isOver) {
          if (guard++ > 20) fail('the long block never ended');
          final bite = play.next!;
          play = play.touch(bite.$1, bite.$2);
        }
        expect(play.won, isTrue);
      }
    });

    test('take back returns the whole exchange', () {
      final start = Play.of(Blocks.at(0));
      final bite = start.next!;
      final bitten = start.touch(bite.$1, bite.$2);
      expect(bitten.made, 1);
      expect(bitten.back.heights, Blocks.at(0).whole);
      expect(identical(start.back, start), isTrue);
    });
  });
}
