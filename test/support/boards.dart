import 'package:cinderplot/game/field.dart';

/// A board written out as a picture, for the tests that need an exact one.
///
/// `*` is a mine and anything else is not. The opening square is given as a
/// cell number so a test can start the board where it means to.
Field boardOf(List<String> rows, {int opening = 0}) {
  final across = rows.first.length;
  final mines = <int>{};
  for (var row = 0; row < rows.length; row++) {
    for (var column = 0; column < across; column++) {
      if (rows[row][column] == '*') mines.add(row * across + column);
    }
  }
  return Field(
    across: across,
    down: rows.length,
    mines: mines,
    opening: opening,
  );
}

/// The cell number of a row and column, for reading a test back.
int at(Field field, int row, int column) => row * field.across + column;
