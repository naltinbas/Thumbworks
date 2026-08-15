import 'level.dart';

/// The five lines that ship.
///
/// Every number here is checked before the bake: the plan run down
/// every deal, every plan of the first man counted, and
/// tool/check_calls.dart refuses the lot if anything disagrees.
class Levels {
  static const all = [
    Level(
      name: 'The Three',
      prisoners: 3,
      dealt: 0x4,
      ways: 8,
      deals: 8,
      note: 'The man at the back sees two caps and calls black if he sees an '
          'odd number of black ones; the next man sees one cap and hears one '
          'call, and knows his own; the front man hears two calls and sees '
          'nothing, and knows his own. All eight deals save the last two.',
    ),
    Level(
      name: 'The Four',
      prisoners: 4,
      dealt: 0x6,
      ways: 16,
      deals: 16,
      note: 'Every man but the first counts the black caps he sees ahead and '
          'the black caps called behind him, and calls the colour that brings '
          'the count to what the first man told: odd or even. Sixteen deals, '
          'three saved on every one.',
    ),
    Level(
      name: 'The Five',
      prisoners: 5,
      dealt: 0x16,
      ways: 32,
      deals: 32,
      note: 'Thirty-two deals, four saved on every one, and the first man right '
          'on sixteen of them, which is luck and nothing else: his call is '
          'made before he learns anything of his own cap.',
    ),
    Level(
      name: 'The Six',
      prisoners: 6,
      dealt: 0x2d,
      ways: 64,
      deals: 64,
      note: 'Sixty-four deals and five saved on every one; the plan works for '
          'any length of line, since one word of parity is all the men ahead '
          'ever need, checked here to eight men and 256 deals.',
    ),
    Level(
      name: 'The Five Saved',
      prisoners: 5,
      dealt: 0x16,
      warden: true,
      ways: 0,
      deals: 32,
      note: 'The first man\'s call can depend only on the sixteen ways the caps '
          'ahead can fall, and for each of those his own cap can be either; '
          'whatever plan he has, of the 32 deals he is right on exactly 16, '
          'every one of his 65,536 plans counted. Against a warden who caps '
          'him after he speaks he is right on none.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
