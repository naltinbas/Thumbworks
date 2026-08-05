import 'pyx.dart';

/// Works out the fewest weighings that are certain to settle a box, and the
/// weighing to make next.
///
/// The beam is played against, not with. Whatever weighing is put on it, the
/// answer that comes back is the one that leaves the most work still to do, so
/// nothing here is ever settled by luck and a number that comes out of it is a
/// promise rather than a hope.
///
/// The searching is a plain minimax over the verdicts still standing. Each
/// weighing splits them into three by which way the beam would go, and what it
/// costs is one more than the worst of the three. What keeps it affordable is
/// the counting: a set of verdicts that cannot be told apart in the weighings
/// left is given up on at once, without trying anything.
class Assay {
  Assay._(this.coins);

  factory Assay.of(int coins) => Assay._(coins);

  final int coins;

  final _known = <String, int>{};
  late final List<Weighing> _all = _everyWeighing();

  /// The fewest weighings certain to bring a set of verdicts down to one.
  ///
  /// Null when it cannot be done in [most], which never happens on a box that
  /// ships.
  int? fewestFor(List<Verdict> standing, {int most = 6}) {
    if (standing.length <= 1) return 0;

    final key = _keyOf(standing);
    final known = _known[key];
    if (known != null) return known <= most ? known : null;

    // Counting first. A weighing has three answers, so k of them tell at most
    // 3^k verdicts apart, and there is no point trying if there are more than
    // that.
    var tells = 1;
    for (var go = 0; go < most; go++) {
      tells *= 3;
    }
    if (standing.length > tells) return null;

    for (var allowed = 1; allowed <= most; allowed++) {
      for (final weighing in _all) {
        final worst = _worstAfter(weighing, standing, allowed);
        if (worst == null) continue;
        _known[key] = allowed;
        return allowed;
      }
    }
    return null;
  }

  /// The weighing to make next: one that settles the box in as few more as it
  /// can now be settled in.
  Weighing? nextFor(List<Verdict> standing, {int most = 6}) {
    if (standing.length <= 1) return null;
    final fewest = fewestFor(standing, most: most);
    if (fewest == null) return null;

    for (final weighing in _all) {
      if (_worstAfter(weighing, standing, fewest) != null) return weighing;
    }
    return null;
  }

  /// Whether every one of the three answers to a weighing can be finished off
  /// in one fewer than [allowed], and how bad the worst of them is.
  int? _worstAfter(Weighing weighing, List<Verdict> standing, int allowed) {
    var worst = 0;
    for (final tip in Tip.values) {
      final left = weighing.after(standing, tip);
      if (left.length == standing.length) return null; // Told us nothing.
      if (left.isEmpty) continue;
      final after = fewestFor(left, most: allowed - 1);
      if (after == null) return null;
      if (after + 1 > worst) worst = after + 1;
    }
    return worst;
  }

  /// Which way the beam goes: the answer that leaves the most to do.
  Tip answerFor(Weighing weighing, List<Verdict> standing) {
    var worst = Tip.level;
    var most = -1;
    var biggest = -1;

    for (final tip in Tip.values) {
      final left = weighing.after(standing, tip);
      if (left.isEmpty) continue;
      final cost = fewestFor(left) ?? 99;
      if (cost > most || (cost == most && left.length > biggest)) {
        most = cost;
        biggest = left.length;
        worst = tip;
      }
    }
    return worst;
  }

  /// Every weighing worth making: the same number of coins on each pan, and
  /// each pair of pans only once.
  List<Weighing> _everyWeighing() {
    final all = <Weighing>[];
    final seen = <String>{};

    void grow(int coin, List<int> left, List<int> right, int spare) {
      if (coin == coins) {
        if (left.length != right.length || left.isEmpty) return;
        // The two pans are the same weighing the other way up.
        final key = left.first < right.first
            ? '${left.join(',')}|${right.join(',')}'
            : '${right.join(',')}|${left.join(',')}';
        if (!seen.add(key)) return;
        all.add(Weighing(left, right));
        return;
      }
      // Give up early on branches that cannot come out even.
      if ((left.length - right.length).abs() > spare) return;

      grow(coin + 1, left, right, spare - 1);
      grow(coin + 1, [...left, coin], right, spare - 1);
      grow(coin + 1, left, [...right, coin], spare - 1);
    }

    grow(0, const [], const [], coins);
    return all;
  }

  static String _keyOf(List<Verdict> standing) {
    final marks = List.of(standing)
      ..sort((one, other) =>
          one.coin != other.coin
              ? one.coin.compareTo(other.coin)
              : (one.heavy ? 1 : 0).compareTo(other.heavy ? 1 : 0));
    return marks.map((verdict) => verdict.toString()).join();
  }
}
