import 'package:flutter_test/flutter_test.dart';
import 'package:starholme/round/play.dart';
import 'package:starholme/round/rules.dart';
import 'package:starholme/round/tours.dart';

/// The law of the star, held to.
void main() {
  group('the rules', () {
    test('every label\'s ways is what the sweep finds', () {
      for (final tour in Tours.all) {
        expect(Rules.waysTo(tour.posts), tour.ways,
            reason: tour.name);
      }
    });

    test('the census and the two-per-post law hold', () {
      expect(Rules.lawsHold(), isTrue);
    });

    test('the star holds no seven-round', () {
      expect(Rules.waysTo(7), 0);
    });

    test('fifteen lanes stand, three at every post', () {
      expect(Rules.lanes, hasLength(15));
      for (var post = 0; post < 10; post++) {
        expect(Rules.around(post), hasLength(3), reason: '$post');
      }
    });

    test('soundness reads a walk lane by lane', () {
      expect(Rules.sound([0, 1, 2, 3, 4]), isTrue);
      expect(Rules.sound([5, 7, 9, 6, 8]), isTrue);
      // The outer ring skips no post.
      expect(Rules.sound([0, 1, 3, 4, 2]), isFalse);
      expect(Rules.sound([0, 1]), isFalse);
    });

    test('the exemplar round is real at every length', () {
      for (final posts in [5, 6, 8, 9]) {
        final round = Rules.round(posts);
        expect(round, isNotNull, reason: '$posts');
        expect(Rules.sound(round!), isTrue);
        expect(round, hasLength(posts));
      }
      expect(Rules.round(10), isNull);
    });
  });

  group('the play', () {
    test('opens empty and unsettled on every tour', () {
      for (final tour in Tours.all) {
        final play = Play.of(tour);
        expect(play.walk, isEmpty, reason: tour.name);
        expect(play.isDone, isFalse, reason: tour.name);
        expect(play.isOver, isFalse, reason: tour.name);
      }
    });

    test('the walk holds to lanes and refuses revisits', () {
      var play = Play.of(Tours.at(0)).tapAt(0).tapAt(1);
      expect(play.walk, [0, 1]);
      // No lane from one to three.
      expect(play.tapAt(3), same(play));
      // No revisiting.
      expect(play.tapAt(0), same(play));
      expect(play.moves, 2);
    });

    test('the round closes only on its full walk', () {
      var play = Play.of(Tours.at(0));
      for (final post in [0, 1, 2, 3]) {
        play = play.tapAt(post);
      }
      expect(play.tapAt(0), same(play));
      play = play.tapAt(4);
      play = play.tapAt(0);
      expect(play.closed, isTrue);
      expect(play.isDone, isTrue);
      expect(play.moves, 6);
      expect(play.tapAt(7), same(play));
    });

    test('back opens a closed round, then unwinds it', () {
      var play = Play.of(Tours.at(0));
      for (final post in [0, 1, 2, 3, 4, 0]) {
        play = play.tapAt(post);
      }
      expect(play.isDone, isTrue);
      play = play.back;
      expect(play.closed, isFalse);
      expect(play.walk, hasLength(5));
      play = play.back;
      expect(play.walk, hasLength(4));
    });

    test('the pointer walks the nine round home', () {
      var play = Play.of(Tours.at(3));
      var guard = 0;
      while (!play.isDone && guard++ < 14) {
        play = play.tapAt(play.next!);
      }
      expect(play.isDone, isTrue);
      expect(play.walk, hasLength(9));
      expect(play.moves, 10);
    });

    test('the hopeless tour admits it at twenty-four moves', () {
      var play = Play.of(Tours.at(4));
      for (final post in [0, 1, 2, 3, 4]) {
        play = play.tapAt(post);
      }
      for (var dither = 0; dither < 19; dither++) {
        play = dither.isEven ? play.back : play.tapAt(4);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.isDone, isFalse);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.next, isNull);
    });

    test('a winnable tour never gives up', () {
      var play = Play.of(Tours.at(0)).tapAt(0);
      for (var dither = 0; dither < 23; dither++) {
        play = dither.isEven ? play.tapAt(1) : play.back;
      }
      expect(play.moves, 24);
      expect(play.gaveUp, isFalse);
      expect(play.isOver, isFalse);
    });

    test('the mark stands closed', () {
      final mark = Play.standing(Tours.at(3), Rules.round(9)!);
      expect(mark.isDone, isTrue);
    });
  });
}
