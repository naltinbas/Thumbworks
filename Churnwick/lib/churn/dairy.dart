/// The dairy: churns of fixed sizes, a pump to fill them from and a drain to
/// empty them into.
///
/// A churn can be filled to the brim, emptied out, or poured into another one
/// until the first is empty or the second is full. There is nothing else to
/// do and no way to measure by eye, which is what makes it a puzzle rather
/// than a chore.
class Dairy {
  Dairy({
    required this.name,
    required List<int> churns,
    required this.want,
  }) : churns = List.unmodifiable(churns);

  final String name;

  /// How much each churn holds, in gallons.
  final List<int> churns;

  /// The amount that has to be standing in one of them.
  final int want;

  int get count => churns.length;

  int get biggest => churns.reduce((one, other) => one > other ? one : other);

  /// Nothing in any of them.
  List<int> get empty => List.filled(count, 0);

  bool isDone(List<int> standing) => standing.contains(want);
}

/// What was done to get from one arrangement of milk to the next.
class Pour {
  const Pour.fill(this.churn) : into = -1;
  const Pour.empty(this.churn) : into = -2;
  const Pour.tip(this.churn, this.into);

  /// The churn that was picked up.
  final int churn;

  /// The churn it went into, or -1 for the pump and -2 for the drain.
  final int into;

  bool get isFill => into == -1;
  bool get isEmpty => into == -2;
  bool get isTip => into >= 0;

  /// Does it, and gives back what is standing afterwards.
  List<int> on(Dairy dairy, List<int> standing) {
    final next = List.of(standing);
    if (isFill) {
      next[churn] = dairy.churns[churn];
    } else if (isEmpty) {
      next[churn] = 0;
    } else {
      final room = dairy.churns[into] - next[into];
      final moved = next[churn] < room ? next[churn] : room;
      next[churn] -= moved;
      next[into] += moved;
    }
    return next;
  }

  /// Whether it would change anything. Pouring into a full churn or emptying
  /// an empty one is not a move, it is a wasted walk across the dairy.
  bool doesAnything(Dairy dairy, List<int> standing) {
    if (isFill) return standing[churn] < dairy.churns[churn];
    if (isEmpty) return standing[churn] > 0;
    if (churn == into) return false;
    return standing[churn] > 0 && standing[into] < dairy.churns[into];
  }

  @override
  bool operator ==(Object other) =>
      other is Pour && other.churn == churn && other.into == into;

  @override
  int get hashCode => Object.hash(churn, into);
}

/// Everything worth doing from an arrangement of milk.
List<Pour> pouringsFrom(Dairy dairy, List<int> standing) => [
      for (var churn = 0; churn < dairy.count; churn++) ...[
        Pour.fill(churn),
        Pour.empty(churn),
        for (var into = 0; into < dairy.count; into++)
          if (into != churn) Pour.tip(churn, into),
      ],
    ].where((pour) => pour.doesAnything(dairy, standing)).toList();
