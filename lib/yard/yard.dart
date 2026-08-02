import 'dart:typed_data';

/// Which way something went.
enum Way {
  up(0, -1),
  down(0, 1),
  left(-1, 0),
  right(1, 0);

  const Way(this.column, this.row);

  /// What a step this way adds to a square's column and to its row.
  final int column;
  final int row;

  Way get back => switch (this) {
        Way.up => Way.down,
        Way.down => Way.up,
        Way.left => Way.right,
        Way.right => Way.left,
      };
}

/// The walls and the marks: everything about a yard that never moves.
///
/// Kept apart from what does move, because a position is a hauler and some
/// crates and nothing else — which is what makes it small enough to put a few
/// hundred thousand of them in a set.
class Ground {
  Ground({
    required this.across,
    required this.down,
    required Set<int> walls,
    required Set<int> marks,
  })  : walls = Set.unmodifiable(walls),
        marks = Set.unmodifiable(marks) {
    // Every step anybody can take, worked out once. The search walks this
    // table a few million times, and a lookup is not the same price as two
    // divisions and four comparisons.
    _steps = Int32List(across * down * 4);
    for (var at = 0; at < across * down; at++) {
      for (final way in Way.values) {
        final column = at % across + way.column;
        final row = at ~/ across + way.row;
        final off = column < 0 || column >= across || row < 0 || row >= down;
        final next = off ? -1 : row * across + column;
        _steps[at * 4 + way.index] =
            next == -1 || walls.contains(next) ? -1 : next;
      }
    }
  }

  final int across;
  final int down;

  /// Squares nothing can be in.
  final Set<int> walls;

  /// Squares a crate is meant to end up on.
  final Set<int> marks;

  late final Int32List _steps;

  int get squares => across * down;

  int columnOf(int at) => at % across;
  int rowOf(int at) => at ~/ across;

  /// The square one step [way] from here, or -1 if that is a wall or the edge
  /// of the yard. There is no difference worth keeping between the two:
  /// nothing goes into either.
  int beyond(int at, Way way) => _steps[at * 4 + way.index];

  bool isWall(int at) => at < 0 || walls.contains(at);
  bool isMark(int at) => marks.contains(at);
  bool isFloor(int at) => at >= 0 && !walls.contains(at);
}

/// One shove: which crate, and which way it went.
class Shove {
  const Shove(this.crate, this.way);

  /// Where the crate was before it moved.
  final int crate;
  final Way way;

  @override
  bool operator ==(Object other) =>
      other is Shove && other.crate == crate && other.way == way;

  @override
  int get hashCode => Object.hash(crate, way);

  @override
  String toString() => '$crate ${way.name}';
}

/// A position: where the hauler is, and where the crates are.
///
/// Immutable, and cheap to compare — the crates are kept sorted, so two
/// positions with the same crates in a different order are the same position,
/// which they are.
class Yard {
  Yard._(this.ground, this.hauler, this.crates, this.pushes, this.moved);

  factory Yard.of(Ground ground, int hauler, Iterable<int> crates) =>
      Yard._(ground, hauler, [...crates]..sort(), 0, null);

  final Ground ground;
  final int hauler;

  /// Where the crates are, sorted.
  final List<int> crates;

  /// How many crates have been shoved.
  ///
  /// The number a yard is scored on. Walking about is free — it can never make
  /// a yard worse — and the only thing that is hard to take back is a shove.
  final int pushes;

  /// Where the crate that moved last ended up, or null if none has.
  ///
  /// The search leans on this: only the crate that just moved can have made
  /// the position hopeless, so only that one is worth looking at.
  final int? moved;

  Uint8List? _occupied;

  /// Which squares hold a crate, as a table. Built once per position, because
  /// the walk below asks about nearly every square in the yard.
  Uint8List get occupied {
    final known = _occupied;
    if (known != null) return known;
    final table = Uint8List(ground.squares);
    for (final crate in crates) {
      table[crate] = 1;
    }
    return _occupied = table;
  }

  bool hasCrate(int at) => at >= 0 && occupied[at] == 1;

  bool get isDone => crates.every(ground.isMark);

  int get onMarks => crates.where(ground.isMark).length;

  /// This position one step [way], or null if nothing moves that way.
  ///
  /// A step into a crate shoves it, if there is somewhere for it to go. A step
  /// into a wall is not a move, and neither is a shove into anything.
  Yard? step(Way way) {
    final ahead = ground.beyond(hauler, way);
    if (ahead < 0) return null;

    if (!hasCrate(ahead)) {
      return Yard._(ground, ahead, crates, pushes, null);
    }

    final onto = ground.beyond(ahead, way);
    if (onto < 0 || hasCrate(onto)) return null;

    final shifted = [
      for (final crate in crates)
        if (crate == ahead) onto else crate,
    ]..sort();
    return Yard._(ground, ahead, shifted, pushes + 1, onto);
  }

  /// The same crates, with the hauler somewhere else. Used by the search,
  /// which counts shoves and not walking.
  Yard withHauler(int at) => Yard._(ground, at, crates, pushes, moved);

  /// This position after a shove, or null if that shove cannot be made from
  /// here — including because the hauler cannot walk to the square they would
  /// have to shove from.
  ///
  /// Walking is not counted, but it does have to be possible.
  Yard? after(Shove shove) {
    if (!hasCrate(shove.crate)) return null;
    final stand = ground.beyond(shove.crate, shove.way.back);
    if (stand < 0 || !canReach(stand)) return null;
    return withHauler(stand).step(shove.way);
  }

  Uint8List? _walked;
  int _pocket = -1;

  void _walk() {
    final seen = Uint8List(ground.squares);
    final todo = <int>[hauler];
    seen[hauler] = 1;
    var lowest = hauler;
    while (todo.isNotEmpty) {
      final here = todo.removeLast();
      if (here < lowest) lowest = here;
      for (final way in Way.values) {
        final next = ground.beyond(here, way);
        if (next < 0 || seen[next] == 1 || occupied[next] == 1) continue;
        seen[next] = 1;
        todo.add(next);
      }
    }
    _walked = seen;
    _pocket = lowest;
  }

  /// Whether the hauler can walk to a square without shoving anything.
  bool canReach(int at) {
    if (_walked == null) _walk();
    return at >= 0 && _walked![at] == 1;
  }

  /// Every square the hauler can walk to without shoving anything.
  Set<int> get reach {
    if (_walked == null) _walk();
    return {
      for (var at = 0; at < ground.squares; at++)
        if (_walked![at] == 1) at,
    };
  }

  /// The steps that take the hauler to a square without shoving anything, or
  /// null if they cannot get there.
  ///
  /// Walking is free, so a tap on a far corner of the yard is one move as far
  /// as anything that counts is concerned.
  List<Way>? walkTo(int at) {
    if (at == hauler) return const [];
    if (!canReach(at)) return null;

    final cameFrom = <int, Way>{};
    final seen = <int>{hauler};
    final todo = <int>[hauler];
    while (todo.isNotEmpty) {
      final here = todo.removeAt(0);
      if (here == at) break;
      for (final way in Way.values) {
        final next = ground.beyond(here, way);
        if (next < 0 || occupied[next] == 1) continue;
        if (!seen.add(next)) continue;
        cameFrom[next] = way;
        todo.add(next);
      }
    }

    final steps = <Way>[];
    var here = at;
    while (here != hauler) {
      final way = cameFrom[here]!;
      steps.insert(0, way);
      here = ground.beyond(here, way.back);
    }
    return steps;
  }

  /// What tells two positions apart for a search: the crates, and which part
  /// of the yard the hauler is shut into by them.
  ///
  /// Not the hauler's exact square. With the same crates and the hauler
  /// anywhere in the same pocket, exactly the same shoves are possible, and
  /// telling those apart multiplies the search by the size of the yard for
  /// nothing.
  ///
  /// Written as characters rather than as a joined-up list of numbers. A
  /// search puts a few hundred thousand of these in a set, and building one
  /// string instead of a dozen is the difference between answering in a
  /// moment and answering in a second.
  String get sameness {
    if (_walked == null) _walk();
    return String.fromCharCodes([_pocket, ...crates]);
  }
}
