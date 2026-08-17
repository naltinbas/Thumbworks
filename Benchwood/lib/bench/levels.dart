import 'level.dart';

/// The five asks, first to last. Each ways count is the sweep's, and
/// the checker refuses the bake if one drifts. The numbers inside the
/// notes are the same sweep's, written out by hand.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The First Card',
      card: [0, 1, 0, 2, 1, 3, 2, 0],
      slots: 2,
      walks: 5,
      ways: 2,
      runs: 19,
      note: 'Eight calls on a bench of two slots. Five walks is the fewest '
          'there is, and two of the 19 ways of playing the card manage it. '
          'Carrying back whatever has been down longest also takes five '
          'here, which is luck rather than a rule.',
    ),
    Level(
      name: 'The Round',
      card: [0, 1, 2, 0, 1, 2],
      slots: 2,
      walks: 4,
      ways: 1,
      runs: 8,
      note: 'Three tools called round and round on a bench of two. Four '
          'walks is the fewest, and exactly one of the eight ways of playing '
          'the card manages it: carry back B when C is called, since A comes '
          'round sooner, and then A when B is called, since A is not called '
          'again at all. Carrying back the oldest tool takes six, a walk for '
          'every call.',
    ),
    Level(
      name: 'Belady\'s Card',
      card: [0, 1, 2, 3, 0, 1, 4, 0, 1, 2, 3, 4],
      slots: 3,
      walks: 7,
      ways: 5,
      runs: 1377,
      note: 'The card Belady, Nelson and Shedler wrote up in 1969, on a '
          'bench of three slots. Seven walks is the fewest, and five of the '
          '1,377 ways of playing the card manage it. Carrying back the '
          'oldest tool takes nine.',
    ),
    Level(
      name: 'The Fourth Slot',
      card: [0, 1, 2, 3, 0, 1, 4, 0, 1, 2, 3, 4],
      slots: 4,
      walks: 6,
      ways: 6,
      runs: 94,
      note: 'The same card with a fourth slot on the bench. The fewest '
          'walks falls from seven to six, as more room ought to mean fewer '
          'walks. Carrying back the oldest tool goes the other way and takes '
          'ten where it took nine, which is the anomaly the 1969 paper is '
          'about: a bigger bench, more walking.',
    ),
    Level(
      name: 'The Three Walks',
      card: [0, 1, 2, 0, 1, 2],
      slots: 2,
      walks: 3,
      ways: 0,
      runs: 8,
      note: 'Hopeless, and the card at the end of the ask says so. Three '
          'different tools have to be fetched at least once each, so three '
          'walks is a floor to begin with. After the third call the bench '
          'holds two of the three, so one is down in the store, and the last '
          'three calls ask for all three again. That is a fourth walk '
          'whatever was carried back. None of the eight ways of playing the '
          'card does it in three.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
