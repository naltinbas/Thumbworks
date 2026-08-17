import 'package:flutter_test/flutter_test.dart';
import 'package:rickmere/rick/frac.dart';
import 'package:rickmere/rick/levels.dart';
import 'package:rickmere/rick/play.dart';
import 'package:rickmere/rick/root3.dart';
import 'package:rickmere/rick/rules.dart';

/// The green itself: the roots of three, the ricks and the ring.
void main() {
  group('numbers with a root of three in them', () {
    test('multiply by turning the root into a three', () {
      final root = Root3(Frac.zero, Frac.one);
      expect(root * root, Root3.of(3));
      expect(Root3.of(1) + Root3.of(2), Root3.of(3));
      expect(Root3(Frac.of(1), Frac.of(1)) * Root3(Frac.of(1), Frac.of(-1)),
          Root3.of(-2));
    });

    test('are equal only when both halves are', () {
      expect(Root3.of(2) == Root3(Frac.of(2), Frac.of(1)), isFalse);
      expect(Root3(Frac.of(1, 2), Frac.of(1, 3)) ==
          Root3(Frac.of(2, 4), Frac.of(2, 6)), isTrue);
      expect(Root3.of(0).isZero, isTrue);
    });

    test('are told over a common bottom', () {
      expect('${Root3(Frac.of(4, 3), Frac.of(1, 3))}',
          '(4 and the root of three) over 3');
      expect('${Root3(Frac.of(6), Frac.of(-11, 3))}',
          '(18 less 11 roots of three) over 3');
      expect('${Root3.of(7)}', '7');
    });
  });

  group('the green', () {
    test('holds 2,148 fields', () {
      expect(Rules.fields().length, 2148);
      expect(Rules.isField(Rules.opening), isTrue);
      expect(Rules.isField([(0, 0), (1, 1), (2, 2)]), isFalse);
      expect(Rules.isField([(0, 0), (0, 0), (2, 2)]), isFalse);
      expect(Rules.isField([(0, 0), (1, 1), (9, 9)]), isFalse);
    });

    test('a rick is raised away from the field, whichever way it runs', () {
      // The same three posts written the other way round give the same
      // ricks, because outward is judged from the field itself.
      const one = [(0, 0), (3, 0), (0, 4)];
      const other = [(0, 0), (0, 4), (3, 0)];
      final a = Rules.markerSides(one).first;
      final b = Rules.markerSides(other).first;
      expect(a, b);
    });

    test('the four corner fields all reach the widest ring', () {
      const corners = [
        [(0, 0), (0, 4), (4, 0)],
        [(0, 0), (0, 4), (4, 4)],
        [(0, 0), (4, 0), (4, 4)],
        [(0, 4), (4, 0), (4, 4)],
      ];
      for (final posts in corners) {
        expect(Rules.markerSides(posts).first, Rules.widest, reason: '$posts');
      }
    });
  });

  group('the two voices', () {
    test('the markers are evenly spread on every field, raised either way',
        () {
      var raisings = 0;
      for (final posts in Rules.fields()) {
        for (final out in [true, false]) {
          raisings++;
          expect(Rules.evenByLength(posts, out: out), isTrue,
              reason: Rules.tellPosts(posts));
          expect(Rules.evenByTurning(posts, out: out), isTrue,
              reason: Rules.tellPosts(posts));
        }
      }
      expect(raisings, 4296);
    });

    test('and the two triangles of markers add to the field itself', () {
      for (final posts in Rules.fields()) {
        final outer = Rules.twiceAreaOf(Rules.markers(posts));
        final inner = Rules.twiceAreaOf(Rules.markers(posts, out: false));
        final both = outer + inner;
        expect(both, Root3.of(Rules.twiceArea(posts)),
            reason: Rules.tellPosts(posts));
        expect(both.b, Frac.zero, reason: 'the roots did not cancel');
      }
    });

    test('turning a marker sixty degrees lands it on the next', () {
      final m = Rules.markers(Rules.opening);
      final turned = [
        Rules.turnedOnto(m[0], m[1], 1),
        Rules.turnedOnto(m[0], m[1], -1),
      ];
      expect(turned.contains(m[2]), isTrue);
    });
  });

  group('the asks', () {
    test('are landed by as many fields as the sweep counted', () {
      for (final level in Levels.all) {
        var n = 0;
        for (final posts in Rules.fields()) {
          if (level.meets(posts)) n++;
        }
        expect(n, level.ways, reason: level.name);
      }
    });

    test('the fewest posts each one takes', () {
      expect([for (final level in Levels.all) level.fewest], [1, 2, 3, 3, null]);
    });

    test('none of them is landed before a post is moved', () {
      for (final level in Levels.all) {
        expect(level.meets(Rules.opening), isFalse, reason: level.name);
      }
    });
  });

  group('a go', () {
    test('opens on a field of half an acre', () {
      final play = Play.of(Levels.at(0));
      expect(play.posts, [(0, 2), (1, 1), (2, 1)]);
      expect(play.halfAcres, 1);
      expect(play.squareCorner, isFalse);
      expect(play.even, isTrue);
      expect(play.lifted, isNull);
      expect(play.moves, 0);
    });

    test('a lift and a stand make one move', () {
      var play = Play.of(Levels.at(1)).tap((0, 2));
      expect(play.lifted, 0);
      expect(play.moves, 0);
      play = play.tap((4, 4));
      expect(play.posts[0], (4, 4));
      expect(play.lifted, isNull);
      expect(play.moves, 1);
    });

    test('a post can be put back where it came from', () {
      final play = Play.of(Levels.at(1)).tap((0, 2)).tap((0, 2));
      expect(play.lifted, isNull);
      expect(play.posts, Rules.opening);
      expect(play.moves, 0);
    });

    test('a stand that makes a line or a double is refused', () {
      final play = Play.of(Levels.at(1)).tap((0, 2));
      expect(identical(play.tap((1, 1)), play), isTrue);
      expect(identical(play.tap((3, 1)), play), isTrue);
      expect(identical(play.tap((9, 9)), play), isTrue);
    });

    test('back undoes the last move', () {
      final play = Play.of(Levels.at(3)).tap((0, 2)).tap((4, 4));
      expect(play.moves, 1);
      expect(play.back.posts, Rules.opening);
      final opening = Play.of(Levels.at(3));
      expect(identical(opening.back, opening), isTrue);
    });

    test('the pointer lands every ask, in the fewest posts', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        while (!play.isDone) {
          final was = play.nearest!.$2;
          final aim = play.next!;
          play = play.tap(play.posts[aim.$1]).tap(aim.$2);
          expect(play.nearest!.$2, was - 1, reason: level.name);
        }
        expect(play.moves, level.fewest, reason: level.name);
        expect(play.next, isNull, reason: level.name);
      }
    });

    test('the pointer says what to do with the hand it has', () {
      final play = Play.of(Levels.at(0));
      expect(play.pointed((1, (4, 4))), 'Lift post 2.');
      final held = play.tap(play.posts[1]);
      expect(held.pointed((1, (4, 4))), 'Stand it on the peg at 4, 4.');
      expect(held.pointed((0, (4, 4))), 'Put post 2 back where it was.');
    });

    test('the hopeless ask admits it after four fields', () {
      var play = Play.of(Levels.all.last);
      expect(play.gaveUp, isFalse);
      for (final peg in [(4, 4), (0, 0), (4, 0), (3, 3)]) {
        play = play.tap(play.posts[0]).tap(peg);
      }
      expect(play.seen.length, 4);
      expect(play.gaveUp, isTrue);
      expect(play.even, isTrue);
    });

    test('a winnable ask never gives up', () {
      var play = Play.of(Levels.at(3));
      for (final peg in [(4, 4), (0, 0)]) {
        play = play.tap(play.posts[0]).tap(peg);
      }
      expect(play.gaveUp, isFalse);
      expect(play.seen, isEmpty);
    });

    test('the why names the diary it was printed in', () {
      final words = whyWords(Play.of(Levels.all.last));
      expect(words, contains("The Ladies' Diary in 1825"));
      expect(words, contains('the root of three is not a fraction'));
      expect(words, contains('The Uneven Three'));
    });
  });
}
