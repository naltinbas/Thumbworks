import 'fair.dart';
import 'most.dart';

/// A day at the fair part way through.
class Play {
  Play._(this.fair, this.answer, this.took);

  factory Play.of(Fair fair, Hiring answer) =>
      Play._(fair, answer, List.filled(fair.jobs, -1));

  final Fair fair;

  /// The most that can be covered and the set of jobs that says why there is
  /// no more, worked out when the day opens.
  final Hiring answer;

  /// The hand taken on for each job, or -1.
  final List<int> took;

  int get most => answer.most;

  int handOn(int job) => took[job];

  /// The job a hand is already on, or -1.
  int jobOf(int hand) => took.indexOf(hand);

  bool isFree(int hand) => !took.contains(hand);

  int get covered => took.where((hand) => hand >= 0).length;

  /// Whether a job could still be given to a hand.
  bool canTake(int job, int hand) =>
      fair.can(job, hand) && took[job] < 0 && isFree(hand);

  /// The jobs nobody is on that no free hand could take.
  List<int> get stuck => [
        for (var job = 0; job < fair.jobs; job++)
          if (took[job] < 0 && !fair.whoCan[job].any(isFree)) job,
      ];

  /// Nothing else can be given out. The day is over whether it went well or
  /// not.
  bool get isDone => stuck.length == fair.jobs - covered;

  bool get isMost => covered == most;

  /// The most this day can still come to, counting what is already given out.
  ///
  /// The same walk, over the jobs nobody is on and the hands nobody has taken.
  /// A different question from the one answered when the day opened, and just
  /// as cheap.
  int get couldStillGet {
    final left = [
      for (var job = 0; job < fair.jobs; job++)
        if (took[job] < 0) job,
    ];
    if (left.isEmpty) return covered;

    final rest = Fair(
      name: fair.name,
      work: [for (final job in left) fair.work[job]],
      hands: fair.hands,
      whoCan: [
        for (final job in left) {for (final hand in fair.whoCan[job]) if (isFree(hand)) hand},
      ],
    );
    return covered + Hirings.most(rest).most;
  }

  Play take(int job, int hand) {
    if (job < 0 || job >= fair.jobs || hand < 0 || hand >= fair.people) {
      return this;
    }
    if (took[job] == hand) {
      final next = List.of(took);
      next[job] = -1;
      return Play._(fair, answer, next);
    }
    if (!canTake(job, hand)) return this;
    final next = List.of(took);
    next[job] = hand;
    return Play._(fair, answer, next);
  }

  Play let(int job) {
    if (job < 0 || took[job] < 0) return this;
    final next = List.of(took);
    next[job] = -1;
    return Play._(fair, answer, next);
  }

  Play get again => Play.of(fair, answer);

  /// Asked. A job and a hand to give it to that still leaves the day as good
  /// as it can now be. Worked out from what is already given out rather than
  /// read off the answer the day opened with, so it is still right after a
  /// mistake.
  (int, int)? get next {
    var best = (-1, -1);
    var most = -1;
    for (var job = 0; job < fair.jobs; job++) {
      if (took[job] >= 0) continue;
      for (final hand in fair.whoCan[job]) {
        if (!isFree(hand)) continue;
        final after = take(job, hand).couldStillGet;
        if (after > most) {
          most = after;
          best = (job, hand);
        }
      }
    }
    return best.$1 < 0 ? null : best;
  }
}
