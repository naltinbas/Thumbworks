/// One web, as it ships.
class Web {
  const Web({
    required this.name,
    required this.dots,
    required this.playerFirst,
    required this.standing,
    this.note,
  });

  final String name;
  final int dots;

  /// Whether the player weaves first.
  final bool playerFirst;

  /// The player's standing with best weaving on both sides: 1 the
  /// player can win, 0 the player can hold a draw, -1 the player
  /// loses however they weave.
  final int standing;

  final String? note;

  bool get winnable => standing >= 0;
}
