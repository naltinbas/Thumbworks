import 'dart:collection';
import 'dart:math' as math;
import 'dart:ui';

import '../game/board.dart';
import 'grid_geometry.dart';

/// What the thumb has spelled so far, as a picture of one moment.
///
/// Passed to the painter and to whatever is showing the word, so both are
/// looking at the same trace rather than each asking the board again.
class Trace {
  const Trace({
    this.spots = const [],
    this.word = '',
    this.verdict = Refusal.tooShort,
    this.thumb,
    this.settling = false,
  });

  final List<Spot> spots;

  /// Lower case, the way the board spells it.
  final String word;

  /// What the board would say about the trace as it stands.
  final Refusal verdict;

  /// Where the finger is, in the view's own coordinates, or null once it has
  /// lifted.
  final Offset? thumb;

  /// The finger has gone and this is the trace being shown one last time
  /// before it clears.
  final bool settling;

  bool get isEmpty => spots.isEmpty;
  bool get isWord => verdict == Refusal.none;
}

/// Turns what a thumb does into a list of squares.
///
/// All the difficulty of this game's input is here, and none of it is about
/// widgets, so it is written against points and a geometry and can be tested
/// by saying where a thumb went.
class Tracer {
  Tracer(this.geometry);

  final GridGeometry geometry;

  final List<Spot> _spots = [];
  Offset? _from;

  /// The trace as it stands, oldest first.
  late final List<Spot> spots = UnmodifiableListView(_spots);

  /// A finger has landed.
  void begin(Offset point) {
    _spots.clear();
    _from = point;
    _take(point);
  }

  /// A finger has moved to [point].
  ///
  /// A pointer report can arrive a long way from the last one, especially on a
  /// slow frame, and a thumb thrown across three squares means all three. So
  /// the gap is walked in short steps rather than only its end being looked
  /// at, which is also what keeps a fast diagonal from skipping the square it
  /// went through.
  void extend(Offset point) {
    final from = _from ?? point;
    final steps = math.max(
      1,
      ((point - from).distance / (geometry.pitch * 0.25)).ceil(),
    );
    for (var step = 1; step <= steps; step++) {
      _take(Offset.lerp(from, point, step / steps)!);
    }
    _from = point;
  }

  void clear() {
    _spots.clear();
    _from = null;
  }

  void _take(Offset point) {
    final spot = geometry.claim(point);
    if (spot == null) return;
    if (_spots.isEmpty) {
      _spots.add(spot);
      return;
    }
    if (spot == _spots.last) return;

    // Going back over the square before the last one takes the last one off.
    // A thumb that has gone one square too far is the commonest mistake in
    // the game, and the fix for it should be to back up rather than to lift
    // and start the word again.
    if (_spots.length >= 2 && spot == _spots[_spots.length - 2]) {
      _spots.removeLast();
      return;
    }

    // Any other square already in the trace is a loop, and the board will not
    // have one. Ignoring it leaves the trace as it was, so the thumb can carry
    // on from where it is.
    if (_spots.contains(spot)) return;

    // A thumb that left the grid and came back somewhere unreachable. Refusing
    // to join them keeps every trace this makes a legal one, so the game never
    // has to tell a player their line was broken.
    if (!_spots.last.touches(spot)) return;

    _spots.add(spot);
  }
}
