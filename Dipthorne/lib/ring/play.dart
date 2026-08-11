import 'fewest.dart';
import 'ring.dart';

/// A dip part run: who has stepped out, who still stands, where you stand.
class Play {
  const Play._(
    this.ring,
    this.chosen,
    this.standing,
    this.out,
    this.from,
  );

  Play.of(Ring ring)
      : this._(
          ring,
          -1,
          [for (var seat = 1; seat <= ring.children; seat++) seat],
          const [],
          0,
        );

  final Ring ring;

  /// The seat you stand in, 1-counted, or -1 while you are still choosing.
  final int chosen;

  /// The seats still in, in ring order.
  final List<int> standing;

  /// The seats out so far, in the order the rhyme found them.
  final List<int> out;

  /// Where in [standing] the next chant begins.
  final int from;

  bool get hasChosen => chosen != -1;

  /// Over: one child left, or the rhyme has found you.
  bool get isOver =>
      hasChosen && (standing.length == 1 || !standing.contains(chosen));

  bool get won => isOver && standing.length == 1 && standing.single == chosen;

  bool isIn(int seat) => standing.contains(seat);

  /// Takes a seat. Only before the rhyme starts.
  Play choose(int seat) {
    if (out.isNotEmpty || seat < 1 || seat > ring.children) return this;
    return Play._(ring, seat, standing, out, from);
  }

  /// The seat the next chant will land on, or null when it is over or
  /// nobody has been chosen yet.
  int? get landsOn {
    if (!hasChosen || isOver) return null;
    return standing[(from + ring.beats - 1) % standing.length];
  }

  /// One chant of the rhyme: the child it lands on steps out.
  Play step() {
    if (!hasChosen || isOver) return this;
    final at = (from + ring.beats - 1) % standing.length;
    final gone = standing[at];
    final fewer = [...standing]..removeAt(at);
    return Play._(
      ring,
      chosen,
      fewer,
      [...out, gone],
      at == fewer.length ? 0 : at,
    );
  }

  /// The safe seat, asked of the reckoning rather than the count.
  int get safe => Dips.byReckoning(ring.children, ring.beats);
}
