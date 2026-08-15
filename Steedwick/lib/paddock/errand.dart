import 'rules.dart';

/// What an errand asks of a standing.
enum Asked { paleOneBottomLeft, quarterTurn, palesDown, colourSwap, paleSwap }

/// One errand on the sham: what is asked, and what the ride found.
class Errand {
  const Errand({
    required this.name,
    required this.asked,
    required this.fewest,
    required this.rides,
    this.note,
  });

  final String name;
  final Asked asked;

  /// The fewest moves that land it; nought for the hopeless.
  final int fewest;

  /// How many fewest rides land it; nought for the hopeless.
  final int rides;

  /// One thing worth knowing about this errand, said by the why.
  final String? note;

  bool get winnable => rides > 0;

  /// Whether a standing meets the asking.
  bool meets(Standing s) => switch (asked) {
        Asked.paleOneBottomLeft => s[0] == 6,
        Asked.quarterTurn => s[0] == 2 && s[1] == 8 && s[2] == 0 && s[3] == 6,
        Asked.palesDown => {s[0], s[1]}.containsAll({6, 8}),
        Asked.colourSwap => {s[0], s[1]}.containsAll({6, 8}) && {s[2], s[3]}.containsAll({0, 2}),
        Asked.paleSwap => s[0] == 2 && s[1] == 0 && s[2] == 6 && s[3] == 8,
      };

  /// The task, told in words for the ledger.
  String get task => switch (asked) {
        Asked.paleOneBottomLeft => 'ride pale one to the bottom-left stall',
        Asked.quarterTurn => 'ride every steed one corner round, clockwise',
        Asked.palesDown => 'ride both pale steeds into the bottom corners',
        Asked.colourSwap => 'swap the pale steeds for the dark, corners for corners',
        Asked.paleSwap => 'swap the two pale steeds with each other, the dark ones home',
      };
}
