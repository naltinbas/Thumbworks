import 'level.dart';

/// The five asks, first to last. Each ways count is the sweep's, and
/// the checker refuses the bake if one drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Half',
      kind: 'loud',
      hattings: 4,
      ways: 23270,
      aim: [
        [0, 2, 2, 0],
        [2, 2, 2, 0],
        [2, 2, 2, 0],
      ],
      note: 'Half the hattings is what one villager gets by naming a colour '
          'and the others holding their tongues: right on the four hattings '
          'where the hat is that colour, wrong on the other four. 23,270 of '
          'the 531,441 agreements win four with everybody speaking on '
          'something, and 2,652 more win four with a villager silent '
          'throughout.',
    ),
    Level(
      name: 'The Silent One',
      kind: 'quiet',
      hattings: 4,
      ways: 2652,
      aim: [
        [0, 0, 0, 0],
        [2, 2, 2, 2],
        [2, 2, 2, 2],
      ],
      note: 'With one villager silent throughout, four is all the other two '
          'can win, and 2,652 agreements manage it. Two speakers cannot do '
          'better: every word one of them is to say is right on one of the '
          'two hattings that sight allows and wrong on the other, so their '
          'wrong words are as many as their right ones and cannot be piled '
          'onto fewer hattings than they win.',
    ),
    Level(
      name: 'The Five',
      kind: 'plain',
      hattings: 5,
      ways: 624,
      aim: [
        [0, 2, 2, 2],
        [2, 2, 0, 0],
        [2, 0, 2, 0],
      ],
      note: '624 agreements of the 531,441 win five hattings. To win more '
          'than four the wrong words have to double up, two of them landing '
          'on the same hatting, and that is what the sights are for: the '
          'villagers can tell from what they see when to keep quiet.',
    ),
    Level(
      name: 'The Six',
      kind: 'plain',
      hattings: 6,
      ways: 4,
      aim: [
        [0, 2, 2, 1],
        [2, 1, 0, 2],
        [2, 0, 1, 2],
      ],
      note: 'Six is the best there is, and only four of the 531,441 '
          'agreements reach it. The plainest is this: speak only when the '
          'two hats you can see are the same colour, and then name the other '
          'colour. That loses on the two hattings where all three hats '
          'match, since then everyone speaks and everyone is wrong, and wins '
          'the other six, since exactly one villager sees a matching pair '
          'and names their own hat right.',
    ),
    Level(
      name: 'The Seven',
      kind: 'past',
      hattings: 7,
      ways: 0,
      aim: [],
      note: 'Hopeless, and the card at the end of the ask says so. Every '
          'word an agreement calls for is right on one of the two hattings '
          'that sight allows and wrong on the other, so the wrong words are '
          'as many as the words, and each hatting the village loses can '
          'swallow at most three of them, one from each villager. Winning '
          'seven leaves one hatting to swallow every wrong word, so the '
          'agreement can call for at most three words in all, and three '
          'words win at most three hattings. None of the 531,441 agreements '
          'wins seven, and none wins eight.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
