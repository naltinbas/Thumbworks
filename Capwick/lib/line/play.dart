import 'level.dart';
import 'rules.dart';

/// A line being called down. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.level, this.calls, this.moves, this.before);

  factory Play.of(Level level) => Play._(level, const [], 0, null);

  /// A play stood at a run of calls, for the mark and the tests.
  factory Play.standing(Level level, List<bool> calls) => Play._(level, List.of(calls), calls.length, null);

  final Level level;

  /// The calls made so far, from the back: true for black.
  final List<bool> calls;

  /// Calls made, counted.
  final int moves;

  final Play? before;

  int get n => level.prisoners;

  /// The caps as they stand: the deal, or, with the warden, the first
  /// man's cap set against his call once he has spoken.
  List<bool> get caps {
    final dealt = Rules.deal(n, level.dealt);
    if (level.warden && calls.isNotEmpty) dealt[0] = !calls[0];
    return dealt;
  }

  /// The prisoner whose turn it is, or n when all have called.
  int get current => calls.length;

  bool get allCalled => current == n;

  /// Whether call [i] was right; null when not yet made.
  bool? right(int i) => i < calls.length ? calls[i] == caps[i] : null;

  int get rightCount => [for (var i = 0; i < calls.length; i++) if (right(i)!) i].length;

  /// The black caps the current man sees ahead of him.
  int get blackAhead => allCalled ? 0 : Rules.blackAhead(caps, current);

  bool get isDone {
    if (!allCalled) return false;
    for (var i = level.warden ? 0 : 1; i < n; i++) {
      if (!right(i)!) return false;
    }
    return true;
  }

  /// All called and the ask not met: over, not landed.
  bool get missed => allCalled && !isDone;

  bool get gaveUp => !level.winnable && missed;

  bool get isOver => isDone || missed;

  bool get touches => !isOver && !allCalled;

  /// The current man calls black (true) or white (false).
  Play tap(bool black) {
    if (!touches) return this;
    return Play._(level, [...calls, black], moves + 1, this);
  }

  Play get back => before ?? this;

  /// What the show-me points at: the plan's call for the current man,
  /// ('black', i) or ('white', i); null when nothing lands.
  (String, int)? get next {
    if (isOver || !level.winnable || allCalled) return null;
    final call = Rules.planCall(caps, current, calls);
    return (call ? 'black' : 'white', current);
  }
}
