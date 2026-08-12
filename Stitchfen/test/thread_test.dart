import 'package:flutter_test/flutter_test.dart';
import 'package:stitchfen/thread/play.dart';
import 'package:stitchfen/thread/rows.dart';
import 'package:stitchfen/thread/rules.dart';

/// The law of the sampler, held to.
void main() {
  group('the rules', () {
    test('a ladder is three evenly spaced stitches on one thread',
        () {
      final rules = Rules(6);
      expect(rules.ladders('RRRBBB'.split('')),
          containsAll([(0, 1), (3, 1)]));
      expect(rules.ladderFree('RRBBRR'.split('')), isTrue);
      // A spread ladder: stitches 1, 3, 5.
      expect(rules.ladders('RBRBRB'.split('')),
          containsAll([(0, 2), (1, 2)]));
    });

    test('the sweep and the prefix ledger agree at every size', () {
      for (final stitches in [6, 7, 8, 9]) {
        final rules = Rules(stitches);
        expect(rules.ways(), rules.waysByPrefix(),
            reason: '$stitches');
      }
    });

    test('every label\'s ways is what the sweep finds', () {
      for (final row in Rows.all) {
        expect(Rules(row.stitches).waysFrom(row.fixed), row.ways,
            reason: row.name);
      }
    });

    test('the six eights pair off under a thread-swap', () {
      final eight = Rules(8);
      final alive = <String>[];
      eight.threadings((threading) {
        if (eight.ladderFree(threading)) {
          alive.add(threading.join());
        }
      });
      expect(alive, hasLength(6));
      for (final one in alive) {
        final swapped = one
            .split('')
            .map((thread) => thread == 'R' ? 'B' : 'R')
            .join();
        expect(alive, contains(swapped), reason: one);
      }
    });

    test('every three-stitch beginning finishes at most one way', () {
      final eight = Rules(8);
      for (final a in const ['R', 'B']) {
        for (final b in const ['R', 'B']) {
          for (final c in const ['R', 'B']) {
            expect(eight.waysFrom([a, b, c]), lessThanOrEqualTo(1),
                reason: '$a$b$c');
          }
        }
      }
    });

    test('nine stitches leave nothing', () {
      expect(Rules(9).ways(), 0);
      expect(Rules(9).threading(const []), isNull);
    });
  });

  group('the play', () {
    test('the row opens all madder past what is fixed', () {
      final play = Play.of(Rows.at(3));
      expect(play.threads.take(3), ['R', 'R', 'B']);
      expect(play.threads.skip(3), everyElement('R'));
      expect(play.isDone, isFalse);
    });

    test('taps flip a stitch and count', () {
      var play = Play.of(Rows.at(0));
      play = play.tapAt(2);
      expect(play.threads[2], 'B');
      expect(play.moves, 1);
      play = play.tapAt(2);
      expect(play.threads[2], 'R');
      expect(play.moves, 2);
    });

    test('the fixed stitches never flip', () {
      final play = Play.of(Rows.at(3));
      expect(play.canFlip(0), isFalse);
      expect(play.tapAt(0), same(play));
      expect(play.canFlip(3), isTrue);
    });

    test('a known good six lands', () {
      var play = Play.of(Rows.at(0));
      const target = 'RRBBRR';
      for (var at = 0; at < 6; at++) {
        while (play.threads[at] != target[at]) {
          play = play.tapAt(at);
        }
      }
      expect(play.isDone, isTrue);
      expect(play.tapAt(0), same(play));
    });

    test('back takes back a flip', () {
      var play = Play.of(Rows.at(0)).tapAt(1);
      expect(play.moves, 1);
      expect(play.back.moves, 0);
      expect(play.back.threads[1], 'R');
      expect(Play.of(Rows.at(0)).back.moves, 0);
    });

    test('show me walks the one way home', () {
      var play = Play.of(Rows.at(3));
      var guard = 0;
      while (!play.isDone && guard++ < 12) {
        final aim = play.next;
        expect(aim, isNotNull);
        final (stitch, thread) = aim!;
        while (play.threads[stitch] != thread) {
          play = play.tapAt(stitch);
        }
      }
      expect(play.isDone, isTrue);
      expect(play.threads.join(), 'RRBBRRBB');
    });

    test('the hopeless row has nothing to point at', () {
      expect(Play.of(Rows.at(4)).next, isNull);
    });

    test('the hopeless row admits it after twelve flips', () {
      var play = Play.of(Rows.at(4));
      for (var flip = 0; flip < Play.gaveUpAt; flip++) {
        expect(play.gaveUp, isFalse);
        play = play.tapAt(flip % 9);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.isDone, isFalse);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
    });

    test('a winnable row never gives up', () {
      var play = Play.of(Rows.at(0));
      for (var flip = 0; flip < Play.gaveUpAt; flip++) {
        play = play.tapAt(0);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.gaveUp, isFalse);
    });
  });
}
