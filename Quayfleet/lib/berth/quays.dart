import 'most.dart';
import 'quay.dart';

/// One day at the quay, ready to be worked.
class Day {
  Day({required this.quay, required this.most});

  final Quay quay;

  /// The most ships that can be berthed. Written down here as well as worked
  /// out, so that a test can hold the two against each other.
  final int most;

  String get name => quay.name;
}

/// The days that ship.
///
/// The first two are there to teach. Every one after them came out of
/// `make find`, which makes days up and keeps only the ones where both of the
/// obvious ways of working through the book come out short: taking whoever
/// comes alongside first, and taking the shortest stay first. A day where
/// either of those happens to be right teaches nothing.
class Days {
  const Days._();

  static final List<Day> all = [
    _slackWater(),
    _theMorningTide(),
    _springTide(),
    _theHerringRun(),
    _michaelmas(),
    _neapTide(),
    _theWholeSeason(),
  ];

  static int get count => all.length;

  static Day at(int number) => all[number.clamp(0, all.length - 1)];

  /// Worked out once, when a day is opened.
  static Berthing answerFor(int number) => Berthings.most(at(number).quay);

  /// Four ships, and one of them sits across the middle of the day. Leave that
  /// one out and the other three all fit.
  static Day _slackWater() => Day(
        most: 3,
        quay: Quay(
          name: 'Slack Water',
          opens: 8,
          shuts: 16,
          ships: const [
            Ship('Kittiwake', 8, 10),
            Ship('Sea Pink', 9, 15),
            Ship('Redwing', 11, 13),
            Ship('Curlew', 13, 16),
          ],
        ),
      );

  /// The first day where taking whoever comes alongside first is wrong. The
  /// Providence is alongside before anybody, and she holds the berth so long
  /// that two ships are turned away for her.
  static Day _theMorningTide() => Day(
        most: 3,
        quay: Quay(
          name: 'The Morning Tide',
          opens: 6,
          shuts: 16,
          ships: const [
            Ship('Providence', 6, 12),
            Ship('Marigold', 7, 9),
            Ship('Osprey', 9, 11),
            Ship('Whimbrel', 11, 14),
            Ship('Bess of Wells', 13, 16),
          ],
        ),
      );

  static Day _springTide() => Day(
        most: 3,
        quay: Quay(
          name: 'Spring Tide',
          opens: 6,
          shuts: 18,
          ships: const [
            Ship('Nancy Brig', 13, 16),
            Ship('Guillemot', 11, 15),
            Ship('Ann Cleeve', 12, 14),
            Ship('Turnstone', 11, 13),
            Ship('Ebb Tide', 10, 13),
            Ship('Mary Ann', 6, 11),
            Ship('Fastnet', 13, 18),
          ],
        ),
      );

  static Day _theHerringRun() => Day(
        most: 3,
        quay: Quay(
          name: 'The Herring Run',
          opens: 6,
          shuts: 18,
          ships: const [
            Ship('Saltings', 11, 15),
            Ship('Lark', 10, 12),
            Ship('Whimbrel', 11, 13),
            Ship('Cormorant', 10, 15),
            Ship('Sanderling', 13, 16),
            Ship('Providence', 7, 11),
            Ship('Gannet', 12, 17),
          ],
        ),
      );

  static Day _michaelmas() => Day(
        most: 4,
        quay: Quay(
          name: 'Michaelmas',
          opens: 6,
          shuts: 20,
          ships: const [
            Ship('Kestrel', 9, 11),
            Ship('Sea Pink', 7, 9),
            Ship('Redwing', 13, 15),
            Ship('Fastnet', 14, 19),
            Ship('Mary Ann', 7, 11),
            Ship('Dunlin', 12, 14),
            Ship('Peewit', 9, 10),
            Ship('Bess of Wells', 11, 16),
            Ship('Osprey', 13, 18),
          ],
        ),
      );

  static Day _neapTide() => Day(
        most: 4,
        quay: Quay(
          name: 'Neap Tide',
          opens: 6,
          shuts: 20,
          ships: const [
            Ship('Guillemot', 11, 15),
            Ship('Nightjar', 17, 19),
            Ship('Ann Cleeve', 16, 18),
            Ship('Marigold', 10, 12),
            Ship('Curlew', 15, 20),
            Ship('Lapwing', 8, 10),
            Ship('Nancy Brig', 16, 20),
            Ship('Turnstone', 18, 20),
            Ship('Kittiwake', 7, 9),
          ],
        ),
      );

  static Day _theWholeSeason() => Day(
        most: 5,
        quay: Quay(
          name: 'The Whole Season',
          opens: 5,
          shuts: 21,
          ships: const [
            Ship('Ebb Tide', 7, 9),
            Ship('Cormorant', 5, 10),
            Ship('Fastnet', 18, 21),
            Ship('Bess of Wells', 13, 18),
            Ship('Peewit', 18, 19),
            Ship('Saltings', 11, 15),
            Ship('Lapwing', 8, 10),
            Ship('Sanderling', 14, 17),
            Ship('Providence', 6, 11),
            Ship('Wren', 19, 20),
            Ship('Gannet', 15, 18),
          ],
        ),
      );
}
