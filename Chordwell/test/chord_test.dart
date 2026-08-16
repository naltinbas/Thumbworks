import 'package:flutter_test/flutter_test.dart';
import 'package:chordwell/chord/frac.dart';
import 'package:chordwell/chord/levels.dart';
import 'package:chordwell/chord/play.dart';
import 'package:chordwell/chord/rules.dart';

/// The wheel, the crossings, the asks and the play, checked at the
/// domain: nothing here touches a widget.
void main() {
  group('the wheel', () {
    test('twelve pegs, sixty-six chords, 495 crossings', () {
      expect(Rules.pegs, hasLength(12));
      expect(Rules.pegs.every(Rules.onWheel), isTrue);
      expect(Rules.chords, hasLength(66));
      expect(Rules.crossings, hasLength(495));
      expect(Rules.pegs[1], (3, 4));
      expect(Rules.pegs[9], (-5, 0));
    });

    test('a crossing worked exactly, and the two products agree', () {
      final p = Rules.crossing((3, 4), (3, -4), (5, 0), (-5, 0))!;
      expect(Rules.tellPoint(p), '(3, 0)');
      expect(Rules.product(p, (3, 4), (3, -4)), Frac.of(16));
      expect(Rules.product(p, (5, 0), (-5, 0)), Frac.of(16));
      expect(Rules.power(p), Frac.of(16));
      expect(Rules.tellLength(Rules.piece2(p, (3, 4))), '4');
      expect(Rules.tellLength(Rules.piece2(p, (5, 0))), '2');
      expect(Rules.tellLength(Rules.piece2(p, (-5, 0))), '8');
      expect(Rules.halves(p, (3, 4), (3, -4)), isTrue);
      expect(Rules.halves(p, (5, 0), (-5, 0)), isFalse);
      expect(Rules.square((3, 4), (3, -4), (5, 0), (-5, 0)), isTrue);
      expect(Rules.isDiameter((5, 0), (-5, 0)), isTrue);
      expect(Rules.isMiddle(p), isFalse);
      final q = Rules.crossing((0, 5), (4, -3), (3, 4), (0, -5))!;
      expect(Rules.tellPoint(q), '(2, 1)');
      expect(Rules.tellLength(Rules.piece2(q, (0, 5))), 'root 20');
      expect(Rules.tellLength(Rules.piece2(q, (3, 4))), 'root 10');
      expect(Rules.tellLength(Rules.piece2(q, (0, -5))), 'root 40');
      expect(Rules.product(q, (0, 5), (4, -3)), Frac.of(20));
      expect(Rules.product(q, (3, 4), (0, -5)), Frac.of(20));
    });

    test('chords that share a peg or miss do not cross', () {
      expect(Rules.crossing((0, 5), (3, 4), (3, 4), (5, 0)), isNull);
      expect(Rules.crossing((0, 5), (3, 4), (4, 3), (5, 0)), isNull);
      expect(Rules.crossing((0, 5), (0, -5), (5, 0), (-5, 0)), isNotNull);
      expect(Rules.isMiddle(Rules.crossing((0, 5), (0, -5), (5, 0), (-5, 0))!), isTrue);
    });

    test('the products agree with the power on every crossing', () {
      for (final ((a, b), (c, d)) in Rules.crossings) {
        final A = Rules.pegs[a], B = Rules.pegs[b], C = Rules.pegs[c], D = Rules.pegs[d];
        final p = Rules.crossing(A, B, C, D)!;
        expect(Rules.product(p, A, B), Rules.product(p, C, D), reason: '$A $B $C $D');
        expect(Rules.product(p, A, B), Rules.power(p), reason: '$A $B $C $D');
      }
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The Odd Cross']);
      for (final level in Levels.all) {
        var n = 0;
        for (final ((a, b), (c, d)) in Rules.crossings) {
          if (level.meets(Rules.pegs[a], Rules.pegs[b], Rules.pegs[c], Rules.pegs[d])) n++;
        }
        expect(n, level.ways, reason: level.name);
        final aim = level.aim;
        if (aim != null) expect(level.meets(Rules.pegs[aim[0]], Rules.pegs[aim[1]], Rules.pegs[aim[2]], Rules.pegs[aim[3]]), isTrue, reason: level.name);
        if (!level.winnable) expect(aim, isNull);
      }
      expect(Levels.at(0).aim, [0, 6, 1, 7]);
      expect(Levels.at(1).aim, [0, 6, 1, 11]);
      expect(Levels.at(2).aim, [0, 4, 1, 6]);
      expect(Levels.at(3).aim, [0, 2, 1, 11]);
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'set two chords that cross at the middle of the wheel');
      expect(Levels.at(1).task, 'set two chords whose pieces multiply to 9 on each');
      expect(Levels.at(3).task, 'set two chords so that one cuts the other in half, away from the middle');
      expect(Levels.at(4).task, 'set two chords whose products of pieces differ');
    });

    test('an ask is met by the crossing', () {
      expect(Levels.at(0).meets((0, 5), (0, -5), (5, 0), (-5, 0)), isTrue);
      expect(Levels.at(0).meets((3, 4), (3, -4), (5, 0), (-5, 0)), isFalse);
      expect(Levels.at(1).meets((0, 5), (0, -5), (3, 4), (-3, 4)), isTrue);
      expect(Levels.at(1).meets((3, 4), (3, -4), (5, 0), (-5, 0)), isFalse);
      expect(Levels.at(2).meets((0, 5), (4, -3), (3, 4), (0, -5)), isTrue);
      expect(Levels.at(3).meets((3, 4), (3, -4), (5, 0), (-5, 0)), isTrue);
      expect(Levels.at(3).meets((0, 5), (0, -5), (5, 0), (-5, 0)), isFalse);
      expect(Levels.at(3).meets((0, 5), (3, 4), (4, 3), (5, 0)), isFalse);
      expect(Levels.at(4).meets((3, 4), (3, -4), (5, 0), (-5, 0)), isFalse);
    });
  });

  group('the play', () {
    test('opens with no pegs set', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.chosen, isEmpty);
        expect((play.moves, play.crossing, play.products), (0, null, null));
        expect(play.isOver, isFalse, reason: level.name);
      }
    });

    test('taps set and lift pegs, four at most', () {
      var play = Play.of(Levels.at(0)).tap(1).tap(5);
      expect(play.chosen, [1, 5]);
      expect(play.first, ((3, 4), (3, -4)));
      expect(play.second, isNull);
      play = play.tap(3).tap(9);
      expect(play.chosen, [1, 5, 3, 9]);
      expect(play.tap(0), same(play));
      expect(play.tap(3).chosen, [1, 5, 9]);
      expect(play.moves, 4);
      expect(play.crossing, isNotNull);
      expect(play.products, (Frac.of(16), Frac.of(16)));
      expect(play.power, Frac.of(16));
      expect(play.tap(12), same(play));
    });

    test('back undoes one tap', () {
      final play = Play.of(Levels.at(0)).tap(1).tap(5);
      expect(play.back.chosen, [1]);
      expect(play.back.back.chosen, isEmpty);
    });

    test('the pointer sets the aim in order, and lifts a stray last peg', () {
      var play = Play.of(Levels.at(0));
      expect(play.next, (0, false));
      expect(Play.pointed((0, false)), 'Set the peg at (0, 5).');
      play = play.tap(3);
      expect(play.next, (3, true));
      expect(Play.pointed((3, true)), 'Lift the peg at (5, 0).');
      play = play.tap(3).tap(0);
      expect(play.next, (6, false));
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('following the pointer lands every winnable ask in four taps', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var steps = 0;
        while (!play.isDone && steps < 8) {
          final (peg, _) = play.next!;
          play = play.tap(peg);
          steps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
        expect(play.moves, 4, reason: level.name);
      }
    });

    test('the odd cross admits it the moment two chords cross, or after twenty taps', () {
      var play = Play.of(Levels.at(4)).tap(0).tap(1).tap(2).tap(3);
      expect(play.crossing, isNull);
      expect(play.gaveUp, isFalse);
      play = play.tap(1).tap(2).tap(3).tap(6).tap(3).tap(9);
      expect(play.chosen, [0, 6, 3, 9]);
      expect(play.crossing, isNotNull);
      expect(play.moves, 10);
      expect(play.gaveUp, isTrue);
      expect(play.next, isNull);
      var wander = Play.of(Levels.at(4));
      for (var k = 0; k < 20; k++) {
        wander = wander.tap(0);
      }
      expect(wander.gaveUp, isTrue);
    });

    test('the why tells Euclid and the sweep', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('thirty-fifth of his third book'));
      expect(words, contains('495 crossings'));
      expect(words, contains('This is ask 5, The Odd Cross.'));
      expect(words, contains('worked in full'));
    });
  });
}
