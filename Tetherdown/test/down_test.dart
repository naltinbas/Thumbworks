import 'package:flutter_test/flutter_test.dart';
import 'package:tetherdown/down/downs.dart';
import 'package:tetherdown/down/play.dart';
import 'package:tetherdown/down/rules.dart';

/// The law of the down, held to.
void main() {
  group('the rules', () {
    test('three mutual ropes knot a triangle', () {
      final rules = Rules(4);
      expect(rules.triangles(const [(0, 1), (1, 2), (0, 2)]),
          [(0, 1, 2)]);
      expect(rules.triangleFree(const [(0, 1), (1, 2), (2, 3)]),
          isTrue);
    });

    test('the fence line matches the pasture arithmetic', () {
      for (final posts in [4, 5, 6]) {
        final rules = Rules(posts);
        expect(rules.fenceLine, rules.pastureMost(),
            reason: '$posts');
        expect(rules.waysTo(rules.fenceLine + 1), 0,
            reason: '$posts');
      }
    });

    test('every label\'s ways is what the sweep finds', () {
      for (final down in Downs.all) {
        expect(Rules(down.posts).waysTo(down.asked), down.ways,
            reason: down.name);
      }
    });

    test('every fullest tethering splits into two pastures', () {
      for (final posts in [4, 5, 6]) {
        expect(Rules(posts).fullestSplit(), isTrue,
            reason: '$posts');
      }
    });

    test('a two-pasture knows itself', () {
      final rules = Rules(4);
      expect(
        rules.twoPasture(const [(0, 1), (0, 3), (2, 1), (2, 3)]),
        isTrue,
      );
      expect(
        rules.twoPasture(const [(0, 1), (1, 2), (2, 3)]),
        isFalse,
      );
    });

    test('a tethering lands what it promises', () {
      final found = Rules(6).tethering(9)!;
      expect(found, hasLength(9));
      expect(Rules(6).triangleFree(found), isTrue);
      expect(Rules(5).tethering(7), isNull);
    });
  });

  group('the play', () {
    test('two picks tie a rope', () {
      var play = Play.of(Downs.at(0));
      play = play.tapAt(0);
      expect(play.picked, 0);
      expect(play.moves, 0);
      play = play.tapAt(1);
      expect(play.picked, isNull);
      expect(play.ropes, [(0, 1)]);
      expect(play.moves, 1);
    });

    test('the same two posts untie their rope', () {
      var play = Play.of(Downs.at(0)).tapAt(0).tapAt(1);
      play = play.tapAt(1).tapAt(0);
      expect(play.ropes, isEmpty);
      // Tying and untying both count.
      expect(play.moves, 2);
    });

    test('picking a post twice lets it go', () {
      var play = Play.of(Downs.at(0)).tapAt(2);
      play = play.tapAt(2);
      expect(play.picked, isNull);
      expect(play.moves, 0);
    });

    test('a knot shows itself and blocks the landing', () {
      var play = Play.of(Downs.at(1));
      for (final rope in const [(0, 1), (1, 2), (0, 2), (2, 3), (3, 4)]) {
        play = play.tapAt(rope.$1).tapAt(rope.$2);
      }
      expect(play.ropes, hasLength(5));
      expect(play.knotted, [(0, 1, 2)]);
      expect(play.isDone, isFalse);
    });

    test('the square lands on any of its three tetherings', () {
      var play = Play.of(Downs.at(0));
      for (final rope in const [(0, 1), (1, 2), (2, 3), (0, 3)]) {
        play = play.tapAt(rope.$1).tapAt(rope.$2);
      }
      expect(play.isDone, isTrue);
      expect(play.tapAt(0), same(play));
    });

    test('back takes back the last tying', () {
      var play = Play.of(Downs.at(0)).tapAt(0).tapAt(1);
      play = play.tapAt(1).tapAt(2);
      expect(play.moves, 2);
      expect(play.back.ropes, [(0, 1)]);
      expect(play.back.moves, 1);
    });

    test('show me points a rope of a real tethering', () {
      var play = Play.of(Downs.at(2));
      var guard = 0;
      while (!play.isDone && guard++ < 12) {
        final aim = play.next;
        expect(aim, isNotNull);
        final ((a, b), tie) = aim!;
        expect(tie, isTrue);
        play = play.tapAt(a).tapAt(b);
      }
      expect(play.isDone, isTrue);
    });

    test('show me unties a stray first', () {
      var play = Play.of(Downs.at(0));
      // A diagonal the square tethering never uses.
      play = play.tapAt(0).tapAt(2);
      final aim = play.next;
      expect(aim, isNotNull);
      // Either the found tethering avoids (0,2) and wants it
      // untied, or it uses it and wants the next rope tied.
      final ((a, b), tie) = aim!;
      if (!tie) {
        expect((a, b), (0, 2));
      }
    });

    test('the hopeless down has nothing to point at', () {
      expect(Play.of(Downs.at(4)).next, isNull);
    });

    test('the hopeless down admits it after twelve tyings', () {
      // Six ties and unties of one rope: every action counts.
      var play = Play.of(Downs.at(4));
      for (var round = 0; round < 6; round++) {
        expect(play.gaveUp, isFalse);
        play = play.tapAt(0).tapAt(1);
        play = play.tapAt(0).tapAt(1);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.isDone, isFalse);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
    });

    test('a winnable down never gives up', () {
      var play = Play.of(Downs.at(1));
      final all = play.rules.allRopes;
      for (var at = 0; play.moves < Play.gaveUpAt && at < all.length; at++) {
        final (a, b) = all[at];
        play = play.tapAt(a).tapAt(b);
      }
      expect(play.moves, greaterThanOrEqualTo(5));
      expect(play.gaveUp, isFalse);
    });
  });
}
