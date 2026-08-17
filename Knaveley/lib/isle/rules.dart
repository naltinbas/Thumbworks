/// An island where every villager is either a knight, who says nothing
/// but the truth, or a knave, who says nothing but falsehood. Each one
/// makes a telling about the others, and the game is naming who is
/// which so that every telling holds: a knight's telling true and a
/// knave's false.
///
/// Puzzles of this kind are Raymond Smullyan's, from What Is the Name
/// of This Book? in 1978, and the arithmetic behind them is plain: a
/// naming is a row of knights and knaves, and it holds when every
/// villager's kind matches the truth of what that villager says. With
/// n villagers there are two to the n namings to try, and some sets of
/// tellings are held by none of them.
class Rules {
  /// The kinds a villager can be.
  static const knight = true, knave = false;

  /// What a telling can be about.
  static const isKnight = 'knight',
      isKnave = 'knave',
      same = 'same',
      different = 'different',
      someKnave = 'someKnave',
      selfKnave = 'selfKnave';

  /// Whether the telling [what] made by villager [who] is true under
  /// the naming [naming].
  static bool holds(List<dynamic> what, int who, List<bool> naming) {
    switch (what[0] as String) {
      case isKnight:
        return naming[what[1] as int];
      case isKnave:
        return !naming[what[1] as int];
      case same:
        return naming[what[1] as int] == naming[what[2] as int];
      case different:
        return naming[what[1] as int] != naming[what[2] as int];
      case someKnave:
        return !naming[what[1] as int] || !naming[what[2] as int];
      default:
        return !naming[who];
    }
  }

  /// Whether every villager's kind matches the truth of the telling
  /// that villager makes.
  static bool consistent(List<List<dynamic>> tellings, List<bool> naming) {
    for (var who = 0; who < tellings.length; who++) {
      if (naming[who] != holds(tellings[who], who, naming)) return false;
    }
    return true;
  }

  /// Which villagers are caught out by a naming: their kind and their
  /// telling disagree.
  static List<int> caught(
      List<List<dynamic>> tellings, List<bool> naming) => [
        for (var who = 0; who < tellings.length; who++)
          if (naming[who] != holds(tellings[who], who, naming)) who,
      ];

  /// Every naming of [many] villagers.
  static Iterable<List<bool>> namings(int many) sync* {
    for (var mask = 0; mask < (1 << many); mask++) {
      yield [for (var i = 0; i < many; i++) mask >> i & 1 == 1];
    }
  }

  static int howManyNamings(int many) => 1 << many;

  /// The namings that hold every telling.
  static List<List<bool>> answers(List<List<dynamic>> tellings) => [
        for (final naming in namings(tellings.length))
          if (consistent(tellings, naming)) naming,
      ];

  static const names = ['Alder', 'Birch', 'Cedar', 'Damson', 'Elder'];

  static String tellName(int who) => names[who];

  /// A telling in words, as the villager would say it.
  static String tellTelling(List<dynamic> what, int who) {
    switch (what[0] as String) {
      case isKnight:
        return '${tellName(what[1] as int)} is a knight';
      case isKnave:
        return '${tellName(what[1] as int)} is a knave';
      case same:
        return '${tellName(what[1] as int)} and '
            '${tellName(what[2] as int)} are of a kind';
      case different:
        return '${tellName(what[1] as int)} and '
            '${tellName(what[2] as int)} are not of a kind';
      case someKnave:
        return 'one of ${tellName(what[1] as int)} and '
            '${tellName(what[2] as int)} is a knave';
      default:
        return 'I am a knave';
    }
  }

  static String tellNaming(List<bool> naming) => [
        for (var who = 0; who < naming.length; who++)
          '${tellName(who)} the ${naming[who] ? 'knight' : 'knave'}',
      ].join(', ');
}
