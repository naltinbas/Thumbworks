import 'spindle.dart';

/// The jobs that ship.
///
/// Every number here is checked twice over: tool/check_spindles.dart
/// walks every board of each and refuses the bake if a written figure
/// is wrong, and the suite runs the doubling rule, the leapfrog
/// reckoning and the old iteration besides.
class Spindles {
  static const all = [
    Spindle(
      name: 'The Three Rounds',
      spindles: 3,
      rounds: 3,
      fewest: 7,
      note: 'Two to the three, less one. The walk of all 27 boards '
          'says the same, and so does the old iteration, played out '
          'move by move.',
    ),
    Spindle(
      name: 'The Full Hand',
      spindles: 3,
      rounds: 4,
      fewest: 15,
      note: 'Doubling and one more: each round added doubles the work '
          'and adds a move. The walk of all 81 boards agrees.',
    ),
    Spindle(
      name: 'The Long Patience',
      spindles: 3,
      rounds: 5,
      fewest: 31,
      note: 'Thirty one moves, and not one to spare: the walk of all '
          '243 boards found no shorter way, and the iteration lands '
          'home in exactly as many.',
    ),
    Spindle(
      name: 'The Fourth Spindle',
      spindles: 4,
      rounds: 5,
      fewest: 13,
      note: 'A fourth spindle cuts thirty one to thirteen. The '
          'leapfrog reckoning carries some rounds aside and doubles '
          'the rest; it was only proved right for four spindles in '
          '2014, and the walk of all 1,024 boards re-proves it here '
          'for this tower.',
    ),
    Spindle(
      name: 'The Six on Four',
      spindles: 4,
      rounds: 6,
      fewest: 17,
      note: 'Six rounds on four spindles: seventeen, by the leapfrog '
          'reckoning and by the walk of all 4,096 boards, the two '
          'never parting.',
    ),
    Spindle(
      name: 'The Wager',
      spindles: 3,
      rounds: 4,
      fewest: 15,
      wager: 14,
      note: 'The house bets you cannot bring the full hand home in '
          'fourteen. The house is safe the way Loyd was safe: the '
          'walk of all 81 boards holds no road home shorter than '
          'fifteen. Play it out and watch the floor hold.',
    ),
  ];

  static int get count => all.length;

  static Spindle at(int number) => all[number];
}
