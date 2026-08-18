import 'rules.dart';

/// One ask: how many tables the guests are to sit at, and what else is
/// asked of them.
class Level {
  const Level({
    required this.name,
    required this.tables,
    required this.kind,
    required this.ways,
    required this.fewest,
    required this.note,
  });

  final String name;

  /// How many tables the seating is to have.
  final int tables;

  /// 'any': nothing more is asked. 'different': no two tables hold the
  /// same number. 'together': nobody sits on their own. 'same': every
  /// table holds the same number.
  final String kind;

  /// How many seatings land it. The sweep's number, and the checker
  /// refuses the bake if it drifts.
  final int ways;

  /// The moves from the opening to the nearest seating that lands it;
  /// null when none does.
  final int? fewest;

  /// Something worth knowing, written out by hand.
  final String note;

  bool get winnable => ways > 0;

  /// Whether this seating lands the ask.
  bool meets(List<List<int>> seating) {
    final tidied = Rules.tidy(seating);
    if (tidied.length != tables) return false;
    switch (kind) {
      case 'different':
        return Rules.allDifferent(tidied);
      case 'together':
        return Rules.nobodyAlone(tidied);
      case 'same':
        return Rules.sizes(tidied).toSet().length == 1;
      default:
        return true;
    }
  }

  /// The task, told in words.
  String get task => switch (kind) {
        'different' =>
          'seat the guests at $tables tables, no two holding the same number',
        'together' => 'seat the guests at $tables tables with nobody on '
            'their own',
        'same' => 'seat the guests at $tables tables holding the same number',
        _ => 'seat the guests at $tables tables',
      };
}
