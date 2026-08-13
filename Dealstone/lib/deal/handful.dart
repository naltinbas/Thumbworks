/// One handful: the stones to deal and the deals asked.
class Handful {
  const Handful({
    required this.name,
    required this.stones,
    required this.asked,
    required this.opens,
    required this.ways,
    this.note,
  });

  final String name;

  /// The stones in the hand.
  final int stones;

  /// Deals to the stair asked, exactly.
  final int asked;

  /// The piles the hand opens on.
  final List<int> opens;

  /// Hands of the sweep that land; nought on the hopeless
  /// handful, and the label says so.
  final int ways;

  /// One thing worth knowing about this handful, said by the
  /// why.
  final String? note;

  bool get winnable => ways > 0;

  /// The task, told in words for the ledger.
  String get task => asked == 0
      ? 'pile $stones stones into a hand the deal cannot move'
      : 'pile $stones stones into a hand exactly $asked '
          'deal${asked == 1 ? '' : 's'} from the stair';
}
