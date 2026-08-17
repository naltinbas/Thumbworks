import 'level.dart';

/// The five asks, first to last. Each count is the sweep's, and the
/// checker refuses the bake if one drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'In the Code',
      kind: 'code',
      ways: 30,
      fewest: 2,
      note: '30 of the 256 messages are in the code, which is more than any '
          'of the other eight sums gets: 28 messages come to one over nine, '
          '28 to two, 29 to three, and so on. Nine sums share 256 messages '
          'and they cannot share them evenly, so the largest class has at '
          'least 28, and this one has 30.',
    ),
    Level(
      name: 'Four Alight',
      kind: 'four',
      ways: 8,
      fewest: 3,
      note: '8 of the 30 messages in the code have four lamps lit. Four '
          'lamps out of eight can be chosen 70 ways, and the sums of their '
          'places run from 10 to 26, so only a few of the 70 land on 18 or '
          '27, the two multiples of nine in that range.',
    ),
    Level(
      name: 'The Dark Line',
      kind: 'dark',
      ways: 1,
      fewest: 3,
      note: 'One message of the 256, and it is in the code: no lamps lit '
          'means a sum of nothing, which is nothing over nine. A lamp going '
          'out of a dark line changes nothing the reader can see, and it '
          'puts a dark lamp back, which is right.',
    ),
    Level(
      name: 'All Alight',
      kind: 'lit',
      ways: 1,
      fewest: 5,
      note: 'One message of the 256, and it is in the code as well: 1 and 2 '
          'and on to 8 come to 36, which is four nines. The two extremes of '
          'the valley, every lamp dark and every lamp lit, are both messages '
          'the reader can mend.',
    ),
    Level(
      name: 'Fool the Reader',
      kind: 'fool',
      ways: 0,
      fewest: null,
      note: 'Hopeless, and the card at the end of the ask says so. Take any '
          'two different messages in the code and any lamp out of each: the '
          'seven lamps left can never look the same. If they did, the reader '
          'would have two messages to choose between and no way to choose, '
          'but the sums forbid it. All 30 messages in the code were tried '
          'with every one of their eight lamps out before the sham was '
          'built, 240 readings, and the reader got every one of them back.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
