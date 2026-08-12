import 'stile.dart';

/// The five stiles that ship.
///
/// Every number here is checked twice before the bake: the sweep
/// dials every stride of every round, and tool/check_stiles.dart
/// refuses the lot if anything disagrees.
class Stiles {
  static const all = [
    Stile(
      name: 'The Even Fence',
      pegs: 5,
      asked: 1,
      ways: 8,
      note: 'One gap length means the pegs land evenly: a round of '
          'five with any stride, or ten with an even one. Eight '
          'dials of the sweep\'s hundred-odd land it.',
    ),
    Stile(
      name: 'The Two of Nine',
      pegs: 9,
      asked: 2,
      ways: 18,
      note: 'Nine pegs shy of a full round always split the hoop '
          'two ways: eighteen dials land it, every one a round of '
          'ten, eleven, or twelve.',
    ),
    Stile(
      name: 'The Eleven',
      pegs: 11,
      asked: 2,
      ways: 4,
      note: 'Eleven distinct pegs need a round of twelve, and only '
          'the four strides that share nothing with twelve keep '
          'all eleven apart.',
    ),
    Stile(
      name: 'The Three of Seven',
      pegs: 7,
      asked: 3,
      ways: 2,
      note: 'The needle of the fence: of every dial to twelfths, '
          'only four over eleven and its mirror land seven pegs in '
          'three gap lengths, and the longest gap is the other two '
          'put together, as it always is.',
    ),
    Stile(
      name: 'The Fourth Gap',
      pegs: 8,
      asked: 4,
      ways: 0,
      note: 'The sweep has dialed every stride of every round to '
          'twelfths and hammered every count of pegs to thirty, '
          'all 1,980 fences of them: the gaps take one, two, or '
          'three lengths, and a fourth has never once shown.',
    ),
  ];

  static int get count => all.length;

  static Stile at(int number) => all[number];
}
