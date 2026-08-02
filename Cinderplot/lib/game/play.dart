import 'field.dart';

/// What has been done to a square.
enum Face {
  /// Not opened and not flagged.
  shut,

  /// Opened. If it held a mine the game is already over.
  open,

  /// Marked by the player as a mine. A flag is an opinion, not a fact: the
  /// game never checks one and never opens anything because of one.
  flagged,
}

/// How a game ended.
enum Ending { going, cleared, blown }

/// A game in progress: a field, and what the player has uncovered of it.
///
/// Immutable. Every move returns a new one, which is what lets a test play a
/// whole game as an expression and lets the solver look ahead without
/// disturbing anything.
class Play {
  const Play._({
    required this.field,
    required this.faces,
    required this.ending,
    required this.moves,
  });

  /// A new game, with the opening square already open.
  factory Play.of(Field field) {
    final faces = List.filled(field.cells, Face.shut);
    _uncover(field, faces, field.opening);
    return Play._(
      field: field,
      faces: List.unmodifiable(faces),
      ending: _endingFor(field, faces),
      moves: 0,
    );
  }

  final Field field;
  final List<Face> faces;
  final Ending ending;

  /// How many squares the player has opened. The opening one is not one of
  /// them: it was a gift, not a move.
  final int moves;

  bool get isOver => ending != Ending.going;

  Face faceAt(int at) => faces[at];
  bool isOpen(int at) => faces[at] == Face.open;
  bool isFlagged(int at) => faces[at] == Face.flagged;
  bool isShut(int at) => faces[at] == Face.shut;

  /// The number under an open square. Only ever asked about open ones.
  int countAt(int at) => field.countAt(at);

  Iterable<int> get opened sync* {
    for (var at = 0; at < faces.length; at++) {
      if (faces[at] == Face.open) yield at;
    }
  }

  /// How many squares are neither open nor a mine — what is left to do.
  int get toGo {
    var left = 0;
    for (var at = 0; at < faces.length; at++) {
      if (faces[at] != Face.open && !field.holdsMine(at)) left++;
    }
    return left;
  }

  /// The mines, less the flags planted. It can go negative, and it should:
  /// telling somebody they have flags to spare when they have put one in the
  /// wrong place is telling them something untrue.
  int get minesLeft =>
      field.mines.length - faces.where((face) => face == Face.flagged).length;

  /// Opens a square, and everything a blank one leads to.
  Play open(int at) {
    if (isOver || faces[at] != Face.shut) return this;

    final next = [...faces];
    if (field.holdsMine(at)) {
      next[at] = Face.open;
      return Play._(
        field: field,
        faces: List.unmodifiable(next),
        ending: Ending.blown,
        moves: moves + 1,
      );
    }

    _uncover(field, next, at);
    return Play._(
      field: field,
      faces: List.unmodifiable(next),
      ending: _endingFor(field, next),
      moves: moves + 1,
    );
  }

  /// Opens everything round an open number that has that many flags on it.
  ///
  /// The old two-button shortcut, and it is not a favour: the game opens what
  /// the flags say to open, and if a flag is in the wrong place that is a
  /// mine. It saves the eight taps, not the thinking.
  Play sweep(int at) {
    if (isOver || faces[at] != Face.open) return this;
    final near = field.around(at);
    final flags = near.where((one) => faces[one] == Face.flagged).length;
    if (flags != field.countAt(at) || flags == 0) return this;

    var play = this;
    for (final one in near) {
      if (faces[one] == Face.shut) play = play.open(one);
    }
    return play;
  }

  /// Puts a flag on a shut square, or takes one off.
  Play flag(int at) {
    if (isOver || faces[at] == Face.open) return this;
    final next = [...faces];
    next[at] = faces[at] == Face.flagged ? Face.shut : Face.flagged;
    return Play._(
      field: field,
      faces: List.unmodifiable(next),
      ending: ending,
      moves: moves,
    );
  }

  /// Opens [from] and, if it is blank, everything that follows from it.
  ///
  /// Written as a list rather than by calling itself, because a board that is
  /// mostly blank is one call deep per square and a phone's stack is not.
  static void _uncover(Field field, List<Face> faces, int from) {
    final todo = <int>[from];
    while (todo.isNotEmpty) {
      final here = todo.removeLast();
      if (faces[here] == Face.open) continue;
      // A flag in the way is left alone. The player put it there, and walking
      // over it would be the game overruling them about a square nobody asked
      // it about.
      if (faces[here] == Face.flagged && here != from) continue;
      faces[here] = Face.open;
      if (field.isBlank(here)) todo.addAll(field.around(here));
    }
  }

  static Ending _endingFor(Field field, List<Face> faces) {
    for (var at = 0; at < faces.length; at++) {
      if (!field.holdsMine(at) && faces[at] != Face.open) return Ending.going;
    }
    return Ending.cleared;
  }
}
