import 'package:flutter_test/flutter_test.dart';
import 'package:thrissleton/third/hands.dart';
import 'package:thrissleton/third/play.dart';
import 'package:thrissleton/third/rules.dart';

/// The law of the stones, held to.
void main() {
  group('the rules', () {
    test('every label\'s ways is what the sweep finds', () {
      for (final hand in Hands.all) {
        expect(
          Rules.waysTo(hand.asked, locked: hand.locked),
          hand.ways,
          reason: hand.name,
        );
      }
    });

    test('the spreads stand where they were pinned', () {
      expect(Rules.spread(), {10: 96, 4: 5760, 1: 1920});
      expect(
          Rules.spread(locked: (0, 6)), {4: 960, 1: 320, 10: 16});
    });

    test('the laws hold over the whole sweep', () {
      expect(Rules.lawsHold(), isTrue);
    });

    test('thirds read off a hand, triple by triple', () {
      expect(Rules.thirds([1, 1, 1, 1, 1]), hasLength(10));
      expect(Rules.thirds([1, 2, 3, 4, 5]), hasLength(4));
      // 1+2+3, 1+3+5, 2+3+4, 3+4+5.
      expect(
        Rules.thirds([1, 2, 3, 4, 5]),
        [(0, 1, 2), (0, 2, 4), (1, 2, 3), (2, 3, 4)],
      );
    });

    test('the two cases stand on any hand offered', () {
      expect(Rules.twoCases([1, 1, 1, 4, 4]), isTrue);
      expect(Rules.twoCases([1, 2, 3, 4, 5]), isTrue);
      expect(Rules.twoCases([6, 6, 6, 6, 6]), isTrue);
    });

    test('no shipped hand opens landed', () {
      for (final hand in Hands.all) {
        expect(
          Rules.thirds(hand.opens).length == hand.asked,
          isFalse,
          reason: hand.name,
        );
      }
    });
  });

  group('the play', () {
    test('opens on its hand\'s faces, unsettled', () {
      for (final hand in Hands.all) {
        final play = Play.of(hand);
        expect(play.faces, hand.opens, reason: hand.name);
        expect(play.isDone, isFalse, reason: hand.name);
        expect(play.isOver, isFalse, reason: hand.name);
      }
    });

    test('a tap turns one face up and wraps past six', () {
      var play = Play.of(Hands.at(4));
      play = play.tapAt(1);
      expect(play.faces[1], 2);
      expect(play.moves, 1);
      for (var turn = 0; turn < 5; turn++) {
        play = play.tapAt(1);
      }
      expect(play.faces[1], 1);
      expect(play.moves, 6);
    });

    test('the held stone refuses the tap', () {
      final play = Play.of(Hands.at(3));
      expect(play.turns(0), isFalse);
      expect(play.tapAt(0), same(play));
      expect(play.turns(1), isTrue);
    });

    test('back takes back one tap', () {
      final play = Play.of(Hands.at(4)).tapAt(0).tapAt(2);
      expect(play.back.moves, 1);
      expect(play.back.faces[2], 1);
      expect(play.back.back.back, same(play.back.back));
    });

    test('one tap lands the four thirds', () {
      // From all ones, turning one stone to three keeps ten;
      // turning it to two leaves remainders 2-4: thirds drop
      // to four.
      var play = Play.of(Hands.at(0));
      play = play.tapAt(0);
      expect(play.thirds, hasLength(4));
      expect(play.isDone, isTrue);
      expect(play.moves, 1);
      expect(play.tapAt(1), same(play));
    });

    test('the pointer lands the perfect ten', () {
      var play = Play.of(Hands.at(2));
      var guard = 0;
      while (!play.isDone && guard++ < 15) {
        play = play.tapAt(play.next!);
      }
      expect(play.isDone, isTrue);
      expect(play.thirds, hasLength(10));
    });

    test('the hopeless hand admits it at fifteen taps', () {
      var play = Play.of(Hands.at(4));
      for (var dither = 0; dither < 15; dither++) {
        play = play.tapAt(dither % 5);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.isDone, isFalse);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.next, isNull);
    });

    test('a winnable hand never gives up', () {
      // Stone five of 1, 2, 3, 4 and x never makes one
      // remainder rule, so the ten stays out of reach and the
      // dither lands nothing.
      var play = Play.of(Hands.at(2));
      for (var dither = 0; dither < 15; dither++) {
        play = play.tapAt(4);
      }
      expect(play.moves, 15);
      expect(play.gaveUp, isFalse);
      expect(play.isOver, isFalse);
    });

    test('the mark stands dialled home', () {
      final mark = Play.standing(Hands.at(2), const [3, 6, 3, 6, 3]);
      expect(mark.isDone, isTrue);
      expect(mark.thirds, hasLength(10));
    });
  });
}
