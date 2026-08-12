import 'package:acreford/acre/fields.dart';
import 'package:acreford/acre/play.dart';
import 'package:acreford/acre/rules.dart';
import 'package:flutter_test/flutter_test.dart';

/// The law of the field, held to.
void main() {
  const unitSquare = [(0, 0), (1, 0), (1, 1), (0, 1)];
  const bigSquare = [(0, 0), (3, 0), (3, 3), (0, 3)];

  group('the rules', () {
    test('every label\'s ways is what the sweep finds', () {
      for (final field in Fields.all) {
        expect(
          Rules.waysTo(
            field.posts,
            twoA: field.twoA,
            inside: field.inside,
            midRail: field.midRail,
          ),
          field.ways,
          reason: field.name,
        );
      }
    });

    test('the sweep sizes stand where they were pinned', () {
      var tris = 0, quads = 0;
      Rules.paddocks(3, (_) => tris++);
      Rules.paddocks(4, (_) => quads++);
      expect(tris, 516);
      expect(quads, 1758);
    });

    test('the two counts on paddocks small and large', () {
      expect(Rules.twiceAcres(unitSquare), 2);
      expect(Rules.rimPosts(unitSquare), 4);
      expect(Rules.insidePosts(unitSquare), 0);
      expect(Rules.twiceAcresByPick(unitSquare), 2);
      // The whole field: four inside, twelve on the rim.
      expect(Rules.twiceAcres(bigSquare), 18);
      expect(Rules.rimPosts(bigSquare), 12);
      expect(Rules.insidePosts(bigSquare), 4);
      expect(Rules.twiceAcresByPick(bigSquare), 18);
    });

    test('a rail runs over a post and the rim counts it', () {
      const tri = [(0, 0), (2, 0), (1, 1)];
      expect(Rules.rimPosts(tri), 4);
      expect(Rules.midRailPosts(tri), 1);
      expect(Rules.twiceAcres(tri), 2);
      expect(Rules.insidePosts(tri), 0);
    });

    test('Pick holds on every paddock of the sweep', () {
      expect(Rules.pickHolds(3), isTrue);
      expect(Rules.pickHolds(4), isTrue);
    });

    test('soundness: no crossing, no straight-through, no revisit',
        () {
      expect(Rules.sound(unitSquare), isTrue);
      // The bowtie crosses itself.
      expect(Rules.sound(const [(0, 0), (1, 1), (1, 0), (0, 1)]),
          isFalse);
      // A walked post must be a bend.
      expect(Rules.sound(const [(0, 0), (1, 0), (2, 0)]), isFalse);
      expect(
          Rules.sound(const [(0, 0), (1, 0), (2, 0), (1, 1)]), isFalse);
      // No post walked twice.
      expect(Rules.sound(const [(0, 0), (1, 0), (0, 0), (0, 1)]),
          isFalse);
    });

    test('an open chain refuses a crossing rail', () {
      expect(Rules.chainSound(const [(0, 0), (1, 1), (1, 0)]), isTrue);
      expect(
        Rules.chainSound(const [(0, 0), (1, 1), (1, 0), (0, 1)]),
        isFalse,
      );
      expect(Rules.chainSound(const [(0, 0), (1, 0), (2, 0)]), isFalse);
    });

    test('only three posts hold the half acre', () {
      expect(Rules.waysTo(4, twoA: 1), 0);
    });

    test('the bare rim writes the five even counts alone', () {
      final bare = <int>{};
      Rules.paddocks(4, (walk) {
        if (Rules.midRailPosts(walk) == 0) {
          bare.add(Rules.twiceAcres(walk));
        }
      });
      expect(bare.toList()..sort(), [2, 4, 6, 8, 10]);
    });

    test('two and a half acres rims five or seven, never even', () {
      final rims = <int>{};
      Rules.paddocks(4, (walk) {
        if (Rules.twiceAcres(walk) == 5) {
          rims.add(Rules.rimPosts(walk));
        }
      });
      expect(rims.toList()..sort(), [5, 7]);
    });

    test('a paddock to an asking is real and lands it', () {
      final walk = Rules.paddock(4, twoA: 5, inside: 1);
      expect(walk, isNotNull);
      expect(Rules.sound(walk!), isTrue);
      expect(Rules.twiceAcres(walk), 5);
      expect(Rules.insidePosts(walk), 1);
      expect(Rules.paddock(4, twoA: 5, midRail: false), isNull);
    });
  });

  group('the play', () {
    test('opens empty and unsettled on every field', () {
      for (final field in Fields.all) {
        final play = Play.of(field);
        expect(play.walk, isEmpty, reason: field.name);
        expect(play.isDone, isFalse, reason: field.name);
        expect(play.isOver, isFalse, reason: field.name);
      }
    });

    test('the fence walks post to post and counts the moves', () {
      var play = Play.of(Fields.at(0));
      play = play.tapAt((0, 0)).tapAt((1, 0));
      expect(play.walk, [(0, 0), (1, 0)]);
      expect(play.moves, 2);
      expect(play.rimSoFar, 2);
      // A walked post refuses a second walk.
      expect(play.tapAt((1, 0)), same(play));
      // A rail with no bend at the shared post refuses.
      expect(play.tapAt((2, 0)), same(play));
    });

    test('a crossing rail is refused', () {
      final play =
          Play.of(Fields.at(1)).tapAt((0, 0)).tapAt((1, 1)).tapAt((1, 0));
      expect(play.tapAt((0, 1)), same(play));
    });

    test('the fence closes only on its full walk', () {
      var play = Play.of(Fields.at(0)).tapAt((0, 0)).tapAt((1, 0));
      // Two posts cannot close.
      expect(play.tapAt((0, 0)), same(play));
      play = play.tapAt((0, 1));
      play = play.tapAt((0, 0));
      expect(play.closed, isTrue);
      expect(play.isDone, isTrue);
      expect(play.twoA, 1);
      expect(play.twoAByPick, 1);
      expect(play.moves, 4);
      // A landed field refuses further taps.
      expect(play.tapAt((2, 2)), same(play));
    });

    test('back opens a closed fence, then unwinds it', () {
      var play = Play.of(Fields.at(1))
          .tapAt((0, 0))
          .tapAt((1, 0))
          .tapAt((1, 1))
          .tapAt((0, 1))
          .tapAt((0, 0));
      expect(play.closed, isTrue);
      play = play.back;
      expect(play.closed, isFalse);
      expect(play.walk, hasLength(4));
      play = play.back;
      expect(play.walk, hasLength(3));
      expect(play.moves, 7);
    });

    test('closed off the asking is not done', () {
      // Three half-acres from four posts on the Whole Acre.
      final play = Play.of(Fields.at(1))
          .tapAt((0, 0))
          .tapAt((1, 0))
          .tapAt((2, 1))
          .tapAt((0, 1))
          .tapAt((0, 0));
      expect(play.closed, isTrue);
      expect(play.twoA, 3);
      expect(play.isDone, isFalse);
      expect(play.isOver, isFalse);
    });

    test('the pointer fences the half over home', () {
      var play = Play.of(Fields.at(3));
      var guard = 0;
      while (!play.isDone && guard++ < 8) {
        final (post, _) = play.next!;
        play = play.tapAt(post);
      }
      expect(play.isDone, isTrue);
      expect(play.twoA, 5);
      expect(play.midRail, greaterThan(0));
      expect(play.moves, 5);
    });

    test('the pointer knows a stranded walk when it holds one', () {
      // No third post makes half an acre on a base of three.
      final play = Play.of(Fields.at(0)).tapAt((0, 0)).tapAt((3, 3));
      expect(play.couldStillLand, isFalse);
      expect(play.next, isNull);
    });

    test('the hopeless field admits it at twenty-one moves', () {
      var play = Play.of(Fields.at(4))
          .tapAt((0, 0))
          .tapAt((1, 0))
          .tapAt((1, 1))
          .tapAt((0, 1))
          .tapAt((0, 0));
      for (var dither = 0; dither < 8; dither++) {
        play = play.back.tapAt((0, 0));
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.closed, isTrue);
      expect(play.isDone, isFalse);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.next, isNull);
    });

    test('a winnable field never gives up', () {
      var play = Play.of(Fields.at(1))
          .tapAt((0, 0))
          .tapAt((1, 0))
          .tapAt((2, 1))
          .tapAt((0, 1))
          .tapAt((0, 0));
      for (var dither = 0; dither < 8; dither++) {
        play = play.back.tapAt((0, 0));
      }
      expect(play.moves, 21);
      expect(play.gaveUp, isFalse);
      expect(play.isOver, isFalse);
    });
  });
}
