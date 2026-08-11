import 'rules.dart';

/// One ferry job, as it ships.
class Ferry {
  const Ferry({
    required this.name,
    required this.keeper,
    required this.each,
    required this.capacity,
    required this.fewest,
    required this.reach,
    this.note,
  });

  final String name;

  /// Whether this is the keeper's crossing rather than a counted
  /// party.
  final bool keeper;

  /// For counted parties, how many of each kind.
  final int each;

  final int capacity;

  /// The fewest crossings, or null for a ferry that never fills its
  /// far bank.
  final int? fewest;

  /// How many arrangements the walk reaches from the start.
  final int reach;

  final String? note;

  bool get winnable => fewest != null;

  /// The rules, built fresh: the walk is cheap at these sizes.
  Rules rules() {
    if (keeper) {
      return Rules(
        names: const ['the keeper', 'the wolf', 'the goat', 'the cabbage'],
        rowers: const [true, false, false, false],
        capacity: capacity,
        safe: (bank) {
          if (bank.contains(0)) return true;
          final wolf = bank.contains(1);
          final goat = bank.contains(2);
          final cabbage = bank.contains(3);
          return !(wolf && goat) && !(goat && cabbage);
        },
      );
    }
    return Rules(
      names: [
        for (var m = 0; m < each; m++) 'missionary ${m + 1}',
        for (var c = 0; c < each; c++) 'cannibal ${c + 1}',
      ],
      rowers: List.filled(each * 2, true),
      capacity: capacity,
      safe: (bank) {
        final m = bank.where((who) => who < each).length;
        final c = bank.length - m;
        return m == 0 || m >= c;
      },
    );
  }
}
