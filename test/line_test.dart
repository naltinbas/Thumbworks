import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tallyloom/game/line.dart';

/// Everything the line logic is meant to work out, worked out the slow
/// obvious way: write down every arrangement of the clue that fits what is
/// known, and keep the squares they agree on.
///
/// This is the definition of what a line deduces. It is also uselessly slow on
/// a real line, which is why the game does not use it — so it is worth having
/// exactly here, as the thing the fast version is checked against.
List<Square>? byHand(List<int> clue, List<Square> squares) {
  final runs = clue.where((run) => run > 0).toList();
  final fits = <List<bool>>[];

  void place(int i, int at, List<bool> soFar) {
    if (i == runs.length) {
      final whole = [...soFar, ...List.filled(squares.length - soFar.length, false)];
      for (var s = 0; s < whole.length; s++) {
        if (whole[s] && squares[s] == Square.blank) return;
        if (!whole[s] && squares[s] == Square.filled) return;
      }
      fits.add(whole);
      return;
    }
    for (var start = at; start + runs[i] <= squares.length; start++) {
      final next = [
        ...soFar,
        ...List.filled(start - soFar.length, false),
        ...List.filled(runs[i], true),
      ];
      if (next.length < squares.length) next.add(false);
      place(i + 1, next.length, next);
    }
  }

  place(0, 0, <bool>[]);
  if (fits.isEmpty) return null;

  return [
    for (var s = 0; s < squares.length; s++)
      if (fits.every((fit) => fit[s]))
        Square.filled
      else if (fits.every((fit) => !fit[s]))
        Square.blank
      else
        Square.unknown,
  ];
}

/// Every way a line of [length] squares can be partly known, for the small
/// lengths where writing them all down is cheap.
Iterable<List<Square>> everyState(int length) sync* {
  final states = <List<Square>>[[]];
  for (var i = 0; i < length; i++) {
    final grown = <List<Square>>[];
    for (final state in states) {
      for (final square in Square.values) {
        grown.add([...state, square]);
      }
    }
    states
      ..clear()
      ..addAll(grown);
  }
  yield* states;
}

/// Every clue that could belong to a line of [length] squares.
Iterable<List<int>> everyClue(int length) sync* {
  Iterable<List<int>> from(int room) sync* {
    yield <int>[];
    for (var run = 1; run <= room; run++) {
      for (final rest in from(room - run - 1)) {
        yield [run, ...rest];
      }
    }
  }

  yield* from(length);
}

String show(List<Square> squares) => squares
    .map((s) => switch (s) {
          Square.filled => '#',
          Square.blank => '.',
          Square.unknown => '?',
        })
    .join();

void main() {
  group('a line works out what its clue forces', () {
    test('a run as wide as the line fills it', () {
      final line = Line([4], List.filled(4, Square.unknown));
      expect(show(line.deduce()!), '####');
    });

    test('a clue of nothing empties the line', () {
      final line = Line([0], List.filled(5, Square.unknown));
      expect(show(line.deduce()!), '.....');
    });

    test('a big run in a small line overlaps itself in the middle', () {
      // Four in a line of five can start at nought or one, so the middle
      // three are filled either way and the ends are not yet known.
      final line = Line([4], List.filled(5, Square.unknown));
      expect(show(line.deduce()!), '?###?');
    });

    test('a known square pins the run around it', () {
      final squares = [
        Square.unknown,
        Square.unknown,
        Square.filled,
        Square.unknown,
        Square.unknown,
      ];
      // The two must cover the square that is known, so it can only start at
      // one or two: the ends are ruled out and the middle stays.
      expect(show(Line([2], squares).deduce()!), '.?#?.');
    });

    test('runs that only fit one way fill the line', () {
      final line = Line([2, 2], List.filled(5, Square.unknown));
      expect(show(line.deduce()!), '##.##');
    });

    test('a clue that cannot fit is impossible', () {
      expect(Line([3, 3], List.filled(6, Square.unknown)).deduce(), isNull);
      expect(Line([5], List.filled(4, Square.unknown)).deduce(), isNull);
    });

    test('a clue that contradicts what is known is impossible', () {
      final squares = [Square.blank, Square.blank, Square.blank];
      expect(Line([1], squares).deduce(), isNull);
    });
  });

  // The fast version against the slow obvious one, on every clue and every
  // state of knowledge a short line can be in. This is the whole of what the
  // solver believes, checked exhaustively rather than sampled.
  //
  // Eight wide by default, which is three thousand states against fifty five
  // clues and takes about three seconds. The cost triples with every square
  // after that, so going wider is a thing to ask for rather than something
  // everybody pays for on every run: set TALLYLOOM_LINE_WIDTH, which is what
  // `make verify` and the nightly CI job do.
  group('against every arrangement written out by hand', () {
    final widest =
        int.tryParse(Platform.environment['TALLYLOOM_LINE_WIDTH'] ?? '') ?? 8;
    for (var length = 1; length <= widest; length++) {
      test('every clue and every state of a line $length wide', () {
        var checked = 0;
        for (final clue in everyClue(length)) {
          for (final state in everyState(length)) {
            final fast = Line(clue.isEmpty ? [0] : clue, state).deduce();
            final slow = byHand(clue, state);
            expect(
              fast == null ? null : show(fast),
              slow == null ? null : show(slow),
              reason: 'clue $clue on ${show(state)}',
            );
            checked++;
          }
        }
        expect(checked, greaterThan(0));
      });
    }
  });
}
