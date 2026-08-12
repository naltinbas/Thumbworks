import 'package:flutter_test/flutter_test.dart';
import 'package:tussockmere/mere/fields.dart';
import 'package:tussockmere/mere/play.dart';
import 'package:tussockmere/mere/rules.dart';

void main() {
  group('the marsh', () {
    test('a tussock touches six inside, fewer at the edges', () {
      final rules = Rules(4);
      expect(rules.neighbours(5), hasLength(6));
      expect(rules.neighbours(0), hasLength(2));
      expect(rules.neighbours(3), hasLength(3));
    });

    test('crossings read along rows, columns, and the slant', () {
      final rules = Rules(3);
      expect(rules.crosses([1, 1, 1, 0, 0, 0, 0, 0, 0], 1), isTrue);
      expect(rules.crosses([2, 0, 0, 2, 0, 0, 2, 0, 0], 2), isTrue);
      // Gold using the slant neighbour (r+1, c-1).
      expect(rules.crosses([1, 0, 0, 1, 1, 0, 0, 0, 1], 1), isFalse);
      expect(rules.crosses([1, 0, 0, 1, 1, 0, 0, 1, 1], 1), isTrue);
    });

    test('every filling of both marshes carries exactly one '
        'crossing', () {
      expect(Rules(3).everyFillingCarriesOne(), isTrue);
      expect(Rules(4).everyFillingCarriesOne(), isTrue);
    });

    test('the solves and the opening books', () {
      final three = Rules(3);
      expect(three.winner(List.filled(9, 0), 1), 1);
      expect(three.strongOpenings(), [1, 2, 4, 6, 7]);
      final four = Rules(4);
      expect(four.winner(List.filled(16, 0), 1), 1);
      final book = four.strongOpenings();
      expect(book, [3, 6, 9, 12]);
      for (final at in book) {
        expect(at ~/ 4 + at % 4, 3);
      }
    });
  });

  group('a play', () {
    test('your step is answered by the mere', () {
      final play = Play.of(Fields.at(0));
      expect(play.cells.where((cell) => cell != 0), isEmpty);
      final stepped = play.step(4);
      expect(stepped.cells[4], 1);
      expect(stepped.cells.where((cell) => cell == 2), hasLength(1));
      expect(stepped.moves, 1);
      expect(stepped.back.cells, play.cells);
    });

    test('a taken tussock refuses the foot', () {
      final play = Play.of(Fields.at(0)).step(4);
      expect(play.mayStep(4), isFalse);
      expect(play.step(4), same(play));
    });

    test('the pie moves the stone across the slant and turns it '
        'gold', () {
      final play = Play.of(Fields.at(2));
      expect(play.pieOpen, isTrue);
      expect(play.cells[6], 2);
      final taken = play.takePie();
      expect(taken.swapped, isTrue);
      expect(taken.cells[6], isNot(2));
      // (1,2) claimed becomes (2,1): tussock 9, then the mere
      // answers somewhere.
      expect(taken.cells[9], 1);
      expect(taken.cells.where((cell) => cell == 2), hasLength(1));
    });

    test('the pie verdicts, judged by the solve', () {
      final pie = Play.of(Fields.at(2));
      expect(pie.next, 'take');
      expect(pie.takePie().standing, 1);
      expect(pie.declinePie().standing, 2);

      final humble = Play.of(Fields.at(3));
      expect(humble.next, 'decline');
      expect(humble.declinePie().standing, 1);
      expect(humble.takePie().standing, 2);
    });

    test('following the solve links the banks on every winnable '
        'field', () {
      for (final field in Fields.all.where((field) => field.winnable)) {
        var play = Play.of(field);
        var guard = 0;
        while (!play.isDone) {
          if (guard++ > 20) fail('${field.name} never linked');
          final way = play.next;
          expect(way, isNotNull, reason: field.name);
          play = switch (way!) {
            'take' => play.takePie(),
            'decline' => play.declinePie(),
            _ => play.step(int.parse(way)),
          };
        }
        expect(play.isDone, isTrue, reason: field.name);
        expect(play.isLost, isFalse, reason: field.name);
      }
    });

    test('the second chair loses every line', () {
      var play = Play.of(Fields.at(4));
      expect(play.standing, 2);
      expect(play.next, isNull);
      var guard = 0;
      while (!play.isOver) {
        if (guard++ > 16) fail('the chair never fell');
        final open = play.cells.indexOf(0);
        play = play.step(open);
      }
      expect(play.isLost, isTrue);
      expect(play.isDone, isFalse);
    });

    test('a declined pie hands the marsh to the mere', () {
      var play = Play.of(Fields.at(2)).declinePie();
      expect(play.standing, 2);
      var guard = 0;
      while (!play.isOver) {
        if (guard++ > 16) fail('the declined pie never settled');
        final open = play.cells.indexOf(0);
        play = play.step(open);
      }
      expect(play.isLost, isTrue);
    });
  });
}
