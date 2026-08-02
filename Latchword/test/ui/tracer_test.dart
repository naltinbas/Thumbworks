import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:latchword/game/board.dart';
import 'package:latchword/ui/grid_geometry.dart';
import 'package:latchword/ui/tracer.dart';

/// A five by five grid in a square of three hundred points, which is roughly
/// what a phone gives the board.
final _grid = GridGeometry.fit(const Size(300, 300), 5);

Offset _middleOf(int row, int col) => _grid.centreOf(Spot(row, col));

/// The point where four squares meet, which is the worst place a thumb can be
/// and the one the game has to have an opinion about.
Offset _cornerBelowRightOf(int row, int col) =>
    _middleOf(row, col) + Offset(_grid.pitch / 2, _grid.pitch / 2);

/// Somewhere off the top of the board, over whichever column [col] is.
Offset _aboveTheGrid(int col) =>
    Offset(_middleOf(0, col).dx, _grid.grid.top - 30);

/// What a thumb that went to these points in this order spells out.
List<Spot> _thumbWent(List<Offset> points) {
  final tracer = Tracer(_grid)..begin(points.first);
  for (final point in points.skip(1)) {
    tracer.extend(point);
  }
  return tracer.spots.toList();
}

void main() {
  test('takes the square the thumb lands on', () {
    expect(_thumbWent([_middleOf(2, 3)]), [const Spot(2, 3)]);
  });

  test('takes nothing when the thumb lands between squares', () {
    expect(_thumbWent([_cornerBelowRightOf(1, 1)]), isEmpty);
  });

  test('takes nothing when the thumb lands off the board', () {
    expect(_thumbWent([const Offset(2, 2)]), isEmpty);
  });

  test('takes every square the thumb crosses', () {
    expect(
      _thumbWent([
        _middleOf(0, 0),
        _middleOf(0, 1),
        _middleOf(0, 2),
        _middleOf(1, 2),
      ]),
      [const Spot(0, 0), const Spot(0, 1), const Spot(0, 2), const Spot(1, 2)],
    );
  });

  test('fills in the squares a fast drag flew over', () {
    // One report, four squares of travel: the pointer does not stop to be
    // asked, so the squares in between have to be worked out.
    expect(
      _thumbWent([_middleOf(0, 0), _middleOf(0, 4)]),
      [
        const Spot(0, 0),
        const Spot(0, 1),
        const Spot(0, 2),
        const Spot(0, 3),
        const Spot(0, 4),
      ],
    );
  });

  test('leaves out the two squares a diagonal passes between', () {
    expect(
      _thumbWent([_middleOf(0, 0), _middleOf(1, 1)]),
      [const Spot(0, 0), const Spot(1, 1)],
    );
  });

  test('leaves out a corner the thumb goes right over', () {
    // The thumb touches the exact point where four squares meet on its way,
    // which is as close as it can get to two squares without being in either.
    expect(
      _thumbWent([
        _middleOf(0, 0),
        _cornerBelowRightOf(0, 0),
        _middleOf(1, 1),
      ]),
      [const Spot(0, 0), const Spot(1, 1)],
    );
  });

  test('takes the last square off when the thumb comes back over the one '
      'before it', () {
    expect(
      _thumbWent([
        _middleOf(0, 0),
        _middleOf(0, 1),
        _middleOf(0, 2),
        _middleOf(0, 1),
      ]),
      [const Spot(0, 0), const Spot(0, 1)],
    );
  });

  test('unwinds the whole trace if the thumb goes all the way back', () {
    expect(
      _thumbWent([
        _middleOf(0, 0),
        _middleOf(0, 1),
        _middleOf(0, 2),
        _middleOf(0, 3),
        _middleOf(0, 0),
      ]),
      [const Spot(0, 0)],
    );
  });

  test('carries on from where it is when the thumb crosses its own trace', () {
    // Coming back over the first square is not the way back, so it is neither
    // taken again nor allowed to undo three squares of work.
    expect(
      _thumbWent([
        _middleOf(0, 0),
        _middleOf(0, 1),
        _middleOf(1, 1),
        _middleOf(1, 0),
        _middleOf(0, 0),
        _middleOf(2, 0),
      ]),
      [
        const Spot(0, 0),
        const Spot(0, 1),
        const Spot(1, 1),
        const Spot(1, 0),
        const Spot(2, 0),
      ],
    );
  });

  test('keeps what the thumb spelled after it wanders off the grid', () {
    expect(
      _thumbWent([
        _middleOf(0, 0),
        _middleOf(0, 1),
        _aboveTheGrid(1),
        const Offset(-40, -40),
      ]),
      [const Spot(0, 0), const Spot(0, 1)],
    );
  });

  test('picks the trace up again where the thumb comes back on', () {
    expect(
      _thumbWent([
        _middleOf(0, 0),
        _aboveTheGrid(0),
        _aboveTheGrid(1),
        _middleOf(0, 1),
      ]),
      [const Spot(0, 0), const Spot(0, 1)],
    );
  });

  test('will not join two squares the thumb reached round the outside', () {
    // Off the top of the board at the first column and back on at the fourth.
    // Those two do not touch, and a trace that jumped between them is one the
    // board would refuse, so it is never built in the first place.
    expect(
      _thumbWent([
        _middleOf(0, 0),
        _aboveTheGrid(0),
        _aboveTheGrid(3),
        _middleOf(0, 3),
      ]),
      [const Spot(0, 0)],
    );
  });

  test('takes the whole diagonal a thumb flung across the board crossed', () {
    // One report from corner to corner, which is what a fast drag looks like
    // on a slow frame: five squares of travel and nothing in between.
    expect(
      _thumbWent([_middleOf(4, 0), _middleOf(0, 4)]),
      [
        const Spot(4, 0),
        const Spot(3, 1),
        const Spot(2, 2),
        const Spot(1, 3),
        const Spot(0, 4),
      ],
    );
  });

  test('survives a fling that ends a long way off the board', () {
    // A thumb thrown off the screen. The trace keeps what it crossed on the
    // way and the walk out to nowhere costs a bounded amount of work.
    expect(
      _thumbWent([_middleOf(2, 0), const Offset(9000, 9000)]),
      [const Spot(2, 0), const Spot(3, 1), const Spot(4, 2)],
    );
  });

  test('takes one square from a thumb that lands and does not move', () {
    expect(
      _thumbWent([_middleOf(1, 1), _middleOf(1, 1), _middleOf(1, 1)]),
      [const Spot(1, 1)],
    );
  });

  test('takes nothing from a thumb that lands between squares and stays', () {
    expect(
      _thumbWent([_cornerBelowRightOf(1, 1), _cornerBelowRightOf(1, 1)]),
      isEmpty,
    );
  });

  test('picks a trace up from nothing when the thumb finds the board late',
      () {
    // Landing off the grid is not the end of the drag: the first square the
    // thumb reaches starts the word.
    expect(
      _thumbWent([const Offset(2, 2), _middleOf(0, 0), _middleOf(0, 1)]),
      [const Spot(0, 0), const Spot(0, 1)],
    );
  });

  test('starts the next trace from nothing', () {
    final tracer = Tracer(_grid)
      ..begin(_middleOf(0, 0))
      ..extend(_middleOf(0, 1))
      ..begin(_middleOf(2, 2));
    expect(tracer.spots, [const Spot(2, 2)]);
  });
}
