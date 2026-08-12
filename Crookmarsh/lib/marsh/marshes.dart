import 'setting.dart';

/// The five marshes that ship.
///
/// Every number here is checked before the bake: the tuck test,
/// the hull walk and the sweep, and tool/check_marshes.dart
/// refuses the lot if anything disagrees.
class Marshes {
  static const all = [
    Setting(
      name: 'The Crooked Four',
      posts: 4,
      asked: 0,
      ways: 240,
      note: 'No frame from four posts means one tucked inside '
          'the others\' triangle: 240 of the 1,278 clear '
          'settings stand so crooked.',
    ),
    Setting(
      name: 'The True Frame',
      posts: 4,
      asked: 1,
      ways: 1038,
      note: 'Four posts stand true 1,038 ways: the marsh prefers '
          'a frame to a tuck by better than four to one.',
    ),
    Setting(
      name: 'The One Frame',
      posts: 5,
      asked: 1,
      ways: 12,
      note: 'The needle of the marsh: only twelve of the 1,668 '
          'clear settings of five hold exactly one frame, a '
          'triangle with two posts tucked just so.',
    ),
    Setting(
      name: 'The Full Five',
      posts: 5,
      asked: 5,
      ways: 848,
      note: 'Five posts all cornering outward frame every four '
          'of themselves: five frames from five posts, and 848 '
          'settings manage it.',
    ),
    Setting(
      name: 'The Frameless Five',
      posts: 5,
      asked: 0,
      ways: 0,
      note: 'The happy ending theorem: five posts, none three to '
          'a line, always hold a frame. The sweep stood all '
          '1,668 clear settings of five and found frames in '
          'every one, always one, three, or five of them, never '
          'an even count and never none.',
    ),
  ];

  static int get count => all.length;

  static Setting at(int number) => all[number];
}
