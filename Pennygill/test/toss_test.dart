import 'package:flutter_test/flutter_test.dart';
import 'package:pennygill/toss/call.dart';
import 'package:pennygill/toss/odds.dart';
import 'package:pennygill/toss/play.dart';
import 'package:pennygill/toss/wagers.dart';

void main() {
  group('the calls', () {
    test('say themselves and reply by the old rule', () {
      expect(const Call(7).said, 'HHH');
      expect(const Call(2).said, 'THT');
      expect(const Call(6).beatenBy.said, 'THH');
      expect(const Call(1).beatenBy.said, 'HTT');
      expect(Call.all.map((call) => call.said).toSet(), hasLength(8));
    });
  });

  group('the two reckonings', () {
    test('agree on every ordered pair of calls', () {
      // The anchor. Conway counts overlaps and reads them as binary; the
      // walk solves the flipping's little chain exactly. 56 pairs, no
      // parting anywhere.
      for (final one in Call.all) {
        for (final other in Call.all) {
          if (one == other) continue;
          expect(Odds.byConway(one, other), Odds.byWalk(one, other),
              reason: '$one vs $other');
        }
      }
    });

    test('the house reply beats every call there is', () {
      for (final call in Call.all) {
        final odds = Odds.byWalk(call, call.beatenBy);
        expect(odds.asDouble, greaterThan(0.5), reason: call.said);
      }
    });

    test('and the beatings run in a ring, which is the whole lesson', () {
      // HTT loses to HHT loses to THH loses to TTH loses to HTT: no call
      // is best, because better-than refuses to line up.
      const ring = [Call(4), Call(6), Call(3), Call(1)];
      for (var leg = 0; leg < ring.length; leg++) {
        final loser = ring[leg];
        final winner = ring[(leg + 1) % ring.length];
        expect(Odds.byWalk(loser, winner).asDouble, greaterThan(0.5),
            reason: '${loser.said} should lose to ${winner.said}');
      }
    });

    test('the three-head call is the worst, at seven in eight', () {
      expect(Odds.byWalk(const Call(7), const Call(7).beatenBy),
          Ratio.of(7, 8));
      expect(Odds.byWalk(const Call(0), const Call(0).beatenBy),
          Ratio.of(7, 8));
    });

    test('the turned-over reply is exactly even, every call', () {
      for (final call in Call.all) {
        expect(Odds.byWalk(call, Call(call.flips ^ 7)), Ratio.of(1, 2),
            reason: call.said);
      }
    });
  });

  group('a match at a table', () {
    test('your call brings the house reply on its heels', () {
      final play = Play.of(Wagers.at(0)).call(const Call(6));
      expect(play.yours!.said, 'HHT');
      expect(play.theirs!.said, 'THH');
      expect(play.theirChance, Ratio.of(3, 4));
    });

    test('the even table answers with your opposite', () {
      final play = Play.of(Wagers.at(4)).call(const Call(6));
      expect(play.theirs!.said, 'TTH');
      expect(play.theirChance, Ratio.of(1, 2));
    });

    test('the turned table has called already, and the reply is known', () {
      final play = Play.of(Wagers.at(3));
      expect(play.theirs!.said, 'HTH');
      expect(play.beatingReply!.said, 'HHT');
      final replied = play.call(play.beatingReply!);
      expect(replied.theirChance!.asDouble, lessThan(0.5));
    });

    test('the flips find whoever\'s call shows, and score the round', () {
      var play = Play.of(Wagers.at(0)).call(const Call(6));
      // HHT: heads, heads, tails shows your call.
      play = play.flip(true).flip(true).flip(false);
      expect(play.shownBy, play.yours);
      expect(play.yourRounds, 1);
      expect(play.roundOver, isTrue);
      expect(play.isOver, isTrue);
      expect(play.won, isTrue);
    });

    test('the house\'s call ends rounds too, and the match at the stakes',
        () {
      var play = Play.of(Wagers.at(1)).call(const Call(6));
      for (var round = 0; round < 3; round++) {
        play = play.flip(false).flip(true).flip(true);
        expect(play.shownBy, play.theirs, reason: 'round $round');
        expect(play.theirRounds, round + 1);
        if (round < 2) {
          play = play.nextRound;
          expect(play.flips, isEmpty);
        }
      }
      expect(play.isOver, isTrue);
      expect(play.won, isFalse);
    });

    test('a long round settles eventually all the same', () {
      var play = Play.of(Wagers.at(0)).call(const Call(6));
      // Tails forever build nothing for HHT, then the house's THH shows.
      play = play
          .flip(false)
          .flip(false)
          .flip(false)
          .flip(true)
          .flip(true);
      expect(play.shownBy, play.theirs);
      expect(play.theirRounds, 1);
    });

    test('no flip lands before the calls or after the match', () {
      final uncalled = Play.of(Wagers.at(0));
      expect(identical(uncalled.flip(true), uncalled), isTrue);
      var play = Play.of(Wagers.at(0)).call(const Call(6));
      play = play.flip(true).flip(true).flip(false);
      expect(identical(play.flip(true), play), isTrue);
    });
  });
}
