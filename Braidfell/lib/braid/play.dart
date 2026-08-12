import 'rules.dart';
import 'yard.dart';

/// A yard being braided. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.yard, this.bundles, this.work, this.before);

  factory Play.of(Yard yard) =>
      Play._(yard, List.of(yard.bundles), 0, null);

  final Yard yard;

  /// The bundles as they stand, in yard order.
  final List<int> bundles;

  /// Work done so far.
  final int work;

  final Play? before;

  bool get isDone => bundles.length == 1;

  /// Whether the finished skein met the asking.
  bool get met => isDone && work <= yard.asked;

  /// Braid two bundles by their places.
  Play braid(int one, int two) {
    if (isDone || one == two) return this;
    final joined = bundles[one] + bundles[two];
    final rest = <int>[
      for (var at = 0; at < bundles.length; at++)
        if (at != one && at != two) bundles[at],
      joined,
    ];
    return Play._(yard, rest, work + joined, this);
  }

  Play get back => before ?? this;

  /// The least the whole yard can finish for from here.
  int get floor => work + Rules.leastWork(bundles);

  /// The two lightest bundles' places, for the pointer; null when
  /// the yard is done.
  (int, int)? get lightest {
    if (isDone) return null;
    var one = 0;
    var two = 1;
    if (bundles[two] < bundles[one]) {
      one = 1;
      two = 0;
    }
    for (var at = 2; at < bundles.length; at++) {
      if (bundles[at] < bundles[one]) {
        two = one;
        one = at;
      } else if (bundles[at] < bundles[two]) {
        two = at;
      }
    }
    return (one, two);
  }
}
