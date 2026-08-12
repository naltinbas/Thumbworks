/// One sash of the moor: its lights, and how many panes to set
/// without framing a window.
class Sash {
  const Sash({
    required this.name,
    required this.across,
    required this.down,
    required this.count,
    required this.ways,
    this.note,
  });

  final String name;

  /// Lights across and down.
  final int across;
  final int down;

  /// Panes the sash must take, window-free.
  final int count;

  /// Placings of the sweep that do it; nought on the hopeless
  /// sash, and the label says so.
  final int ways;

  /// One thing worth knowing about this sash, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  /// The task, told in words for the ledger.
  String get task => 'set $count panes in the '
      '$across-by-$down sash framing no window';
}
