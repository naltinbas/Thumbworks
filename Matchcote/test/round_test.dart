import 'package:flutter_test/flutter_test.dart';
import 'package:matchcote/round/cotes.dart';
import 'package:matchcote/round/play.dart';
import 'package:matchcote/round/rules.dart';

/// The law of the cote, held to.
void main() {
  group('the rules', () {
    test('pairings fill a round or nothing', () {
      final four = Rules(4);
      expect(four.pairings([0, 1, 2, 3], {}), hasLength(3));
      expect(Rules(5).pairings([0, 1, 2, 3, 4], {}), isEmpty);
    });

    test('every label\'s ways is what the sweep finds', () {
      for (final cote in Cotes.all) {
        expect(Rules(cote.players).fixtures(cote.given),
            cote.ways,
            reason: cote.name);
      }
    });

    test('the 720 is six schedules times their orderings', () {
      expect(Rules(6).fixtures(const []), 6 * 120);
    });

    test('a found fixture covers cleanly', () {
      final one = Rules(6).fixture(const [])!;
      expect(Rules(6).covers(one), isTrue);
      expect(Rules(5).fixture(const []), isNull);
    });
  });

  group('the play', () {
    test('two picks pair into the filling round', () {
      var play = Play.of(Cotes.at(0));
      play = play.tapAt(0);
      expect(play.picked, 0);
      play = play.tapAt(1);
      expect(play.filling, [(0, 1)]);
      expect(play.moves, 1);
    });

    test('a stood player and a used pair are refused', () {
      var play = Play.of(Cotes.at(0)).tapAt(0).tapAt(1);
      // Player 0 stands in the filling round.
      final refused = play.tapAt(0).tapAt(2);
      expect(refused.filling, play.filling);
      expect(refused.moves, play.moves);
      // Fill the round, then try to reuse the pair.
      play = play.tapAt(2).tapAt(3);
      final reused = play.tapAt(0).tapAt(1);
      expect(reused.moves, play.moves);
    });

    test('the same two players unpair from the filling round', () {
      var play = Play.of(Cotes.at(0)).tapAt(0).tapAt(1);
      play = play.tapAt(0).tapAt(1);
      expect(play.filling, isEmpty);
      expect(play.moves, 2);
    });

    test('the four fixes over three rounds', () {
      var play = Play.of(Cotes.at(0));
      for (final round in const [
        [(0, 1), (2, 3)],
        [(0, 2), (1, 3)],
        [(0, 3), (1, 2)],
      ]) {
        for (final pair in round) {
          play = play.tapAt(pair.$1).tapAt(pair.$2);
        }
      }
      expect(play.isDone, isTrue);
      expect(play.tapAt(0), same(play));
    });

    test('given rounds stand and count toward the cover', () {
      final play = Play.of(Cotes.at(1));
      expect(play.rounds, hasLength(1));
      expect(play.used, hasLength(3));
      expect(play.isDone, isFalse);
    });

    test('back takes back the last pairing', () {
      var play = Play.of(Cotes.at(0)).tapAt(0).tapAt(1);
      expect(play.back.filling, isEmpty);
      expect(Play.of(Cotes.at(0)).back.moves, 0);
    });

    test('show me pairs the cote home', () {
      var play = Play.of(Cotes.at(2));
      var guard = 0;
      while (!play.isDone && guard++ < 20) {
        final aim = play.next;
        expect(aim, isNotNull);
        play = play.tapAt(aim!.$1).tapAt(aim.$2);
      }
      expect(play.isDone, isTrue);
    });

    test('the hopeless cote has nothing to point at', () {
      expect(Play.of(Cotes.at(4)).next, isNull);
    });

    test('the hopeless cote admits it after eight pairings', () {
      var play = Play.of(Cotes.at(4));
      for (var round = 0; round < 4; round++) {
        expect(play.gaveUp, isFalse);
        play = play.tapAt(0).tapAt(1);
        play = play.tapAt(0).tapAt(1);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.isDone, isFalse);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
    });

    test('a winnable cote never gives up', () {
      var play = Play.of(Cotes.at(3));
      for (var round = 0; round < 4; round++) {
        play = play.tapAt(0).tapAt(1);
        play = play.tapAt(0).tapAt(1);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.gaveUp, isFalse);
    });
  });
}
