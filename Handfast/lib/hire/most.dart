import 'fair.dart';

/// The most work that can be taken on, and the reason there is no more.
class Hiring {
  const Hiring({
    required this.took,
    required this.short,
    required this.onlyThese,
  });

  /// The hand taken on for each job, or -1 for a job nobody does.
  final List<int> took;

  /// The jobs that cannot all be covered however they are handed out.
  ///
  /// Between them these jobs have fewer hands that can take any of them on
  /// than there are jobs in the list, so at least the difference has to go
  /// undone. It is a proof anybody can check by looking at the board: cover
  /// up every column but [onlyThese] and count the crosses that are left.
  final List<int> short;

  /// The only hands that can take on any of [short].
  final List<int> onlyThese;

  int get most => took.where((hand) => hand >= 0).length;

  /// How many jobs go undone whatever is done.
  int get undone => took.length - most;

  /// Whether the shortfall really accounts for every job left undone.
  bool get shortSaysSo => short.length - onlyThese.length == undone;
}

/// Works out the most work a fair can cover.
///
/// By taking the jobs one at a time and, for each, walking about looking for a
/// hand. If a hand who can do it is free, that is that. If not, each hand who
/// could do it is asked whether the job they are already on could be passed to
/// somebody else, and so on down the line. When that walk finds anybody free
/// at the end of it, every job on the chain shuffles along by one and one more
/// job gets covered. When it does not, this job goes undone and nothing that
/// happens later will change that.
///
/// The reason it stops there is the part worth having. Take the jobs nobody is
/// on, and every job that could be reached from them by that same walk. Every
/// hand who can take on any of those jobs is already on one of them, or the
/// walk would have found them free. So those jobs have exactly as many hands
/// between them as there are jobs in the list, less the ones nobody is on: a
/// set of jobs with too few hands, which is why no arrangement can do better.
/// That is Hall's condition from 1935, and it comes out of the same walk for
/// nothing.
class Hirings {
  const Hirings._();

  static Hiring most(Fair fair) {
    // Which job each hand is on, or -1.
    final onJob = List.filled(fair.people, -1);

    for (var job = 0; job < fair.jobs; job++) {
      _findAHand(fair, job, List.filled(fair.people, false), onJob);
    }

    final took = List.filled(fair.jobs, -1);
    for (var hand = 0; hand < fair.people; hand++) {
      if (onJob[hand] >= 0) took[onJob[hand]] = hand;
    }

    final (short, onlyThese) = _shortfall(fair, took, onJob);
    return Hiring(took: took, short: short, onlyThese: onlyThese);
  }

  static bool _findAHand(
    Fair fair,
    int job,
    List<bool> asked,
    List<int> onJob,
  ) {
    for (final hand in fair.whoCan[job]) {
      if (asked[hand]) continue;
      asked[hand] = true;
      if (onJob[hand] < 0 || _findAHand(fair, onJob[hand], asked, onJob)) {
        onJob[hand] = job;
        return true;
      }
    }
    return false;
  }

  /// The jobs that cannot be covered, and the hands they have between them.
  static (List<int>, List<int>) _shortfall(
    Fair fair,
    List<int> took,
    List<int> onJob,
  ) {
    final reached = <int>{};
    final hands = <int>{};
    final waiting = <int>[
      for (var job = 0; job < fair.jobs; job++)
        if (took[job] < 0) job,
    ];
    reached.addAll(waiting);

    while (waiting.isNotEmpty) {
      final job = waiting.removeLast();
      for (final hand in fair.whoCan[job]) {
        if (!hands.add(hand)) continue;
        final onIt = onJob[hand];
        if (onIt >= 0 && reached.add(onIt)) waiting.add(onIt);
      }
    }

    final short = reached.toList()..sort();
    final onlyThese = hands.toList()..sort();
    return (short, onlyThese);
  }

  /// The same question answered by trying every way of handing the work out.
  ///
  /// Slow and stupid on purpose. It is what holds the walk above to account
  /// rather than anything the game runs.
  static int byTrying(Fair fair) {
    var best = 0;

    void hand(int job, int taken, int so) {
      if (so + (fair.jobs - job) <= best) return;
      if (job == fair.jobs) {
        if (so > best) best = so;
        return;
      }
      for (final person in fair.whoCan[job]) {
        if (taken & (1 << person) != 0) continue;
        hand(job + 1, taken | (1 << person), so + 1);
      }
      hand(job + 1, taken, so);
    }

    hand(0, 0, 0);
    return best;
  }

  /// The smallest number of jobs that cannot be covered, found by looking at
  /// every set of jobs there is and counting the hands it can reach. Also here
  /// only to hold the walk to account.
  static int shortfallByTrying(Fair fair) {
    var worst = 0;
    for (var set = 1; set < (1 << fair.jobs); set++) {
      final jobs = [
        for (var job = 0; job < fair.jobs; job++)
          if (set & (1 << job) != 0) job,
      ];
      final over = jobs.length - fair.reachedBy(jobs).length;
      if (over > worst) worst = over;
    }
    return worst;
  }

  /// What somebody gets by working down the board and giving each job to the
  /// first free hand who can take it on. It is what anybody does and it is
  /// often not the most.
  static List<int> byWorkingDown(Fair fair) {
    final took = List.filled(fair.jobs, -1);
    final busy = List.filled(fair.people, false);

    for (var job = 0; job < fair.jobs; job++) {
      for (final hand in fair.whoCan[job].toList()..sort()) {
        if (busy[hand]) continue;
        busy[hand] = true;
        took[job] = hand;
        break;
      }
    }
    return took;
  }
}
