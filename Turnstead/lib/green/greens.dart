import 'green.dart';

/// The greens that ship.
///
/// Every playable card allows exactly sides-less-one rounds, which the
/// pigeonhole says is the least and the wheel says is enough. The Short
/// Card allows one fewer, and cannot be written: each side has five
/// sides to meet and four rounds to meet them in, said in one breath.
class Greens {
  const Greens._();

  static final List<Green> all = [
    Green(
      name: 'The Four Sides',
      sides: 4,
      rounds: 3,
      possible: true,
      note: 'Three rounds for three opponents each: the least the '
          'pigeonhole allows, and the wheel reaches it.',
    ),
    Green(name: 'The Six Sides', sides: 6, rounds: 5, possible: true),
    Green(
      name: 'The Short Card',
      sides: 6,
      rounds: 4,
      possible: false,
      note: 'Each side has five sides to meet and meets at most one a '
          'round: five rounds at the least, and this card allows four. '
          'That is the whole proof, said in one breath.',
    ),
    Green(
      name: 'The Eight Sides',
      sides: 8,
      rounds: 7,
      possible: true,
      note: 'Twenty eight matches in seven rounds of four. Pair freely '
          'and it is easy to strand; the wheel never does.',
    ),
    Green(name: 'The Ten Sides', sides: 10, rounds: 9, possible: true),
  ];

  static int get count => all.length;

  static Green at(int number) => all[number.clamp(0, all.length - 1)];
}
