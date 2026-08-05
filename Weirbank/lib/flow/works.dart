/// One place on the works: what it is called, and where it sits when drawn.
class Pond {
  const Pond(this.name, this.x, this.y);

  final String name;

  /// Where it goes, from 0 to 1 across and down. The drawing scales these to
  /// whatever glass it is given, so a works is written down once and looks
  /// right on every phone.
  final double x;
  final double y;
}

/// One pipe: which way it runs, and how much it will take.
class Pipe {
  const Pipe(this.from, this.to, this.holds);

  final int from;
  final int to;

  /// How much can go down it. Water only runs one way in these.
  final int holds;
}

/// A waterworks: ponds, the pipes between them, the spring and the mill.
class Works {
  Works({
    required this.ponds,
    required List<Pipe> pipes,
    this.spring = 0,
    int? mill,
  })  : pipes = List.unmodifiable(pipes),
        mill = mill ?? ponds.length - 1 {
    _outOf = List.generate(ponds.length, (_) => <int>[]);
    _intoOf = List.generate(ponds.length, (_) => <int>[]);
    for (var pipe = 0; pipe < pipes.length; pipe++) {
      _outOf[pipes[pipe].from].add(pipe);
      _intoOf[pipes[pipe].to].add(pipe);
    }
  }

  final List<Pond> ponds;
  final List<Pipe> pipes;

  /// Where the water comes from, and where it is wanted.
  final int spring;
  final int mill;

  late final List<List<int>> _outOf;
  late final List<List<int>> _intoOf;

  int get count => ponds.length;

  /// The pipes leaving a pond, and the pipes arriving at it.
  List<int> out(int pond) => _outOf[pond];
  List<int> into(int pond) => _intoOf[pond];

  /// Whether water could reach the mill at all, ignoring how much.
  bool get isJoined {
    final seen = <int>{spring};
    final todo = <int>[spring];
    while (todo.isNotEmpty) {
      for (final pipe in out(todo.removeLast())) {
        if (seen.add(pipes[pipe].to)) todo.add(pipes[pipe].to);
      }
    }
    return seen.contains(mill);
  }
}
