import 'mesh.dart';

/// The meshes that ship.
///
/// Every claim here is checked twice over: tool/check_meshes.dart
/// searches the shorter weaves and, where the counting is small
/// enough, enumerates every weave outright, and refuses the bake on
/// any disagreement.
class Meshes {
  static const all = [
    Mesh(
      name: 'The Three Strands',
      strands: 3,
      combs: 3,
      winnable: true,
      note: 'Three combs riddle three strands, and fewer cannot: the '
          'search followed everything two combs can leave and none of '
          'it comes clean.',
    ),
    Mesh(
      name: 'The Four',
      strands: 4,
      combs: 5,
      winnable: true,
      note: 'Five combs riddle four strands. Twelve of the 7,776 '
          'five-comb weaves do it; find any one of them.',
    ),
    Mesh(
      name: 'The Short Weave',
      strands: 4,
      combs: 4,
      winnable: false,
      note: 'Four combs cannot riddle four strands, and the suite '
          'holds two proofs that share nothing: it ran all 1,296 '
          'four-comb weaves through every grist, and it followed '
          'everything four combs can leave. Nothing comes clean '
          'either way.',
    ),
    Mesh(
      name: 'The Five',
      strands: 5,
      combs: 9,
      winnable: true,
      note: 'Nine combs riddle five strands, and eight cannot: the '
          'search followed everything eight combs can leave, every '
          'branch, and none of it comes clean.',
    ),
    Mesh(
      name: 'The Six',
      strands: 6,
      combs: 12,
      winnable: true,
      note: 'Twelve combs riddle six strands, and eleven cannot, by '
          'the same search. Sixty four grists run the frame every '
          'time a comb lands.',
    ),
  ];

  static int get count => all.length;

  static Mesh at(int number) => all[number];
}
