/// What a player may do when it is their turn.
enum Move {
  /// Bank what the turn has made so far and hand over.
  bank,

  /// One die. A one loses the turn.
  one,

  /// Two dice. Either of them a one loses the turn, and two ones lose the
  /// score as well.
  two,
}

/// The rules, as numbers.
///
/// Everything that decides anything reads them from here, so a game, a solver
/// and a test can never be playing three different games.
class Rules {
  const Rules._();

  /// What it takes to win.
  static const target = 100;

  /// The faces of a die.
  static const faces = 6;

  /// What two dice with no one on them pay.
  ///
  /// The total, and twice the total if they match. That last part is the
  /// whole reason there are two ways to roll: without it, two dice would be
  /// exactly one die rolled twice with no choice in between — the same odds,
  /// the same payouts, and never once worth picking over rolling one die and
  /// then deciding. A pair paying double is a gamble the other one cannot
  /// make.
  static int paidFor(int first, int second) =>
      first == second ? (first + second) * 2 : first + second;

  /// Every payout two dice can make without a one on them, as a payout and
  /// how many of the thirty six rolls make it, flat so the solver's inner
  /// loop reads a list of numbers rather than a list of pairs.
  static const boldPays = [
    5, 2, //
    6, 2,
    7, 4,
    8, 5,
    9, 4,
    10, 2,
    11, 2,
    12, 1,
    16, 1,
    20, 1,
    24, 1,
  ];

  /// The most a turn can be worth before banking it wins the game outright.
  static int mostTurn(int score) => target - score;
}
