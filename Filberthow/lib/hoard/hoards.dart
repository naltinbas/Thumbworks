import 'hoard.dart';

/// The hoards that ship.
///
/// The winnable ones split into two or three clusters, and the smallest
/// cluster is always the take. The Fibonacci hoard is one cluster whole:
/// its smallest cluster is itself, out of every opener's reach, and it
/// ships labelled in the house tradition of maps nobody can win.
class Hoards {
  const Hoards._();

  static final List<Hoard> all = [
    Hoard(
      name: 'The Twenty',
      nuts: 20,
      winnable: true,
      note: 'Twenty splits into thirteen, five and two. Take the two: '
          'what is left splits cleanly, and the grey squirrel can never '
          'reach a whole cluster.',
    ),
    Hoard(
      name: 'The Thirty',
      nuts: 30,
      winnable: true,
      note: 'Thirty is twenty one, eight and one: the winning first take '
          'is a single nut, and anything bolder loses.',
    ),
    Hoard(
      name: 'The Fibonacci Hoard',
      nuts: 34,
      winnable: false,
      note: 'Thirty four is a Fibonacci number: one cluster, whole. The '
          'smallest cluster is the hoard itself, no opener may take it '
          'all, and every other take hands the grey squirrel a split it '
          'can work. This hoard is here to be felt, not won.',
    ),
    Hoard(name: 'The Three Clusters', nuts: 43, winnable: true),
    Hoard(
      name: 'The Long Hoard',
      nuts: 54,
      winnable: true,
      note: 'Fifty four is thirty four, thirteen, five and two: four '
          'clusters, the deepest split on the shelf.',
    ),
  ];

  static int get count => all.length;

  static Hoard at(int number) => all[number.clamp(0, all.length - 1)];
}
