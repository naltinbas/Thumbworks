import 'package:flutter_test/flutter_test.dart';
import 'package:beadlow/bead/play.dart';
import 'package:beadlow/bead/rings.dart';
import 'package:beadlow/bead/rules.dart';

void main() {
  group('the countings', () {
    test('what each turn fixes, summed and divided', () {
      expect(Rules.byCounting(3, 2), 4);
      expect(Rules.byCounting(4, 2), 6);
      expect(Rules.byCounting(5, 2), 8);
      expect(Rules.byCounting(6, 2), 14);
      expect(Rules.byCounting(3, 3), 11);
      expect(Rules.fixedByTurn(6, 2), [64, 2, 4, 8, 4, 2]);
      expect(Rules.fixedByTurn(4, 2), [16, 2, 4, 2]);
    });

    test('a necklace is its smallest turning', () {
      expect(Rules.necklaceOf([1, 0, 0]), [0, 0, 1]);
      expect(Rules.necklaceOf([0, 1, 0]), [0, 0, 1]);
      expect(Rules.necklaceOf([1, 1, 1]), [1, 1, 1]);
      expect(Rules.necklaceOf([2, 0, 1]), [0, 1, 2]);
    });

    test('the shelf and the counting agree on every ring', () {
      for (final ring in Rings.all) {
        final shelf = Rules.shelf(ring.beads, ring.dyes);
        expect(shelf.length, Rules.byCounting(ring.beads, ring.dyes),
            reason: ring.name);
        expect(shelf.length, ring.holds, reason: ring.name);
        for (final necklace in shelf) {
          expect(Rules.necklaceOf(necklace), necklace);
        }
      }
    });

    test('the five: two solids and six mixed, five being prime', () {
      final shelf = Rules.shelf(5, 2);
      expect(shelf, hasLength(8));
      expect(
        shelf.where((necklace) => necklace.toSet().length == 1),
        hasLength(2),
      );
    });

    test('the three of three: three solids among the eleven', () {
      final shelf = Rules.shelf(3, 3);
      expect(shelf, hasLength(11));
      expect(
        shelf.where((necklace) => necklace.toSet().length == 1),
        hasLength(3),
      );
    });
  });

  group('a stall', () {
    test('a bead dyes onward and wraps', () {
      var play = Play.of(Rings.at(0));
      play = play.dye(1);
      expect(play.beads, [0, 1, 0]);
      play = play.dye(1);
      expect(play.beads, [0, 0, 0]);
      expect(play.back.beads, [0, 1, 0]);
    });

    test('a new string lands on the shelf, a repeat is named', () {
      var play = Play.of(Rings.at(0));
      play = play.stringIt();
      expect(play.strung, hasLength(1));
      expect(play.strings, 1);
      // The same necklace turned: one bead over.
      play = play.dye(0).dye(1);
      // Beads (1,1,0) vs shelved (0,0,0)? No: dye(0),dye(1) makes
      // (1,1,0), a new necklace. String it, then turn it and try
      // again.
      play = play.stringIt();
      expect(play.strung, hasLength(2));
      play = play.dye(0).dye(2);
      // (0,1,1) is (1,1,0) turned: the shelf already holds it.
      expect(play.alreadyAt, 1);
      play = play.stringIt();
      expect(play.strung, hasLength(2));
      expect(play.strings, 3);
    });

    test('the missing necklace is always one the shelf lacks', () {
      var play = Play.of(Rings.at(0));
      while (!play.isDone) {
        final missing = play.missing!;
        for (var at = 0; at < play.ring.beads; at++) {
          while (play.beads[at] != missing[at]) {
            play = play.dye(at);
          }
        }
        expect(play.alreadyAt, -1);
        play = play.stringIt();
      }
      expect(play.strung, hasLength(4));
      expect(play.missing, isNull);
    });

    test('every winnable ring completes by the pointer', () {
      for (final ring in Rings.all.where((ring) => ring.winnable)) {
        var play = Play.of(ring);
        var guard = 0;
        while (!play.isDone) {
          if (guard++ > 30) fail('${ring.name} never filled');
          final missing = play.missing!;
          for (var at = 0; at < ring.beads; at++) {
            while (play.beads[at] != missing[at]) {
              play = play.dye(at);
            }
          }
          play = play.stringIt();
        }
        expect(play.strings, ring.asked, reason: ring.name);
      }
    });

    test('the seventh: the shelf fills at six and the next string '
        'jams it', () {
      var play = Play.of(Rings.at(4));
      var guard = 0;
      while (play.strung.length < 6) {
        if (guard++ > 10) fail('the shelf never filled');
        final missing = play.missing!;
        for (var at = 0; at < 4; at++) {
          while (play.beads[at] != missing[at]) {
            play = play.dye(at);
          }
        }
        play = play.stringIt();
      }
      expect(play.missing, isNull);
      expect(play.isOver, isFalse);
      play = play.stringIt();
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.strung, hasLength(6));
    });
  });
}
