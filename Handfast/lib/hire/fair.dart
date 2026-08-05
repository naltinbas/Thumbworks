/// A hiring fair: work that wants doing, and the hands standing about.
///
/// Each hand can take on some of the work and not the rest, and nobody can be
/// in two places at once. Every job is one hand's whole day.
class Fair {
  Fair({
    required this.name,
    required List<String> work,
    required List<String> hands,
    required List<Set<int>> whoCan,
  })  : work = List.unmodifiable(work),
        hands = List.unmodifiable(hands),
        whoCan = List.unmodifiable([
          for (final can in whoCan) Set<int>.unmodifiable(can),
        ]);

  final String name;

  /// The work, in the order it is written on the board.
  final List<String> work;

  /// The hands, in the order they are standing.
  final List<String> hands;

  /// For each job, the hands that can take it on.
  final List<Set<int>> whoCan;

  int get jobs => work.length;
  int get people => hands.length;

  bool can(int job, int hand) => whoCan[job].contains(hand);

  /// The hands that could take on any of a set of jobs, between them.
  Set<int> reachedBy(Iterable<int> jobs) => {
        for (final job in jobs) ...whoCan[job],
      };

  /// How many crosses there are on the board.
  int get marks => whoCan.fold(0, (sum, can) => sum + can.length);
}
