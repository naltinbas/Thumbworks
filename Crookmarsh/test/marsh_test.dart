import 'package:crookmarsh/marsh/marshes.dart';
import 'package:crookmarsh/marsh/play.dart';
import 'package:crookmarsh/marsh/rules.dart';
import 'package:flutter_test/flutter_test.dart';

/// The law of the marsh, held to.
void main() {
  group('the rules', () {
    test('a square stands true, a tucked post does not', () {
      expect(
        Rules.trueByTuck(const [(0, 0), (2, 0), (2, 2), (0, 2)]),
        isTrue,
      );
      expect(
        Rules.trueByWalk(const [(0, 0), (2, 0), (2, 2), (0, 2)]),
        isTrue,
      );
      // One post tucked inside the others' triangle.
      expect(
        Rules.trueByTuck(const [(0, 0), (3, 0), (1, 3), (1, 1)]),
        isFalse,
      );
      expect(
        Rules.trueByWalk(const [(0, 0), (3, 0), (1, 3), (1, 1)]),
        isFalse,
      );
    });

    test('three to a line spoils a four for both tests', () {
      const lined = [(0, 0), (1, 1), (2, 2), (3, 0)];
      expect(Rules.trueByTuck(lined), isFalse);
      expect(Rules.trueByWalk(lined), isFalse);
      expect(Rules.shared(lined), hasLength(1));
    });

    test('the law holds over the whole sweep', () {
      expect(Rules.lawHolds(), isTrue);
    });

    test('every label\'s ways is what the sweep finds', () {
      for (final marsh in Marshes.all) {
        expect(Rules.waysTo(marsh.posts, marsh.asked), marsh.ways,
            reason: marsh.name);
      }
    });

    test('frames from five come odd, never even', () {
      for (final even in [0, 2, 4]) {
        expect(Rules.waysTo(5, even), 0, reason: '$even');
      }
    });

    test('a setting lands what it promises', () {
      final found = Rules.setting(5, 1)!;
      expect(Rules.clearStanding(found), isTrue);
      expect(Rules.frames(found), hasLength(1));
      expect(Rules.setting(5, 0), isNull);
    });
  });

  group('the play', () {
    test('taps set posts, tap again lifts them', () {
      var play = Play.of(Marshes.at(0)).tapAt((1, 1));
      expect(play.posts, [(1, 1)]);
      expect(play.moves, 1);
      play = play.tapAt((1, 1));
      expect(play.posts, isEmpty);
      expect(play.moves, 2);
    });

    test('a full marsh refuses another post', () {
      // Full with a shared line, so the marsh is still open.
      var play = Play.of(Marshes.at(0));
      for (final spot in const [(0, 0), (1, 1), (2, 2), (3, 0)]) {
        play = play.tapAt(spot);
      }
      expect(play.allSet, isTrue);
      expect(play.isDone, isFalse);
      expect(play.tapAt((3, 3)), same(play));
      expect(play.tapAt((0, 0)).posts, hasLength(3));
    });

    test('the crooked four lands on a tucked setting', () {
      var play = Play.of(Marshes.at(0));
      for (final spot in const [(0, 0), (3, 0), (1, 3), (1, 1)]) {
        play = play.tapAt(spot);
      }
      expect(play.frames, isEmpty);
      expect(play.lined, isEmpty);
      expect(play.isDone, isTrue);
      expect(play.tapAt((2, 2)), same(play));
    });

    test('the true frame lands on a square', () {
      var play = Play.of(Marshes.at(1));
      for (final spot in const [(0, 0), (2, 0), (2, 2), (0, 2)]) {
        play = play.tapAt(spot);
      }
      expect(play.frames, hasLength(1));
      expect(play.isDone, isTrue);
    });

    test('a shared line blocks the landing until lifted', () {
      var play = Play.of(Marshes.at(1));
      for (final spot in const [(0, 0), (1, 1), (2, 2), (3, 0)]) {
        play = play.tapAt(spot);
      }
      expect(play.lined, isNotEmpty);
      expect(play.isDone, isFalse);
      play = play.tapAt((1, 1)).tapAt((1, 2));
      expect(play.lined, isEmpty);
      expect(play.isDone, isTrue);
    });

    test('back takes back one touch', () {
      final play = Play.of(Marshes.at(0)).tapAt((0, 0)).tapAt((1, 1));
      expect(play.back.posts, [(0, 0)]);
      expect(play.back.moves, 1);
      expect(Play.of(Marshes.at(0)).back.moves, 0);
    });

    test('show me walks to a landing', () {
      var play = Play.of(Marshes.at(2));
      var guard = 0;
      while (!play.isDone && guard++ < 12) {
        final aim = play.next;
        expect(aim, isNotNull);
        play = play.tapAt(aim!);
      }
      expect(play.isDone, isTrue);
      expect(play.frames, hasLength(1));
    });

    test('the hopeless marsh has nothing to point at', () {
      expect(Play.of(Marshes.at(4)).next, isNull);
    });

    test('the hopeless marsh admits it after sixteen touches', () {
      var play = Play.of(Marshes.at(4));
      for (var touch = 0; touch < Play.gaveUpAt; touch++) {
        expect(play.gaveUp, isFalse);
        play = play.tapAt((0, 0));
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.isDone, isFalse);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
    });

    test('a winnable marsh never gives up', () {
      var play = Play.of(Marshes.at(0));
      for (var touch = 0; touch < Play.gaveUpAt; touch++) {
        play = play.tapAt((0, 0));
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.gaveUp, isFalse);
      expect(play.isOver, isFalse);
    });
  });
}
