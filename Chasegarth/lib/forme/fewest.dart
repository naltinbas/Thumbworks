import 'dart:collection';

import 'chase.dart';
import 'parity.dart';

/// Every arrangement a chase can be slid into, and how far each is from
/// reading right.
///
/// Walked outwards from the finished frame, so the number against an
/// arrangement is the fewest slides there are and not merely one somebody
/// found. A frame of nine cells has 181,440 arrangements that can be reached,
/// which is a moment's work and settles every question the game ever asks.
///
/// It also settles the other question for nothing. Whatever this walk does not
/// reach cannot be slid into reading right, and the parity says the same thing
/// without walking anything, so the two can be held against each other on
/// every arrangement there is.
class Slides {
  Slides(this.chase) {
    _walk();
  }

  final Chase chase;

  final _far = <String, int>{};

  /// How many arrangements were reached.
  int get reached => _far.length;

  /// How far an arrangement is from reading right, or null when it can never
  /// be got there.
  int? from(List<int> stands) => _far[_keyOf(stands)];

  bool canBeLocked(List<int> stands) => _far.containsKey(_keyOf(stands));

  /// A slide to make next that is on a shortest way to the finished frame:
  /// the cell whose letter should be slid into the empty one.
  int? nextFrom(List<int> stands) {
    final now = from(stands);
    if (now == null || now == 0) return null;
    final empty = stands.indexOf(-1);
    for (final cell in chase.beside(empty)) {
      final after = slide(stands, cell);
      if (from(after) == now - 1) return cell;
    }
    return null;
  }

  /// Slides the letter in a cell into the empty one, if they are neighbours.
  static List<int> slide(List<int> stands, int cell) {
    final empty = stands.indexOf(-1);
    final next = List.of(stands);
    next[empty] = next[cell];
    next[cell] = -1;
    return next;
  }

  void _walk() {
    final start = chase.locked;
    _far[_keyOf(start)] = 0;
    final waiting = Queue<List<int>>()..add(start);

    while (waiting.isNotEmpty) {
      final stands = waiting.removeFirst();
      final far = _far[_keyOf(stands)]!;
      final empty = stands.indexOf(-1);

      for (final cell in chase.beside(empty)) {
        final next = slide(stands, cell);
        final key = _keyOf(next);
        if (_far.containsKey(key)) continue;
        _far[key] = far + 1;
        waiting.add(next);
      }
    }
  }

  /// Every arrangement at a given distance, in the order the walk found them.
  Iterable<List<int>> allAt(int far) sync* {
    for (final entry in _far.entries) {
      if (entry.value == far) yield _fromKey(entry.key);
    }
  }

  /// The arrangement furthest from reading right, and how far it is. The worst
  /// anybody could be handed.
  (List<int>, int) get furthest {
    var worst = chase.locked;
    var far = 0;
    for (final entry in _far.entries) {
      if (entry.value <= far) continue;
      far = entry.value;
      worst = _fromKey(entry.key);
    }
    return (worst, far);
  }

  /// How many arrangements there are altogether, reachable or not.
  int get everyArrangement {
    var all = 1;
    for (var cell = 1; cell <= chase.cells; cell++) {
      all *= cell;
    }
    return all;
  }

  /// Walks every arrangement there is and checks the parity says exactly what
  /// this walk found. It is not used by the game, only by the tests.
  (int agreed, int disagreed) againstParity() {
    var agreed = 0;
    var disagreed = 0;

    void every(List<int> so, List<int> left) {
      if (left.isEmpty) {
        final can = canBeLocked(so);
        if (can == Parity.canBeLocked(chase, so)) {
          agreed++;
        } else {
          disagreed++;
        }
        return;
      }
      for (var at = 0; at < left.length; at++) {
        every([...so, left[at]], [...left]..removeAt(at));
      }
    }

    every(const [], [-1, for (var sort = 0; sort < chase.sorts; sort++) sort]);
    return (agreed, disagreed);
  }

  static String _keyOf(List<int> stands) =>
      String.fromCharCodes([for (final sort in stands) sort + 2]);

  static List<int> _fromKey(String key) =>
      [for (final code in key.codeUnits) code - 2];
}
