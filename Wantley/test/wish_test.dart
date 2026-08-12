import 'package:flutter_test/flutter_test.dart';
import 'package:wantley/wish/play.dart';
import 'package:wantley/wish/rules.dart';
import 'package:wantley/wish/wishes.dart';

/// The law of the lists, held to.
void main() {
  group('the rules', () {
    test('every label\'s ways is what the sweep finds', () {
      for (final wish in Wishes.all) {
        expect(
          Rules(wish.farms).waysTo(wish.wishes),
          wish.ways,
          reason: wish.name,
        );
      }
    });

    test('the three voices agree over every wish list', () {
      expect(Rules(4).voicesAgree(), isTrue);
      expect(Rules(5).voicesAgree(), isTrue);
    });

    test('counts read the treading, farm by farm', () {
      final rules = Rules(4);
      // Paths 0-1 and 2-3: the pairs list starts (0,1) and
      // ends (2,3) on four farms.
      final trodden = List.filled(6, false);
      trodden[0] = true;
      trodden[5] = true;
      expect(rules.counts(trodden), [1, 1, 1, 1]);
    });

    test('the arithmetic speaks without searching', () {
      expect(Rules.arithmeticSays([1, 1, 1, 1]), isTrue);
      expect(Rules.arithmeticSays([3, 3, 3, 1]), isFalse);
      // An odd sum dies at once.
      expect(Rules.arithmeticSays([2, 1, 1, 1]), isFalse);
      // Erdos and Gallai past parity: 4,4,1,1,0 sums even.
      expect(Rules.arithmeticSays([4, 4, 1, 1, 0]), isFalse);
    });

    test('the build lands what can land and dies on what cannot',
        () {
      final built = Rules(5).build([4, 4, 3, 3, 2]);
      expect(built, isNotNull);
      expect(built, hasLength(8));
      expect(Rules(4).build([3, 3, 3, 1]), isNull);
    });
  });

  group('the play', () {
    test('opens bare and unsettled on every list', () {
      for (final wish in Wishes.all) {
        final play = Play.of(wish);
        expect(play.paths, 0, reason: wish.name);
        expect(play.isDone, isFalse, reason: wish.name);
        expect(play.isOver, isFalse, reason: wish.name);
      }
    });

    test('a tap treads and a second lifts, both counted', () {
      var play = Play.of(Wishes.at(4));
      play = play.flipAt(0);
      expect(play.trodden[0], isTrue);
      expect(play.paths, 1);
      expect(play.moves, 1);
      play = play.flipAt(0);
      expect(play.trodden[0], isFalse);
      expect(play.moves, 2);
    });

    test('back takes back one tread', () {
      final play = Play.of(Wishes.at(4)).flipAt(1).flipAt(3);
      expect(play.back.moves, 1);
      expect(play.back.trodden[3], isFalse);
      expect(play.back.back.back, same(play.back.back));
    });

    test('the four ones land on two matched paths', () {
      // Pairs of four farms: (0,1) is 0 and (2,3) is 5.
      var play = Play.of(Wishes.at(0));
      play = play.flipAt(0).flipAt(5);
      expect(play.isDone, isTrue);
      expect(play.isOver, isTrue);
      expect(play.moves, 2);
      // A landed list refuses further taps.
      expect(play.flipAt(2), same(play));
    });

    test('the pointer lands the one way in eight treads', () {
      var play = Play.of(Wishes.at(3));
      var guard = 0;
      while (!play.isDone && guard++ < 10) {
        play = play.flipAt(play.next!);
      }
      expect(play.isDone, isTrue);
      expect(play.paths, 8);
      expect(play.moves, 8);
    });

    test('the pointer lifts a stray path first', () {
      // Tread a path the one way does without: 3-4 is the last
      // pair of five farms.
      var play = Play.of(Wishes.at(3));
      play = play.flipAt(play.rules.pairs.length - 1);
      final pointed = play.next;
      expect(pointed, play.rules.pairs.length - 1);
    });

    test('the hopeless list admits it at twelve moves', () {
      var play = Play.of(Wishes.at(4));
      for (var dither = 0; dither < 12; dither++) {
        play = play.flipAt(dither % 2);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.isDone, isFalse);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.next, isNull);
    });

    test('a winnable list never gives up', () {
      var play = Play.of(Wishes.at(1));
      for (var dither = 0; dither < 12; dither++) {
        play = play.flipAt(dither % 2);
      }
      expect(play.moves, 12);
      expect(play.gaveUp, isFalse);
      expect(play.isOver, isFalse);
    });

    test('the mark stands landed', () {
      final mark = Play.standing(
        Wishes.at(3),
        Rules(5).build(Wishes.at(3).wishes)!,
      );
      expect(mark.isDone, isTrue);
      expect(mark.paths, 8);
    });
  });
}
