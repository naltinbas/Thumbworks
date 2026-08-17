import 'level.dart';
import 'rules.dart';

/// The five asks, first to last. Each ways count is the sweep's, and
/// the checker refuses the bake if one drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Two',
      tellings: [
        [Rules.isKnight, 1],
        [Rules.different, 0, 1],
      ],
      ways: 1,
      note: 'Alder says Birch is a knight and Birch says the two of them are '
          'not of a kind. One naming of the four holds: both are knaves. If '
          'Alder were a knight then Birch would be one too, and then Birch\'s '
          'telling would be false with Birch a knight, which cannot be.',
    ),
    Level(
      name: 'The Three',
      tellings: [
        [Rules.isKnave, 1],
        [Rules.isKnave, 2],
        [Rules.same, 0, 1],
      ],
      ways: 1,
      note: 'One naming of the eight holds: Birch alone is a knight. Cedar '
          'says Alder and Birch are of a kind, and they are not, so Cedar is '
          'a knave; then Birch, who calls Cedar a knave, is a knight; and '
          'then Alder, who calls Birch a knave, is not.',
    ),
    Level(
      name: 'The Four',
      tellings: [
        [Rules.isKnave, 1],
        [Rules.same, 2, 3],
        [Rules.different, 0, 3],
        [Rules.someKnave, 0, 1],
      ],
      ways: 2,
      note: 'Two namings of the sixteen hold this one, and they disagree '
          'about every villager: Alder and Damson knights with Birch and '
          'Cedar knaves, or the other way but for Damson, who is a knight in '
          'both. A set of tellings need not settle who is who.',
    ),
    Level(
      name: 'The Quiet Four',
      tellings: [
        [Rules.someKnave, 1, 2],
        [Rules.same, 0, 3],
        [Rules.different, 1, 3],
        [Rules.isKnave, 0],
      ],
      ways: 1,
      note: 'One naming of the sixteen holds: Alder is a knight and the '
          'other three are knaves. Damson calls Alder a knave, so the two of '
          'them are of different kinds; Birch says Alder and Damson are of a '
          'kind, so Birch is a knave; and the rest follows.',
    ),
    Level(
      name: 'The Paradox',
      tellings: [
        [Rules.selfKnave],
        [Rules.isKnight, 0],
        [Rules.isKnave, 1],
      ],
      ways: 0,
      note: 'Hopeless, and the card at the end of the ask says so. Alder '
          'says "I am a knave". A knight cannot say it, since it would be '
          'false; a knave cannot say it either, since it would be true. '
          'Nobody on the island can make that telling at all, so no naming '
          'of the eight holds, whatever Birch and Cedar say.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
