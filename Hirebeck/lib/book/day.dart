/// One day of hirings, as it ships.
class Day {
  const Day({
    required this.name,
    required this.guests,
    required this.starts,
    required this.ends,
    required this.ask,
    required this.fullest,
    required this.ways,
    this.note,
  });

  final String name;

  /// Who wants the hall, hiring by hiring.
  final List<String> guests;

  /// Their hours, o'clock to o'clock.
  final List<int> starts;
  final List<int> ends;

  /// How many the day asks you to book.
  final int ask;

  /// The fullest any book can be, as the sweep counted.
  final int fullest;

  /// How many choices reach the fullest.
  final int ways;

  final String? note;

  bool get winnable => ask <= fullest;

  int get hirings => guests.length;
}
