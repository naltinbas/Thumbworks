import 'package:flutter_test/flutter_test.dart';
import 'package:gapstile/gap/play.dart';
import 'package:gapstile/gap/rules.dart';
import 'package:gapstile/gap/stiles.dart';

/// The law of the hoop, held to.
void main() {
  group('the rules', () {
    test('pegs land at the stride\'s multiples, distinct and sorted',
        () {
      // 0, 4, 8, 12, 16, 20, 24 mod 11: 0, 4, 8, 1, 5, 9, 2.
      expect(Rules.spots(4, 11, 7), [0, 1, 2, 4, 5, 8, 9]);
      // A stride sharing a factor with the round lands pegs on pegs.
      expect(Rules.spots(2, 10, 9), [0, 2, 4, 6, 8]);
    });

    test('the needle shows three lengths and the sum law', () {
      // Gaps round the spots above: 1, 1, 2, 1, 3, 1, 2.
      final gaps = Rules.gaps(4, 11, 7);
      expect(gaps.reduce((a, b) => a + b), 11);
      final sizes = gaps.toSet().toList()..sort();
      expect(sizes, [1, 2, 3]);
      expect(sizes[2], sizes[0] + sizes[1]);
      expect(Rules.sizeCount(4, 11, 7), 3);
      expect(Rules.sumLawHolds(4, 11, 7), isTrue);
    });

    test('one peg leaves one gap, the whole hoop', () {
      expect(Rules.gaps(3, 7, 1), [7]);
      expect(Rules.sizeCount(3, 7, 1), 1);
    });

    test('every label\'s ways is what the sweep finds', () {
      for (final stile in Stiles.all) {
        expect(
          Rules.dialsThatGive(stile.pegs, stile.asked).length,
          stile.ways,
          reason: stile.name,
        );
      }
    });

    test('the needle is four over eleven and its mirror, alone', () {
      expect(Rules.dialsThatGive(7, 3), [(4, 11), (7, 11)]);
    });

    test('the whole sweep holds: never four, and the sum law', () {
      expect(Rules.lawHolds(), isTrue);
    });
  });

  group('the play', () {
    test('starts at one over two with no turns taken', () {
      final play = Play.of(Stiles.at(0));
      expect(play.stride, 1);
      expect(play.round, 2);
      expect(play.dials, 0);
      expect(play.isOver, isFalse);
    });

    test('the dial clamps: the stride stays inside the round', () {
      var play = Play.of(Stiles.at(0));
      // At a round of two the only stride is one.
      expect(play.strideBy(1), same(play));
      expect(play.strideBy(-1), same(play));
      expect(play.roundBy(-1), same(play));
      play = play.roundBy(1);
      expect(play.round, 3);
      expect(play.dials, 1);
      // Shrinking the round pulls the stride back inside it.
      play = play.roundBy(1).strideBy(1).strideBy(1);
      expect((play.stride, play.round), (3, 4));
      play = play.roundBy(-1);
      expect((play.stride, play.round), (2, 3));
    });

    test('back takes back one turn', () {
      final play = Play.of(Stiles.at(0)).roundBy(1).roundBy(1);
      expect(play.dials, 2);
      expect(play.back.dials, 1);
      expect(play.back.round, 3);
      expect(Play.of(Stiles.at(0)).back.dials, 0);
    });

    test('the even fence lands at one over five', () {
      var play = Play.of(Stiles.at(0));
      for (var turn = 0; turn < 3; turn++) {
        play = play.roundBy(1);
      }
      expect((play.stride, play.round), (1, 5));
      expect(play.allApart, isTrue);
      expect(play.sizeCount, 1);
      expect(play.isDone, isTrue);
      expect(play.isOver, isTrue);
      // A done play refuses further turns.
      expect(play.roundBy(1), same(play));
    });

    test('pegs on pegs is not apart and not done', () {
      final play = Play.standing(Stiles.at(1), 2, 10);
      expect(play.spots, [0, 2, 4, 6, 8]);
      expect(play.allApart, isFalse);
      expect(play.isDone, isFalse);
    });

    test('the needle stands done at four over eleven', () {
      final play = Play.standing(Stiles.at(3), 4, 11);
      expect(play.allApart, isTrue);
      expect(play.sizeCount, 3);
      expect(play.isDone, isTrue);
    });

    test('show me points a dial that lands the asking', () {
      final aim = Play.of(Stiles.at(3)).next;
      expect(aim, isNotNull);
      final (stride, round) = aim!;
      expect(Rules.sizeCount(stride, round, 7), 3);
      expect(Rules.spots(stride, round, 7).length, 7);
    });

    test('the hopeless stile has nothing to point at', () {
      expect(Play.of(Stiles.at(4)).next, isNull);
    });

    test('the hopeless stile admits it after twelve turns', () {
      var play = Play.of(Stiles.at(4));
      for (var turn = 0; turn < 10; turn++) {
        play = play.roundBy(1);
      }
      play = play.strideBy(1).strideBy(1);
      expect(play.dials, Play.gaveUpAt);
      expect(play.isDone, isFalse);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
    });

    test('a winnable stile never gives up', () {
      // The needle's road here lands nothing: a stride of one
      // never shows three lengths, and at a round of twelve the
      // strides of two and three drop pegs onto pegs.
      var play = Play.of(Stiles.at(3));
      for (var turn = 0; turn < 10; turn++) {
        play = play.roundBy(1);
      }
      play = play.strideBy(1).strideBy(1);
      expect(play.dials, Play.gaveUpAt);
      expect(play.isDone, isFalse);
      expect(play.gaveUp, isFalse);
      expect(play.isOver, isFalse);
    });
  });
}
