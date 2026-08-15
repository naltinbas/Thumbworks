import 'level.dart';

/// The five yards that ship.
///
/// Every number here is checked before the bake: every posting swept on
/// the small yards and walked on all, the far flags and the posting one
/// in from them held to the walk on every yard from three to nine, and
/// tool/check_postings.dart refuses the lot if anything disagrees.
class Levels {
  static const all = [
    Level(
      name: 'The Four Yard',
      size: 4,
      watchmen: 4,
      ways: 256,
      postings: 1820,
      note: 'Sixteen flags and four watchmen: the four corners are each beyond '
          'the others\' watch, so three never do, and four do 256 ways of the '
          '1,820, one to a corner\'s quarter and any of its four flags will '
          'serve, four to the fourth.',
    ),
    Level(
      name: 'The Five Yard',
      size: 5,
      watchmen: 4,
      ways: 79,
      postings: 12650,
      note: 'Twenty-five flags, and still four watchmen: the far flags are the '
          'four corners again, three flags apart, and four watch the yard 79 '
          'ways of the 12,650.',
    ),
    Level(
      name: 'The Six Yard',
      size: 6,
      watchmen: 4,
      ways: 1,
      postings: 58905,
      note: 'Thirty-six flags and four watchmen, and one posting alone of the '
          '58,905 watches the yard: one in from each corner, each watching a '
          'three-by-three quarter of the yard exactly.',
    ),
    Level(
      name: 'The Nine Yard',
      size: 9,
      watchmen: 9,
      ways: 1,
      postings: 260887834350,
      note: 'Eighty-one flags and nine watchmen, one posting alone: three rows of '
          'three, one in from every far flag, each watching his own three-by-three '
          'and nothing wasted.',
    ),
    Level(
      name: 'The Six Yard with Three',
      size: 6,
      watchmen: 3,
      ways: 0,
      postings: 7140,
      note: 'The four corners of the six yard are each beyond the others\' '
          'watch, five flags apart, so each wants a watchman of its own and '
          'three never do: of the 7,140 postings of three, every one leaves a '
          'corner unwatched.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
