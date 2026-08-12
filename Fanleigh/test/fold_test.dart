import 'package:fanleigh/fold/folds.dart';
import 'package:fanleigh/fold/play.dart';
import 'package:fanleigh/fold/rules.dart';
import 'package:flutter_test/flutter_test.dart';

/// The law of the fold, held to.
void main() {
  group('the rules', () {
    test('hurdles cross when their posts interleave', () {
      expect(Rules.cross((0, 2), (1, 3)), isTrue);
      expect(Rules.cross((0, 2), (2, 4)), isFalse);
      expect(Rules.cross((0, 3), (1, 5)), isTrue);
      expect(Rules.cross((1, 3), (3, 5)), isFalse);
    });

    test('a full fencing folds into pens with crowns that add up',
        () {
      final six = Rules(6);
      const fan = [(0, 2), (0, 3), (0, 4)];
      expect(six.fenced(fan), isTrue);
      expect(six.pens(fan), hasLength(4));
      expect(six.crown(fan), [4, 1, 2, 2, 2, 1]);
      expect(six.ears(fan), [1, 5]);
    });

    test('Catalan counts the foldings', () {
      expect(Rules(5).foldings(), 5);
      expect(Rules(6).foldings(), 14);
    });

    test('the law holds over both paddocks', () {
      expect(Rules(5).lawHolds(), isTrue);
      expect(Rules(6).lawHolds(), isTrue);
    });

    test('every label\'s ways is what the sweep finds', () {
      for (final fold in Folds.all) {
        expect(Rules(fold.posts).waysTo(fold.lands), fold.ways,
            reason: fold.name);
      }
    });

    test('the zigzags are the three-eared foldings', () {
      final six = Rules(6);
      var threeEars = 0;
      six.fencings((hurdles) {
        if (six.ears(hurdles).length == 3) {
          threeEars++;
          expect(
            six
                .crown(hurdles)
                .every((pens) => pens == 1 || pens == 3),
            isTrue,
          );
        }
      });
      expect(threeEars, 2);
    });
  });

  group('the play', () {
    test('two picks lay a hurdle', () {
      var play = Play.of(Folds.at(0));
      play = play.tapAt(0);
      expect(play.picked, 0);
      play = play.tapAt(2);
      expect(play.hurdles, [(0, 2)]);
      expect(play.moves, 1);
    });

    test('rim neighbours refuse a hurdle', () {
      var play = Play.of(Folds.at(0)).tapAt(0);
      play = play.tapAt(1);
      expect(play.hurdles, isEmpty);
      expect(play.picked, isNull);
      expect(play.moves, 0);
    });

    test('the same two posts lift their hurdle', () {
      var play = Play.of(Folds.at(0)).tapAt(0).tapAt(2);
      play = play.tapAt(2).tapAt(0);
      expect(play.hurdles, isEmpty);
      expect(play.moves, 2);
    });

    test('the pentagon folds with any two clear hurdles', () {
      var play = Play.of(Folds.at(0));
      play = play.tapAt(0).tapAt(2);
      play = play.tapAt(0).tapAt(3);
      expect(play.fenced, isTrue);
      expect(play.isDone, isTrue);
      expect(play.ears, hasLength(2));
      expect(play.tapAt(1), same(play));
    });

    test('a crossing shows itself and blocks the fold', () {
      var play = Play.of(Folds.at(1));
      play = play.tapAt(0).tapAt(2);
      play = play.tapAt(1).tapAt(3);
      play = play.tapAt(0).tapAt(4);
      expect(play.crossings, isNotEmpty);
      expect(play.isDone, isFalse);
    });

    test('the fan lands when a post corners four pens', () {
      var play = Play.of(Folds.at(1));
      for (final hurdle in const [(0, 2), (0, 3), (0, 4)]) {
        play = play.tapAt(hurdle.$1).tapAt(hurdle.$2);
      }
      expect(play.crown[0], 4);
      expect(play.isDone, isTrue);
    });

    test('a fenced paddock missing the asking stays open', () {
      var play = Play.of(Folds.at(3));
      for (final hurdle in const [(0, 2), (0, 3), (0, 4)]) {
        play = play.tapAt(hurdle.$1).tapAt(hurdle.$2);
      }
      expect(play.fenced, isTrue);
      expect(play.isDone, isFalse);
    });

    test('back takes back a laying', () {
      var play = Play.of(Folds.at(0)).tapAt(0).tapAt(2);
      expect(play.back.hurdles, isEmpty);
      expect(play.back.moves, 0);
      expect(Play.of(Folds.at(0)).back.moves, 0);
    });

    test('show me folds the paddock home', () {
      var play = Play.of(Folds.at(3));
      var guard = 0;
      while (!play.isDone && guard++ < 12) {
        final aim = play.next;
        expect(aim, isNotNull);
        final ((a, b), lay) = aim!;
        expect(lay, isTrue);
        play = play.tapAt(a).tapAt(b);
      }
      expect(play.isDone, isTrue);
      expect(play.ears, hasLength(3));
    });

    test('the hopeless fold has nothing to point at', () {
      expect(Play.of(Folds.at(4)).next, isNull);
    });

    test('the hopeless fold admits it after twelve layings', () {
      var play = Play.of(Folds.at(4));
      for (var round = 0; round < 6; round++) {
        expect(play.gaveUp, isFalse);
        play = play.tapAt(0).tapAt(2);
        play = play.tapAt(0).tapAt(2);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.isDone, isFalse);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
    });

    test('a winnable fold never gives up', () {
      var play = Play.of(Folds.at(1));
      for (var round = 0; round < 6; round++) {
        play = play.tapAt(0).tapAt(2);
        play = play.tapAt(0).tapAt(2);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.gaveUp, isFalse);
    });
  });
}
