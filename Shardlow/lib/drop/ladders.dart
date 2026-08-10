import 'ladder.dart';

/// The ladders that ship.
///
/// The one pot morning is the lesson that a single pot allows no cleverness
/// at all: dropped from anywhere above the lowest unsettled rung, a break
/// would leave everything below it unaskable, so it has to go rung by rung.
/// After that the second pot changes everything, and the numbers grow the way
/// the counting says they must.
class Ladders {
  const Ladders._();

  static const all = <Ladder>[
    Ladder(name: 'One Pot', rungs: 6, pots: 1, fewest: 6),
    Ladder(name: 'The Second Pot', rungs: 10, pots: 2, fewest: 4),
    Ladder(name: 'The Yard Ladder', rungs: 15, pots: 2, fewest: 5),
    Ladder(name: 'The Long Ladder', rungs: 25, pots: 2, fewest: 7),
    Ladder(name: 'The Kiln Stair', rungs: 30, pots: 3, fewest: 6),
    Ladder(name: 'The Church Tower', rungs: 60, pots: 3, fewest: 7),
    Ladder(name: 'The Whole Works', rungs: 100, pots: 4, fewest: 8),
  ];

  static int get count => all.length;

  static Ladder at(int number) => all[number.clamp(0, all.length - 1)];
}
