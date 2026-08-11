import 'consignment.dart';

/// The consignments that ship. Paints: 0 madder, 1 weld, 2 woad,
/// 3 lime.
class Consignments {
  const Consignments._();

  static final List<Consignment> all = [
    Consignment(
      name: 'The Easy Lading',
      crates: const [
        [(0, 1), (2, 3), (0, 2)],
        [(2, 3), (0, 1), (1, 3)],
        [(0, 1), (2, 3), (0, 3)],
        [(2, 3), (0, 1), (1, 2)],
      ],
      ways: 42,
      note: 'Forty two ways to stack it fair: a consignment for learning '
          'the ropes, which here are actual ropes.',
    ),
    Consignment(
      name: 'The Fair Set',
      crates: const [
        [(0, 1), (2, 0), (3, 0)],
        [(1, 2), (3, 1), (0, 1)],
        [(2, 3), (0, 2), (1, 2)],
        [(3, 0), (1, 3), (2, 3)],
      ],
      ways: 24,
    ),
    Consignment(
      name: 'The Tight Consignment',
      crates: const [
        [(1, 3), (0, 3), (0, 2)],
        [(3, 0), (1, 1), (0, 2)],
        [(3, 1), (0, 2), (1, 2)],
        [(3, 0), (2, 2), (2, 3)],
      ],
      ways: 2,
      note: 'Two ways in the whole 1,296, and they are each other with '
          'the lines swapped: really one stacking, found or not found.',
    ),
    Consignment(
      name: 'The Short of Madder',
      crates: const [
        [(1, 2), (2, 3), (1, 3)],
        [(1, 2), (2, 3), (1, 3)],
        [(0, 1), (2, 3), (1, 2)],
        [(1, 2), (2, 3), (0, 3)],
      ],
      ways: 0,
      note: 'Count the madder: it shows on two faces in the whole '
          'consignment. A fair stack needs it at two rope-ends on each '
          'line, four in all, and two is all there is. No stacking '
          'exists, and the counting is the proof.',
    ),
    Consignment(
      name: 'The Second Thoughts',
      crates: const [
        [(1, 1), (1, 0), (0, 0)],
        [(2, 3), (2, 2), (2, 0)],
        [(0, 2), (1, 1), (3, 1)],
        [(0, 0), (3, 2), (3, 2)],
      ],
      ways: 4,
      note: 'Crates painted the same on opposite faces make ropes from '
          'a post to itself, and the loops still close: four ways, all '
          'kin.',
    ),
  ];

  static int get count => all.length;

  static Consignment at(int number) =>
      all[number.clamp(0, all.length - 1)];
}
