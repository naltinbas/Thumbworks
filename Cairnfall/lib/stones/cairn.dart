/// How stones may be taken off a cairn.
///
/// Three rules rather than one. A game of nothing but open cairns is Nim, and
/// Nim is a game people either know the trick to or do not; three rules mixed
/// together makes a position nobody has seen before, and the whole point of
/// what the game will show you is that the same arithmetic still settles it.
enum Rule {
  /// As many as you like, down to the last stone.
  open,

  /// One, two or three.
  three,

  /// One stone, or exactly half of them when there is an even number.
  halves,
}

/// One cairn: a rule, and how many stones are on it.
class Cairn {
  const Cairn(this.rule, this.stones);

  final Rule rule;
  final int stones;

  bool get isGone => stones == 0;

  /// How many stones may be taken off this cairn, fewest first.
  List<int> get takes => switch (rule) {
        Rule.open => [for (var take = 1; take <= stones; take++) take],
        Rule.three => [for (var take = 1; take <= stones && take <= 3; take++) take],
        Rule.halves => [
            if (stones >= 1) 1,
            if (stones >= 4 && stones.isEven) stones ~/ 2,
          ],
      };

  Cairn less(int taken) => Cairn(rule, stones - taken);

  @override
  bool operator ==(Object other) =>
      other is Cairn && other.rule == rule && other.stones == stones;

  @override
  int get hashCode => Object.hash(rule, stones);

  @override
  String toString() => '${rule.name} $stones';
}

/// What each rule is called on the screen, and what it lets you do.
extension RuleWords on Rule {
  String get name => switch (this) {
        Rule.open => 'open',
        Rule.three => 'up to three',
        Rule.halves => 'one or half',
      };

  String get says => switch (this) {
        Rule.open => 'Take as many as you like.',
        Rule.three => 'Take one, two or three.',
        Rule.halves => 'Take one stone, or exactly half when there is an '
            'even number of them.',
      };
}
