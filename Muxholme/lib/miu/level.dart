import 'rules.dart';

/// One string on the sham: what to derive, in how many steps, and what
/// the sweep found.
class Level {
  const Level({
    required this.name,
    required this.target,
    required this.steps,
    required this.ways,
    required this.derivations,
    this.note,
  });

  final String name;

  /// The string to derive from MI.
  final String target;

  /// Steps allowed.
  final int steps;

  /// Derivations of so many steps that end at the target, by the sweep;
  /// nought for the hopeless.
  final int ways;

  /// Derivations of so many steps from MI, all of them.
  final int derivations;

  /// One thing worth knowing about this string, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  Rules get rules => const Rules();

  static const _words = {1: 'one', 2: 'two', 3: 'three', 5: 'five', 6: 'six'};

  /// The task, told in words for the ledger.
  String get task => 'derive $target from MI in ${_words[steps] ?? '$steps'} step${steps == 1 ? '' : 's'}';
}
