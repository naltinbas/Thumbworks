import 'level.dart';
import 'rules.dart';

/// A show being judged. Every state is a fresh value, and the one before
/// hangs on for take-back.
class Play {
  Play._(this.level, this.profile, this.moves, this.before);

  /// The show opens with every judge ranking the pies alike, apple first.
  factory Play.of(Level level) => Play._(level, List.generate(Rules.judges, (_) => List.generate(level.pies, (i) => i)), 0, null);

  /// A play stood at a profile, for the mark and the tests.
  factory Play.standing(Level level, List<List<int>> profile) => Play._(level, [for (final b in profile) List.of(b)], 0, null);

  final Level level;

  /// Each judge's ballot, first to last.
  final List<List<int>> profile;

  /// Taps, counted.
  final int moves;

  final Play? before;

  /// The line past which the hopeless ask admits it.
  static const gaveUpAt = 24;

  int get pies => level.pies;

  bool get isDone => level.meets(profile);

  bool get gaveUp => !level.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// Taps pie [pie] on judge [judge]'s ballot: it moves up a place, and
  /// from the top round to the bottom.
  Play tap(int judge, int pie) {
    if (isOver || judge < 0 || judge >= Rules.judges || pie < 0 || pie >= pies) return this;
    final ballot = List.of(profile[judge]);
    final at = ballot.indexOf(pie);
    if (at == 0) {
      ballot.removeAt(0);
      ballot.add(pie);
    } else {
      ballot[at] = ballot[at - 1];
      ballot[at - 1] = pie;
    }
    final next = [for (var j = 0; j < Rules.judges; j++) j == judge ? ballot : profile[j]];
    return Play._(level, next, moves + 1, this);
  }

  Play get back => before ?? this;

  int? get winner => Rules.condorcetWinner(profile, pies);
  List<int> get points => Rules.points(profile, pies);
  List<int>? get ringOrder => Rules.ringOrder(profile, pies);

  /// What the show-me points at: (judge, pie), the pie to tap on the
  /// first ballot off the sweep's first profile; null when nothing lands.
  (int, int)? get next {
    if (isOver || !level.winnable) return null;
    final aim = aimFor(level);
    if (aim == null) return null;
    for (var j = 0; j < Rules.judges; j++) {
      final want = aim[j], have = profile[j];
      for (var i = 0; i < pies; i++) {
        if (want[i] != have[i]) return (j, want[i]);
      }
    }
    return null;
  }

  /// The sweep's first profile for the ask, kept once found.
  static List<List<int>>? aimFor(Level level) {
    if (!_aims.containsKey(level.name)) {
      _aims[level.name] = Rules.first(level.pies, level.meets);
    }
    return _aims[level.name];
  }

  static final _aims = <String, List<List<int>>?>{};
}
