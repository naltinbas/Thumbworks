/// One field of the marsh: its size, who steps first, and whether
/// the pie is on the table.
class Field {
  const Field({
    required this.name,
    required this.size,
    this.houseOpens,
    this.pieOffered = false,
    required this.winnable,
    this.note,
  });

  final String name;

  /// Tussocks along each side.
  final int size;

  /// The tussock the mere opens on, or null when you step first.
  final int? houseOpens;

  /// Whether the opening may be taken for your own: the pie rule.
  final bool pieOffered;

  /// Whether right play links your banks; the label says so when
  /// not.
  final bool winnable;

  /// One thing worth knowing about this field, said by the why.
  final String? note;

  /// The task, told in words for the ledger.
  String get task {
    if (houseOpens == null) return 'link west to east, stepping first';
    if (pieOffered) return 'judge the pie, then link west to east';
    return 'link west to east from the second chair';
  }
}
