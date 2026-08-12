/// One purse: the price asked, and whether a second way is the
/// asking.
class Purse {
  const Purse({
    required this.name,
    required this.price,
    this.secondWay = false,
    required this.ways,
    this.note,
  });

  final String name;

  /// The price to pay.
  final int price;

  /// Whether the asking is a payment DIFFERENT from the one the
  /// well already shows: the hopeless asking.
  final bool secondWay;

  /// Payments of the sweep that land it; nought on the hopeless
  /// purse, and the label says so.
  final int ways;

  /// One thing worth knowing about this purse, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  /// The task, told in words for the ledger.
  String get task => secondWay
      ? 'pay $price a second way, unlike the way shown'
      : 'pay $price in coins with no two neighbours';
}
