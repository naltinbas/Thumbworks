import 'mere.dart';
import 'rules.dart';

/// A night being dialled. Every state is a fresh value, and the
/// one before hangs on for take-back.
class Play {
  Play._(this.mere, this.rules, this.starts, this.moves, this.before);

  factory Play.of(Mere mere) => Play._(
      mere, Rules(mere.lengths), List.of(mere.opens), 0, null);

  /// A play stood at a dialling, for the mark and the tests.
  factory Play.standing(Mere mere, List<int> starts) => Play._(
      mere, Rules(mere.lengths), List.of(starts), 1, null);

  final Mere mere;
  final Rules rules;

  /// Each watch's first hour.
  final List<int> starts;

  /// Slides taken, counted gross.
  final int moves;

  final Play? before;

  /// The line past which the hopeless mere admits it.
  static const gaveUpAt = 16;

  int get pairs => rules.pairsOverlapping(starts);

  (int, int)? get common => rules.commonHours(starts);

  int get commonWidth {
    final held = common;
    return held == null ? 0 : held.$2 - held.$1 + 1;
  }

  bool get isDone {
    if (pairs != mere.pairs) return false;
    if (mere.common == null) return true;
    return commonWidth == mere.common;
  }

  bool get gaveUp => !mere.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// Slides one watch an hour either way, clamped to the wall.
  Play slideAt(int watch, int by) {
    if (isOver || watch < 0 || watch >= starts.length) return this;
    final to = (starts[watch] + by)
        .clamp(0, rules.startsOf(watch) - 1);
    if (to == starts[watch]) return this;
    final slid = List.of(starts);
    slid[watch] = to;
    return Play._(mere, rules, slid, moves + 1, this);
  }

  Play get back => before ?? this;

  /// The slide the show-me points at: (watch, rightward) on a
  /// fewest-slides road to a landing, or null when none lands.
  (int, bool)? get next {
    if (isOver || !mere.winnable) return null;
    List<int>? bestAim;
    var nearest = 1 << 30;
    rules.diallings((aim) {
      if (rules.pairsOverlapping(aim) != mere.pairs) return;
      if (mere.common != null) {
        final held = rules.commonHours(aim);
        final width = held == null ? 0 : held.$2 - held.$1 + 1;
        if (width != mere.common) return;
      }
      var slides = 0;
      for (var watch = 0; watch < starts.length; watch++) {
        slides += (aim[watch] - starts[watch]).abs();
      }
      if (slides < nearest) {
        nearest = slides;
        bestAim = List.of(aim);
      }
    });
    final aim = bestAim;
    if (aim == null) return null;
    for (var watch = 0; watch < starts.length; watch++) {
      if (aim[watch] != starts[watch]) {
        return (watch, aim[watch] > starts[watch]);
      }
    }
    return null;
  }
}
