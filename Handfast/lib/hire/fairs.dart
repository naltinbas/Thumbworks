import 'fair.dart';
import 'most.dart';

/// One day at the fair, ready to be worked out.
class Day {
  Day({required this.fair, required this.most});

  final Fair fair;

  /// The most jobs that can be covered. Written down here as well as worked
  /// out, so that a test can hold the two against each other.
  final int most;

  String get name => fair.name;
}

/// The days that ship.
///
/// The first three can be covered entirely. The rest cannot, and the
/// interesting part of each is which jobs go undone and why.
/// Every one of them came out of `make find`, which throws away any fair where
/// working down the board and giving each job to the first free hand happens
/// to be the answer.
class Days {
  const Days._();

  static final List<Day> all = [
    _ladyDay(),
    _whitsun(),
    _michaelmas(),
    _theStatuteFair(),
    _martinmas(),
    _theLongList(),
    _theWholeParish(),
  ];

  static int get count => all.length;

  static Day at(int number) => all[number.clamp(0, all.length - 1)];

  /// Worked out once, when a day is opened.
  static Hiring answerFor(int number) => Hirings.most(at(number).fair);

  static Day _ladyDay() => Day(
        most: 6,
        fair: Fair(
          name: 'Lady Day',
          work: const [
            'Hedging',
            'Ditching',
            'Thatching',
            'Carting',
            'Milking',
            'Malting',
          ],
          hands: const [
            'Turner',
            'Fletcher',
            'Hobbs',
            'Wray',
            'Cade',
            'Blount',
          ],
          whoCan: const [
            {1, 3, 4},
            {3},
            {0, 5},
            {1},
            {2, 5},
            {0},
          ],
        ),
      );

  static Day _whitsun() => Day(
        most: 6,
        fair: Fair(
          name: 'Whitsun',
          work: const [
            'Shearing',
            'Threshing',
            'Ploughing',
            'Hurdling',
            'Coppicing',
            'Reaping',
          ],
          hands: const [
            'Marsden',
            'Pike',
            'Gerrard',
            'Rudd',
            'Nye',
            'Betts',
          ],
          whoCan: const [
            {0, 2, 4, 5},
            {1},
            {0, 1, 3, 5},
            {4, 5},
            {0, 2, 5},
            {2, 3},
          ],
        ),
      );

  static Day _theStatuteFair() => Day(
        most: 6,
        fair: Fair(
          name: 'The Statute Fair',
          work: const [
            'Hedging',
            'Byre work',
            'Ditching',
            'Sawing',
            'Dairy work',
            'Carting',
            'Wall mending',
          ],
          hands: const [
            'Swaine',
            'Ackroyd',
            'Hobbs',
            'Cade',
            'Wray',
            'Nye',
            'Blount',
          ],
          whoCan: const [
            {2, 4},
            {2},
            {0, 5},
            {1, 4, 6},
            {2},
            {0, 1, 3, 5},
            {3},
          ],
        ),
      );

  static Day _martinmas() => Day(
        most: 7,
        fair: Fair(
          name: 'Martinmas',
          work: const [
            'Threshing',
            'Thatching',
            'Malting',
            'Hedging',
            'Ditching',
            'Carting',
            'Shearing',
            'Coppicing',
          ],
          hands: const [
            'Turner',
            'Fletcher',
            'Marsden',
            'Rudd',
            'Pike',
            'Betts',
            'Gerrard',
            'Sillitoe',
          ],
          whoCan: const [
            {0, 1, 2, 3, 7},
            {0, 4, 7},
            {4, 5, 7},
            {0, 1, 4, 5},
            {0, 7},
            {4, 7},
            {0, 4},
            {3, 4, 5, 6},
          ],
        ),
      );

  static Day _theLongList() => Day(
        most: 7,
        fair: Fair(
          name: 'The Long List',
          work: const [
            'Hurdling',
            'Reaping',
            'Ploughing',
            'Milking',
            'Sawing',
            'Wall mending',
            'Byre work',
            'Dairy work',
          ],
          hands: const [
            'Ackroyd',
            'Swaine',
            'Hobbs',
            'Nye',
            'Cade',
            'Wray',
            'Blount',
            'Fletcher',
          ],
          whoCan: const [
            {1, 4, 5},
            {2, 5},
            {2, 4, 7},
            {1, 2},
            {0, 4, 7},
            {0, 1, 3, 4, 6},
            {1, 5, 7},
            {2, 4},
          ],
        ),
      );

  static Day _michaelmas() => Day(
        most: 8,
        fair: Fair(
          name: 'Michaelmas',
          work: const [
            'Thatching',
            'Hedging',
            'Ditching',
            'Threshing',
            'Malting',
            'Carting',
            'Shearing',
            'Coppicing',
          ],
          hands: const [
            'Turner',
            'Sillitoe',
            'Marsden',
            'Pike',
            'Rudd',
            'Betts',
            'Gerrard',
            'Cade',
          ],
          whoCan: const [
            {0, 1, 2, 3},
            {0, 1, 3},
            {6},
            {0, 1, 2, 3, 6, 7},
            {1, 3, 4, 5},
            {1, 2, 3, 6},
            {0, 3, 4, 5},
            {0, 2, 4, 5, 7},
          ],
        ),
      );

  static Day _theWholeParish() => Day(
        most: 7,
        fair: Fair(
          name: 'The Whole Parish',
          work: const [
            'Hedging',
            'Ditching',
            'Thatching',
            'Sawing',
            'Milking',
            'Ploughing',
            'Reaping',
            'Byre work',
            'Wall mending',
          ],
          hands: const [
            'Wray',
            'Hobbs',
            'Nye',
            'Swaine',
            'Cade',
            'Ackroyd',
            'Blount',
            'Rudd',
          ],
          whoCan: const [
            {0, 3, 5, 6, 7},
            {0, 2, 3, 6},
            {0, 4},
            {4, 7},
            {0, 1},
            {4, 6, 7},
            {1, 4, 6},
            {0, 7},
            {0, 4},
          ],
        ),
      );
}
