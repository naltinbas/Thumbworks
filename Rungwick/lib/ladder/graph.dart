import 'dart:typed_data';

/// Every word of one length, and which of them are one letter apart.
///
/// The whole game is a walk on this graph, so it is worked out once and then
/// only read. Finding the neighbours of a word by comparing it to every other
/// word is two and a half thousand comparisons a step; bucketing on patterns
/// — `?ord`, `w?rd`, `wo?d`, `wor?` — finds them in four lookups.
class Ladder {
  Ladder._(this.words, this._where, this._starts, this._near);

  factory Ladder.of(List<String> words) {
    final where = <String, int>{
      for (var i = 0; i < words.length; i++) words[i]: i,
    };
    final length = words.isEmpty ? 0 : words.first.length;

    // Every word with one letter blanked out, so two words that fall in the
    // same bucket are one letter apart by construction.
    final buckets = <String, List<int>>{};
    for (var i = 0; i < words.length; i++) {
      for (var at = 0; at < length; at++) {
        final pattern = '${words[i].substring(0, at)}.'
            '${words[i].substring(at + 1)}';
        (buckets[pattern] ??= <int>[]).add(i);
      }
    }

    // Flattened: one long list of neighbours, and where each word's run of
    // them starts. A list of lists would be three thousand objects for a
    // thing that is read a million times.
    final sets = List.generate(words.length, (_) => <int>{});
    for (final together in buckets.values) {
      for (final one in together) {
        for (final other in together) {
          if (one != other) sets[one].add(other);
        }
      }
    }

    final starts = Int32List(words.length + 1);
    var total = 0;
    for (var i = 0; i < words.length; i++) {
      starts[i] = total;
      total += sets[i].length;
    }
    starts[words.length] = total;

    final near = Int32List(total);
    var at = 0;
    for (var i = 0; i < words.length; i++) {
      final sorted = sets[i].toList()..sort();
      for (final other in sorted) {
        near[at++] = other;
      }
    }

    return Ladder._(List.unmodifiable(words), where, starts, near);
  }

  final List<String> words;
  final Map<String, int> _where;
  final Int32List _starts;
  final Int32List _near;

  int get count => words.length;

  int get length => words.isEmpty ? 0 : words.first.length;

  /// Which word this is, or -1 if it is not one.
  int numberOf(String word) => _where[word] ?? -1;

  bool has(String word) => _where.containsKey(word);

  String wordAt(int number) => words[number];

  /// The words one letter away from this one.
  Iterable<int> nextTo(int word) sync* {
    for (var at = _starts[word]; at < _starts[word + 1]; at++) {
      yield _near[at];
    }
  }

  int howManyNextTo(int word) => _starts[word + 1] - _starts[word];

  /// How far every word is from this one, or -1 for the ones it cannot reach.
  ///
  /// One walk outwards answers for the whole list at once, which is what
  /// makes everything else here cheap: the shortest way through, how many
  /// steps are left from wherever a player has got to, and whether the step
  /// they just took was on a shortest ladder or beside one.
  Int32List stepsFrom(int word) {
    final away = Int32List(count)..fillRange(0, count, -1);
    away[word] = 0;
    final queue = <int>[word];
    var head = 0;
    while (head < queue.length) {
      final here = queue[head++];
      for (final next in nextTo(here)) {
        if (away[next] >= 0) continue;
        away[next] = away[here] + 1;
        queue.add(next);
      }
    }
    return away;
  }

  /// One shortest ladder from one word to another, or null if there is none.
  ///
  /// Every step of it is a word, every step changes one letter, and no ladder
  /// between the two is shorter — which is the whole of what the number on a
  /// level means.
  List<int>? climb(int from, int to) {
    if (from == to) return [from];
    final away = stepsFrom(to);
    if (away[from] < 0) return null;

    final rungs = <int>[from];
    var here = from;
    while (here != to) {
      // Down the hill, and there is always a way down: a word this far from
      // the end has a neighbour one nearer, by how the distances were worked
      // out.
      final nearer = nextTo(here).firstWhere(
        (next) => away[next] == away[here] - 1,
      );
      rungs.add(nearer);
      here = nearer;
    }
    return rungs;
  }
}
