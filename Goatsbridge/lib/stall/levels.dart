import 'level.dart';

/// The five asks, the last of them hopeless.
class Levels {
  static const all = [
    Level(
      name: 'Two in Three',
      kind: 'exact',
      num: 2,
      den: 3,
      ways: 1,
      note: 'Three doors and the host opening one: staying wins one game in '
          'three, the game where the first pick was right, and switching wins '
          'the other two, the cart being behind the one door the host left '
          'shut; of the 72 settings only this one wins two in three exactly.',
    ),
    Level(
      name: 'Three in Four',
      kind: 'exact',
      num: 3,
      den: 4,
      ways: 1,
      note: 'Four doors and the host opening two: switching wins three in four, '
          'staying one in four; with the host opening only one of the four, '
          'switching wins three in eight, still better than staying.',
    ),
    Level(
      name: 'Better Than Even',
      kind: 'over',
      num: 1,
      den: 2,
      ways: 8,
      note: 'Eight settings win more than half the games, and every one of them '
          'switches with the host opening all the doors but one, from three doors '
          'at two in three to ten doors at nine in ten; staying never passes one '
          'in three.',
    ),
    Level(
      name: 'The Least Gain',
      kind: 'least',
      ways: 1,
      note: 'Ten doors and the host opening only one: switching wins nine in '
          'eighty, 11.25 in a hundred, the least it ever does on the sham, and '
          'still more than staying\'s one in ten; the fewer doors the host opens '
          'the less switching gains, and it always gains.',
    ),
    Level(
      name: 'The Stay',
      kind: 'stay',
      ways: 0,
      note: 'Staying wins one game in n, the game where the first pick was right. '
          'When it was wrong, the cart is behind one of the other doors, the host '
          'opens only goats, and switching lands among fewer doors than the cart '
          'could be behind, n - 1 - k of them for the n - 1 it could be behind: so '
          'switching wins (n - 1)/n times 1/(n - 1 - k), more than 1/n whenever '
          'the host opens a door at all; in none of the 72 settings does staying '
          'win more, nor even as many.',
    ),
  ];

  static int get count => all.length;

  static Level at(int i) => all[i];
}
