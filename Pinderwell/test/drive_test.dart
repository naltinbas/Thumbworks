import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:pinderwell/drive/cold.dart';
import 'package:pinderwell/drive/fields.dart';
import 'package:pinderwell/drive/play.dart';

void main() {
  group('the two constructions', () {
    test('sweep and ladder agree on every square of a sixty-pace field', () {
      // The anchor. The sweep knows the game and nothing about pairs; the
      // ladder builds pairs and never plays a push. 3721 squares, no
      // disagreement.
      final swept = Cold.sweep(60);
      final laddered = Cold.ladder(60);
      for (var east = 0; east <= 60; east++) {
        for (var north = 0; north <= 60; north++) {
          expect(swept[east][north], laddered.contains((east, north)),
              reason: '$east east $north north');
        }
      }
    });

    test('and the ladder is the golden ratio counting', () {
      // The third voice, checked rather than cited: the smaller pace count
      // of rung n is the floor of n times phi.
      final phi = (1 + sqrt(5)) / 2;
      final rungs = Cold.ladder(200)
          .where((rung) => rung.$1 < rung.$2 || rung == (0, 0))
          .toList()
        ..sort((a, b) => a.$1.compareTo(b.$1));
      expect(rungs.length, greaterThan(20));
      for (var rung = 0; rung < rungs.length; rung++) {
        expect(rungs[rung].$1, (rung * phi).floor(), reason: 'rung $rung');
        expect(rungs[rung].$2, rungs[rung].$1 + rung, reason: 'rung $rung');
      }
    });

    test('every row, every column and every diagonal has one cold square',
        () {
      // The shape a player can check by eye once Why draws it. Along any
      // wall distance and along any diagonal there is exactly one safe
      // square. Lines past twenty three have theirs beyond the sixty-pace
      // board, rung 24's being thirty eight east and sixty two north, so
      // the sweep is asked only about lines it holds whole.
      final swept = Cold.sweep(60);
      for (var line = 0; line <= 23; line++) {
        var inRow = 0, inColumn = 0, onDiagonal = 0;
        for (var other = 0; other <= 60; other++) {
          if (swept[line][other]) inColumn++;
          if (swept[other][line]) inRow++;
          if (other + line <= 60 && swept[other + line][other]) onDiagonal++;
        }
        expect(inRow, 1, reason: 'row $line');
        expect(inColumn, 1, reason: 'column $line');
        expect(onDiagonal, 1, reason: 'diagonal $line');
      }
    });

    test('from cold every push lands hot, from hot some push lands cold', () {
      final swept = Cold.sweep(40);
      for (var east = 0; east <= 40; east++) {
        for (var north = 0; north <= 40; north++) {
          var coldPushes = 0;
          for (var paces = 1; paces <= east; paces++) {
            if (swept[east - paces][north]) coldPushes++;
          }
          for (var paces = 1; paces <= north; paces++) {
            if (swept[east][north - paces]) coldPushes++;
          }
          final most = min(east, north);
          for (var paces = 1; paces <= most; paces++) {
            if (swept[east - paces][north - paces]) coldPushes++;
          }
          if (swept[east][north]) {
            expect(coldPushes, 0, reason: '$east,$north is cold');
          } else {
            expect(coldPushes, greaterThan(0),
                reason: '$east,$north is hot');
          }
        }
      }
    });
  });

  group('every field that ships', () {
    for (var number = 0; number < Fields.count; number++) {
      final field = Fields.at(number);

      test('${field.name} says what the search says', () {
        expect(Cold.fewestFrom(field.east, field.north), field.fewest);
        expect(Cold.isCold(field.east, field.north), field.hopeless);
      });
    }

    test('the hopeless field starts on the third rung of the ladder', () {
      final hopeless = Fields.all.singleWhere((field) => field.hopeless);
      expect((hopeless.east, hopeless.north), (3, 5));
      expect(Cold.ladder(10), contains((3, 5)));
    });
  });

  group('a drive against the pinder', () {
    test('starts with the fee still to be won at par', () {
      final play = Play.of(Fields.at(1));
      expect(play.made, 0);
      expect(play.isOver, isFalse);
      expect(play.winnable, isTrue);
      expect(play.couldFinishIn, Fields.at(1).fewest);
    });

    test('a push goes west, south, or evenly both, and nothing else', () {
      final play = Play.of(Fields.at(0));
      expect(play.mayPush(1, 2), isTrue);
      expect(play.mayPush(4, 0), isTrue);
      expect(play.mayPush(2, 0), isTrue);
      expect(play.mayPush(4, 2), isFalse);
      expect(play.mayPush(5, 2), isFalse);
      expect(play.mayPush(3, 0), isFalse);
      expect(play.mayPush(1, 0), isFalse);
      expect(identical(play.touch(3, 0), play), isTrue);
    });

    test('the pinder answers onto the ladder while the player is winning',
        () {
      var play = Play.of(Fields.at(1));
      play = play.touch(play.next!.$1, play.next!.$2);
      expect(play.isOver, isFalse);
      expect(play.theirFrom, isNotNull);
      // His answer left a hot square, or the player could never win on.
      expect(play.winnable, isTrue);
    });

    test('a wrong push hands the ewe to the pinder, and the game knows '
        'at once', () {
      var play = Play.of(Fields.at(0));
      // From four east two north, pushing to four... to two east two north
      // lands hot: the pinder answers to a rung and the fee is his.
      play = play.touch(2, 2);
      expect(play.winnable, isFalse);
      expect(play.couldFinishIn, isNull);
    });

    test('take back undoes the push and the answer together', () {
      final start = Play.of(Fields.at(1));
      final pushed = start.touch(start.next!.$1, start.next!.$2);
      expect(pushed.made, 1);
      expect(pushed.back.made, 0);
      expect(pushed.back.east, Fields.at(1).east);
      expect(identical(start.back, start), isTrue);
    });

    test('following the search wins every field that can be won, at par', () {
      for (var number = 0; number < Fields.count; number++) {
        final field = Fields.at(number);
        if (field.hopeless) continue;
        var play = Play.of(field);
        var guard = 0;
        while (!play.isOver) {
          if (guard++ > 20) fail('${field.name} never ended');
          expect(play.couldFinishIn, field.fewest, reason: field.name);
          final push = play.next!;
          play = play.touch(push.$1, push.$2);
        }
        expect(play.won, isTrue, reason: field.name);
        expect(play.made, field.fewest, reason: field.name);
      }
    });

    test('the pinder never loses the hopeless field, however it is driven',
        () {
      final hopeless = Fields.all.indexWhere((field) => field.hopeless);
      final random = Random(7);
      for (var go = 0; go < 30; go++) {
        var play = Play.of(Fields.at(hopeless));
        var guard = 0;
        while (!play.isOver) {
          if (guard++ > 30) fail('the drive never ended');
          final pushes = <(int, int)>[
            for (var east = 0; east <= play.east; east++)
              for (var north = 0; north <= play.north; north++)
                if (play.mayPush(east, north)) (east, north),
          ];
          final push = pushes[random.nextInt(pushes.length)];
          play = play.touch(push.$1, push.$2);
        }
        expect(play.won, isFalse);
      }
    });
  });
}
