/// One tilth: the board as the season starts.
class Tilth {
  const Tilth({
    required this.name,
    required this.board,
    required this.winnable,
    this.note,
  });

  final String name;

  /// Seeds by furrow, furrow one nearest the barn.
  final List<int> board;

  /// Whether the tilth can be played home. Written down here as well as
  /// worked out, so a test can hold the two against each other.
  final bool winnable;

  /// A sentence of its own this tilth has earned, said after the why, or
  /// null for the tilths whose story is the usual one.
  final String? note;

  int get seeds => board.fold(0, (sum, furrow) => sum + furrow);
}
