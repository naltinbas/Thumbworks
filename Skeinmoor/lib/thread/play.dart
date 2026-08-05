import 'dart:typed_data';

import 'boards.dart';
import 'field.dart';

/// A board being filled in.
///
/// Which thread owns each cell, and the path each one has taken so far. The
/// paths are kept as well as the owners because a thread is drawn and rubbed
/// out from its end, and knowing which cell came last is what makes that
/// possible.
class Play {
  Play._(this.board, this.field, this._owner, this._paths, this._flipped);

  factory Play.of(Board board) {
    final field = board.field;
    final owner = Int32List(field.cells)..fillRange(0, field.cells, -1);
    for (var thread = 0; thread < field.threads; thread++) {
      owner[field.ends[thread].$1] = thread;
      owner[field.ends[thread].$2] = thread;
    }
    return Play._(
      board,
      field,
      owner,
      [for (var t = 0; t < field.threads; t++) <int>[field.ends[t].$1]],
      Uint8List(field.threads),
    );
  }

  final Board board;
  final Field field;
  final Int32List _owner;
  final List<List<int>> _paths;

  /// Which way round each thread is being drawn. A thread has no direction of
  /// its own — a player grabs whichever end is nearer — so this says which of
  /// the two the path starts from.
  final Uint8List _flipped;

  /// The end a thread is being drawn from.
  int fromOf(int thread) =>
      _flipped[thread] == 0 ? field.ends[thread].$1 : field.ends[thread].$2;

  /// The end a thread is being drawn towards.
  int toOf(int thread) =>
      _flipped[thread] == 0 ? field.ends[thread].$2 : field.ends[thread].$1;

  /// Which thread owns a cell, or -1.
  int ownerOf(int at) => at < 0 || at >= field.cells ? -1 : _owner[at];

  /// The cells a thread runs through, from its first end onwards.
  List<int> pathOf(int thread) => List.unmodifiable(_paths[thread]);

  /// The cell a thread has got to.
  int headOf(int thread) => _paths[thread].last;

  /// Whether a cell is on a thread's path — which is not the same as the
  /// thread owning it, because the far end is owned from the start and is not
  /// on the path until the thread arrives.
  bool isOn(int thread, int at) => _paths[thread].contains(at);

  /// Whether a thread has reached its far end.
  bool isJoined(int thread) => _paths[thread].last == toOf(thread);

  /// How many cells have something on them.
  int get filled {
    var found = 0;
    for (var at = 0; at < field.cells; at++) {
      if (_owner[at] >= 0) found++;
    }
    return found;
  }

  int get empty => field.cells - filled;

  /// Every thread joined and every cell taken, which is what finished means.
  ///
  /// Both halves are needed. Joining the ends is easy; doing it in a way that
  /// leaves nothing over is the puzzle.
  bool get isDone {
    for (var thread = 0; thread < field.threads; thread++) {
      if (!isJoined(thread)) return false;
    }
    return filled == field.cells;
  }

  int get joined {
    var found = 0;
    for (var thread = 0; thread < field.threads; thread++) {
      if (isJoined(thread)) found++;
    }
    return found;
  }

  Play _copy() => Play._(
        board,
        field,
        Int32List.fromList(_owner),
        [for (final path in _paths) List.of(path)],
        Uint8List.fromList(_flipped),
      );

  /// Whether a thread can be taken on to a cell from where it has got to.
  bool canGoTo(int thread, int at) => whyNot(thread, at) == null;

  /// Why a thread cannot be taken on to a cell, or null if it can.
  ///
  /// The reasons are worth having as words rather than as a bool, because the
  /// two that are not simply "that is not next to it" are the two rules of the
  /// game and a player is owed them.
  String? whyNot(int thread, int at) {
    if (at < 0 || at >= field.cells) return 'That is off the board.';
    if (isJoined(thread)) return 'That thread is joined up already.';
    if (!field.touching(_paths[thread].last, at)) {
      return 'A thread goes one cell at a time, and not across corners.';
    }
    if (at == toOf(thread)) return null;
    if (isOn(thread, at)) return 'It is already there.';
    final end = field.endAt(at);
    if (end >= 0) return 'That is an end, and ends stay where they are.';
    return null;
  }

  /// This board with a thread taken on one cell.
  ///
  /// Going onto a cell another thread is using rubs that thread back to
  /// there, which is what everybody expects from a game of this shape: the
  /// newer line wins and the older one gets out of the way.
  Play goTo(int thread, int at) {
    if (!canGoTo(thread, at)) return this;
    final next = _copy();

    final other = next._owner[at];
    if (other >= 0 && other != thread) next._cutBackTo(other, at);

    next._owner[at] = thread;
    next._paths[thread].add(at);
    return next;
  }

  /// This board with a thread's last cell rubbed out.
  Play back(int thread) {
    if (_paths[thread].length < 2) return this;
    final next = _copy();
    final last = next._paths[thread].removeLast();
    if (last != toOf(thread)) next._owner[last] = -1;
    return next;
  }

  /// This board with a thread rubbed back to a cell it has already been
  /// through, that cell still on it.
  Play backTo(int thread, int at) {
    if (!isOn(thread, at)) return this;
    final next = _copy();
    while (next._paths[thread].last != at) {
      final last = next._paths[thread].removeLast();
      if (last != toOf(thread)) next._owner[last] = -1;
    }
    return next;
  }

  /// This board with a thread started again from one of its ends.
  ///
  /// Either end will do. Grabbing the far one turns the thread round rather
  /// than refusing, because a thread joins two ends and neither of them is
  /// the first one.
  Play startFrom(int thread, int at) {
    final ends = field.ends[thread];
    if (at != ends.$1 && at != ends.$2) return this;
    final next = clear(thread)._copy();
    next._flipped[thread] = at == ends.$1 ? 0 : 1;
    next._paths[thread] = <int>[at];
    return next;
  }

  /// A finger arriving on a cell while a thread is being drawn: it goes on,
  /// or comes back to where it has already been, or nothing happens.
  ///
  /// Dragging back over your own line has to shorten it. Anything else and a
  /// mistake in the middle of a long thread means rubbing the whole thing out.
  Play draw(int thread, int at) =>
      isOn(thread, at) ? backTo(thread, at) : goTo(thread, at);

  /// This board with a thread rubbed out altogether.
  Play clear(int thread) => backTo(thread, fromOf(thread));

  Play get again => Play.of(board);

  /// Rubs a thread back to just before a cell, so another may have it.
  void _cutBackTo(int thread, int at) {
    while (_paths[thread].contains(at) && _paths[thread].length > 1) {
      final last = _paths[thread].removeLast();
      if (last != toOf(thread)) _owner[last] = -1;
    }
  }
}
