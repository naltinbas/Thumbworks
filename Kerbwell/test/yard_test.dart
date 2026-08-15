import 'package:flutter_test/flutter_test.dart';
import 'package:kerbwell/yard/play.dart';
import 'package:kerbwell/yard/rules.dart';
import 'package:kerbwell/yard/yards.dart';

/// The law of the yard, held to.
void main() {
  group('the rules', () {
    test('every label\'s ways is what the sweep finds', () {
      final rules = Rules(5);
      for (final yard in Yards.all) {
        final (ways, all, _) = rules.sweep(yard.slabs, yard.asked);
        expect(ways, yard.ways, reason: yard.name);
        expect(all, yard.placings, reason: yard.name);
      }
    });

    test('the kerb, the box and joining read as told', () {
      const square = {(0, 0), (1, 0), (0, 1), (1, 1)};
      expect(Rules.kerb(square), 8);
      expect(Rules.box(square), (2, 2));
      expect(Rules.boxKerb(square), 8);
      expect(Rules.joined(square), isTrue);
      const ell = {(0, 0), (1, 0), (2, 0), (0, 1)};
      expect(Rules.kerb(ell), 10);
      expect(Rules.boxKerb(ell), 10);
      const apart = {(0, 0), (2, 0)};
      expect(Rules.joined(apart), isFalse);
      expect(Rules.kerb(apart), 8);
      expect(Rules.boxKerb(apart), 8);
    });

    test('the formula and the box agree with the sweep, one to ten', () {
      final rules = Rules(5);
      for (var count = 1; count <= 10; count++) {
        final (_, _, shortest) = rules.sweep(count, 0);
        expect(shortest, Rules.shortestByFormula(count), reason: '$count');
        expect(shortest, Rules.shortestBox(count), reason: '$count');
      }
      expect(Rules.shortestByFormula(5), 10);
      expect(Rules.shortestByFormula(9), 12);
      expect(Rules.shortestByFormula(10), 14);
    });

    test('the box kerb never exceeds the kerb, on every five', () {
      var seen = 0;
      Rules(5).placings(5, (slabs) {
        seen++;
        expect(Rules.boxKerb(slabs), lessThanOrEqualTo(Rules.kerb(slabs)));
        expect(Rules.kerb(slabs), greaterThanOrEqualTo(10));
        final (w, h) = Rules.box(slabs);
        expect(w * h, greaterThanOrEqualTo(5));
      });
      expect(seen, 571);
    });

    test('the sweep places each joined shape once', () {
      final rules = Rules(5);
      final seen = <String>{};
      rules.placings(4, (slabs) {
        final key = (slabs.toList()..sort((a, b) => a.$2 != b.$2 ? a.$2 - b.$2 : a.$1 - b.$1)).join(';');
        expect(seen.add(key), isTrue, reason: key);
        expect(Rules.joined(slabs), isTrue);
      });
      expect(seen, hasLength(228));
    });
  });

  group('the play', () {
    test('opens bare', () {
      for (final yard in Yards.all) {
        final play = Play.of(yard);
        expect(play.slabs, isEmpty, reason: yard.name);
        expect(play.isDone, isFalse);
      }
    });

    test('a tap lays, a tap lifts, counted both ways', () {
      var play = Play.of(Yards.at(0));
      play = play.tap((2, 2));
      expect(play.slabs, {(2, 2)});
      expect(play.moves, 1);
      play = play.tap((2, 2));
      expect(play.slabs, isEmpty);
      expect(play.moves, 2);
      expect(play.back.slabs, {(2, 2)});
    });

    test('no more slabs than the yard asks, none off the yard', () {
      final play = Play.of(Yards.at(0)).tap((0, 0)).tap((1, 0)).tap((0, 1)).tap((1, 1));
      expect(play.isDone, isTrue);
      expect(play.tap((3, 3)), same(play));
      final bare = Play.of(Yards.at(0));
      expect(bare.tap((7, 7)), same(bare));
    });

    test('the square yard lands by hand, and a loose pair does not join', () {
      final square = Play.of(Yards.at(0)).tap((1, 1)).tap((2, 1)).tap((1, 2)).tap((2, 2));
      expect(square.kerb, 8);
      expect(square.isDone, isTrue);
      final loose = Play.of(Yards.at(0)).tap((0, 0)).tap((2, 0));
      expect(loose.joined, isFalse);
    });

    test('the pointer lands the six and the ten', () {
      for (final number in [1, 3]) {
        var play = Play.of(Yards.at(number));
        var guard = 0;
        while (!play.isDone && guard++ < 24) {
          final (_, cell) = play.next!;
          play = play.tap(cell);
        }
        expect(play.isDone, isTrue, reason: '$number');
        expect(play.moves, Yards.at(number).slabs);
      }
    });

    test('the pointer lifts a slab off the placing first', () {
      final aim = Play.aimFor(Yards.at(2))!;
      final stray = Rules(5).cells.firstWhere((c) => !aim.contains(c));
      final play = Play.of(Yards.at(2)).tap(stray);
      expect(play.next, ('lift', stray));
    });

    test('the hopeless yard admits it at eleven moves', () {
      var play = Play.of(Yards.at(4));
      for (final cell in const [(1, 1), (2, 1), (3, 1), (1, 2), (2, 2)]) {
        play = play.tap(cell);
      }
      expect(play.moves, 5);
      expect(play.kerb, 10);
      expect(play.boxKerb, 10);
      for (var dither = 0; dither < 3; dither++) {
        play = play.tap((2, 2)).tap((2, 2));
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.next, isNull);
      expect(play.slabs, hasLength(5));
    });

    test('a winnable yard never gives up', () {
      var play = Play.of(Yards.at(0));
      for (var dither = 0; dither < 6; dither++) {
        play = play.tap((1, 1)).tap((1, 1));
      }
      expect(play.moves, 12);
      expect(play.gaveUp, isFalse);
    });

    test('the mark stands laid', () {
      final mark = Play.standing(Yards.at(2), const {
        (1, 1), (2, 1), (3, 1), (1, 2), (2, 2), (3, 2), (1, 3), (2, 3),
      });
      expect(mark.isDone, isTrue);
      expect(mark.kerb, 12);
    });
  });
}
