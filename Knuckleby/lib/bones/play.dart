import 'bench.dart';
import 'rules.dart';

/// A bench being cut. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.bench, this.one, this.two, this.cuts, this.before);

  factory Play.of(Bench bench) => Play._(
        bench,
        bench.lockedOne
            ? Rules.standard(bench.facesOne)
            : List.filled(bench.facesOne, bench.lowPip),
        List.filled(bench.facesTwo, bench.lowPip),
        0,
        null,
      );

  final Bench bench;

  /// The faces as they stand, in the order they sit on the bench.
  final List<int> one;
  final List<int> two;

  /// Recuts taken.
  final int cuts;

  final Play? before;

  /// The line past which a hopeless bench admits it.
  static const gaveUpAt = 8;

  /// The faces of one die by its number.
  List<int> faces(int die) => die == 0 ? one : two;

  Map<int, int> get wanted => Rules.table(
      Rules.standard(bench.facesOne), Rules.standard(bench.facesTwo));

  Map<int, int> get thrown => Rules.table(one, two);

  bool get matches => Rules.sameTable(thrown, wanted);

  /// Whether the standing dice are the standard arrangement itself.
  bool get isStandard {
    final sortedOne = List.of(one)..sort();
    final sortedTwo = List.of(two)..sort();
    return _same(sortedOne, Rules.standard(bench.facesOne)) &&
        _same(sortedTwo, Rules.standard(bench.facesTwo));
  }

  bool get isDone =>
      matches && (!bench.otherThanStandard || !isStandard);

  bool get gaveUp =>
      !bench.winnable && cuts >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// Whether a die's face may be cut at all.
  bool mayCut(int die) => !(die == 0 && bench.lockedOne);

  /// One recut: the face steps to the next pip, wrapping.
  Play cut(int die, int face) {
    if (isOver || !mayCut(die)) return this;
    final faces = die == 0 ? List.of(one) : List.of(two);
    var pip = faces[face] + (bench.evensOnly ? 2 : 1);
    if (pip > 8) pip = bench.lowPip;
    faces[face] = pip;
    return Play._(bench, die == 0 ? faces : one,
        die == 0 ? two : faces, cuts + 1, this);
  }

  Play get back => before ?? this;

  /// How many face-pips stand apart from the nearest matching pair,
  /// counted over the best pairing of dice to answers; -1 when the
  /// bench has no matching pair at all.
  int get apart {
    final answers = Rules.matching(bench.facesOne, bench.facesTwo,
        low: bench.lowPip);
    var least = -1;
    for (final (a, b) in answers) {
      // The standard pair is refused on some benches; skip it as a
      // target there.
      if (bench.otherThanStandard &&
          _same(a, Rules.standard(bench.facesOne)) &&
          _same(b, Rules.standard(bench.facesTwo))) {
        continue;
      }
      final ways = bench.facesOne == bench.facesTwo
          ? [(a, b), (b, a)]
          : [(a, b)];
      for (final (first, second) in ways) {
        if (bench.lockedOne &&
            !_same(first, Rules.standard(bench.facesOne))) {
          continue;
        }
        final far = _apartOf(one, first) + _apartOf(two, second);
        if (least == -1 || far < least) least = far;
      }
    }
    return least;
  }

  /// The face the nearest matching pair would recut first: the die,
  /// the face, and the pip it wants; null when the bench is matched
  /// or hopeless.
  (int, int, int)? get pointed {
    final answers = Rules.matching(bench.facesOne, bench.facesTwo,
        low: bench.lowPip);
    (int, int, int)? best;
    var least = -1;
    for (final (a, b) in answers) {
      if (bench.otherThanStandard &&
          _same(a, Rules.standard(bench.facesOne)) &&
          _same(b, Rules.standard(bench.facesTwo))) {
        continue;
      }
      final ways = bench.facesOne == bench.facesTwo
          ? [(a, b), (b, a)]
          : [(a, b)];
      for (final (first, second) in ways) {
        if (bench.lockedOne &&
            !_same(first, Rules.standard(bench.facesOne))) {
          continue;
        }
        final far = _apartOf(one, first) + _apartOf(two, second);
        if (least != -1 && far >= least) continue;
        final cut = _firstWrong(one, first, 0) ??
            _firstWrong(two, second, 1);
        if (cut == null) continue;
        least = far;
        best = cut;
      }
    }
    return best;
  }

  /// The first face of [die] holding a pip its [answer] has no room
  /// for, told with the pip the answer still wants.
  static (int, int, int)? _firstWrong(
      List<int> die, List<int> answer, int which) {
    final counts = <int, int>{};
    for (final pip in answer) {
      counts[pip] = (counts[pip] ?? 0) + 1;
    }
    final keeps = List<bool>.filled(die.length, false);
    for (var face = 0; face < die.length; face++) {
      final held = counts[die[face]] ?? 0;
      if (held > 0) {
        counts[die[face]] = held - 1;
        keeps[face] = true;
      }
    }
    for (var face = 0; face < die.length; face++) {
      if (keeps[face]) continue;
      final want = counts.keys
          .where((pip) => counts[pip]! > 0)
          .fold<int>(-1, (kept, pip) => kept == -1 ? pip : kept);
      if (want == -1) return null;
      return (which, face, want);
    }
    return null;
  }

  static int _apartOf(List<int> die, List<int> answer) {
    // Greedy multiset overlap: shared pips cost nothing.
    final counts = <int, int>{};
    for (final pip in answer) {
      counts[pip] = (counts[pip] ?? 0) + 1;
    }
    var shared = 0;
    for (final pip in die) {
      final held = counts[pip] ?? 0;
      if (held > 0) {
        counts[pip] = held - 1;
        shared++;
      }
    }
    return die.length - shared;
  }

  static bool _same(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var at = 0; at < a.length; at++) {
      if (a[at] != b[at]) return false;
    }
    return true;
  }
}
