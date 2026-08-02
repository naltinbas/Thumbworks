import 'reason.dart';

/// A board to play on, and how hard it is allowed to be.
///
/// Difficulty here is not how many mines there are. It is which kind of
/// reasoning the board may ask for — and because a board is only kept if the
/// solver finished it with the rules named here, the difficulty on the label
/// is the difficulty in the box.
class Plot {
  const Plot({
    required this.name,
    required this.about,
    required this.across,
    required this.down,
    required this.mines,
    required this.needs,
  });

  final String name;

  /// What kind of thinking this one asks for, in a few words.
  final String about;

  final int across;
  final int down;
  final int mines;

  /// The rule a board of this size needs: no more than this, and no less.
  ///
  /// Both halves matter. No more, because a board that asks for reasoning the
  /// size did not promise is a board that will be called unfair. No less,
  /// because a board that could have been finished by counting is not the
  /// puzzle somebody picked when they picked this one.
  final Rule needs;

  int get cells => across * down;
  double get density => mines / cells;
}

class Plots {
  const Plots._();

  static const all = <Plot>[
    Plot(
      name: 'The paddock',
      about: 'One number at a time',
      across: 8,
      down: 10,
      mines: 10,
      needs: Rule.counted,
    ),
    Plot(
      name: 'The commons',
      about: 'Two numbers together',
      across: 9,
      down: 13,
      mines: 22,
      needs: Rule.subset,
    ),
    Plot(
      name: 'The quarry',
      about: 'Every way the mines could lie',
      across: 10,
      down: 16,
      mines: 38,
      needs: Rule.whole,
    ),
  ];

  static int get count => all.length;

  static Plot at(int which) => all[which.clamp(0, all.length - 1)];
}
