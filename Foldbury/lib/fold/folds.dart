import 'fold.dart';

/// The folds that ship.
///
/// Every one past the teaching pair came out of `make find`, which keeps a
/// fold only when the matching floor is exactly the answer, so the map
/// carries its own proof, and when posting greedily at the busiest gate
/// costs a shepherd more than the fewest, so the obvious way has somewhere
/// to fall.
///
/// The Three Lanes is the odd one out on purpose: a ring of three lanes has
/// no two lanes that keep apart, so the matching floor says one and the
/// answer is two. There the other floor carries it: three lanes, no gate
/// touching more than two, and half of three rounds up.
class Folds {
  const Folds._();

  static final List<Fold> all = [
    Fold(
      name: 'The Drove Road',
      fewest: 2,
      gates: const [
        Gate('Foldgate', 0.10, 0.62),
        Gate('Wicket', 0.30, 0.42),
        Gate('Middle Stile', 0.50, 0.60),
        Gate('Far Stile', 0.70, 0.40),
        Gate('Hurdle End', 0.90, 0.58),
      ],
      lanes: const [
        Lane(0, 1),
        Lane(1, 2),
        Lane(2, 3),
        Lane(3, 4),
      ],
    ),
    Fold(
      name: 'The Three Lanes',
      fewest: 2,
      gates: const [
        Gate('Foldgate', 0.50, 0.20),
        Gate('Wicket', 0.24, 0.70),
        Gate('Hurdle End', 0.76, 0.70),
      ],
      lanes: const [
        Lane(0, 1),
        Lane(1, 2),
        Lane(2, 0),
      ],
    ),
    Fold(
      name: 'The Seven Gates',
      fewest: 3,
      gates: const [
        Gate('Rack Hill', 0.83, 0.23),
        Gate('Foldgate', 0.52, 0.55),
        Gate('Far Stile', 0.73, 0.68),
        Gate('Hurdle End', 0.80, 0.36),
        Gate('Wicket', 0.24, 0.54),
        Gate('Sheepwash', 0.53, 0.81),
        Gate('Middle Stile', 0.24, 0.79),
      ],
      lanes: const [
        Lane(4, 5),
        Lane(1, 6),
        Lane(2, 3),
        Lane(1, 2),
        Lane(2, 5),
        Lane(0, 3),
        Lane(1, 5),
        Lane(1, 4),
        Lane(1, 3),
      ],
    ),
    Fold(
      name: 'The Nine Gates',
      fewest: 4,
      gates: const [
        Gate('Foldgate', 0.51, 0.63),
        Gate('Wicket', 0.35, 0.50),
        Gate('Sheepwash', 0.11, 0.78),
        Gate('Rack Hill', 0.67, 0.47),
        Gate('Middle Stile', 0.44, 0.80),
        Gate('Cote Door', 0.41, 0.27),
        Gate('Far Stile', 0.77, 0.66),
        Gate('Hurdle End', 0.90, 0.54),
        Gate('Grip Gate', 0.11, 0.60),
      ],
      lanes: const [
        Lane(3, 4),
        Lane(4, 6),
        Lane(0, 5),
        Lane(2, 8),
        Lane(0, 4),
        Lane(3, 7),
        Lane(0, 6),
        Lane(0, 1),
        Lane(2, 4),
        Lane(1, 3),
        Lane(0, 7),
        Lane(1, 8),
      ],
    ),
    Fold(
      name: 'The Whole Fold',
      fewest: 5,
      gates: const [
        Gate('Grip Gate', 0.18, 0.61),
        Gate('Foldgate', 0.41, 0.45),
        Gate('Rack Hill', 0.38, 0.15),
        Gate('Middle Stile', 0.47, 0.65),
        Gate('Far Stile', 0.63, 0.52),
        Gate('Cote Door', 0.43, 0.27),
        Gate('Hurdle End', 0.68, 0.33),
        Gate('Sheepwash', 0.55, 0.15),
        Gate('Wold Gate', 0.82, 0.18),
        Gate('Wicket', 0.31, 0.72),
      ],
      lanes: const [
        Lane(3, 9),
        Lane(0, 5),
        Lane(3, 6),
        Lane(1, 3),
        Lane(1, 4),
        Lane(3, 5),
        Lane(2, 6),
        Lane(4, 8),
        Lane(5, 8),
        Lane(1, 5),
        Lane(4, 9),
        Lane(1, 2),
        Lane(7, 8),
        Lane(6, 8),
      ],
    ),
  ];

  static int get count => all.length;

  static Fold at(int number) => all[number.clamp(0, all.length - 1)];
}
