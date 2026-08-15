import 'rules.dart';

/// One hand on the sham: the five cards, whether the card to hide is
/// chosen for you, and what the sweep found.
class Level {
  const Level({
    required this.name,
    required this.hand,
    this.hiddenFixed,
    required this.ways,
    required this.layouts,
    this.note,
  });

  final String name;

  /// The five cards dealt.
  final List<Playcard> hand;

  /// The card that must be hidden, when the level says so.
  final Playcard? hiddenFixed;

  /// Layouts the partner reads right, by the sweep; nought for the
  /// hopeless.
  final int ways;

  /// Layouts, all told: five to hide and twenty-four orders, or the
  /// twenty-four orders when the hidden card is fixed.
  final int layouts;

  /// One thing worth knowing about this hand, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  String get handWords => hand.map(Rules.name).join(' ');

  /// The task, told in words for the ledger.
  String get task => hiddenFixed == null
      ? 'hide one of $handWords and lay the other four so the partner names it'
      : 'hide ${Rules.name(hiddenFixed!)} of $handWords and lay the other four so the partner names it';
}
