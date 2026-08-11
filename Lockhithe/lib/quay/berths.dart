import 'berth.dart';

/// The berths that ship.
class Berths {
  const Berths._();

  static final List<Berth> all = [
    Berth(
      name: 'The Four Lockers',
      lockers: 4,
      note: 'Four sailors, two looks each. Guessing at random, the crew '
          'comes through one round in sixteen. Following the chits, five '
          'in twelve: the loops decide, and most stowings have no loop '
          'past two.',
    ),
    Berth(name: 'The Six Lockers', lockers: 6),
    Berth(
      name: 'The Eight Lockers',
      lockers: 8,
      note: 'The sweep of all 40,320 stowings counts 14,736 with no loop '
          'past four: 307 in 840, and the counting says the same without '
          'grinding.',
    ),
    Berth(
      name: 'The Full Crew',
      lockers: 10,
      note: 'Ten sailors at random come through one round in a thousand. '
          'Following the chits, better than one in three. The chits do '
          'not know where anything is; the loops were simply always '
          'there.',
    ),
  ];

  static int get count => all.length;

  static Berth at(int number) => all[number.clamp(0, all.length - 1)];
}
