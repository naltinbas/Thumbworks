import 'package:flutter_test/flutter_test.dart';
import 'package:cornerwick/square/frac.dart';
import 'package:cornerwick/square/levels.dart';
import 'package:cornerwick/square/play.dart';
import 'package:cornerwick/square/rules.dart';

/// The squares, the joins, the asks and the play, checked at the domain:
/// nothing here touches a widget.
void main() {
  group('the squares', () {
    test('the centres, the joins, the crossing and the second voice on a named four', () {
      final f = [(1, 1), (3, 1), (3, 3), (1, 3)];
      expect(Rules.centre((1, 1), (3, 1)), (4, 0));
      expect(Rules.square((1, 1), (3, 1)), [(2, 2), (6, 2), (6, -2), (2, -2)]);
      expect(Rules.centres(f), [(4, 0), (8, 4), (4, 8), (0, 4)]);
      expect(Rules.joins(f), ((0, 8), (-8, 0)));
      expect(Rules.lengthsSquared(f), (Frac.of(16), Frac.of(16)));
      expect(Rules.sameLength(f), isTrue);
      expect(Rules.atRightAngles(f), isTrue);
      expect(Rules.turnedIsTheOther(f), isTrue);
      expect(Rules.crossing(f), (Frac.of(2), Frac.of(2)));
      expect(Rules.centresMakeSquare(f), isTrue);
      expect(Rules.parallelogram(f), isTrue);
      expect(Rules.centresWhole(f), isTrue);
      expect(Rules.threeInLine(f), isFalse);
      final g = [(0, 0), (4, 1), (3, 4), (1, 2)];
      expect(Rules.lengthsSquared(g), (Frac.of(65, 2), Frac.of(65, 2)));
      expect(Rules.centresMakeSquare(g), isFalse);
      expect(Rules.centresWhole(g), isFalse);
      expect(Rules.threeInLine([(0, 0), (1, 0), (2, 0), (3, 3)]), isTrue);
      expect(Rules.centres([(0, 0), (0, 1), (1, 1), (1, 0)]).every((c) => c == (1, 1)), isTrue);
      expect(Rules.crossing([(0, 0), (0, 1), (1, 1), (1, 0)]), isNull);
      expect(Rules.tellLength(Frac.of(25)), '5');
      expect(Rules.tellLength(Frac.of(50)), 'root 50');
      expect(Rules.tellLength(Frac.of(65, 2)), 'root 65/2');
      expect(Rules.tellPeg((3, 1)), '(3, 1)');
      expect(Rules.pegs, hasLength(25));
    });

    test('the sweep: the joins are equal and square on every four, by the centres and by the turned join', () {
      var fours = 0, clear = 0, whole = 0, square = 0;
      Rules.fours((f) {
        fours++;
        expect(Rules.sameLength(f) && Rules.atRightAngles(f), isTrue, reason: '$f');
        expect(Rules.turnedIsTheOther(f), isTrue, reason: '$f');
        if (Rules.threeInLine(f)) return;
        clear++;
        if (Rules.centresWhole(f)) whole++;
        if (Rules.centresMakeSquare(f)) {
          square++;
          expect(Rules.parallelogram(f), isTrue, reason: '$f');
        }
      });
      expect((fours, clear, whole, square), (303600, 227952, 18528, 5192));
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The Skew Cross']);
      for (final level in Levels.all) {
        var ways = 0;
        Rules.fours((f) {
          if (level.meets(f)) ways++;
        });
        expect(ways, level.ways, reason: level.name);
        final aim = level.aim;
        if (aim != null) expect(level.meets(aim), isTrue, reason: level.name);
        if (!level.winnable) expect(aim, isNull);
      }
      expect(Levels.at(0).aim, [(0, 0), (2, 0), (1, 1), (3, 1)]);
      expect(Levels.at(1).aim, [(0, 0), (1, 0), (1, 1), (0, 1)]);
      expect(Levels.at(2).aim, [(0, 0), (1, 0), (0, 1), (1, 2)]);
      expect(Levels.at(3).aim, [(0, 0), (1, 0), (3, 1), (1, 4)]);
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'set four pegs whose four square-centres all fall on peg places');
      expect(Levels.at(1).task, 'set four pegs whose four square-centres make a square');
      expect(Levels.at(2).task, 'set four pegs whose two joins cross on a peg place');
      expect(Levels.at(3).task, 'set four pegs whose two joins are five long');
      expect(Levels.at(4).task, 'set four pegs whose two joins differ in length, or miss the right angle');
    });

    test('an ask is met by the four, and never by three pegs in a line', () {
      final square = [(1, 1), (3, 1), (3, 3), (1, 3)];
      final para = [(0, 0), (3, 1), (4, 4), (1, 3)];
      final five = [(0, 0), (1, 0), (3, 1), (1, 4)];
      expect(Levels.at(0).meets(square), isTrue);
      expect(Levels.at(0).meets([(0, 0), (4, 1), (3, 4), (1, 2)]), isFalse);
      expect(Levels.at(1).meets(square), isTrue);
      expect(Levels.at(1).meets(para), isTrue);
      expect(Levels.at(1).meets(five), isFalse);
      expect(Levels.at(2).meets(para), isTrue);
      expect(Levels.at(2).meets([(0, 0), (4, 1), (3, 4), (1, 2)]), isFalse);
      expect(Levels.at(3).meets(five), isTrue);
      expect(Levels.at(3).meets(square), isFalse);
      expect(Levels.at(4).meets(square), isFalse);
      expect(Levels.at(0).meets([(0, 0), (1, 0), (2, 0), (1, 1)]), isFalse);
      expect(Levels.at(0).meets([(0, 0), (2, 0), (2, 2)]), isFalse);
    });
  });

  group('the play', () {
    test('opens with no pegs set', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.pegs, isEmpty);
        expect((play.moves, play.full, play.tried), (0, false, 0));
        expect(play.isOver, isFalse, reason: level.name);
      }
    });

    test('taps set pegs in order, four at most, and the last one lifts', () {
      var play = Play.of(Levels.at(4)).tap((0, 0)).tap((3, 1));
      expect(play.pegs, [(0, 0), (3, 1)]);
      expect(play.centresSoFar, [(4, -2)]);
      expect(play.tap((0, 0)), same(play));
      play = play.tap((3, 1));
      expect(play.pegs, [(0, 0)]);
      play = play.tap((3, 1)).tap((4, 4)).tap((1, 3));
      expect(play.full, isTrue);
      expect(play.tried, 1);
      expect(play.lengthsSquared, (Frac.of(36), Frac.of(36)));
      expect(play.crossing, (Frac.of(2), Frac.of(2)));
      expect(play.centresMakeSquare, isTrue);
      expect(play.tap((2, 2)), same(play));
      expect(play.tap((5, 0)), same(play));
    });

    test('back undoes one tap', () {
      final play = Play.of(Levels.at(0)).tap((1, 1)).tap((3, 1));
      expect(play.back.pegs, [(1, 1)]);
      expect(play.back.back.pegs, isEmpty);
    });

    test('the pointer sets the aim in order, and lifts a stray last peg', () {
      var play = Play.of(Levels.at(1));
      expect(play.next, ((0, 0), false));
      expect(Play.pointed(((0, 0), false)), 'Set the peg at (0, 0).');
      play = play.tap((2, 2));
      expect(play.next, ((2, 2), true));
      expect(Play.pointed(((2, 2), true)), 'Lift the peg at (2, 2).');
      play = play.tap((2, 2)).tap((0, 0));
      expect(play.next, ((1, 0), false));
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('following the pointer lands every winnable ask in four taps', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var steps = 0;
        while (!play.isDone && steps < 12) {
          final (peg, _) = play.next!;
          play = play.tap(peg);
          steps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
        expect(play.moves, 4, reason: level.name);
      }
    });

    test('the skew cross admits it after three fours, or twenty taps', () {
      var play = Play.of(Levels.at(4)).tap((0, 0)).tap((3, 1)).tap((4, 4)).tap((1, 3));
      expect(play.tried, 1);
      expect(play.gaveUp, isFalse);
      play = play.tap((1, 3)).tap((2, 3));
      expect(play.tried, 2);
      play = play.tap((2, 3)).tap((0, 4));
      expect(play.tried, 3);
      expect(play.gaveUp, isTrue);
      expect(play.moves, 8);
      expect(play.lengthsSquared, (Frac.of(49), Frac.of(49)));
      expect(play.next, isNull);
      var wander = Play.of(Levels.at(4));
      for (var k = 0; k < 20; k++) {
        wander = wander.tap((0, 0));
      }
      expect(wander.gaveUp, isTrue);
      expect(wander.moves, 20);
    });

    test('the why tells Van Aubel and the sweep', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('Van Aubel proved it in 1878'));
      expect(words, contains('303,600'));
      expect(words, contains('This is ask 5, The Skew Cross.'));
      expect(words, contains('squared in full'));
    });
  });
}
