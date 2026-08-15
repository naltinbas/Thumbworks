import 'level.dart';
import 'rules.dart';

/// A time being struck. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.level, this.now, this.left, this.lit, this.moves, this.before);

  factory Play.of(Level level) => Play._(
      level, 0, List.filled(level.fuses, Rules.hour), List.generate(level.fuses, (_) => (false, false)), 0, null);

  /// A play stood at a moment, for the mark and the tests.
  factory Play.standing(Level level, int now, List<int> left, List<(bool, bool)> lit) =>
      Play._(level, now, List.of(left), List.of(lit), lit.fold(0, (a, b) => a + (b.$1 ? 1 : 0) + (b.$2 ? 1 : 0)), null);

  final Level level;

  /// Quarter-minutes since the start.
  final int now;

  /// Each fuse's burning left, in quarter-minutes.
  final List<int> left;

  /// Each fuse's ends, left and right, alight or not.
  final List<(bool, bool)> lit;

  /// Ends lit, counted.
  final int moves;

  final Play? before;

  int ends(int i) => (lit[i].$1 ? 1 : 0) + (lit[i].$2 ? 1 : 0);

  List<Fuse> get fuses => [for (var i = 0; i < left.length; i++) (left[i], ends(i))];

  bool alight(int i) => left[i] > 0 && ends(i) > 0;

  bool get anythingAlight => [for (var i = 0; i < left.length; i++) if (alight(i)) i].isNotEmpty;

  /// The next burnout, quarter-minutes from now, or null.
  int? get nextBurnout => Rules.nextBurnout(fuses);

  bool get isDone => now == level.asked;

  /// Past the time, or nothing left to light or burn: over, not landed.
  bool get missed => !isDone && (now > level.asked || (!anythingAlight && !canLight));

  bool get canLight => [for (var i = 0; i < left.length; i++) if (left[i] > 0 && ends(i) < 2) i].isNotEmpty;

  bool get gaveUp => !level.winnable && missed;

  bool get isOver => isDone || missed;

  /// Whether end [right] of fuse [i] can be lit now.
  bool touches(int i, bool right) {
    if (isOver || i < 0 || i >= left.length || left[i] == 0) return false;
    return right ? !lit[i].$2 : !lit[i].$1;
  }

  /// Lights an end of a fuse.
  Play light(int i, bool right) {
    if (!touches(i, right)) return this;
    final next = List.of(lit);
    next[i] = right ? (lit[i].$1, true) : (true, lit[i].$2);
    return Play._(level, now, left, next, moves + 1, this);
  }

  /// Lets the fuses burn on to the next burnout.
  Play burn() {
    final dt = nextBurnout;
    if (isOver || dt == null) return this;
    final after = Rules.burned(fuses, dt);
    return Play._(level, now + dt, [for (final f in after) f.$1], lit, moves, this);
  }

  Play get back => before ?? this;

  /// What the show-me points at: ('light', fuse, right) for the plan's
  /// next end to light now, or ('burn', 0, false) to let the fuses burn
  /// on; null when nothing lands.
  (String, int, bool)? get next {
    if (isOver || !level.winnable) return null;
    final plan = planFor(level);
    if (plan == null) return null;
    // The plan lights ends at set times; a fuse to light k ends at time
    // t. Follow it while the play matches: at time now, any lighting
    // due and not yet made comes first.
    for (final (t, fuse, k) in plan) {
      if (t != now) continue;
      if (ends(fuse) < k + _endsBefore(plan, t, fuse)) {
        return ('light', fuse, lit[fuse].$1);
      }
    }
    // Nothing due now: burn on, if the play is on the plan.
    return anythingAlight ? ('burn', 0, false) : null;
  }

  /// Ends the plan had lit on [fuse] before time [t].
  static int _endsBefore(List<(int, int, int)> plan, int t, int fuse) {
    var n = 0;
    for (final (pt, pf, k) in plan) {
      if (pf == fuse && pt < t) n += k;
    }
    return n;
  }

  /// The sweep's first striking plan, kept once found.
  static List<(int, int, int)>? planFor(Level level) {
    if (!_plans.containsKey(level.name)) {
      _plans[level.name] = Rules.plan(level.fuses, level.asked);
    }
    return _plans[level.name];
  }

  static final _plans = <String, List<(int, int, int)>?>{};
}
