import 'pitch.dart';

/// The five pitches that ship.
///
/// Every claim here is checked twice before the bake: the sweep
/// lays every wall of every pitch, and tool/check_pitches.dart
/// refuses the lot if anything disagrees.
class Pitches {
  static const all = [
    Pitch(
      name: 'The Two Kinds',
      kinds: 2,
      height: 3,
      reachable: true,
      note: 'Three courses is the very most two kinds allow: the '
          'sweep of every wall finds two that stand at three, '
          'each the other\'s mirror, and nothing at all above.',
    ),
    Pitch(
      name: 'The Eight Courses',
      kinds: 3,
      height: 8,
      reachable: true,
      note: 'Three kinds never run dry as a heap, but a wall can '
          'pen itself in: lay the palindrome a-b-a-c-a-b-a and no '
          'eighth course of any kind stands sound.',
    ),
    Pitch(
      name: 'The Ten',
      kinds: 3,
      height: 10,
      reachable: true,
      note: 'The sweep counts 144 sound walls of ten; wander off '
          'the careful lines and the walk says so before the wall '
          'does.',
    ),
    Pitch(
      name: 'The Dozen',
      kinds: 3,
      height: 12,
      reachable: true,
      note: 'Twelve courses of three kinds, 264 sound ways: the '
          'old weaving trick, follow the pattern that never '
          'repeats, climbs past any height a fell could ask.',
    ),
    Pitch(
      name: 'The Fourth Course',
      kinds: 2,
      height: 4,
      reachable: false,
      note: 'All sixteen walls of four courses in two kinds carry '
          'a doubled run: the sweep lays every one and the third '
          'course is as high as the fell goes.',
    ),
  ];

  static int get count => all.length;

  static Pitch at(int number) => all[number];
}
