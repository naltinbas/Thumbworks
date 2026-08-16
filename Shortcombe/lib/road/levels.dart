import 'level.dart';

/// The five asks, first to last. Every count is the sweep's, and the
/// checker refuses the bake if any drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Sixty-Five',
      kind: 'shutMinutes',
      minutes: 65,
      ways: 1,
      note: 'With the shortcut shut the crowd splits evenly, half by the top '
          'and half by the bottom, and every driver takes 45 minutes on the '
          'fixed road and one minute per hundred on the other: forty hundred, '
          'split twenty and twenty, take 65. On the dial the shut journey '
          'runs from 46 minutes for two hundred to 75 for sixty hundred, one '
          'minute more for every two hundred.',
    ),
    Level(
      name: 'The Eighty',
      kind: 'openMinutes',
      minutes: 80,
      ways: 1,
      note: 'With the shortcut open every driver of a crowd under forty-five '
          'hundred goes top, across and bottom, since that way costs the two '
          'variable roads and no fixed one and beats either old way whatever '
          'the others do; forty hundred all together take 40 + 40 = 80 '
          'minutes, fifteen more than the 65 with the shortcut shut, and none '
          'can do better alone, the top way costing 40 + 45 = 85. Past '
          'forty-five hundred the old ways come back into use until the '
          'variable roads carry forty-five hundred each, and everyone takes '
          '90.',
    ),
    Level(
      name: 'The Helpful Shortcut',
      kind: 'helps',
      ways: 14,
      note: 'The open shortcut speeds the crowd up while it is under thirty '
          'hundred: two hundred take 4 minutes instead of 46, twenty hundred '
          '40 instead of 55, twenty-eight hundred 56 instead of 59, fourteen '
          'crowds of the thirty on the dial. At thirty hundred it makes no '
          'odds, 60 either way, and past thirty it hurts.',
    ),
    Level(
      name: 'The Break-Even',
      kind: 'noOdds',
      ways: 2,
      note: 'Thirty hundred take 60 minutes with the shortcut shut, fifteen and '
          'fifteen, and 60 with it open, all across: 45 + 15 and 30 + 30 '
          'meet, and only there; two settings of the 60, the crowd of thirty '
          'with the shortcut either way.',
    ),
    Level(
      name: 'The Big Crowd Helped',
      kind: 'bigHelped',
      ways: 0,
      note: 'Hopeless, and the tile says so. Past thirty hundred the open '
          'shortcut hurts every driver: under forty-five hundred all go '
          'across, since that way beats either old way whatever the others '
          'do, and take twice the crowd in minutes, more than 45 plus half '
          'the crowd once the crowd tops thirty; from forty-five hundred on '
          'the settled journey is 90, more than the shut 45 plus half the '
          'crowd until the crowd would top ninety. Braess found it in 1968; '
          'on the dial fifteen crowds are hurt, thirty-two hundred by 3 '
          'minutes, forty by 15, forty-six by 22, the most, and sixty by 15.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
