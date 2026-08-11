import 'room.dart';

/// The rooms that ship.
///
/// Every number here is checked twice over: tool/check_rooms.dart
/// counts every laying of each room and refuses the bake on any
/// disagreement, and holds the strip counts to the staircase rule
/// besides.
class Rooms {
  static const all = [
    Room(
      name: 'The Little Landing',
      wide: 4,
      high: 2,
      cells: 0xFF,
      ways: 5,
      note: 'A two-board strip lays by the staircase rule: each '
          'length\'s count is the two before it added, and four '
          'boards make five ways.',
    ),
    Room(
      name: 'The Long Hall',
      wide: 7,
      high: 2,
      cells: 0x3FFF,
      ways: 21,
      note: 'Seven boards long, twenty one ways, and the staircase '
          'rule holds the whole run: one, two, three, five, eight, '
          'thirteen, twenty one, each the two before it added. The '
          'count checks every step.',
    ),
    Room(
      name: 'The Square Parlour',
      wide: 4,
      high: 4,
      cells: 0xFFFF,
      ways: 36,
      note: 'Four by four lays thirty six ways, every one counted.',
    ),
    Room(
      name: 'The Fair Clip',
      wide: 4,
      high: 4,
      cells: 0xFFF6,
      ways: 12,
      note: 'Two corners gone from the same edge: one dark, one '
          'light, so the colours stay even at seven apiece, and the '
          'floor lays twelve ways. Which corners go is the whole '
          'story.',
    ),
    Room(
      name: 'The Clipped Parlour',
      wide: 4,
      high: 4,
      cells: 0x7FFE,
      ways: 0,
      note: 'The famous one: two opposite corners gone, and they '
          'were the same colour. Puzzlers have been set this floor '
          'for a century, and the two counts under the tint are the '
          'whole answer.',
    ),
  ];

  static int get count => all.length;

  static Room at(int number) => all[number];
}
