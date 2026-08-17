import 'level.dart';

/// The five asks, first to last. Each ways count is the sweep's, and
/// the checker refuses the bake if one drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'Nothing Moved',
      kind: 'order',
      ways: 1,
      aim: [1, 2, 3, 4, 5, 6],
      note: 'One out-train of the 132 the siding can make, and the cheapest '
          'of the lot: every wagon rolls straight past the siding, six taps '
          'and nothing shunted. It is the only train the yard can make in six '
          'taps.',
    ),
    Level(
      name: 'Wagon One Last',
      kind: 'last',
      ways: 42,
      aim: [2, 3, 4, 5, 6, 1],
      note: '42 out-trains of the 132 leave wagon 1 until last, which is a '
          'third of them, and 42 is the Catalan number for five wagons. That '
          'is no accident: shunt wagon 1 onto the siding at the start and the '
          'other five can then leave in any order that same siding can make.',
    ),
    Level(
      name: 'The Odd Ones First',
      kind: 'odds',
      ways: 3,
      aim: [1, 3, 5, 4, 2, 6],
      note: 'Three out-trains of the 132 send 1, 3 and 5 out before 2, 4 and '
          '6, and all three take eight taps. They all begin 1, 3, 5: the odd '
          'wagons have to come out in the order they stand, because getting 3 '
          'out before 1 means shunting 1 and 2 onto the siding, and then 2 '
          'sits at the points ahead of 1.',
    ),
    Level(
      name: 'The Reversal',
      kind: 'order',
      ways: 1,
      aim: [6, 5, 4, 3, 2, 1],
      note: 'One out-train of the 132, and the dearest: five wagons shunted '
          'onto the siding, the sixth rolled straight past, and then the '
          'siding emptied one at a time. Eleven taps, and no train the yard '
          'can make costs more.',
    ),
    Level(
      name: 'Three, One, Two',
      kind: 'head',
      ways: 0,
      aim: null,
      note: 'Hopeless, and the card at the end of the ask says so. To send '
          'wagon 3 out first, wagons 1 and 2 must both go onto the siding, 1 '
          'and then 2, which leaves 2 at the points with 1 behind it. Only '
          'the wagon at the points can be sent, so 2 must leave before 1 and '
          'the order 3, 1, 2 is out of reach. Six of the 720 orders of six '
          'wagons begin that way and the siding can make none of them.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
