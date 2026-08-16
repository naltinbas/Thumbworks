import 'package:flutter_test/flutter_test.dart';
import 'package:crossleigh/cut/frac.dart';
import 'package:crossleigh/cut/levels.dart';
import 'package:crossleigh/cut/play.dart';
import 'package:crossleigh/cut/rules.dart';

/// The lines, the cuts, the asks and the play, checked at the domain:
/// nothing here touches a widget.
void main() {
  group('the cuts', () {
    test('a line cut exactly, the ratios by the crossings and by the areas', () {
      final (f, d, e) = Rules.crossings((6, 0), (0, 4));
      expect(Rules.tellPoint(f), '(6, 0)');
      expect(Rules.tellPoint(d), '(24, -12)');
      expect(Rules.tellPoint(e), '(0, 4)');
      expect(Rules.ratiosByCrossings((6, 0), (0, 4)), (Frac.one, Frac.of(-1, 2), Frac.of(2)));
      expect(Rules.ratiosByAreas((6, 0), (0, 4)), (Frac.one, Frac.of(-1, 2), Frac.of(2)));
      expect(Rules.product(Rules.ratiosByCrossings((6, 0), (0, 4))), Frac.of(-1));
      expect(Rules.sidesInside((6, 0), (0, 4)), 2);
      expect(Rules.sidesInside((12, 1), (11, 3)), 0);
      expect(Rules.ratiosByCrossings((1, 0), (2, 1)), (Frac.of(1, 11), Frac.of(11, 13), Frac.of(-13)));
      expect(Rules.crossesAll((0, 0), (1, 1)), isFalse);
      expect(Rules.crossesAll((1, 2), (5, 2)), isFalse);
      expect(Rules.crossesAll((3, 3), (3, 7)), isFalse);
      expect(Rules.crossesAll((2, 5), (5, 2)), isFalse);
      expect(Rules.crossesAll((1, 2), (3, 4)), isTrue);
      expect(Rules.lineOf((3, 1), (7, 3)), Rules.lineOf((7, 3), (3, 1)));
      expect(Rules.lineOf((0, 6), (12, 3)), (1, 4, 24));
      expect(Rules.pegs, hasLength(169));
      expect(Rules.lines, hasLength(6140));
    });

    test('the two voices agree on every line, the product is -1, and two sides or none are cut inside', () {
      for (final (p, q) in Rules.lines) {
        final r = Rules.ratiosByCrossings(p, q);
        expect(Rules.ratiosByAreas(p, q), r, reason: '$p $q');
        expect(Rules.product(r), Frac.of(-1), reason: '$p $q');
        expect(Rules.sidesInside(p, q), anyOf(0, 2), reason: '$p $q');
      }
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The Three Inside']);
      for (final level in Levels.all) {
        var n = 0;
        for (final (p, q) in Rules.lines) {
          if (level.meets(p, q)) n++;
        }
        expect(n, level.ways, reason: level.name);
        final aim = level.aim;
        if (aim != null) expect(level.meets(aim.$1, aim.$2), isTrue, reason: level.name);
        if (!level.winnable) expect(aim, isNull);
      }
      expect(Levels.at(0).aim, ((1, 0), (2, 1)));
      expect(Levels.at(1).aim, ((6, 0), (0, 1)));
      expect(Levels.at(2).aim, ((1, 0), (0, 2)));
      expect(Levels.at(3).aim, ((1, 0), (4, 8)));
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'set a line that cuts two sides of the triangle inside');
      expect(Levels.at(1).task, 'set a line that cuts AB at its middle');
      expect(Levels.at(3).task, 'set a line that cuts BC twice as far from B as from C');
      expect(Levels.at(4).task, 'set a line that cuts all three sides inside');
    });

    test('an ask is met by the line, whichever peg comes first', () {
      expect(Levels.at(0).meets((2, 1), (1, 0)), isTrue);
      expect(Levels.at(0).meets((12, 1), (11, 3)), isFalse);
      expect(Levels.at(1).meets((6, 0), (0, 4)), isTrue);
      expect(Levels.at(1).meets((5, 0), (0, 4)), isFalse);
      expect(Levels.at(2).meets((2, 4), (6, 6)), isTrue);
      expect(Levels.at(2).meets((1, 0), (2, 1)), isFalse);
      expect(Levels.at(3).meets((4, 8), (0, 4)), isTrue);
      expect(Levels.at(3).meets((6, 0), (0, 4)), isFalse);
      expect(Levels.at(4).meets((1, 0), (2, 1)), isFalse);
      expect(Levels.at(0).meets((0, 0), (1, 1)), isFalse);
    });
  });

  group('the play', () {
    test('opens with no pegs set', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.chosen, isEmpty);
        expect((play.moves, play.crosses, play.tried), (0, false, 0));
        expect(play.isOver, isFalse, reason: level.name);
      }
    });

    test('taps set and lift pegs, two at most, and a bad line names its flaw', () {
      // On the hopeless ask nothing lands, so the pegs can come and go.
      var play = Play.of(Levels.at(4)).tap((6, 0));
      expect(play.chosen, [(6, 0)]);
      expect(play.crosses, isFalse);
      play = play.tap((0, 4));
      expect(play.crosses, isTrue);
      expect(play.tried, 1);
      expect(play.ratios, (Frac.one, Frac.of(-1, 2), Frac.of(2)));
      expect(play.tap((3, 3)), same(play));
      expect(play.tap((6, 0)).chosen, [(0, 4)]);
      final level = Play.of(Levels.at(0)).tap((1, 2)).tap((5, 2));
      expect(level.crosses, isFalse);
      expect(level.flaw, 'it runs level with AB and never meets it');
      expect(Play.of(Levels.at(0)).tap((3, 3)).tap((3, 7)).flaw, 'it runs up with CA and never meets it');
      expect(Play.of(Levels.at(0)).tap((2, 5)).tap((5, 2)).flaw, 'it runs along with BC and never meets it');
      expect(Play.of(Levels.at(0)).tap((0, 0)).tap((1, 1)).flaw, 'it goes through a corner of the triangle');
    });

    test('back undoes one tap', () {
      final play = Play.of(Levels.at(0)).tap((6, 0)).tap((0, 4));
      expect(play.back.chosen, [(6, 0)]);
      expect(play.back.back.chosen, isEmpty);
    });

    test('the pointer sets the aim in order, and lifts a stray peg', () {
      var play = Play.of(Levels.at(1));
      expect(play.next, ((6, 0), false));
      expect(Play.pointed(((6, 0), false)), 'Set the peg at (6, 0).');
      play = play.tap((3, 3));
      expect(play.next, ((3, 3), true));
      expect(Play.pointed(((3, 3), true)), 'Lift the peg at (3, 3).');
      play = play.tap((3, 3)).tap((6, 0));
      expect(play.next, ((0, 1), false));
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('following the pointer lands every winnable ask in two taps', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var steps = 0;
        while (!play.isDone && steps < 6) {
          final (peg, _) = play.next!;
          play = play.tap(peg);
          steps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
        expect(play.moves, 2, reason: level.name);
      }
    });

    test('the three inside admits it after three lines, or twelve taps', () {
      var play = Play.of(Levels.at(4)).tap((1, 0)).tap((2, 1));
      expect(play.tried, 1);
      expect(play.gaveUp, isFalse);
      play = play.tap((2, 1)).tap((0, 4));
      expect(play.tried, 2);
      play = play.tap((1, 0)).tap((6, 0));
      expect(play.tried, 3);
      expect(play.gaveUp, isTrue);
      expect(play.next, isNull);
      var wander = Play.of(Levels.at(4));
      for (var k = 0; k < 12; k++) {
        wander = wander.tap((3, 3));
      }
      expect(wander.gaveUp, isTrue);
    });

    test('the why tells Menelaus and the sweep', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('Menelaus of Alexandria'));
      expect(words, contains('6,140 lines'));
      expect(words, contains('This is ask 5, The Three Inside.'));
      expect(words, contains('cut in full'));
    });
  });
}
