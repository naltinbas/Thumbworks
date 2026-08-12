import 'package:flutter_test/flutter_test.dart';
import 'package:pigeonwick/post/play.dart';
import 'package:pigeonwick/post/rounds.dart';
import 'package:pigeonwick/post/rules.dart';

/// The law of the round, held to.
void main() {
  group('the rules', () {
    test('homes are the letters in their own holes', () {
      expect(Rules.homes([0, 2, 1]), [0]);
      expect(Rules.homes([1, 2, 0]), isEmpty);
      expect(Rules.homes([0, 1, 2]), [0, 1, 2]);
    });

    test('the three voices agree at every size', () {
      for (final letters in [3, 4, 5]) {
        final swept = Rules(letters).waysTo(0);
        expect(swept, Rules.deranged(letters), reason: '$letters');
        expect(swept, Rules.byE(letters), reason: '$letters');
      }
    });

    test('every label\'s ways is what the sweep finds', () {
      for (final round in Rounds.all) {
        expect(Rules(round.letters).waysTo(round.home), round.ways,
            reason: round.name);
      }
    });

    test('the spread of four runs nine, eight, six, none, one', () {
      final four = Rules(4);
      expect(
        [for (final home in [0, 1, 2, 3, 4]) four.waysTo(home)],
        [9, 8, 6, 0, 1],
      );
    });

    test('one shy of all home is nobody\'s round at any size', () {
      for (final letters in [3, 4, 5]) {
        expect(Rules(letters).waysTo(letters - 1), 0,
            reason: '$letters');
      }
    });

    test('a round lands what it promises', () {
      final found = Rules(4).round(0)!;
      expect(Rules.homes(found), isEmpty);
      expect(Rules(4).round(3), isNull);
    });
  });

  group('the play', () {
    test('a letter posts to a hole and counts', () {
      var play = Play.of(Rounds.at(0));
      play = play.tapLetter(0).tapHole(1);
      expect(play.posting[0], 1);
      expect(play.moves, 1);
      expect(play.held, isNull);
    });

    test('tapping a full hole with empty hands pulls the letter back',
        () {
      var play = Play.of(Rounds.at(0)).tapLetter(0).tapHole(1);
      play = play.tapHole(1);
      expect(play.posting[0], -1);
      expect(play.moves, 2);
    });

    test('posting onto a full hole swaps the sitter out', () {
      var play = Play.of(Rounds.at(0)).tapLetter(0).tapHole(1);
      play = play.tapLetter(1).tapHole(1);
      expect(play.posting[1], 1);
      expect(play.posting[0], -1);
    });

    test('the two away lands on a full turn', () {
      var play = Play.of(Rounds.at(0));
      for (final (letter, hole) in const [(0, 1), (1, 2), (2, 0)]) {
        play = play.tapLetter(letter).tapHole(hole);
      }
      expect(play.homes, isEmpty);
      expect(play.isDone, isTrue);
      expect(play.tapLetter(0), same(play));
    });

    test('the one home needs its single sitter', () {
      var play = Play.of(Rounds.at(3));
      for (final (letter, hole) in const [
        (0, 0), (1, 2), (2, 3), (3, 1),
      ]) {
        play = play.tapLetter(letter).tapHole(hole);
      }
      expect(play.homes, [0]);
      expect(play.isDone, isTrue);
    });

    test('back takes back a posting', () {
      var play = Play.of(Rounds.at(0)).tapLetter(0).tapHole(1);
      expect(play.back.posting[0], -1);
      expect(play.back.moves, 0);
      expect(Play.of(Rounds.at(0)).back.moves, 0);
    });

    test('show me posts a real round home', () {
      var play = Play.of(Rounds.at(2));
      var guard = 0;
      while (!play.isDone && guard++ < 12) {
        final aim = play.next;
        expect(aim, isNotNull);
        final (letter, hole) = aim!;
        play = play.tapLetter(letter).tapHole(hole);
      }
      expect(play.isDone, isTrue);
      expect(play.homes, isEmpty);
    });

    test('the hopeless round has nothing to point at', () {
      expect(Play.of(Rounds.at(4)).next, isNull);
    });

    test('the hopeless round admits it after twelve postings', () {
      var play = Play.of(Rounds.at(4));
      for (var posting = 0; posting < Play.gaveUpAt; posting++) {
        expect(play.gaveUp, isFalse);
        play = posting.isEven
            ? play.tapLetter(0).tapHole(1)
            : play.tapHole(1);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.isDone, isFalse);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
    });

    test('a winnable round never gives up', () {
      var play = Play.of(Rounds.at(1));
      for (var posting = 0; posting < Play.gaveUpAt; posting++) {
        play = posting.isEven
            ? play.tapLetter(0).tapHole(1)
            : play.tapHole(1);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.gaveUp, isFalse);
    });
  });
}
