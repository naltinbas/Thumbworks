import 'rules.dart';

/// One crew on the sham: how many pirates, how much the captain is to
/// keep, and what the sweep found.
class Level {
  const Level({
    required this.name,
    required this.pirates,
    required this.keep,
    required this.ways,
    required this.plans,
    this.note,
  });

  final String name;

  /// Pirates aboard, the captain among them.
  final int pirates;

  /// The least the captain is to keep.
  final int keep;

  /// Plans that pass keeping that much, by the sweep; nought for the
  /// hopeless.
  final int ways;

  /// Plans keeping that much, all of them.
  final int plans;

  /// One thing worth knowing about this crew, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  static const gold = 10;

  Rules get rules => const Rules(gold);

  static const _words = {2: 'two', 3: 'three', 4: 'four', 5: 'five', 8: 'eight', 9: 'nine', 10: 'ten'};

  static String word(int n) => _words[n] ?? '$n';

  /// The task, told in words for the ledger.
  String get task =>
      'divide the ten coins among the ${word(pirates)} pirates so the plan passes and the captain keeps ${word(keep)} or more';
}
