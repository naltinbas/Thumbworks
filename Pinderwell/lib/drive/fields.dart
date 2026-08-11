import 'field.dart';

/// The fields that ship.
///
/// The pars run two, three, four, four, and the two fours are different
/// shapes of drive: one with the ewe far north of the pen, one far east.
/// Every par was worked out by the search before it was written down, and a
/// test holds the two against each other.
///
/// The Pinder's Ewe starts on a cold square, three east and five north,
/// which is the third rung of the ladder. However she is driven, the pinder
/// has an answer back to the ladder, all the way down to the pen. It ships
/// labelled, in the house tradition of maps nobody can win: the way to
/// believe a safe square is to stand on one and lose.
class Fields {
  const Fields._();

  static final List<Field> all = [
    Field(name: 'The First Field', east: 4, north: 2, fewest: 2),
    Field(name: 'The Long Acre', east: 8, north: 6, fewest: 3),
    Field(name: 'The High Pasture', east: 7, north: 10, fewest: 4),
    Field(name: 'The Great Close', east: 12, north: 7, fewest: 4),
    Field(name: "The Pinder's Ewe", east: 3, north: 5, fewest: null),
  ];

  static int get count => all.length;

  static Field at(int number) => all[number.clamp(0, all.length - 1)];
}
