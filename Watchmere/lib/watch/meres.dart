import 'mere.dart';

/// The five meres that ship.
///
/// Every number here is checked before the bake: the sweep of
/// every dialling, the named-pair arithmetic, and
/// tool/check_watches.dart refuses the lot if anything
/// disagrees.
class Meres {
  static const all = [
    Mere(
      name: 'The Three Watches',
      lengths: [4, 4, 4],
      opens: [0, 4, 8],
      pairs: 3,
      ways: 249,
      note: 'A shared hour comes free with the full ring: the '
          'latest riser and the earliest turner-in are a pair '
          'too, and the hour they share sits inside everybody.',
    ),
    Mere(
      name: 'The Pinch',
      lengths: [4, 4, 4],
      opens: [0, 4, 8],
      pairs: 3,
      common: 1,
      ways: 108,
      note: 'A hundred and eight diallings pinch the night to '
          'one shared hour: the latest riser starts exactly '
          'where the earliest turner-in finishes.',
    ),
    Mere(
      name: 'The Broken Ring',
      lengths: [4, 4, 4],
      opens: [0, 4, 8],
      pairs: 2,
      common: 0,
      ways: 156,
      note: 'Two overlaps never pinch: drop one pair from the '
          'ring and the shared hour goes with it. Only the '
          'full ring forces the night together.',
    ),
    Mere(
      name: 'The Four Watches',
      lengths: [6, 5, 4, 3],
      opens: [0, 6, 8, 9],
      pairs: 6,
      ways: 1206,
      note: 'Four watches, six pairs, and the law scales: the '
          'latest riser and the earliest turner-in still hand '
          'their shared hour to all four at once.',
    ),
    Mere(
      name: 'The Sundered Watch',
      lengths: [4, 4, 4],
      opens: [0, 4, 8],
      pairs: 3,
      common: 0,
      ways: 0,
      note: 'The pair that bars it is named in advance: '
          'whoever rises latest and whoever turns in earliest '
          'must overlap like any pair, and the hour they share '
          'belongs to everybody.',
    ),
  ];

  static int get count => all.length;

  static Mere at(int number) => all[number];
}
