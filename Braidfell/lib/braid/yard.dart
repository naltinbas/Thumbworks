/// One yard: its bundles and the work it asks for.
class Yard {
  const Yard({
    required this.name,
    required this.bundles,
    required this.asked,
    required this.least,
    this.note,
  });

  final String name;

  /// The bundle weights at the off.
  final List<int> bundles;

  /// Work asked for. On the hopeless yard this is under everything
  /// the sweep knows.
  final int asked;

  /// The least work any order needs, by both reckonings.
  final int least;

  /// One thing worth knowing about this yard, said by the why.
  final String? note;

  bool get winnable => asked >= least;

  /// The task, told in words for the ledger.
  String get task => 'one skein for $asked or less';
}
