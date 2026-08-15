import 'level.dart';
import 'rules.dart';

/// A week being walked. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.level, this.placed, this.moves, this.before);

  factory Play.of(Level level) => Play._(level, const [], 0, null);

  /// A play stood at a placing, for the mark and the tests.
  factory Play.standing(Level level, List<int> placed) => Play._(level, List.of(placed), placed.length, null);

  final Level level;

  /// The girls placed on the days to fill, in order: nine to a day,
  /// three to a row.
  final List<int> placed;

  /// Girls placed, counted.
  final int moves;

  final Play? before;

  /// The days built so far, complete ones only, rows sorted.
  List<Day> get builtDays => [
        for (var d = 0; d + 9 <= placed.length; d += 9)
          [
            for (var r = 0; r < 3; r++) (placed.sublist(d + r * 3, d + r * 3 + 3)..sort()),
          ],
      ];

  /// The day under way: its girls so far.
  List<int> get today {
    final start = (placed.length ~/ 9) * 9;
    return placed.length == start ? const [] : placed.sublist(start);
  }

  /// The row under way within today.
  List<int> get currentRow => today.length % 3 == 0 ? const [] : today.sublist((today.length ~/ 3) * 3);

  /// Days walked, given and built.
  List<Day> get days => [...level.given, ...builtDays];

  bool get full => placed.length == level.more * 9;

  /// The pairs walked over the given days and the built days, plus the
  /// rows finished today.
  Set<int> get pairsMet {
    final met = Rules.pairsMet(days);
    final t = today;
    for (var r = 0; r + 3 <= t.length; r += 3) {
      met.addAll(Rules.pairsOfRow(t.sublist(r, r + 3)));
    }
    return met;
  }

  /// The pairs walked twice, over the days and rows finished.
  int get repeats {
    var count = 0;
    final seen = <int>{};
    for (final day in days) {
      for (final p in Rules.pairsOfDay(day)) {
        if (!seen.add(p)) count++;
      }
    }
    final t = today;
    for (var r = 0; r + 3 <= t.length; r += 3) {
      for (final p in Rules.pairsOfRow(t.sublist(r, r + 3))) {
        if (!seen.add(p)) count++;
      }
    }
    return count;
  }

  bool get isDone => full && repeats == 0 && (!level.allPairs || pairsMet.length == 36);

  /// Every day filled and the ask not met: over, not landed.
  bool get missed => full && !isDone;

  bool get gaveUp => !level.winnable && missed;

  bool get isOver => isDone || missed;

  bool touches(int girl) => !isOver && !full && girl >= 0 && girl < Rules.girls && !today.contains(girl);

  /// Places a girl in the row under way.
  Play tap(int girl) {
    if (!touches(girl)) return this;
    return Play._(level, [...placed, girl], moves + 1, this);
  }

  Play get back => before ?? this;

  /// What the show-me points at: ('in', girl) for the next girl of the
  /// sweep's first filling, or ('out', girl) for the last placed when
  /// the placing has strayed from it; null when nothing lands.
  (String, int)? get next {
    if (isOver || !level.winnable) return null;
    final aim = aimFor(level);
    if (aim == null) return null;
    for (var i = 0; i < placed.length; i++) {
      if (placed[i] != aim[i]) return ('out', placed.last);
    }
    return placed.length < aim.length ? ('in', aim[placed.length]) : null;
  }

  /// The sweep's first filling, flattened, kept once found.
  static List<int>? aimFor(Level level) {
    if (!_aims.containsKey(level.name)) {
      final (_, first) = Rules.completions(level.given, level.more);
      _aims[level.name] = first == null ? null : [for (final d in first) for (final r in d) ...r];
    }
    return _aims[level.name];
  }

  static final _aims = <String, List<int>?>{};
}
