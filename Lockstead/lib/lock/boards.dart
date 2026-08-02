import 'lock.dart';

/// A lock to pick, with a name and the promise that comes with it.
class Board {
  const Board({
    required this.name,
    required this.about,
    required this.lock,
    required this.inside,
  });

  final String name;

  /// What makes this one different, in a few words.
  final String about;

  final Lock lock;

  /// The most guesses this lock ever needs, played the way the game plays it.
  ///
  /// Not a target and not a par somebody managed once. A test walks the whole
  /// strategy tree — every code in the lock is a leaf of it — and fails if the
  /// deepest leaf is not this number.
  final int inside;

  int get codes => lock.codes;
}

class Boards {
  const Boards._();

  static const all = <Board>[
    Board(
      name: 'The garden gate',
      about: 'Four pegs, six colours',
      lock: Lock(pegs: 4, colours: 6),
      inside: 5,
    ),
    Board(
      name: 'The strongbox',
      about: 'Five pegs, five colours',
      lock: Lock(pegs: 5, colours: 5),
      inside: 6,
    ),
    Board(
      name: 'The vault',
      about: 'Four pegs, eight colours',
      lock: Lock(pegs: 4, colours: 8),
      inside: 6,
    ),
  ];

  static int get count => all.length;

  static Board at(int which) => all[which.clamp(0, all.length - 1)];
}
