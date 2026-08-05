import 'works.dart';

/// One puzzle: a waterworks, and how much the mill wants.
class Waterwork {
  const Waterwork({
    required this.name,
    required this.ponds,
    required this.pipes,
    required this.target,
  });

  final String name;
  final List<Pond> ponds;
  final List<Pipe> pipes;

  /// How much has to reach the mill. It is the most that can, and a test
  /// works that out again rather than trusting the number here.
  final int target;

  Works get works => Works(ponds: ponds, pipes: pipes);
}

/// The works, in the order they are met.
///
/// Every target here is the most that can possibly get through, so a puzzle
/// finished is a puzzle finished exactly: there is no way to send more and no
/// way to send that much by accident.
class Waterworks {
  const Waterworks._();

  static const all = <Waterwork>[
    Waterwork(
      name: 'Two pipes',
      ponds: [
        Pond('spring', 0.1, 0.5),
        Pond('pool', 0.5, 0.5),
        Pond('mill', 0.9, 0.5),
      ],
      pipes: [Pipe(0, 1, 3), Pipe(1, 2, 2)],
      target: 2,
    ),
    Waterwork(
      name: 'Round the elm',
      ponds: [
        Pond('spring', 0.1, 0.5),
        Pond('north pool', 0.5, 0.22),
        Pond('south pool', 0.5, 0.78),
        Pond('mill', 0.9, 0.5),
      ],
      pipes: [
        Pipe(0, 1, 3),
        Pipe(0, 2, 2),
        Pipe(1, 3, 2),
        Pipe(2, 3, 3),
      ],
      target: 4,
    ),
    Waterwork(
      name: 'The narrows',
      ponds: [
        Pond('spring', 0.08, 0.5),
        Pond('head', 0.36, 0.2),
        Pond('sluice', 0.36, 0.8),
        Pond('tail', 0.66, 0.5),
        Pond('mill', 0.94, 0.5),
      ],
      pipes: [
        Pipe(0, 1, 4),
        Pipe(0, 2, 3),
        Pipe(1, 3, 2),
        Pipe(2, 3, 4),
        Pipe(1, 2, 2),
        Pipe(3, 4, 7),
      ],
      target: 6,
    ),
    Waterwork(
      name: 'The three ways',
      ponds: [
        Pond('spring', 0.06, 0.5),
        Pond('upper', 0.34, 0.16),
        Pond('middle', 0.34, 0.5),
        Pond('lower', 0.34, 0.84),
        Pond('gathering', 0.68, 0.5),
        Pond('mill', 0.94, 0.5),
      ],
      pipes: [
        Pipe(0, 1, 3),
        Pipe(0, 2, 2),
        Pipe(0, 3, 4),
        Pipe(1, 4, 2),
        Pipe(2, 4, 3),
        Pipe(3, 4, 3),
        Pipe(4, 5, 8),
      ],
      target: 7,
    ),
    Waterwork(
      name: 'The long leat',
      ponds: [
        Pond('spring', 0.06, 0.5),
        Pond('head', 0.3, 0.22),
        Pond('weir', 0.3, 0.78),
        Pond('cistern', 0.56, 0.5),
        Pond('sluice', 0.8, 0.2),
        Pond('mill', 0.94, 0.6),
      ],
      pipes: [
        Pipe(0, 1, 5),
        Pipe(0, 2, 4),
        Pipe(1, 3, 3),
        Pipe(2, 3, 3),
        Pipe(1, 4, 2),
        Pipe(3, 4, 2),
        Pipe(3, 5, 4),
        Pipe(4, 5, 3),
      ],
      target: 7,
    ),
    Waterwork(
      name: 'The whole valley',
      ponds: [
        Pond('spring', 0.05, 0.5),
        Pond('north head', 0.28, 0.14),
        Pond('south head', 0.28, 0.86),
        Pond('cistern', 0.5, 0.5),
        Pond('north sluice', 0.72, 0.16),
        Pond('south sluice', 0.72, 0.84),
        Pond('mill', 0.95, 0.5),
      ],
      pipes: [
        Pipe(0, 1, 4),
        Pipe(0, 2, 5),
        Pipe(0, 3, 2),
        Pipe(1, 3, 2),
        Pipe(2, 3, 3),
        Pipe(1, 4, 3),
        Pipe(2, 5, 3),
        Pipe(3, 4, 2),
        Pipe(3, 5, 3),
        Pipe(4, 6, 4),
        Pipe(5, 6, 4),
      ],
      target: 8,
    ),
  ];

  static int get count => all.length;

  static Waterwork at(int which) => all[which.clamp(0, all.length - 1)];
}
