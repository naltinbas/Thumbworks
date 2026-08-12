import 'package:flutter_test/flutter_test.dart';
import 'package:marklow/mark/lows.dart';
import 'package:marklow/mark/play.dart';
import 'package:marklow/mark/rules.dart';

/// The law of the low, held to.
void main() {
  group('the rules', () {
    test('gaps wear the difference and wait for bare ends', () {
      final path = Rules(4, const [(0, 1), (1, 2), (2, 3)]);
      expect(path.gaps([0, 3, 1, 2]), [3, 2, 1]);
      expect(path.gaps([0, -1, 1, 2]), [-1, -1, 1]);
    });

    test('clashes and repeats are called by name', () {
      final path = Rules(4, const [(0, 1), (1, 2), (2, 3)]);
      expect(path.clashes([0, 0, 1, 2]), [0, 1]);
      expect(path.repeats([0, 1, 2, 3]), [0, 1, 2]);
    });

    test('gracefulness asks everything at once', () {
      final path = Rules(4, const [(0, 1), (1, 2), (2, 3)]);
      expect(path.graceful([0, 3, 1, 2]), isTrue);
      expect(path.graceful([0, 1, 2, 3]), isFalse);
      expect(path.graceful([0, 3, 1, -1]), isFalse);
    });

    test('every label\'s ways is what the sweep finds', () {
      for (final low in Lows.all) {
        expect(Rules(low.posts, low.lines).ways(), low.ways,
            reason: low.name);
      }
    });

    test('complements keep their grace on every low', () {
      for (final low in Lows.all) {
        expect(Rules(low.posts, low.lines).complementsHold(),
            isTrue,
            reason: low.name);
      }
    });

    test('rings wear even sums and the five-ring pays odd', () {
      final ring5 = Rules(
          5, const [(0, 1), (1, 2), (2, 3), (3, 4), (0, 4)]);
      expect(ring5.ringParityHolds(), isTrue);
      expect(ring5.ways(), 0);
      expect(ring5.numbering(), isNull);
    });
  });

  group('the play', () {
    test('taps cycle a post through bare and the marks', () {
      var play = Play.of(Lows.at(0));
      expect(play.numbering[1], -1);
      play = play.tapAt(1);
      expect(play.numbering[1], 0);
      for (var turn = 0; turn < 3; turn++) {
        play = play.tapAt(1);
      }
      expect(play.numbering[1], 3);
      play = play.tapAt(1);
      expect(play.numbering[1], -1);
      expect(play.moves, 5);
    });

    test('a graceful path lands', () {
      var play = Play.of(Lows.at(0));
      final aim = [0, 3, 1, 2];
      for (var post = 0; post < 4; post++) {
        while (play.numbering[post] != aim[post]) {
          play = play.tapAt(post);
        }
      }
      expect(play.isDone, isTrue);
      expect(play.tapAt(0), same(play));
    });

    test('back takes back a marking', () {
      var play = Play.of(Lows.at(0)).tapAt(2);
      expect(play.back.numbering[2], -1);
      expect(play.back.moves, 0);
      expect(Play.of(Lows.at(0)).back.moves, 0);
    });

    test('show me marks the low home', () {
      var play = Play.of(Lows.at(1));
      var guard = 0;
      while (!play.isDone && guard++ < 30) {
        final aim = play.next;
        expect(aim, isNotNull);
        final (post, mark) = aim!;
        while (play.numbering[post] != mark) {
          play = play.tapAt(post);
        }
      }
      expect(play.isDone, isTrue);
    });

    test('the hopeless low has nothing to point at', () {
      expect(Play.of(Lows.at(4)).next, isNull);
    });

    test('the hopeless low admits it after twelve markings', () {
      var play = Play.of(Lows.at(4));
      for (var marking = 0; marking < Play.gaveUpAt; marking++) {
        expect(play.gaveUp, isFalse);
        play = play.tapAt(marking % 5);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.isDone, isFalse);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
    });

    test('a winnable low never gives up', () {
      var play = Play.of(Lows.at(2));
      for (var marking = 0; marking < Play.gaveUpAt; marking++) {
        play = play.tapAt(0);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.gaveUp, isFalse);
    });
  });
}
