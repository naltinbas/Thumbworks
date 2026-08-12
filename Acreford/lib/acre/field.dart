/// One field: how many posts the fence takes, and what is
/// asked of the closed paddock.
class Field {
  const Field({
    required this.name,
    required this.posts,
    this.twoA,
    this.inside,
    this.midRail,
    required this.ways,
    this.note,
  });

  final String name;

  /// The posts the fence must walk, exactly.
  final int posts;

  /// Twice the acres asked, exactly; null for any.
  final int? twoA;

  /// Posts asked strictly inside, exactly; null for any.
  final int? inside;

  /// Whether a mid-rail post is asked (true), banned (false),
  /// or free (null).
  final bool? midRail;

  /// Paddocks of the sweep that land it; nought on the
  /// hopeless field, and the label says so.
  final int ways;

  /// One thing worth knowing about this field, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  /// The task, told in words for the ledger.
  String get task {
    final fence = 'fence ${acresWords(twoA)} with $posts posts';
    if (inside != null) {
      return 'fence a paddock of $posts posts holding exactly '
          '$inside post${inside == 1 ? '' : 's'} within';
    }
    if (midRail == false) {
      return '$fence and a bare rim';
    }
    return fence;
  }

  /// Half-acre counts, told in words.
  static String acresWords(int? twoA) {
    if (twoA == null) return 'any paddock at all';
    final whole = twoA ~/ 2;
    final half = twoA.isOdd;
    if (whole == 0) return 'half an acre';
    final acres = whole == 1
        ? (half ? 'an acre' : 'a whole acre')
        : '$whole acres';
    return half ? '$acres and a half' : acres;
  }
}
