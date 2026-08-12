import 'line.dart';
import 'rules.dart';

/// A line of bunting being inked. Every state is a fresh value,
/// and the one before hangs on for take-back.
class Play {
  Play._(this.line, this.rules, this.inks, this.moves, this.before);

  factory Play.of(Line line) => Play._(
      line,
      Rules(line.posts, line.strings),
      List.filled(line.strings.length, 0),
      0,
      null);

  /// A play stood at an inking, for the mark and the tests.
  factory Play.standing(Line line, List<int> inks) => Play._(
      line,
      Rules(line.posts, line.strings),
      List.of(inks),
      inks.where((ink) => ink != 0).length,
      null);

  final Line line;
  final Rules rules;

  /// One ink per string, nought for bare.
  final List<int> inks;

  /// Dips taken, counted gross.
  final int moves;

  final Play? before;

  /// The line past which the hopeless line admits it.
  static const gaveUpAt = 14;

  List<(int, int)> get clashes => rules.clashes(inks);

  /// How many strings wear ink.
  int get inked => inks.where((ink) => ink != 0).length;

  bool get isDone => rules.lands(inks);

  bool get gaveUp => !line.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// Dips one string: bare to the first ink, ink to the next,
  /// the last ink back to bare.
  Play dipAt(int string) {
    if (isOver || string < 0 || string >= inks.length) return this;
    final dipped = List.of(inks);
    dipped[string] = (dipped[string] + 1) % (line.pot + 1);
    return Play._(line, rules, dipped, moves + 1, this);
  }

  Play get back => before ?? this;

  /// The string the show-me points at: the first dip of a
  /// fewest-dips road to a landing, or null when none lands.
  int? get next {
    if (isOver) return null;
    List<int>? bestAim;
    var fewest = 1 << 30;
    rules.inkings(line.pot, (aim) {
      if (!rules.lands(aim)) return;
      var dips = 0;
      for (var at = 0; at < inks.length; at++) {
        dips += (aim[at] - inks[at]) % (line.pot + 1);
      }
      if (dips < fewest) {
        fewest = dips;
        bestAim = List.of(aim);
      }
    });
    final aim = bestAim;
    if (aim == null) return null;
    for (var at = 0; at < inks.length; at++) {
      if (inks[at] != aim[at]) return at;
    }
    return null;
  }
}
