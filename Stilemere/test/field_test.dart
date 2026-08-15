import 'package:flutter_test/flutter_test.dart';
import 'package:stilemere/field/levels.dart';
import 'package:stilemere/field/play.dart';
import 'package:stilemere/field/rules.dart';

/// The law of the field, held to.
void main() {
  group('the rules', () {
    test('steps go right or up, inside the hedges and out of the ponds', () {
      const f = Field(3, 3, ponds: [(2, 1)]);
      expect(f.stepsFrom((0, 0)), [(1, 0), (0, 1)]);
      expect(f.stepsFrom((1, 1)), [(1, 2)]);
      expect(f.stepsFrom((3, 3)), isEmpty);
      expect(f.stepsFrom((3, 2)), [(3, 3)]);
    });

    test('a walk lands only gate to mill by steps, past every stile and no pond', () {
      const f = Field(3, 3, stiles: [(1, 2)]);
      expect(f.lands([(0, 0), (1, 0), (1, 1), (1, 2), (2, 2), (3, 2), (3, 3)]), isTrue);
      expect(f.lands([(0, 0), (1, 0), (2, 0), (3, 0), (3, 1), (3, 2), (3, 3)]), isFalse);
      expect(f.lands([(0, 0), (1, 1), (1, 2), (2, 2), (3, 2), (3, 3)]), isFalse);
      const p = Field(3, 3, ponds: [(2, 1)]);
      expect(p.lands([(0, 0), (1, 0), (2, 0), (2, 1), (2, 2), (3, 2), (3, 3)]), isFalse);
    });

    test('every label\'s ways is what the walk finds', () {
      for (final level in Levels.all) {
        final (landing, all) = level.field.sweep();
        expect(landing, level.ways, reason: level.name);
        expect(all, level.walks, reason: level.name);
      }
    });

    test('Pascal\'s rule, the binomial and the walk agree', () {
      for (var w = 1; w <= 6; w++) {
        for (var h = 1; h <= 6; h++) {
          final f = Field(w, h);
          expect(f.routesFromGate()[w][h], Field.choose(w + h, w), reason: '$w x $h');
          expect(f.routesToMill()[0][0], Field.choose(w + h, w), reason: '$w x $h');
          expect(f.sweep().$2, Field.choose(w + h, w), reason: '$w x $h');
        }
      }
      expect(Field.choose(6, 3), 20);
      expect(Field.choose(8, 4), 70);
      expect(Field.choose(9, 5), 126);
    });

    test('the stiles multiply and the ponds strike out', () {
      expect(const Field(3, 3, stiles: [(1, 2)]).byStiles(), 9);
      expect(const Field(4, 4, stiles: [(1, 1), (3, 2)]).byStiles(), 18);
      expect(const Field(4, 4, stiles: [(1, 3), (3, 1)]).byStiles(), 0);
      const pond = Field(3, 3, ponds: [(2, 1)]);
      expect(pond.routesFromGate()[3][3], 11);
      expect(pond.routesFromGate()[2][1], 0);
      const long = Field(5, 4, stiles: [(2, 3)], ponds: [(1, 1)]);
      expect(long.routesFromGate()[2][3] * long.routesToMill()[2][3], 16);
    });

    test('the landings on from a junction are what the walk finds', () {
      final f = Levels.at(0).field;
      expect(f.landingsFrom([(0, 0)]), 9);
      expect(f.landingsFrom([(0, 0), (1, 0), (2, 0)]), 0);
      expect(f.landingsFrom([(0, 0), (1, 0), (1, 1)]), 3);
    });
  });

  group('the play', () {
    test('opens at the gate', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.walk, [(0, 0)], reason: level.name);
        expect(play.head, (0, 0));
        expect(play.isDone, isFalse);
        expect(play.isOver, isFalse);
      }
    });

    test('a tap steps to a neighbour only, and back undoes', () {
      var play = Play.of(Levels.at(0));
      play = play.tap((1, 0));
      expect(play.walk, [(0, 0), (1, 0)]);
      expect(play.moves, 1);
      expect(play.tap((2, 1)), same(play));
      expect(play.tap((0, 0)), same(play));
      expect(play.back.walk, [(0, 0)]);
      final pond = Play.of(Levels.at(1)).tap((1, 0)).tap((2, 0));
      expect(pond.tap((2, 1)), same(pond));
      expect(pond.tap((3, 0)).walk, hasLength(4));
    });

    test('the fields by hand', () {
      final stile = Play.of(Levels.at(0)).tap((1, 0)).tap((1, 1)).tap((1, 2)).tap((2, 2)).tap((3, 2)).tap((3, 3));
      expect(stile.isDone, isTrue);
      expect(stile.moves, 6);
      final missed = Play.of(Levels.at(0)).tap((1, 0)).tap((2, 0)).tap((3, 0)).tap((3, 1)).tap((3, 2)).tap((3, 3));
      expect(missed.isDone, isFalse);
      expect(missed.missed, isTrue);
      expect(missed.isOver, isTrue);
      expect(missed.gaveUp, isFalse);
      final two = Play.of(Levels.at(2)).tap((1, 0)).tap((1, 1)).tap((2, 1)).tap((3, 1)).tap((3, 2)).tap((4, 2)).tap((4, 3)).tap((4, 4));
      expect(two.isDone, isTrue);
      final long = Play.of(Levels.at(3)).tap((1, 0)).tap((2, 0)).tap((2, 1)).tap((2, 2)).tap((2, 3)).tap((3, 3)).tap((4, 3)).tap((5, 3)).tap((5, 4));
      expect(long.isDone, isTrue);
    });

    test('a pond blocks the step, and a strayed walk is pointed back', () {
      final play = Play.of(Levels.at(1)).tap((1, 0)).tap((1, 1));
      expect(play.field.stepsFrom((1, 1)), [(1, 2)]);
      expect(play.tap((2, 1)), same(play));
      expect(play.stuck, isFalse);
      final strayed = Play.of(Levels.at(3)).tap((1, 0)).tap((2, 0)).tap((3, 0)).tap((4, 0)).tap((5, 0));
      expect(strayed.landingsOn, 0);
      expect(strayed.next, ('back', (5, 0)));
      expect(strayed.back.next, ('back', (4, 0)));
    });

    test('the pointer lands every winnable field', () {
      for (final number in [0, 1, 2, 3]) {
        var play = Play.of(Levels.at(number));
        var guard = 0;
        while (!play.isDone && guard++ < 14) {
          final (what, j) = play.next!;
          play = what == 'back' ? play.back : play.tap(j);
        }
        expect(play.isDone, isTrue, reason: '$number');
      }
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('the hopeless field cracks at the mill', () {
      var play = Play.of(Levels.at(4)).tap((1, 0)).tap((1, 1)).tap((1, 2)).tap((1, 3)).tap((2, 3)).tap((3, 3)).tap((4, 3)).tap((4, 4));
      expect(play.stilesPassed, [(1, 3)]);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.tap((4, 4)), same(play));
    });

    test('the mark stands landed', () {
      final mark = Play.standing(Levels.at(0), const [(0, 0), (1, 0), (1, 1), (1, 2), (2, 2), (3, 2), (3, 3)]);
      expect(mark.isDone, isTrue);
      expect(mark.moves, 6);
    });
  });
}
