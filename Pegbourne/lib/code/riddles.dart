import 'riddle.dart';

/// The riddles that ship. Guesses are packed two bits a peg, colour
/// order red, green, blue, yellow, first peg lowest.
///
/// Every number here is checked twice over: tool/check_riddles.dart
/// sweeps all 256 codes against every riddle and refuses the bake on
/// any disagreement.
class Riddles {
  // Packed guesses: R=0, G=1, B=2, Y=3.
  static const _rrgg = 0x50; // R R G G
  static const _rbrb = 0x88; // R B R B
  static const _rgby = 0xE4; // R G B Y
  static const _rygb = 0x9C; // R Y G B
  static const _bbrr = 0x0A; // B B R R
  static const _rrrr = 0x00;
  static const _gggg = 0x55;
  static const _byby = 0xEE; // B Y B Y

  static const all = [
    Riddle(
      name: 'The First Riddle',
      rows: [
        (_rrgg, 3, 0),
        (_rbrb, 2, 1),
      ],
      ways: 1,
      note: 'Two rows, and one code left standing: three blacks pin '
          'most of the first row where it sits, and the second row '
          'sorts out the rest.',
    ),
    Riddle(
      name: 'The Scattered Four',
      rows: [
        (_rgby, 2, 2),
        (_rrgg, 1, 1),
        (_rygb, 0, 4),
      ],
      ways: 1,
      note: 'The last row is the pretty one: four whites and no '
          'black, every colour right and every place wrong. One code '
          'obliges all three rows.',
    ),
    Riddle(
      name: 'The Twin Pegs',
      rows: [
        (_rbrb, 0, 3),
        (_rrgg, 0, 1),
      ],
      ways: 1,
      note: 'The answer wears a colour twice, which is allowed and '
          'is the trick: the sweep of all 256 codes leaves exactly '
          'one.',
    ),
    Riddle(
      name: 'The Two Minds',
      rows: [
        (_rrgg, 0, 1),
        (_bbrr, 2, 1),
        (_rgby, 1, 2),
      ],
      ways: 2,
      note: 'These rows keep their secret badly: two codes agree '
          'with every one, and the rows cannot tell them apart. Set '
          'either and the riddle is answered; ask why twice to see '
          'both.',
    ),
    Riddle(
      name: 'The Liar\'s Riddle',
      rows: [
        (_rrrr, 3, 0),
        (_gggg, 3, 0),
        (_byby, 1, 1),
      ],
      ways: 0,
      note: 'The first row wants three red pegs and the second three '
          'green, and four slots cannot hold both: somebody wrote '
          'their marks down wrong. The sweep of all 256 codes '
          'agrees with the counting: none fits.',
    ),
  ];

  static int get count => all.length;

  static Riddle at(int number) => all[number];
}
