import 'rules.dart';

/// One rota on the sham: the fixed shifts and what the sweep found.
class Rota {
  const Rota({
    required this.name,
    required this.fixed,
    required this.ways,
    this.note,
  });

  final String name;

  /// The shifts fixed before play, (day, station) to hand.
  final Map<Shift, int> fixed;

  /// Finished rotas that extend the fixed shifts, by the sweep;
  /// nought for the hopeless.
  final int ways;

  /// One thing worth knowing about this rota, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  static const _words = {1: 'one', 2: 'two', 3: 'three', 4: 'four'};

  /// The task, told in words for the ledger.
  String get task =>
      'finish the four-rota from ${_words[fixed.length]} fixed '
      'shift${fixed.length == 1 ? '' : 's'}';
}
