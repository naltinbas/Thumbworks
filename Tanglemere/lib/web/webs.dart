import 'web.dart';

/// The webs that ship.
///
/// Every number here is checked twice over: tool/check_webs.dart
/// searches every weave and sweeps every painting, and refuses the
/// bake on any disagreement.
class Webs {
  static const all = [
    Web(
      name: 'The Five Posts',
      dots: 5,
      playerFirst: true,
      standing: 0,
      note: 'Five posts leave room to live: twelve full paintings of '
          'the web hold no one-colour triangle, every one a ring of '
          'each colour round all five posts, and best weaving on '
          'both sides ends in one of them.',
    ),
    Web(
      name: 'The Second Seat',
      dots: 5,
      playerFirst: false,
      standing: 0,
      note: 'The same five posts from the other chair: the draw '
          'still stands with careful weaving, and the search of '
          'every weave says neither seat can force more.',
    ),
    Web(
      name: 'The Six Posts',
      dots: 6,
      playerFirst: false,
      standing: 1,
      note: 'On six posts somebody must close a triangle: all '
          '32,768 paintings of the full web hold one, and the '
          'counting argument finds it without looking. The search '
          'says the second weaver holds the win: this is your chair. '
          'Weave well.',
    ),
    Web(
      name: 'The First Thread',
      dots: 6,
      playerFirst: true,
      standing: -1,
      note: 'The first weaver on six posts is lost before the first '
          'thread: the search of every weave gives the second seat '
          'the win, and the house sits in it. Play it out and watch '
          'the net close, in the house tradition of games nobody '
          'can win.',
    ),
  ];

  static int get count => all.length;

  static Web at(int number) => all[number];
}
