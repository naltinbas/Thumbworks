import 'package:flutter_test/flutter_test.dart';
import 'package:lotwick/ring/levels.dart';
import 'package:lotwick/ring/play.dart';
import 'package:lotwick/ring/rules.dart';

/// The ring itself: what a bid earns, and what the truth earns.
void main() {
  group('the ring', () {
    test('a tie goes to the rivals', () {
      expect(Rules.wins(5, 5), isFalse);
      expect(Rules.wins(6, 5), isTrue);
      expect(Rules.wins(4, 5), isFalse);
    });

    test('the sealed ring charges the second bid', () {
      expect(Rules.paidBy(Rules.sealed, 10, 12, 9), 1);
      expect(Rules.paidBy(Rules.sealed, 10, 12, 11), -1);
      expect(Rules.paidBy(Rules.sealed, 10, 8, 9), 0);
      expect(Rules.truthPays(Rules.sealed, 10, 9), 1);
    });

    test('the open ring charges the bid, so the truth earns nothing', () {
      expect(Rules.paidBy(Rules.open, 12, 11, 10), 1);
      expect(Rules.paidBy(Rules.open, 12, 12, 10), 0);
      for (var worth = 0; worth <= Rules.most; worth++) {
        for (var rival = 0; rival <= Rules.most; rival++) {
          expect(Rules.truthPays(Rules.open, worth, rival), 0);
        }
      }
    });
  });

  group('the two voices', () {
    test('agree on every setting the dials reach', () {
      for (final (worth, bid, rival) in Rules.settings()) {
        final ran = Rules.paidBy(Rules.sealed, worth, bid, rival) -
            Rules.truthPays(Rules.sealed, worth, rival);
        expect(ran, Rules.windowGap(worth, bid, rival),
            reason: '$worth, $bid, $rival');
      }
    });

    test('and the window never opens upward', () {
      for (final (worth, bid, rival) in Rules.settings()) {
        expect(Rules.windowGap(worth, bid, rival), lessThanOrEqualTo(0),
            reason: '$worth, $bid, $rival');
      }
    });

    test('the window is closed at its lower end', () {
      expect(Rules.windowGap(1, 0, 0), -1);
      expect(Rules.windowGap(1, 1, 0), 0);
      expect(Rules.windowGap(10, 12, 10), 0);
      expect(Rules.windowGap(10, 12, 11), -1);
    });

    test('shading pays in the open ring exactly when it wins under the worth',
        () {
      for (final (worth, bid, rival) in Rules.settings()) {
        final ran = Rules.paidBy(Rules.open, worth, bid, rival) -
            Rules.truthPays(Rules.open, worth, rival);
        expect(ran > 0, Rules.shadingPays(worth, bid, rival),
            reason: '$worth, $bid, $rival');
      }
    });

    test('no bid beats the truth in the sealed ring, on any setting', () {
      var beats = 0;
      for (final (worth, bid, rival) in Rules.settings()) {
        if (Rules.paidBy(Rules.sealed, worth, bid, rival) >
            Rules.truthPays(Rules.sealed, worth, rival)) {
          beats++;
        }
      }
      expect(beats, 0);
    });

    test('the dials reach 2,197 settings', () {
      expect(Rules.howManySettings, 2197);
      expect(Rules.settings().length, 2197);
    });
  });

  group('the asks', () {
    test('are landed by as many settings as the sweep counted', () {
      for (final level in Levels.all) {
        var n = 0;
        for (final (worth, bid, rival) in Rules.settings()) {
          if (level.meets(worth, bid, rival)) n++;
        }
        expect(n, level.ways, reason: level.name);
      }
    });

    test('name the cheapest setting that lands them', () {
      const opening = (Rules.openWorth, Rules.openBid, Rules.openRival);
      for (final level in Levels.all) {
        if (!level.winnable) {
          expect(level.aim, isNull, reason: level.name);
          continue;
        }
        final aim = level.aim!;
        expect(level.meets(aim.$1, aim.$2, aim.$3), isTrue,
            reason: level.name);
        for (final (worth, bid, rival) in Rules.settings()) {
          if (!level.meets(worth, bid, rival)) continue;
          expect(Rules.taps(opening, (worth, bid, rival)),
              greaterThanOrEqualTo(level.fewest!),
              reason: '$worth, $bid, $rival against ${level.name}');
        }
      }
    });

    test('the fewest taps each one takes', () {
      expect([for (final level in Levels.all) level.fewest], [1, 3, 4, 5, null]);
    });

    test('none of them is landed before a tap is taken', () {
      for (final level in Levels.all) {
        expect(
            level.meets(Rules.openWorth, Rules.openBid, Rules.openRival),
            isFalse,
            reason: level.name);
      }
    });
  });

  group('a go', () {
    test('opens on a bid over the worth that loses the beast anyway', () {
      final play = Play.of(Levels.at(0));
      expect((play.worth, play.bid, play.rival), (10, 12, 12));
      expect(play.takesIt, isFalse);
      expect(play.paid, 0);
      expect(play.truthPaid, 0);
      expect(play.moves, 0);
      expect(play.isDone, isFalse);
    });

    test('steps a dial and counts the tap', () {
      final play = Play.of(Levels.at(0)).step(2, -1);
      expect((play.worth, play.bid, play.rival), (10, 12, 11));
      expect(play.moves, 1);
      expect(play.takesIt, isTrue);
      expect(play.paid, -1);
      expect(play.truthPaid, 0);
      expect(play.isDone, isTrue);
    });

    test('refuses a step off the end of a dial', () {
      final play = Play.of(Levels.at(3));
      expect(identical(play.step(1, 1), play), isTrue);
      expect(identical(play.step(0, 0), play), isTrue);
      final low = Play.standing(Levels.at(3), 0, 0, 0);
      expect(identical(low.step(0, -1), low), isTrue);
    });

    test('back undoes the last tap', () {
      final play = Play.of(Levels.at(3)).step(0, 1).step(1, -1);
      expect((play.worth, play.bid, play.rival), (11, 11, 12));
      expect((play.back.worth, play.back.bid, play.back.rival), (11, 12, 12));
      expect(play.back.moves, 1);
      final opening = Play.of(Levels.at(3));
      expect(identical(opening.back, opening), isTrue);
    });

    test('the pointer lands every ask, in the fewest taps', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        while (!play.isDone) {
          final was = play.nearest!.$2;
          final aim = play.next!;
          play = play.step(aim.$1, aim.$2);
          expect(play.nearest!.$2, was - 1, reason: level.name);
        }
        expect(play.moves, level.fewest, reason: level.name);
        expect(play.next, isNull, reason: level.name);
      }
    });

    test('the pointer says which dial and which way', () {
      expect(Play.pointed((1, -1)), 'Put your bid down a crown.');
      expect(Play.pointed((0, 1)),
          'Put what the beast is worth to you up a crown.');
      expect(Play.pointed((2, 1)), 'Put the best bid against you up a crown.');
    });

    test('the hopeless ask admits it after four settings', () {
      var play = Play.of(Levels.all.last);
      expect(play.gaveUp, isFalse);
      for (final dial in [0, 1, 2, 0]) {
        play = play.step(dial, -1);
      }
      expect(play.seen.length, 4);
      expect(play.gaveUp, isTrue);
      expect(identical(play.step(1, -1), play), isTrue);
    });

    test('a winnable ask never gives up', () {
      var play = Play.of(Levels.at(3));
      for (var k = 0; k < 4; k++) {
        play = play.step(2, -1);
      }
      expect(play.gaveUp, isFalse);
      expect(play.seen, isEmpty);
    });

    test('the why names Vickrey and both rings', () {
      final words = whyWords(Play.of(Levels.all.last));
      expect(words, contains('William Vickrey published this in 1961'));
      expect(words, contains('Your own bid never sets the price'));
      expect(words, contains('Outbid the Truth'));
    });
  });
}
