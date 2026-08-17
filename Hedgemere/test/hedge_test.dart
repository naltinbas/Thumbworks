import 'package:flutter_test/flutter_test.dart';
import 'package:hedgemere/hedge/levels.dart';
import 'package:hedgemere/hedge/play.dart';
import 'package:hedgemere/hedge/rules.dart';

/// The hedge itself: the peeling, the walking, and the asks.
void main() {
  group('the hedge', () {
    test('opens on two middle posts and two rounds', () {
      final play = Play.of(Levels.at(0));
      expect(play.hanging, [2, 3, 3, 4, 6]);
      expect(play.middle, [3, 4]);
      expect(play.rounds, 2);
      expect(play.longest, 5);
      expect(play.moves, 0);
      expect(play.isDone, isFalse);
    });

    test('the dials reach 720 hangings and no others', () {
      expect(Rules.howManyHangings, 720);
      expect(Rules.hangings().length, 720);
      expect(Rules.hangings().toSet().map((h) => h.join(',')).toSet().length,
          720);
      expect(Rules.validHanging([2, 3, 3, 4, 6]), isTrue);
      expect(Rules.validHanging([2, 3, 3, 4, 7]), isFalse);
      expect(Rules.validHanging([0, 3, 3, 4, 6]), isFalse);
      expect(Rules.validHanging([3, 3, 3, 4, 6]), isFalse);
    });

    test('every post but the first hangs off an earlier one', () {
      for (final hanging in Rules.hangings()) {
        for (final (a, b) in Rules.paths(hanging)) {
          expect(b, lessThan(a));
        }
        expect(Rules.paths(hanging).length, Rules.posts - 1);
      }
    });
  });

  group('the two voices', () {
    test('name the same middle on every hanging the dials reach', () {
      for (final hanging in Rules.hangings()) {
        expect(Rules.peel(hanging).$1, Rules.measure(hanging).$1,
            reason: Rules.tellHanging(hanging));
      }
    });

    test('leave one post standing or two, never three', () {
      for (final hanging in Rules.hangings()) {
        expect(Rules.middle(hanging).length, anyOf(1, 2),
            reason: Rules.tellHanging(hanging));
      }
    });

    test('agree that the rounds are half the longest walk, rounded down',
        () {
      for (final hanging in Rules.hangings()) {
        final (middle, rounds, _) = Rules.peel(hanging);
        final (_, radius, longest) = Rules.measure(hanging);
        expect(rounds, longest ~/ 2, reason: Rules.tellHanging(hanging));
        expect(radius, (longest + 1) ~/ 2);
        expect(middle.length == 1, longest.isEven);
      }
    });

    test('and the counts come out as the sweep found them', () {
      var one = 0, two = 0;
      final byRounds = <int, int>{};
      for (final hanging in Rules.hangings()) {
        final (middle, rounds, _) = Rules.peel(hanging);
        if (middle.length == 1) {
          one++;
        } else {
          two++;
        }
        byRounds[rounds] = (byRounds[rounds] ?? 0) + 1;
      }
      expect(one, 412);
      expect(two, 308);
      expect(byRounds, {1: 84, 2: 604, 3: 32});
    });

    test('the fallen posts are the ones not left standing', () {
      for (final hanging in [
        [2, 3, 3, 4, 6],
        [2, 3, 4, 5, 6],
        [2, 2, 2, 2, 2],
      ]) {
        final (middle, rounds, fell) = Rules.peel(hanging);
        for (var p = 1; p <= Rules.posts; p++) {
          expect(fell[p] == 0, middle.contains(p));
          expect(fell[p], lessThanOrEqualTo(rounds));
        }
      }
    });
  });

  group('the shapes the asks name', () {
    test('a line of seven takes three rounds and one middle post', () {
      expect(Rules.peel([2, 3, 4, 5, 6]).$1, [4]);
      expect(Rules.peel([2, 3, 4, 5, 6]).$2, 3);
      expect(Rules.longest([2, 3, 4, 5, 6]), 6);
    });

    test('a bush of six round one takes a single round', () {
      expect(Rules.peel([1, 1, 1, 1, 1]).$1, [1]);
      expect(Rules.peel([2, 2, 2, 2, 2]).$1, [2]);
      expect(Rules.peel([2, 2, 2, 2, 2]).$2, 1);
      expect(Rules.longest([2, 2, 2, 2, 2]), 2);
    });

    test('two middle posts come of an odd longest walk', () {
      expect(Rules.peel([2, 2, 2, 2, 6]).$1, [2, 6]);
      expect(Rules.longest([2, 2, 2, 2, 6]), 3);
    });
  });

  group('the asks', () {
    test('are landed by as many hangings as the sweep counted', () {
      for (final level in Levels.all) {
        var n = 0;
        for (final hanging in Rules.hangings()) {
          if (level.meets(hanging)) n++;
        }
        expect(n, level.ways, reason: level.name);
      }
    });

    test('name the cheapest hanging that lands them', () {
      for (final level in Levels.all) {
        if (!level.winnable) {
          expect(level.aim, isNull, reason: level.name);
          continue;
        }
        expect(level.meets(level.aim!), isTrue, reason: level.name);
        for (final hanging in Rules.hangings()) {
          if (!level.meets(hanging)) continue;
          expect(Rules.taps(Rules.opening, hanging),
              greaterThanOrEqualTo(level.fewest!),
              reason: '${Rules.tellHanging(hanging)} against ${level.name}');
        }
      }
    });

    test('the fewest taps each one takes', () {
      expect([for (final level in Levels.all) level.fewest],
          [1, 2, 4, 8, null]);
    });

    test('none of them is landed before a tap is taken', () {
      for (final level in Levels.all) {
        expect(level.meets(Rules.opening), isFalse, reason: level.name);
      }
    });
  });

  group('a go', () {
    test('steps a dial and counts the tap', () {
      final play = Play.of(Levels.at(0)).step(4, -1);
      expect(play.hanging, [2, 3, 3, 4, 5]);
      expect(play.moves, 1);
      expect(play.middle, [3]);
      expect(play.isDone, isTrue);
    });

    test('refuses a step that would leave the dial', () {
      final play = Play.of(Levels.at(3));
      expect(identical(play.step(4, 1), play), isTrue);
      expect(identical(play.step(0, 1), play), isTrue);
      expect(identical(play.step(0, 0), play), isTrue);
      final low = Play.standing(Levels.at(3), const [1, 1, 1, 1, 1]);
      expect(identical(low.step(2, -1), low), isTrue);
    });

    test('back undoes the last tap', () {
      final play = Play.of(Levels.at(3)).step(0, -1).step(1, -1);
      expect(play.hanging, [1, 2, 3, 4, 6]);
      expect(play.moves, 2);
      expect(play.back.hanging, [1, 3, 3, 4, 6]);
      expect(play.back.moves, 1);
      final opening = Play.of(Levels.at(3));
      expect(identical(opening.back, opening), isTrue);
    });

    test('the pointer walks to an aim and stops there', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        while (!play.isDone) {
          final aim = play.next!;
          play = play.step(aim.$1, aim.$2);
        }
        expect(play.moves, level.fewest, reason: level.name);
        expect(play.next, isNull, reason: level.name);
      }
    });

    test('the pointer never wanders further from an aim', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        while (!play.isDone) {
          final was = play.nearest!.$2;
          final aim = play.next!;
          play = play.step(aim.$1, aim.$2);
          expect(play.nearest!.$2, was - 1, reason: level.name);
        }
      }
    });

    test('the pointer says which post and which way', () {
      expect(Play.pointed((3, -1)), 'Hang post 6 off the post before.');
      expect(Play.pointed((0, 1)), 'Hang post 3 off the next post along.');
    });

    test('the hopeless ask admits it after four hedges', () {
      var play = Play.of(Levels.all.last);
      expect(play.gaveUp, isFalse);
      for (final dial in [0, 1, 2, 3]) {
        play = play.step(dial, -1);
      }
      expect(play.seen.length, 4);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(identical(play.step(4, -1), play), isTrue);
    });

    test('a winnable ask never gives up', () {
      var play = Play.of(Levels.at(3));
      for (var k = 0; k < 4; k++) {
        play = play.step(4, -1);
      }
      expect(play.gaveUp, isFalse);
      expect(play.seen, isEmpty);
    });

    test('the why names Jordan and the halfway mark', () {
      final words = whyWords(Play.of(Levels.all.last));
      expect(words, contains('Camille Jordan wrote this down in 1869'));
      expect(words, contains('no third place'));
      expect(words, contains('The Three Middles'));
    });
  });
}
