import 'cairn.dart';

/// One round: a row of cairns to start from.
class Round {
  const Round({required this.name, required this.about, required this.cairns});

  final String name;

  /// What this one is for, in a line. The rounds teach the arithmetic in
  /// order, and saying which part is which is most of the teaching.
  final String about;

  final List<Cairn> cairns;

  int get stones => cairns.fold(0, (all, cairn) => all + cairn.stones);

  Set<Rule> get rules => {for (final cairn in cairns) cairn.rule};
}

/// The rounds, in the order they are met.
///
/// Every one of them is winnable by whoever moves first, which is you — a
/// test says so. That is not a courtesy: a round that is lost before it
/// starts is a round where nothing the player does matters, and this game is
/// only about what they do.
class Rounds {
  const Rounds._();

  static const all = <Round>[
    Round(
      name: 'Two heaps',
      about: 'Whoever takes the last stone wins',
      cairns: [Cairn(Rule.open, 3), Cairn(Rule.open, 5)],
    ),
    Round(
      name: 'Three heaps',
      about: 'Now it is not just about making them equal',
      cairns: [Cairn(Rule.open, 1), Cairn(Rule.open, 2), Cairn(Rule.open, 4)],
    ),
    Round(
      name: 'The short cairn',
      about: 'One where you can only take three at a time',
      cairns: [Cairn(Rule.three, 7), Cairn(Rule.open, 5)],
    ),
    Round(
      name: 'Two short',
      about: 'Two of them, and they go round every four stones',
      cairns: [Cairn(Rule.three, 6), Cairn(Rule.three, 9)],
    ),
    Round(
      name: 'The halving cairn',
      about: 'One stone, or half of them at a stroke',
      cairns: [Cairn(Rule.halves, 12), Cairn(Rule.open, 3)],
    ),
    Round(
      name: 'All three',
      about: 'One of each, and the same arithmetic settles it',
      cairns: [
        Cairn(Rule.open, 6),
        Cairn(Rule.three, 5),
        Cairn(Rule.halves, 8),
      ],
    ),
    Round(
      name: 'The long row',
      about: 'Four cairns, and only one move that wins',
      cairns: [
        Cairn(Rule.open, 7),
        Cairn(Rule.three, 10),
        Cairn(Rule.halves, 16),
        Cairn(Rule.open, 2),
      ],
    ),
    Round(
      name: 'The yard',
      about: 'Five, and none of them small',
      cairns: [
        Cairn(Rule.halves, 20),
        Cairn(Rule.open, 11),
        Cairn(Rule.three, 13),
        Cairn(Rule.halves, 9),
        Cairn(Rule.open, 6),
      ],
    ),
  ];

  static int get count => all.length;

  static Round at(int which) => all[which.clamp(0, all.length - 1)];
}
