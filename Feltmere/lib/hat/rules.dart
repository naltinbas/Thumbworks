/// Three villagers stand in a ring at the fair, each with a black or a
/// white hat put on by the toss of a coin. Everyone sees the other two
/// hats and never their own. At a word they all speak at once: each
/// either names a colour for their own hat or holds their tongue. The
/// village wins if at least one of them names a colour and every colour
/// named is right.
///
/// They may agree anything they like beforehand, and what they agree is
/// a rule for each villager saying what to do for each of the four
/// things that villager might see. The game is finding a good
/// agreement.
///
/// Todd Ebert asked the question in 1998. The best any agreement can do
/// with three villagers is six hattings in eight, and the reason is a
/// count: every villager who speaks on a sight is right on one of the
/// two hattings that sight allows and wrong on the other, so a wrong
/// word is paid for every word spoken.
class Rules {
  static const villagers = 3;

  /// What a villager may do: name black, name white, or hold their
  /// tongue.
  static const black = 0, white = 1, quiet = 2;

  static const says = [black, white, quiet];

  /// The four things a villager can see, as the hats of the next two
  /// round the ring.
  static const sights = [
    [black, black],
    [black, white],
    [white, black],
    [white, white],
  ];

  /// Every way the three hats can fall, eight of them.
  static List<List<int>> get hattings => [
        for (var mask = 0; mask < 8; mask++)
          [mask & 1, (mask >> 1) & 1, (mask >> 2) & 1],
      ];

  /// What villager [who] sees when the hats are [hats]: the next two
  /// round the ring.
  static List<int> sightOf(List<int> hats, int who) =>
      [hats[(who + 1) % villagers], hats[(who + 2) % villagers]];

  /// Which of the four sights that is.
  static int sightNumber(List<int> hats, int who) {
    final seen = sightOf(hats, who);
    for (var i = 0; i < sights.length; i++) {
      if (sights[i][0] == seen[0] && sights[i][1] == seen[1]) return i;
    }
    return 0;
  }

  /// An agreement: for each villager, what to say for each sight.
  static bool valid(List<List<int>> agreement) =>
      agreement.length == villagers &&
      agreement.every((rule) =>
          rule.length == sights.length && rule.every(says.contains));

  /// Whether the village wins the hatting [hats] under [agreement].
  static bool winsOn(List<List<int>> agreement, List<int> hats) {
    var spoken = false;
    for (var who = 0; who < villagers; who++) {
      final say = agreement[who][sightNumber(hats, who)];
      if (say == quiet) continue;
      if (say != hats[who]) return false;
      spoken = true;
    }
    return spoken;
  }

  /// How many of the eight hattings the village wins.
  static int wins(List<List<int>> agreement) {
    var count = 0;
    for (final hats in hattings) {
      if (winsOn(agreement, hats)) count++;
    }
    return count;
  }

  /// The hattings the village loses, told as strings.
  static List<String> losses(List<List<int>> agreement) => [
        for (final hats in hattings)
          if (!winsOn(agreement, hats)) tellHats(hats),
      ];

  /// How many words the agreement calls for over all four sights of all
  /// three villagers.
  static int words(List<List<int>> agreement) {
    var count = 0;
    for (final rule in agreement) {
      for (final say in rule) {
        if (say != quiet) count++;
      }
    }
    return count;
  }

  /// How many wrong words the agreement risks over the eight hattings,
  /// which is one for every word it calls for.
  static int wrongs(List<List<int>> agreement) {
    var count = 0;
    for (final hats in hattings) {
      for (var who = 0; who < villagers; who++) {
        final say = agreement[who][sightNumber(hats, who)];
        if (say != quiet && say != hats[who]) count++;
      }
    }
    return count;
  }

  /// Whether any villager holds their tongue whatever they see.
  static bool hasQuiet(List<List<int>> agreement) =>
      agreement.any((rule) => rule.every((say) => say == quiet));

  /// The agreement everyone starts from: nobody says anything.
  static List<List<int>> get quietAll => [
        for (var who = 0; who < villagers; who++)
          [for (var sight = 0; sight < sights.length; sight++) quiet],
      ];

  /// The taps it takes to build [agreement] from silence, a tap for
  /// black and two for white, since the cells go round quiet, black,
  /// white.
  static int taps(List<List<int>> agreement) {
    var count = 0;
    for (final rule in agreement) {
      for (final say in rule) {
        if (say == black) count += 1;
        if (say == white) count += 2;
      }
    }
    return count;
  }

  /// Every agreement the three can come to: three rules of four sights
  /// with three choices each.
  static Iterable<List<List<int>>> agreements() sync* {
    final rules = <List<int>>[];
    for (var mask = 0; mask < 81; mask++) {
      rules.add([
        mask % 3,
        (mask ~/ 3) % 3,
        (mask ~/ 9) % 3,
        (mask ~/ 27) % 3,
      ]);
    }
    for (final a in rules) {
      for (final b in rules) {
        for (final c in rules) {
          yield [a, b, c];
        }
      }
    }
  }

  static String tellSay(int say) => switch (say) {
        black => 'black',
        white => 'white',
        _ => 'quiet',
      };

  static String tellHat(int hat) => hat == black ? 'black' : 'white';

  static String tellHats(List<int> hats) =>
      hats.map((hat) => hat == black ? 'B' : 'W').join('');

  static String tellSight(int sight) =>
      '${tellHats(sights[sight])} seen';

  static String tellVillager(int who) => ['Ash', 'Birch', 'Cedar'][who];
}
