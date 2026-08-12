/// One task at the binding table: a stack of leaves and what the
/// binder wants of it.
class Quire {
  const Quire({
    required this.name,
    required this.start,
    this.seat,
    this.home = false,
    required this.weaves,
    this.note,
  });

  final String name;

  /// The stack as it lies at the off, top first. Leaf 0 is the
  /// plate, the engraved leaf the seat tasks follow.
  final List<int> start;

  /// Carry the plate to this seat, counted from the top, or null.
  final int? seat;

  /// Bring every leaf back to bound order instead.
  final bool home;

  /// Fewest weaves that do it; null when no weaving ever does, and
  /// the label says so.
  final int? weaves;

  /// One thing worth knowing about this quire, said by the why.
  final String? note;

  int get leaves => start.length;

  bool get winnable => weaves != null;

  /// Whether a stack settles this task.
  bool isDone(List<int> stack) {
    if (home) {
      for (var at = 0; at < stack.length; at++) {
        if (stack[at] != at) return false;
      }
      return true;
    }
    return stack[seat!] == 0;
  }
}
