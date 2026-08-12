import 'green.dart';

/// The five greens that ship.
///
/// Every number here is checked twice before the bake: the sweep of
/// every fence plays each green out, and tool/check_greens.dart
/// refuses the lot if any count, floor, or label disagrees with it.
class Greens {
  static const all = [
    Green(
      name: 'The Half Acre',
      size: 5,
      area2: 1,
      posts: 3,
      ways: 320,
      note: 'Every half-acre fence on this green is a bare '
          'three-hurdle triangle: Pick allows it nothing swallowed '
          'and no crossing walked but the hurdles themselves.',
    ),
    Green(
      name: 'The Empty Pen',
      size: 5,
      area2: 6,
      penned: 0,
      posts: 4,
      ways: 300,
      note: 'Three acres swallowing nothing must walk eight '
          'crossings, and no triangle on this green manages that '
          'line: four hurdles is the floor.',
    ),
    Green(
      name: 'The Full Fold',
      size: 5,
      area2: 6,
      penned: 2,
      posts: 3,
      ways: 1096,
      note: 'Pick pins the line at four crossings walked, so a '
          'three-hurdle fence here always has one crossing sitting '
          'on a rail between hurdles.',
    ),
    Green(
      name: 'The Nine Swallowed',
      size: 5,
      penned: 9,
      posts: 4,
      ways: 47,
      note: 'Nine swallowed costs nine acres and a half at the '
          'least, the barest line being three crossings, and no '
          'triangle on this green holds nine: it takes four '
          'hurdles.',
    ),
    Green(
      name: 'The Third Acre',
      size: 5,
      thirds: 1,
      posts: null,
      note: 'The acreages of this green march in steps of a half, '
          'from the bare triangle up to the whole sixteen; a third '
          'falls between the steps and always will.',
    ),
  ];

  /// Closed misses a hopeless green allows before calling it.
  static const missesAllowed = 3;

  static int get count => all.length;

  static Green at(int number) => all[number];
}
