import 'level.dart';

/// The five asks, the last of them hopeless.
class Levels {
  static const all = [
    Level(
      name: 'The Far Pocket',
      kind: 'far',
      ways: 39,
      note: 'The ball crosses the table q/g times along and p/g times up, g the '
          'sides\' common factor, and lands in the far pocket when both counts are '
          'odd: 39 of the 121 tables, every square among them, where the ball runs '
          'straight up the diagonal without a bounce, 11 tables.',
    ),
    Level(
      name: 'The Right Pocket',
      kind: 'right',
      ways: 41,
      note: 'The right-hand pocket takes the ball when the tables crossed along are '
          'odd and up even, 41 of the 121, the two by three among them, three '
          'bounces in six steps; the top pocket takes the other 41, and the two by '
          'four is one of those, one bounce in four steps.',
    ),
    Level(
      name: 'The One Bounce',
      kind: 'bounces',
      count: 1,
      ways: 10,
      note: 'One bounce is one side twice the other, the ball crossing one table '
          'along and two up or the other way about: ten tables of the 121, from the '
          'two by four to the twelve by six.',
    ),
    Level(
      name: 'The Longest Rally',
      kind: 'most',
      ways: 2,
      note: 'The eleven by twelve and the twelve by eleven bounce 21 times, the '
          'most on the sham, over 132 steps, one less than each side and both '
          'together less two; the seven by five bounces ten times in 35 steps.',
    ),
    Level(
      name: 'The Home Pocket',
      kind: 'home',
      ways: 0,
      note: 'Coming home would take an even count of tables both along and up, '
          'and the two counts are the sides with their common factor divided out, '
          'so they share no factor and cannot both be even: none of the 121 tables '
          'sends the ball home, and the ball rolled step by step never gets '
          'there either.',
    ),
  ];

  static int get count => all.length;

  static Level at(int i) => all[i];
}
