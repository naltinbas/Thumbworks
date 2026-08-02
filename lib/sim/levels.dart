import 'shapes.dart';
import 'stroke.dart';
import 'world.dart';

/// One puzzle: what is already there, where the ball starts, where it has to
/// get to, and how much chalk there is.
class Level {
  const Level({
    required this.name,
    required this.solid,
    required this.start,
    required this.goal,
    required this.ink,
    required this.solution,
    this.spikes = const [],
  });

  final String name;

  /// What is drawn on the slate already and cannot be rubbed out.
  final List<Line> solid;

  final Spot start;
  final Blob goal;
  final List<Blob> spikes;

  /// How much chalk the level gives.
  final double ink;

  /// A drawing that solves it.
  ///
  /// Every level ships with one, and a test draws it and watches the ball
  /// arrive. That is what says a level is possible — not somebody's memory of
  /// having done it once, and not a search, which would only prove that
  /// something can solve it rather than that a person can.
  final List<List<Spot>> solution;

  /// The world this level starts as, with a drawing added.
  World worldWith(Drawing drawing) => World.of(
        solid: [...solid, ...drawing.lines],
        goal: goal,
        spikes: spikes,
        from: start,
      );

  /// The drawing the level ships as its answer.
  Drawing get answer {
    var drawing = Drawing.with_(ink);
    for (final stroke in solution) {
      drawing = drawing.add(Stroke(stroke));
    }
    return drawing;
  }
}

/// The levels, in order.
///
/// Written by hand rather than generated. A drawing puzzle is about one idea
/// each — a ramp, a wall, a catch, a lid — and a generator produces geometry
/// with no ideas in it at all.
class Levels {
  const Levels._();

  static const all = <Level>[
    Level(
      name: 'A slope',
      solid: [],
      start: Spot(2, 2),
      goal: Blob(Spot(8, 15.4), 0.8),
      ink: 13,
      solution: [
        [Spot(1.82, 6.78), Spot(2.18, 8.13)],
      ],
    ),
    Level(
      name: 'The gap',
      solid: [
        Line(Spot(0, 7), Spot(3.6, 8.6)),
        Line(Spot(6.6, 10.2), Spot(10, 11.8)),
      ],
      start: Spot(1, 3),
      goal: Blob(Spot(9.2, 14.6), 0.8),
      ink: 4,
      solution: [
        [Spot(4.43, 9.31), Spot(5.42, 10.30)],
      ],
    ),
    Level(
      name: 'Back uphill',
      solid: [
        Line(Spot(0, 6.5), Spot(4.5, 8.5)),
      ],
      start: Spot(1, 2),
      goal: Blob(Spot(1.6, 17.4), 0.85),
      spikes: [Blob(Spot(5.6, 11.2), 0.7)],
      ink: 4,
      solution: [
        [Spot(5.73, 8.72), Spot(4.52, 9.42)],
      ],
    ),
    Level(
      name: 'Over the wall',
      solid: [
        Line(Spot(0, 8), Spot(7.6, 11.6)),
        Line(Spot(7.6, 11.6), Spot(7.6, 9.9)),
      ],
      start: Spot(1.2, 2),
      goal: Blob(Spot(8.8, 16.4), 0.85),
      ink: 5,
      solution: [
        [Spot(4.10, 10.20), Spot(7.60, 9.90)],
      ],
    ),
    Level(
      name: 'The funnel',
      solid: [
        Line(Spot(0, 9), Spot(3.9, 12)),
        Line(Spot(10, 9), Spot(6.1, 12)),
      ],
      start: Spot(5, 2),
      goal: Blob(Spot(1.2, 17.2), 0.85),
      spikes: [Blob(Spot(5, 15.4), 0.8)],
      ink: 4,
      solution: [
        [Spot(5.18, 11.92), Spot(4.82, 13.27)],
      ],
    ),
    Level(
      name: 'The crossing',
      solid: [
        // Steep and long, so the ball arrives at the bottom with everything it
        // is going to get. There is no way to make it faster later.
        Line(Spot(0.6, 5.5), Spot(7, 13)),
      ],
      start: Spot(1, 2),
      goal: Blob(Spot(9.05, 9.2), 0.9),
      spikes: [Blob(Spot(8, 15.5), 0.9)],
      ink: 6,
      solution: [
        [Spot(3.93, 9.65), Spot(9.30, 9.20)],
      ],
    ),
    Level(
      name: 'Two steps',
      solid: [
        Line(Spot(0, 5.5), Spot(3, 6.6)),
        Line(Spot(10, 10.5), Spot(7, 11.6)),
      ],
      start: Spot(0.8, 2),
      goal: Blob(Spot(5, 18), 0.85),
      spikes: [Blob(Spot(2, 14), 0.75), Blob(Spot(8.4, 15), 0.75)],
      ink: 6,
      solution: [
        [Spot(5.78, 11.93), Spot(7.00, 11.60)],
      ],
    ),
    Level(
      name: 'The hole',
      solid: [
        Line(Spot(0, 10), Spot(4.4, 11.2)),
        Line(Spot(5.6, 11.5), Spot(9.2, 12.6)),
      ],
      start: Spot(1, 2),
      goal: Blob(Spot(9.1, 16.6), 0.85),
      spikes: [Blob(Spot(5, 14.6), 0.75)],
      ink: 4,
      solution: [
        [Spot(4.69, 11.74), Spot(5.90, 12.44)],
      ],
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number.clamp(0, all.length - 1)];
}
