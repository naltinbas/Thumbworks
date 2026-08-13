import 'feast.dart';

/// The five feasts that ship.
///
/// Every number here is checked before the bake: the sweeps of
/// all 64 and 1,024 feasts, the wallflower law on each, and
/// tool/check_clinks.dart refuses the lot if anything
/// disagrees.
class Feasts {
  static const all = [
    Feast(
      name: 'The One Count',
      guests: 5,
      asked: 1,
      ways: 14,
      note: 'Fourteen feasts level the table: the silent one, '
          'the full one, and the twelve rings where every '
          'guest clinks both neighbours.',
    ),
    Feast(
      name: 'The Two Counts',
      guests: 5,
      asked: 2,
      ways: 310,
      note: 'Three hundred and ten feasts settle on two '
          'counts; five hundred and eighty settle on three, '
          'the commonest lot of the thousand and twenty-four.',
    ),
    Feast(
      name: 'The Four Counts',
      guests: 5,
      asked: 4,
      ways: 120,
      note: 'Four different counts is the ceiling at five '
          'guests: a hundred and twenty feasts reach it, and '
          'not one goes further.',
    ),
    Feast(
      name: 'The Three of Four',
      guests: 4,
      asked: 3,
      ways: 24,
      note: 'Four guests cap at three different counts, '
          'twenty-four ways: the table shrinks and the law '
          'holds its shape.',
    ),
    Feast(
      name: 'The All Different',
      guests: 5,
      asked: 5,
      ways: 0,
      note: 'Five different counts among nought to four must '
          'use them all, and the wallflower who clinked '
          'nobody cannot sit with the toast of the table who '
          'clinked everyone, the wallflower included.',
    ),
  ];

  static int get count => all.length;

  static Feast at(int number) => all[number];
}
