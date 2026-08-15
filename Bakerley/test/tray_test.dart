import 'package:flutter_test/flutter_test.dart';
import 'package:bakerley/tray/levels.dart';
import 'package:bakerley/tray/play.dart';
import 'package:bakerley/tray/rules.dart';

/// The fours, the search, the colouring and the play, checked at the
/// domain: nothing here touches a widget.
void main() {
  group('the fours', () {
    test('their orientations, turned and flipped', () {
      expect(Rules.orientations(0), hasLength(2));
      expect(Rules.orientations(1), hasLength(1));
      expect(Rules.orientations(2), hasLength(4));
      expect(Rules.orientations(3), hasLength(4));
      expect(Rules.orientations(4), hasLength(8));
      for (var k = 0; k < 5; k++) {
        for (var o = 0; o < Rules.orientations(k).length; o++) {
          var t = o;
          for (var i = 0; i < 4; i++) {
            t = Rules.turned(k, t);
          }
          expect(t, o, reason: '${Rules.kinds[k]} $o');
          expect(Rules.flipped(k, Rules.flipped(k, o)), o);
        }
      }
      expect(Rules.orientations(2)[3], [(0, 0), (1, 0), (2, 0), (1, 1)]);
    });

    test('their shades: two and two but the tee', () {
      for (var k = 0; k < 5; k++) {
        final shades = Rules.orientations(k).map(Rules.shade).toSet();
        expect(shades, k == 2 ? {2, -2} : {0}, reason: Rules.kinds[k]);
      }
      expect(Rules.shades([1, 1, 1, 1, 1]), {2, -2});
      expect(Rules.shades([0, 0, 2, 0, 0]), {4, 0, -4});
    });

    test('the first move toward an orientation', () {
      expect(Rules.firstMove(2, 0, 0), isNull);
      expect(Rules.firstMove(2, 0, Rules.turned(2, 0)), 'turn');
      expect(Rules.firstMove(4, 0, Rules.flipped(4, 0)), 'flip');
      for (var o = 0; o < 8; o++) {
        // Every elbow orientation is reached from the first.
        var at = 0;
        var steps = 0;
        while (at != o && steps < 8) {
          final move = Rules.firstMove(4, at, o);
          at = move == 'turn' ? Rules.turned(4, at) : Rules.flipped(4, at);
          steps++;
        }
        expect(at, o);
      }
    });
  });

  group('the search', () {
    test('the pinwheel two ways, the elbows ten, both readings', () {
      expect(Rules.fillings(4, 4, [0, 0, 4, 0, 0]).$1, 2);
      expect(Rules.fillings(4, 4, [0, 0, 4, 0, 0], byColumns: true).$1, 2);
      expect(Rules.fillings(4, 4, [0, 0, 0, 0, 4]).$1, 10);
      expect(Rules.fillings(4, 4, [0, 0, 0, 0, 4], byColumns: true).$1, 10);
    });

    test('the mixed and the long trays', () {
      expect(Rules.fillings(5, 4, [0, 0, 2, 2, 1]).$1, 12);
      expect(Rules.fillings(6, 4, [2, 2, 0, 0, 2]).$1, 92);
    });

    test('the five never, nor the skews, nor six tees', () {
      expect(Rules.fillings(5, 4, [1, 1, 1, 1, 1]).$1, 0);
      expect(Rules.fillings(4, 4, [0, 0, 0, 4, 0]).$1, 0);
      expect(Rules.fillings(6, 4, [0, 0, 6, 0, 0]).$1, 0);
      expect(Rules.fillings(8, 4, [0, 0, 8, 0, 0]).$1, 6);
    });

    test('the colouring allows or forbids', () {
      expect(Rules.colouringAllows(5, 4, [1, 1, 1, 1, 1]), isFalse);
      expect(Rules.colouringAllows(4, 4, [0, 0, 4, 0, 0]), isTrue);
      expect(Rules.colouringAllows(4, 4, [0, 0, 0, 4, 0]), isTrue);
      expect(Rules.colouringAllows(6, 4, [0, 0, 6, 0, 0]), isTrue);
    });

    test('the first filling of the pinwheel fills', () {
      final (count, first) = Rules.fillings(4, 4, [0, 0, 4, 0, 0]);
      expect(count, 2);
      expect(first, [(2, 0, 0, 0), (2, 3, 1, 0), (2, 1, 2, 1), (2, 2, 0, 2)]);
      expect(Levels.at(0).meets(first!), isTrue);
    });
  });

  group('the levels', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The Five']);
      for (final level in Levels.all) {
        expect(level.pieces * 4, level.width * level.height, reason: level.name);
      }
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'fill the four-by-four tray with four tees');
      expect(Levels.at(2).task, 'fill the five-by-four tray with two tees, two skews and an elbow');
      expect(Levels.at(4).task, 'fill the five-by-four tray with a bar, a square, a tee, a skew and an elbow');
    });
  });

  group('the play', () {
    test('opens bare with the bag full', () {
      final play = Play.of(Levels.at(0));
      expect(play.laid, isEmpty);
      expect(play.left(2), 4);
      expect(play.bareCells, 16);
      expect(play.stuck, isFalse);
    });

    test('a four is taken, turned, flipped, laid where it fits, and lifted', () {
      var play = Play.of(Levels.at(1));
      play = play.hold(4);
      expect(play.held, 4);
      expect(play.facing, 0);
      play = play.turn();
      expect(play.facing, Rules.turned(4, 0));
      play = play.flip();
      expect(play.facing, Rules.flipped(4, Rules.turned(4, 0)));
      play = play.tap(3, 3);
      expect(play.refused, isTrue);
      // Let go and take it again: it faces its first way.
      play = play.hold(4).hold(4);
      expect(play.facing, 0);
      play = play.tap(0, 0);
      expect(play.laid, [(4, 0, 0, 0)]);
      expect(play.moves, 1);
      expect(play.held, isNull);
      play = play.tap(2, 0);
      expect(play.laid, isEmpty);
      expect(play.moves, 1);
    });

    test('back undoes one action', () {
      final play = Play.of(Levels.at(0)).hold(2).tap(0, 0);
      expect(play.back.laid, isEmpty);
      expect(play.back.held, 2);
    });

    test('the pinwheel lands by hand', () {
      var play = Play.of(Levels.at(0));
      for (final (k, o, x, y) in [(2, 0, 0, 0), (2, 3, 1, 0), (2, 1, 2, 1), (2, 2, 0, 2)]) {
        play = play.hold(k);
        var guard = 0;
        while (play.facing != o && guard++ < 8) {
          play = Rules.firstMove(k, play.facing, o) == 'flip' ? play.flip() : play.turn();
        }
        play = play.tap(x, y);
      }
      expect(play.isDone, isTrue);
      expect(play.moves, 4);
    });

    test('the five gets stuck or gives up', () {
      var play = Play.of(Levels.at(4));
      // Lay the tee, the bar and the square down the left: the skew and
      // the elbow may or may not fit; whatever comes, twenty-four layings
      // end it.
      var layings = 0;
      while (!play.isOver && layings < 30) {
        var laidOne = false;
        for (var k = 0; k < 5 && !laidOne; k++) {
          if (play.left(k) == 0) continue;
          for (var y = 0; y < 4 && !laidOne; y++) {
            for (var x = 0; x < 5 && !laidOne; x++) {
              final next = play.hold(k).tap(x, y);
              if (!next.refused) {
                play = next;
                laidOne = true;
              }
            }
          }
        }
        if (!laidOne) {
          // Nothing fits: lift the last laid and go on.
          final (k, o, x, y) = play.laid.last;
          final c = Rules.orientations(k)[o].first;
          play = play.tap(x + c.$1, y + c.$2);
        }
        layings++;
      }
      expect(play.isOver, isTrue);
      expect(play.gaveUp, isTrue);
      expect(play.next, isNull);
    });

    test('the pointer walks the search\'s first filling', () {
      var play = Play.of(Levels.at(0));
      expect(play.next, (Aim.tray, 2, 0));
      play = play.hold(2);
      expect(play.next, (Aim.cell, 0, 0));
      play = play.tap(0, 0);
      expect(play.next, (Aim.tray, 2, 0));
      play = play.hold(2);
      // The next tee faces 3, three moves off; the pointer says the first.
      expect(play.next!.$1, anyOf(Aim.turn, Aim.flip));
    });

    test('following the pointer fills every winnable tray', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var steps = 0;
        while (!play.isDone && steps < 80) {
          final (aim, a, b) = play.next!;
          play = switch (aim) {
            Aim.tray => play.hold(a),
            Aim.turn => play.turn(),
            Aim.flip => play.flip(),
            Aim.cell || Aim.lift => play.tap(a, b),
          };
          steps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
        expect(play.moves, level.pieces);
      }
    });
  });
}
