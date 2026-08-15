import 'fraction.dart';

/// One share on the sham: the fraction, the cuts allowed, and what
/// the sweep found.
class Loaf {
  const Loaf({
    required this.name,
    required this.num,
    required this.den,
    required this.cuts,
    required this.ways,
    this.note,
  });

  final String name;
  final int num;
  final int den;

  /// Cuts allowed, at most.
  final int cuts;

  /// Sets of cuts that make the share, by the sweep; nought for the
  /// hopeless.
  final int ways;

  /// One thing worth knowing about this share, said by the why.
  final String? note;

  Fraction get share => Fraction(num, den);

  bool get winnable => ways > 0;

  static const _words = {2: 'two', 3: 'three', 4: 'four'};

  /// The task, told in words for the ledger.
  String get task =>
      'cut $num/$den of a loaf as at most ${_words[cuts]} unit cuts, no two alike';
}
