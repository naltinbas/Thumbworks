import 'bench.dart';

/// The benches that ship.
///
/// The winnable ones have real choices, quotients of two and three where
/// the whole game turns. The Golden Bench is fifty five and thirty four,
/// consecutive Fibonacci: inside the gap, every cut forced, and the
/// count against you. The Near Run is the pair one step outside, where
/// the same forced walk comes out yours by a single ell of margin.
class Benches {
  const Benches._();

  static final List<Bench> all = [
    Bench(
      name: 'The First Bench',
      long: 25,
      short: 7,
      winnable: true,
      note: 'Twenty five against seven: the short bolt fits three times, '
          'so there is a real choice, and only one of the three cuts '
          'holds the bench.',
    ),
    Bench(name: 'The Long Bolt', long: 60, short: 37, winnable: true),
    Bench(
      name: 'The Near Run',
      long: 34,
      short: 21,
      winnable: true,
      note: 'Thirty four against twenty one, Fibonacci neighbours just '
          'outside the gap: thirty four squared is 1156, and the gap '
          'ends at 1155. One against, the whole game forced, and the '
          'count comes out yours. That is how thin the edge is.',
    ),
    Bench(
      name: 'The Golden Bench',
      long: 55,
      short: 34,
      winnable: false,
      note: 'Fifty five against thirty four, Fibonacci neighbours inside '
          'the gap: fifty five squared is 3025, one short of 3026. Every '
          'cut from here to the end is forced, the game is the Euclidean '
          'algorithm walking itself, and the parity is the mercer\'s. '
          'This bench is here to be felt, not held.',
    ),
    Bench(name: 'The Broad Cloth', long: 89, short: 24, winnable: true),
  ];

  static int get count => all.length;

  static Bench at(int number) => all[number.clamp(0, all.length - 1)];
}
