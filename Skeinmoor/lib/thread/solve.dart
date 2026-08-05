import 'dart:typed_data';

import 'field.dart';

/// What a search found on a board.
class Found {
  const Found({required this.count, required this.first, required this.looked});

  /// How many ways there are to fill the board. One is a puzzle; two means
  /// there is nothing to work out, because a guess can be as right as a
  /// reason.
  final int count;

  /// One of them: the cells each thread runs through, in order, from one end
  /// to the other.
  ///
  /// On a board with one way this is the way, orderings and all — two
  /// orderings of the same cells are two ways as far as the count is
  /// concerned, so a board that got through with a count of one has nothing
  /// left to choose.
  final List<List<int>>? first;

  final int looked;

  bool get canBeDone => count > 0;
  bool get isOnlyOne => count == 1;
}

/// Fills a board with threads, and counts the ways of doing it.
///
/// The rules are the whole of it: every thread joins its two ends, threads do
/// not cross, and no cell is left empty. That last one is what makes this a
/// puzzle rather than a maze — a board with a spare cell has a hundred
/// answers, and a board with none usually has one.
///
/// There is no fourth rule. A thread is allowed to run alongside itself, which
/// costs a great deal of searching and is worth it: what this counts is what a
/// finger can do on the screen, so a board it calls the only way really is the
/// only way somebody can find.
///
/// Threads are drawn one at a time, in order, from the first end towards the
/// second. When one arrives the next begins. That sounds like it could miss
/// answers, and it cannot: every way of filling the board draws each thread
/// as some path, and this tries every path for every thread.
class Threader {
  Threader(this.field);

  final Field field;

  /// Counts the ways, stopping once [enough] have been found.
  ///
  /// Two is enough for a puzzle: the question is never how many answers there
  /// are, only whether there is more than one.
  Found ways({int enough = 2, int give = 3000000}) {
    final owner = Int32List(field.cells)..fillRange(0, field.cells, -1);
    for (var thread = 0; thread < field.threads; thread++) {
      owner[field.ends[thread].$1] = thread;
      owner[field.ends[thread].$2] = thread;
    }

    // The cells each thread has been through so far. Kept alongside the owner
    // map because the order is part of the answer: the same cells walked the
    // other way round are a different way of filling the board.
    final paths = [
      for (var thread = 0; thread < field.threads; thread++)
        <int>[field.ends[thread].$1],
    ];

    var count = 0;
    var looked = 0;
    List<List<int>>? first;

    void walk(int thread, int head) {
      if (count >= enough || looked > give) return;
      looked++;

      // Arrived. On to the next thread, or done if that was the last.
      if (head == field.ends[thread].$2) {
        if (thread + 1 == field.threads) {
          for (var at = 0; at < field.cells; at++) {
            if (owner[at] < 0) return;
          }
          count++;
          first ??= [for (final path in paths) List<int>.of(path)];
          return;
        }
        walk(thread + 1, field.ends[thread + 1].$1);
        return;
      }

      for (var way = 0; way < 4; way++) {
        final next = field.beside(head, way);
        if (next < 0) continue;

        if (next == field.ends[thread].$2) {
          paths[thread].add(next);
          walk(thread, next);
          paths[thread].removeLast();
          if (count >= enough) return;
          continue;
        }
        if (owner[next] >= 0) continue;

        owner[next] = thread;
        paths[thread].add(next);
        if (!_strandedSomething(owner, thread, next)) {
          walk(thread, next);
        }
        paths[thread].removeLast();
        owner[next] = -1;
        if (count >= enough) return;
      }
    }

    walk(0, field.ends[0].$1);
    return Found(count: count, first: first, looked: looked);
  }

  /// Whether the last cell shut something in.
  ///
  /// Two cheap checks. An empty cell with nothing free beside it and no head
  /// next to it can never be filled. And a thread not yet drawn whose ends
  /// can no longer reach each other through empty cells is a thread that will
  /// not be drawn.
  bool _strandedSomething(Int32List owner, int thread, int at) {
    for (var way = 0; way < 4; way++) {
      final beside = field.beside(at, way);
      if (beside < 0 || owner[beside] >= 0) continue;
      if (!_hasRoom(owner, beside, thread)) return true;
    }
    for (var other = thread + 1; other < field.threads; other++) {
      if (!_canStillJoin(owner, other)) return true;
    }
    return false;
  }

  /// Whether an empty cell has anywhere to go: a free neighbour, or a head
  /// that could still come to it.
  bool _hasRoom(Int32List owner, int at, int thread) {
    var room = 0;
    for (var way = 0; way < 4; way++) {
      final beside = field.beside(at, way);
      if (beside < 0) continue;
      if (owner[beside] < 0) {
        room++;
      } else if (beside == field.ends[owner[beside]].$2 ||
          owner[beside] >= thread) {
        room++;
      }
      if (room >= 2) return true;
    }
    return false;
  }

  /// Whether a thread's two ends can still reach each other through cells
  /// that are empty.
  bool _canStillJoin(Int32List owner, int thread) {
    final from = field.ends[thread].$1;
    final to = field.ends[thread].$2;
    if (field.touching(from, to)) return true;

    final seen = Uint8List(field.cells);
    final todo = <int>[from];
    seen[from] = 1;
    while (todo.isNotEmpty) {
      final here = todo.removeLast();
      for (var way = 0; way < 4; way++) {
        final next = field.beside(here, way);
        if (next < 0 || seen[next] == 1) continue;
        if (next == to) return true;
        if (owner[next] >= 0) continue;
        seen[next] = 1;
        todo.add(next);
      }
    }
    return false;
  }
}
