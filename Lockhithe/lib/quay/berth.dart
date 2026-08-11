/// One berth: how many sailors, and how many looks each gets.
class Berth {
  const Berth({
    required this.name,
    required this.lockers,
    this.note,
  });

  final String name;

  /// Sailors and lockers alike.
  final int lockers;

  /// A sentence of its own this berth has earned, said after the why, or
  /// null for the berths whose story is the usual one.
  final String? note;

  /// Half the lockers each, the classic allowance.
  int get looks => lockers ~/ 2;
}
