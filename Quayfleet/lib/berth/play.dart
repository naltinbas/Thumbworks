import 'most.dart';
import 'quay.dart';

/// A day at the quay part way through.
class Play {
  Play._(this.quay, this.answer, this.taken);

  factory Play.of(Quay quay, Berthing answer) => Play._(quay, answer, const []);

  final Quay quay;

  /// The most that can be berthed, and the hours that prove it, worked out
  /// when the day opens.
  final Berthing answer;

  /// The ships that have been given the berth, in the order they were.
  final List<int> taken;

  int get most => answer.most;

  bool has(int ship) => taken.contains(ship);

  /// Whether a ship can still be given the berth.
  bool canTake(int ship) =>
      !has(ship) && !taken.any((other) => quay.clash(ship, other));

  /// The ship already in the berth that a ship clashes with, or -1.
  int clashFor(int ship) {
    for (final other in taken) {
      if (quay.clash(ship, other)) return other;
    }
    return -1;
  }

  /// The ships that could still be taken.
  Set<int> get stillFree => {
        for (var ship = 0; ship < quay.count; ship++)
          if (canTake(ship)) ship,
      };

  /// Nothing else will fit. The day is over whether it went well or not.
  bool get isDone => stillFree.isEmpty;

  bool get isMost => taken.length == most;

  /// The most this day can still come to, counting what is already berthed.
  ///
  /// The same method, run over the ships that do not clash with anything
  /// already in the berth. It is a different question from the one answered
  /// when the day opened, and just as cheap.
  int get couldStillGet =>
      taken.length + Berthings.most(quay, only: stillFree).most;

  Play take(int ship) {
    if (ship < 0 || ship >= quay.count) return this;
    if (has(ship)) return Play._(quay, answer, [...taken]..remove(ship));
    if (!canTake(ship)) return this;
    return Play._(quay, answer, [...taken, ship]);
  }

  Play get again => Play.of(quay, answer);

  /// Asked. A ship to take next that still leaves the day as good as it can
  /// now be. Worked out from what is in the berth rather than read off the
  /// answer the day opened with, so it is still right after a mistake.
  int? get next {
    final free = stillFree;
    if (free.isEmpty) return null;

    var best = -1;
    var most = -1;
    for (final ship in free) {
      final after = take(ship).couldStillGet;
      if (after > most) {
        most = after;
        best = ship;
      }
    }
    return best < 0 ? null : best;
  }
}
