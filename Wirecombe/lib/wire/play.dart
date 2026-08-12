import 'combe.dart';
import 'rules.dart';

/// A combe being wired. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.combe, this.rules, this.lines, this.picked, this.moves,
      this.before);

  factory Play.of(Combe combe) =>
      Play._(combe, Rules(combe.cottages), const [], null, 0, null);

  /// A play stood at a wiring, for the mark and the tests.
  factory Play.standing(Combe combe, List<(int, int)> lines) =>
      Play._(combe, Rules(combe.cottages), List.of(lines), null,
          lines.length, null);

  final Combe combe;
  final Rules rules;

  /// The lines as they stand.
  final List<(int, int)> lines;

  /// The cottage picked towards a line, or null.
  final int? picked;

  /// Wirings and unwirings taken, counted together.
  final int moves;

  final Play? before;

  /// The line past which the hopeless combe admits it.
  static const gaveUpAt = 12;

  List<int> get lanesEnds => rules.lanesEnds(lines);

  bool get looped => rules.loops(lines);

  int get pieces => rules.pieces(lines);

  bool get isDone =>
      rules.isRun(lines) &&
      (combe.ends == null || lanesEnds.length == combe.ends);

  bool get gaveUp => !combe.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// Picks a cottage; the second wires the line, or unwires it if
  /// it already stands.
  Play tapAt(int cottage) {
    if (isOver) return this;
    final one = picked;
    if (one == null) {
      return Play._(combe, rules, lines, cottage, moves, before);
    }
    if (one == cottage) {
      return Play._(combe, rules, lines, null, moves, before);
    }
    final line = one < cottage ? (one, cottage) : (cottage, one);
    if (lines.contains(line)) {
      return Play._(
          combe,
          rules,
          [for (final l in lines) if (l != line) l],
          null,
          moves + 1,
          this);
    }
    if (lines.length == combe.cottages - 1) {
      // A full combe takes no more wire until one comes off.
      return Play._(combe, rules, lines, null, moves, before);
    }
    return Play._(
        combe, rules, [...lines, line], null, moves + 1, this);
  }

  Play get back => before ?? this;

  /// The line the sweep would wire or unwire next towards its
  /// run; null when none is in reach.
  ((int, int), bool)? get next {
    final aim = rules.run(combe.ends);
    if (aim == null || isDone) return null;
    for (final line in lines) {
      if (!aim.contains(line)) return (line, false);
    }
    for (final line in aim) {
      if (!lines.contains(line)) return (line, true);
    }
    return null;
  }
}
