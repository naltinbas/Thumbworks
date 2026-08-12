import 'fold.dart';

/// The five folds that ship.
///
/// Every number here is checked before the bake: the sweep, the
/// pen census and the crown ledger, and tool/check_folds.dart
/// refuses the lot if anything disagrees.
class Folds {
  static const all = [
    Fold(
      name: 'The Pentagon',
      posts: 5,
      asking: Asking.any,
      ways: 5,
      note: 'Two hurdles fold five posts into three pens, and '
          'there are five ways to lay them: Catalan\'s third '
          'count, and every one keeps exactly two ears.',
    ),
    Fold(
      name: 'The Fan',
      posts: 6,
      asking: Asking.fourCrown,
      ways: 6,
      note: 'A post cornering four pens holds every hurdle: the '
          'fan. Six of the fourteen foldings carry one, one fan '
          'for each post.',
    ),
    Fold(
      name: 'The Even Fold',
      posts: 6,
      asking: Asking.evenFold,
      ways: 8,
      note: 'Keep every post at three pens or fewer and eight '
          'of the fourteen foldings remain: the fans are exactly '
          'what falls away.',
    ),
    Fold(
      name: 'The Zigzag',
      posts: 6,
      asking: Asking.zigzag,
      ways: 2,
      note: 'Crowns of 1 and 3 alternating all round: only the '
          'two zigzag foldings wear it, and they are also the '
          'only foldings with three ears.',
    ),
    Fold(
      name: 'The Earless',
      posts: 6,
      asking: Asking.earless,
      ways: 0,
      note: 'The two-ears theorem: every folding keeps at least '
          'two posts cornering a single pen. The sweep laid all '
          'fourteen and read every crown, and no folding ever '
          'went below two ears, here or on the pentagon.',
    ),
  ];

  static int get count => all.length;

  static Fold at(int number) => all[number];
}
