import 'package:flutter_test/flutter_test.dart';
import 'package:squarholt/hoard/hoards.dart';
import 'package:squarholt/hoard/play.dart';
import 'package:squarholt/hoard/rules.dart';

/// The law of the tiles, held to.
void main() {
  group('the rules', () {
    test('every label\'s ways is what the dials find', () {
      for (final hoard in Hoards.all) {
        expect(
          Rules.writings(hoard.target).length,
          hoard.ways,
          reason: hoard.name,
        );
      }
    });

    test('the writings stand where they were pinned', () {
      expect(Rules.writings(5), [(1, 2)]);
      expect(Rules.writings(25), [(3, 4)]);
      expect(Rules.writings(50), [(1, 7), (5, 5)]);
      expect(Rules.writings(65), [(1, 8), (4, 7)]);
      expect(Rules.writings(97), [(4, 9)]);
      expect(Rules.writings(43), isEmpty);
      expect(Rules.writings(2), [(1, 1)]);
    });

    test('both laws hold over the whole sweep', () {
      expect(Rules.lawsHold(), isTrue);
      expect(Rules.fermatPrimes,
          [5, 13, 17, 29, 37, 41, 53, 61, 73, 89, 97]);
    });

    test('the remainder reads without searching', () {
      expect(Rules.pastFours(43), 3);
      expect(Rules.barredByFours(43), isTrue);
      expect(Rules.barredByFours(50), isFalse);
    });

    test('the old identity writes the composites, sign by sign', () {
      expect(Rules.composed((1, 2), (2, 3)).toSet(),
          Rules.writings(65).toSet());
      expect(Rules.composed((1, 2), (1, 3)).toSet(),
          Rules.writings(50).toSet());
      // Twin factors: one sign lands three and four, the other
      // the empty tile, which the dials cannot reach; that is
      // why twenty-five writes once on them.
      expect(Rules.composed((1, 2), (1, 2)), [(3, 4), (0, 5)]);
    });
  });

  group('the play', () {
    test('opens on twin ones, paying two', () {
      for (final hoard in Hoards.all) {
        final play = Play.of(hoard);
        expect((play.a, play.b), (1, 1), reason: hoard.name);
        expect(play.paid, 2, reason: hoard.name);
        expect(play.isDone, isFalse, reason: hoard.name);
      }
    });

    test('the dials turn and clamp, moves counted gross', () {
      var play = Play.of(Hoards.at(4));
      expect(play.turnA(-1), same(play));
      play = play.turnA(1).turnB(1).turnB(1);
      expect((play.a, play.b), (2, 3));
      expect(play.moves, 3);
      for (var turn = 0; turn < 10; turn++) {
        play = play.turnB(1);
      }
      expect(play.b, Rules.widest);
      expect(play.moves, 9);
    });

    test('back takes back one turn', () {
      final play = Play.of(Hoards.at(4)).turnA(1).turnB(1);
      expect(play.back.moves, 1);
      expect((play.back.a, play.back.b), (2, 1));
      expect(play.back.back.back, same(play.back.back));
    });

    test('one turn pays the five and the play freezes', () {
      final play = Play.of(Hoards.at(0)).turnB(1);
      expect(play.isDone, isTrue);
      expect(play.isOver, isTrue);
      expect(play.paid, 5);
      expect(play.moves, 1);
      expect(play.turnA(1), same(play));
    });

    test('the pointer turns toward a nearest writing', () {
      final play = Play.of(Hoards.at(0));
      expect(play.next, (false, true));
      // From (3, 3) the three-and-four wants the slate grown.
      final near = Play.standing(Hoards.at(1), 3, 3);
      expect(near.next, (false, true));
    });

    test('the pointer pays the great prime', () {
      var play = Play.of(Hoards.at(3));
      var guard = 0;
      while (!play.isDone && guard++ < 16) {
        final (first, up) = play.next!;
        play = first ? play.turnA(up ? 1 : -1) : play.turnB(up ? 1 : -1);
      }
      expect(play.isDone, isTrue);
      expect((play.a, play.b), (4, 9));
      expect(play.moves, 11);
    });

    test('the hopeless hoard admits it at sixteen turns', () {
      var play = Play.of(Hoards.at(4));
      for (var dither = 0; dither < 8; dither++) {
        play = play.turnA(1).turnA(-1);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.isDone, isFalse);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.next, isNull);
    });

    test('a winnable hoard never gives up', () {
      var play = Play.of(Hoards.at(3));
      for (var dither = 0; dither < 8; dither++) {
        play = play.turnA(1).turnA(-1);
      }
      expect(play.moves, 16);
      expect(play.gaveUp, isFalse);
      expect(play.isOver, isFalse);
    });

    test('the mark stands paid', () {
      final mark = Play.standing(Hoards.at(1), 3, 4);
      expect(mark.isDone, isTrue);
      expect(mark.paid, 25);
    });
  });
}
