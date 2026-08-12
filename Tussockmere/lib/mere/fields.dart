import 'field.dart';

/// The five fields that ship.
///
/// Every claim here is checked twice before the bake: the solve
/// plays each field out both ways, the sweep reads every filling,
/// and tool/check_fields.dart refuses the lot if anything
/// disagrees.
class Fields {
  static const all = [
    Field(
      name: 'The Three Field',
      size: 3,
      winnable: true,
      note: 'Nine tussocks, and five of the nine openings survive '
          'a perfect reply: the middle, and the four beside the '
          'short diagonal\'s ends.',
    ),
    Field(
      name: 'The Four Field',
      size: 4,
      winnable: true,
      note: 'Sixteen tussocks, and only the four on the short '
          'diagonal survive a perfect reply: open anywhere else '
          'and the game is already lost to right play.',
    ),
    Field(
      name: 'The Pie',
      size: 4,
      houseOpens: 6,
      pieOffered: true,
      winnable: true,
      note: 'The mere opens on the short diagonal, which survives '
          'perfect play: take the pie. Decline it and the solve '
          'holds the far chair for good.',
    ),
    Field(
      name: 'The Humble Pie',
      size: 4,
      houseOpens: 0,
      pieOffered: true,
      winnable: true,
      note: 'The mere opens in a corner, off the short diagonal: '
          'let the pie by and beat the opening instead. Take it '
          'and the corner is yours to lose with.',
    ),
    Field(
      name: 'The Second Chair',
      size: 4,
      houseOpens: 6,
      winnable: false,
      note: 'No pie, and the mere opens on the short diagonal: the '
          'solve knows every line from here, and every one of '
          'yours loses. The first move of this marsh was the whole '
          'game.',
    ),
  ];

  static int get count => all.length;

  static Field at(int number) => all[number];
}
