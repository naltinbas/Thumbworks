import 'geometry.dart' as g;
import 'geometry.dart' show Pt, Q, pt, shared2;

/// One piece of the cut square: its corners in its own square, running
/// counterclockwise, whole numbers all.
class Piece {
  const Piece(this.name, this.corners);

  final String name;
  final List<(int, int)> corners;

  /// The corners turned [turn] quarter turns counterclockwise, flipped
  /// left for right first when [flipped], and slid so the lowest and
  /// leftmost of them sit on nought: the piece as it lies in its box.
  List<(int, int)> turned(int turn, bool flipped) {
    var pts = [for (final (x, y) in corners) flipped ? (-x, y) : (x, y)];
    if (flipped) pts = pts.reversed.toList();
    for (var t = 0; t < turn % 4; t++) {
      pts = [for (final (x, y) in pts) (-y, x)];
    }
    var minX = pts.first.$1, minY = pts.first.$2;
    for (final (x, y) in pts) {
      if (x < minX) minX = x;
      if (y < minY) minY = y;
    }
    return [for (final (x, y) in pts) (x - minX, y - minY)];
  }

  /// The eight ways of turning and flipping, told once each.
  List<(int, bool)> get ways {
    final seen = <String>{};
    final out = <(int, bool)>[];
    for (final flipped in [false, true]) {
      for (var turn = 0; turn < 4; turn++) {
        final key = turned(turn, flipped).toString();
        if (seen.add(key)) out.add((turn, flipped));
      }
    }
    return out;
  }

  /// Twice the piece's area.
  Q get area2 => area2Of(corners);

  static Q area2Of(List<(int, int)> pts) => g.area2([for (final (x, y) in pts) pt(x, y)]);
}

/// A piece laid: which way it lies and where its box's corner sits.
class Laying {
  const Laying(this.turn, this.flipped, this.x, this.y);

  final int turn;
  final bool flipped;
  final int x;
  final int y;

  @override
  bool operator ==(Object other) =>
      other is Laying && other.turn == turn && other.flipped == flipped && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(turn, flipped, x, y);

  @override
  String toString() => 'Laying($turn, $flipped, $x, $y)';
}

/// A cut square and a frame to lay its four pieces in.
class Rules {
  const Rules({required this.side, required this.width, required this.height});

  /// The side of the square the pieces were cut from: a Fibonacci
  /// number, and the frame's sides are its two neighbours.
  final int side;

  /// The frame.
  final int width;
  final int height;

  /// The four pieces of the square of [side]: with the side F, the cut
  /// is at height F minus the smaller neighbour: two triangles from the
  /// top strip, split by a slant, and two trapeziums from the rest,
  /// split by a slant that leans the other way.
  List<Piece> get pieces {
    final a = _smaller(side); // the smaller neighbour, 5 for 8
    final b = side - a; // the one below it, 3 for 8
    return [
      Piece('triangle 1', [(0, 0), (side, 0), (side, b)]),
      Piece('triangle 2', [(0, 0), (side, 0), (side, b)]),
      Piece('trapezium 1', [(0, 0), (b, 0), (a, a), (0, a)]),
      Piece('trapezium 2', [(0, 0), (b, 0), (a, a), (0, a)]),
    ];
  }

  static int _smaller(int f) {
    var x = 1, y = 1;
    while (y < f) {
      final t = x + y;
      x = y;
      y = t;
    }
    return x;
  }

  /// Twice the frame's area.
  Q get frame2 => Q(2 * width * height);

  /// Twice the pieces' area together: twice the square.
  Q get pieces2 => Q(2 * side * side);

  /// The frame as a polygon.
  List<Pt> get frame => [pt(0, 0), pt(width, 0), pt(width, height), pt(0, height)];

  /// Piece [p] laid as [laying] says, its corners on the frame.
  List<Pt> laid(int p, Laying laying) => [
        for (final (x, y) in pieces[p].turned(laying.turn, laying.flipped)) pt(x + laying.x, y + laying.y),
      ];

  /// The box of piece [p] laid as [laying]: (width, height).
  (int, int) boxOf(int p, Laying laying) {
    var w = 0, h = 0;
    for (final (x, y) in pieces[p].turned(laying.turn, laying.flipped)) {
      if (x > w) w = x;
      if (y > h) h = y;
    }
    return (w, h);
  }

  /// Whether the laying keeps piece [p] inside the frame.
  bool inside(int p, Laying laying) {
    final (w, h) = boxOf(p, laying);
    return laying.x >= 0 && laying.y >= 0 && laying.x + w <= width && laying.y + h <= height;
  }

  /// Every laying of piece [p] inside the frame, told once each.
  List<Laying> layings(int p) => [
        for (final (turn, flipped) in pieces[p].ways)
          for (var x = 0; x + boxOf(p, Laying(turn, flipped, 0, 0)).$1 <= width; x++)
            for (var y = 0; y + boxOf(p, Laying(turn, flipped, 0, 0)).$2 <= height; y++)
              Laying(turn, flipped, x, y),
      ];

  /// Twice the area two laid pieces share, nought when they lie apart.
  Q overlap2(int p, Laying lp, int q, Laying lq) {
    final (wp, hp) = boxOf(p, lp);
    final (wq, hq) = boxOf(q, lq);
    if (lp.x + wp <= lq.x || lq.x + wq <= lp.x || lp.y + hp <= lq.y || lq.y + hq <= lp.y) return Q.zero;
    return shared2(laid(p, lp), laid(q, lq));
  }

  /// Twice the area the four laid pieces share, pair by pair.
  Q overlapOf(List<Laying> all) {
    var sum = Q.zero;
    for (var p = 0; p < 4; p++) {
      for (var q = p + 1; q < 4; q++) {
        sum = sum + overlap2(p, all[p], q, all[q]);
      }
    }
    return sum;
  }

  /// Twice the frame left bare with the four laid: the frame less the
  /// pieces, plus what they share.
  Q gapOf(List<Laying> all) => frame2 - pieces2 + overlapOf(all);

  /// The sweep: every laying of the four pieces inside the frame, the
  /// two triangles in one order and the two trapeziums in one order so
  /// no laying is told twice, and those meeting the ask counted: shared
  /// area at most [overlapAllowed2] (twice it) and, when [mustFill], no
  /// gap. Returns (landing, all, the first landing).
  (int, int, List<Laying>?) sweep({required Q overlapAllowed2, required bool mustFill}) {
    final tri = layings(0), trap = layings(2);
    var landing = 0;
    List<Laying>? first;
    final all = tri.length * (tri.length - 1) ~/ 2 * (trap.length * (trap.length - 1) ~/ 2);
    for (var i = 0; i < tri.length; i++) {
      for (var j = i + 1; j < tri.length; j++) {
        final o01 = overlap2(0, tri[i], 1, tri[j]);
        if (o01 > overlapAllowed2) continue;
        for (var k = 0; k < trap.length; k++) {
          final o02 = overlap2(0, tri[i], 2, trap[k]);
          final o12 = overlap2(1, tri[j], 2, trap[k]);
          final so2 = o01 + o02 + o12;
          if (so2 > overlapAllowed2) continue;
          for (var l = k + 1; l < trap.length; l++) {
            final o03 = overlap2(0, tri[i], 3, trap[l]);
            final o13 = overlap2(1, tri[j], 3, trap[l]);
            final o23 = overlap2(2, trap[k], 3, trap[l]);
            final total = so2 + o03 + o13 + o23;
            if (total > overlapAllowed2) continue;
            if (mustFill && (frame2 - pieces2 + total).sign != 0) continue;
            landing++;
            first ??= [tri[i], tri[j], trap[k], trap[l]];
          }
        }
      }
    }
    return (landing, all, first);
  }
}

/// The Fibonacci numbers, 1, 1, 2, 3, 5, 8, 13, ...
int fibonacci(int n) {
  var x = 1, y = 1;
  for (var i = 2; i <= n; i++) {
    final t = x + y;
    x = y;
    y = t;
  }
  return n <= 1 ? 1 : y;
}
