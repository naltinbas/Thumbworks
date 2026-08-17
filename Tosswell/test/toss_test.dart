import 'package:flutter_test/flutter_test.dart';
import 'package:tosswell/toss/levels.dart';
import 'package:tosswell/toss/play.dart';
import 'package:tosswell/toss/rules.dart';

/// The wager itself: the runs, the rules and the averaging.
void main() {
  /// The purse added over every run through a standing, folded back
  /// from the last row rather than walked.
  int folded(Set<String> stop, int toss, int purse) {
    if (toss == Rules.tosses || stop.contains(Rules.mark((toss, purse)))) {
      return purse * (1 << (Rules.tosses - toss));
    }
    return folded(stop, toss + 1, purse + 1) + folded(stop, toss + 1, purse - 1);
  }

  group('the coin', () {
    test('has 32 runs and 15 standings to mark', () {
      expect(Rules.runs, 32);
      expect(Rules.standings().length, 15);
      expect(Rules.howManyStandings, 15);
      expect(Rules.reachable((3, 1)), isTrue);
      expect(Rules.reachable((3, 2)), isFalse);
      expect(Rules.reachable((3, 5)), isFalse);
    });

    test('with nothing marked every run runs to the last toss', () {
      final ends = Rules.ends(const {});
      expect(ends.length, 32);
      expect(ends.toSet(), {5, 3, 1, -1, -3, -5});
      expect(Rules.added(ends), 0);
      expect(Rules.aheadIn(ends), 16);
    });

    test('the rule that walks after the first toss', () {
      final stop = {Rules.mark((1, 1)), Rules.mark((1, -1))};
      final ends = Rules.ends(stop);
      expect(ends.toSet(), {1, -1});
      expect(Rules.added(ends), 0);
      expect(Rules.aheadIn(ends), 16);
      expect(Rules.ending(stop), {'1,1': 16, '1,-1': 16});
    });

    test('a standing behind a mark cannot be reached', () {
      final stop = {Rules.mark((0, 0))};
      expect(Rules.alive(stop, (0, 0)), isTrue);
      expect(Rules.alive(stop, (1, 1)), isFalse);
      expect(Rules.alive(const {}, (4, -4)), isTrue);
    });
  });

  group('the two voices', () {
    test('agree on every marking, and every one averages nothing', () {
      final standings = Rules.standings();
      for (var mask = 0; mask < 1 << standings.length; mask++) {
        final stop = <String>{
          for (var i = 0; i < standings.length; i++)
            if (mask >> i & 1 == 1) Rules.mark(standings[i]),
        };
        final walked = Rules.added(Rules.ends(stop));
        expect(walked, folded(stop, 0, 0), reason: '$stop');
        expect(walked, 0, reason: '$stop');
      }
    });

    test('every standing folds to just what it holds', () {
      for (final stop in [
        const <String>{},
        {Rules.mark((1, 1))},
        {Rules.mark((1, 1)), Rules.mark((3, 1))},
        {Rules.mark((2, 0)), Rules.mark((4, -2))},
      ]) {
        for (final at in Rules.standings()) {
          expect(folded(stop, at.$1, at.$2),
              at.$2 * (1 << (Rules.tosses - at.$1)),
              reason: '$at under $stop');
        }
      }
    });

    test('802 rules differ in what they do, and none is ahead past 22', () {
      final standings = Rules.standings();
      final seen = <String, int>{};
      for (var mask = 0; mask < 1 << standings.length; mask++) {
        final stop = <String>{
          for (var i = 0; i < standings.length; i++)
            if (mask >> i & 1 == 1) Rules.mark(standings[i]),
        };
        final ends = Rules.ends(stop);
        final key = ends.join(',');
        final marks = stop.length;
        if (!seen.containsKey(key) || marks < seen[key]!) seen[key] = marks;
        expect(Rules.aheadIn(ends), lessThanOrEqualTo(22));
      }
      expect(seen.length, 802);
    });
  });

  group('the asks', () {
    test('are landed by as many rules as the sweep counted', () {
      final standings = Rules.standings();
      final best = <String, Set<String>>{};
      final marks = <String, int>{};
      for (var mask = 0; mask < 1 << standings.length; mask++) {
        final stop = <String>{
          for (var i = 0; i < standings.length; i++)
            if (mask >> i & 1 == 1) Rules.mark(standings[i]),
        };
        final key = Rules.ends(stop).join(',');
        if (!best.containsKey(key) || stop.length < marks[key]!) {
          best[key] = stop;
          marks[key] = stop.length;
        }
      }
      for (final level in Levels.all) {
        var n = 0, cheapest = 99;
        for (final entry in best.entries) {
          if (!level.meets(entry.value)) continue;
          n++;
          if (marks[entry.key]! < cheapest) cheapest = marks[entry.key]!;
        }
        expect(n, level.ways, reason: level.name);
        if (level.winnable) {
          expect(level.fewest, cheapest, reason: level.name);
          expect(level.meets(level.aimMarks), isTrue, reason: level.name);
        }
      }
    });

    test('the fewest marks each one takes', () {
      expect([for (final level in Levels.all) level.fewest], [1, 2, 2, 3, null]);
    });

    test('none of them is landed before a mark is made', () {
      for (final level in Levels.all) {
        expect(level.meets(const {}), isFalse, reason: level.name);
      }
    });
  });

  group('a go', () {
    test('opens with nothing marked', () {
      final play = Play.of(Levels.at(0));
      expect(play.stop, isEmpty);
      expect(play.added, 0);
      expect(play.ahead, 16);
      expect(play.worst, -5);
      expect(play.best, 5);
      expect(play.moves, 0);
      expect(play.isDone, isFalse);
    });

    test('a mark stops the runs that reach it', () {
      final play = Play.of(Levels.at(0)).tap((1, 1));
      expect(play.marked((1, 1)), isTrue);
      expect(play.moves, 1);
      expect(play.ahead, 21);
      expect(play.added, 0);
      expect(play.isDone, isTrue);
    });

    test('a mark can be taken off again', () {
      final play = Play.of(Levels.at(3)).tap((1, 1)).tap((1, 1));
      expect(play.stop, isEmpty);
      expect(play.moves, 2);
    });

    test('a standing no run reaches cannot be marked', () {
      final play = Play.of(Levels.at(3)).tap((0, 0));
      expect(play.marked((0, 0)), isTrue);
      expect(identical(play.tap((1, 1)), play), isTrue);
      expect(identical(play.tap((3, 2)), play), isTrue);
      expect(identical(play.tap((5, 1)), play), isTrue);
    });

    test('back undoes the last mark', () {
      final play = Play.of(Levels.at(3)).tap((1, 1)).tap((2, -2));
      expect(play.moves, 2);
      expect(play.back.stop, {Rules.mark((1, 1))});
      expect(play.back.moves, 1);
      final opening = Play.of(Levels.at(3));
      expect(identical(opening.back, opening), isTrue);
    });

    test('the pointer lands every ask, in the fewest marks', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        expect(play.toGo!.$1, level.fewest, reason: level.name);
        while (!play.isDone) {
          final was = play.toGo!.$1;
          play = play.tap(play.next!);
          expect(play.isDone || play.toGo!.$1 == was - 1, isTrue,
              reason: level.name);
        }
        expect(play.moves, level.fewest, reason: level.name);
        expect(play.next, isNull, reason: level.name);
      }
    });

    test('the pointer says which standing to mark', () {
      expect(Play.pointed((1, 1)),
          'Mark the standing after 1 toss at 1 up.');
      expect(Play.pointed((4, -2)),
          'Mark the standing after 4 tosses at 2 down.');
      expect(Play.pointed((2, 0)),
          'Mark the standing after 2 tosses at level.');
    });

    test('the hopeless ask admits it after four rules', () {
      var play = Play.of(Levels.all.last);
      expect(play.gaveUp, isFalse);
      for (final at in [(4, 4), (4, 2), (4, 0), (4, -2)]) {
        play = play.tap(at);
      }
      expect(play.seen.length, 4);
      expect(play.gaveUp, isTrue);
      expect(play.added, 0);
      expect(identical(play.tap((4, -4)), play), isTrue);
    });

    test('a winnable ask never gives up', () {
      var play = Play.of(Levels.at(3));
      for (final at in [(4, 4), (4, 2), (4, 0), (4, -2)]) {
        play = play.tap(at);
      }
      expect(play.gaveUp, isFalse);
      expect(play.seen, isEmpty);
    });

    test('the why names Doob and the folding back', () {
      final words = whyWords(Play.of(Levels.all.last));
      expect(words, contains("Doob's optional stopping theorem"));
      expect(words, contains('the standing is worth exactly what it holds'));
      expect(words, contains('The Sure Thing'));
    });
  });
}
