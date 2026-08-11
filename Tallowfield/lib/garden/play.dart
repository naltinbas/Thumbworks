import 'code.dart';
import 'evening.dart';

/// An evening being read: the garden as found, and what has been said.
class Play {
  const Play._(this.evening, this.settled, this.slips);

  Play.of(Evening evening) : this._(evening, false, 0);

  final Evening evening;

  /// Whether the reading has been given and taken.
  final bool settled;

  /// Wrong taps so far.
  final int slips;

  int get seen => evening.seen;

  bool lit(int lamp) => seen & (1 << (lamp - 1)) != 0;

  /// Which hedges complain tonight.
  List<bool> get complaints => Code.complaints(seen);

  /// The lamp the tallies name, or nought for a quiet garden.
  int get named => Code.named(seen);

  /// Reads the garden as naming [lamp], nought for all's well. Right
  /// settles the evening; wrong is counted and the evening goes on.
  Play read(int lamp) {
    if (settled) return this;
    if (lamp == named) return Play._(evening, true, slips);
    return Play._(evening, false, slips + 1);
  }

  /// Whether the tallies told the truth tonight: they name exactly the
  /// draught's work only when the draught touched at most one lantern.
  bool get talliesTrue {
    if (evening.snuffed.isEmpty) return named == 0;
    if (evening.snuffed.length == 1) return named == evening.snuffed.single;
    return false;
  }
}
