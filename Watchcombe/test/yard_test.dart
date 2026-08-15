import 'package:flutter_test/flutter_test.dart';
import 'package:watchcombe/yard/levels.dart';
import 'package:watchcombe/yard/play.dart';
import 'package:watchcombe/yard/rules.dart';

/// The law of the yard, held to.
void main() {
  group('the rules', () {
    test('a watchman watches his flag and the eight round it', () {
      const r = Rules(4);
      expect(r.watch(0), [0, 1, 4, 5]);
      expect(r.watch(5), [0, 1, 2, 4, 5, 6, 8, 9, 10]);
      expect(r.watched([5]), hasLength(9));
      expect(r.unwatched([5, 6, 9, 10]), isEmpty);
      expect(r.unwatched([5]), hasLength(7));
      expect(r.lands([5, 6, 9, 10], 4), isTrue);
      expect(r.lands([5, 6, 9], 4), isFalse);
      // The four corners each watch a quarter of the four yard: they land too.
      expect(r.lands([0, 3, 12, 15], 4), isTrue);
      expect(r.lands([0, 1, 4, 5], 4), isFalse);
    });

    test('the walk and the sweep agree on the small yards', () {
      expect(const Rules(3).walk(1), 1);
      expect(const Rules(4).walk(4), 256);
      expect(const Rules(4).sweep(4), (256, 1820));
      expect(const Rules(4).walk(3), 0);
      expect(const Rules(5).walk(4), 79);
      expect(const Rules(5).sweep(4), (79, 12650));
      expect(const Rules(6).walk(4), 1);
      expect(const Rules(6).walk(3), 0);
      expect(const Rules(6).sweep(3), (0, 7140));
      expect(const Rules(4).postings(4), 1820);
      expect(Rules.choose(81, 9), 260887834350);
    });

    test('the far flags bound the yard, and the posting watches it', () {
      for (var n = 3; n <= 7; n++) {
        final r = Rules(n);
        final third = (n + 2) ~/ 3;
        expect(r.far, hasLength(third * third), reason: '$n');
        for (final a in r.far) {
          for (final b in r.far) {
            if (a != b) expect(r.watch(a).any(r.watch(b).contains), isFalse, reason: '$n: $a $b');
          }
        }
        expect(r.posting, hasLength(r.bound), reason: '$n');
        expect(r.unwatched(r.posting), isEmpty, reason: '$n');
        expect(r.walk(r.bound), greaterThan(0), reason: '$n');
        expect(r.walk(r.bound - 1), 0, reason: '$n');
      }
      expect(const Rules(6).posting, [7, 10, 25, 28]);
    });

    test('every label\'s ways is what the walk finds', () {
      for (final level in Levels.all) {
        expect(level.rules.walk(level.watchmen), level.ways, reason: level.name);
        expect(level.rules.postings(level.watchmen), level.postings, reason: level.name);
      }
    });
  });

  group('the play', () {
    test('opens with an empty yard', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.watchmen, isEmpty, reason: level.name);
        expect(play.unwatched, hasLength(level.size * level.size));
        expect(play.isDone, isFalse);
      }
    });

    test('a tap posts, a tap lifts, counted both ways; back undoes', () {
      var play = Play.of(Levels.at(0));
      play = play.tap(5);
      expect(play.watchmen, [5]);
      expect(play.unwatched, hasLength(7));
      play = play.tap(5);
      expect(play.watchmen, isEmpty);
      expect(play.moves, 2);
      expect(play.back.watchmen, [5]);
      expect(play.tap(16), same(play));
    });

    test('the yards by hand', () {
      final four = Play.of(Levels.at(0)).tap(5).tap(6).tap(9).tap(10);
      expect(four.isDone, isTrue);
      expect(four.tap(0), same(four));
      final corners = Play.of(Levels.at(0)).tap(0).tap(3).tap(12).tap(15);
      expect(corners.isDone, isTrue);
      final crowd = Play.of(Levels.at(0)).tap(0).tap(1).tap(4).tap(5);
      expect(crowd.isDone, isFalse);
      expect(crowd.unwatched, [3, 7, 11, 12, 13, 14, 15]);
      final six = Play.of(Levels.at(2)).tap(7).tap(10).tap(25).tap(28);
      expect(six.isDone, isTrue);
    });

    test('the pointer watches every winnable yard', () {
      for (final number in [0, 1, 2, 3]) {
        var play = Play.of(Levels.at(number));
        var guard = 0;
        while (!play.isDone && guard++ < 40) {
          final (_, c) = play.next!;
          play = play.tap(c);
        }
        expect(play.isDone, isTrue, reason: '$number');
      }
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('the pointer says set or lift', () {
      final play = Play.of(Levels.at(2));
      expect(play.next, ('set', 7));
      expect(play.tap(7).next, ('set', 10));
      expect(play.tap(0).next, ('lift', 0));
    });

    test('the hopeless yard admits it at thirteen taps', () {
      var play = Play.of(Levels.at(4));
      for (final c in [7, 10, 25]) {
        play = play.tap(c);
      }
      expect(play.unwatched, isNotEmpty);
      for (var k = 0; k < 10; k++) {
        play = play.tap(28);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.tap(3), same(play));
    });

    test('a winnable yard never gives up', () {
      var play = Play.of(Levels.at(0));
      for (var k = 0; k < 14; k++) {
        play = play.tap(0);
      }
      expect(play.moves, 14);
      expect(play.gaveUp, isFalse);
    });

    test('the mark stands watched', () {
      final mark = Play.standing(Levels.at(2), Play.aimFor(Levels.at(2)));
      expect(mark.isDone, isTrue);
    });
  });
}
