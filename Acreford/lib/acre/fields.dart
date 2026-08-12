import 'field.dart';

/// The five fields that ship.
///
/// Every number here is checked before the bake: the sweep of
/// all 516 three-post and 1,758 four-post paddocks, Pick's
/// count against the rails' crossing sum on every one, and
/// tool/check_acres.dart refuses the lot if anything disagrees.
class Fields {
  static const all = [
    Field(
      name: 'The Half Acre',
      posts: 3,
      twoA: 1,
      ways: 124,
      note: 'Half an acre is the least any paddock holds, and '
          'only three posts can hold so little: a fourth corner '
          'pushes the rim to four, and Pick makes the acre '
          'whole at the least.',
    ),
    Field(
      name: 'The Whole Acre',
      posts: 4,
      twoA: 2,
      ways: 225,
      note: 'A whole acre from four posts is always bare: '
          'Pick leaves no room, the rim exactly the four '
          'corners and not one post within.',
    ),
    Field(
      name: 'The Post Within',
      posts: 4,
      inside: 1,
      ways: 456,
      note: 'One post within makes the acres read the rim: '
          'twice the acres comes out exactly the rim count, '
          'so the fence pays two whole acres at the least.',
    ),
    Field(
      name: 'The Half Over',
      posts: 4,
      twoA: 5,
      ways: 212,
      note: 'Every one of the 212 lets a post onto a rail: '
          'the rim pays five or seven, never even, and the '
          'half acre wants the odd.',
    ),
    Field(
      name: 'The Even Rim',
      posts: 4,
      twoA: 5,
      midRail: false,
      ways: 0,
      note: 'Bare rims write five half-acre counts and no '
          'more: two, four, six, eight and ten, the evens '
          'alone. Two and a half is five of the halves, and '
          'five is odd.',
    ),
  ];

  static int get count => all.length;

  static Field at(int number) => all[number];
}
