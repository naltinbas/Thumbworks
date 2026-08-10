import 'fewest.dart';
import 'till.dart';

/// One customer at the counter: a till, an amount, and the fewest coins it
/// can be counted out in.
class Round {
  Round({
    required this.name,
    required this.till,
    required this.amount,
    required this.fewest,
  });

  final String name;
  final Till till;

  /// What is owed, in pence.
  final int amount;

  /// The fewest coins. Written down here as well as worked out, so a test can
  /// hold the two against each other.
  final int fewest;

  String get spoken => till.spoken(amount);
}

/// The rounds that ship.
///
/// All the old till rounds are amounts whose fewest is exactly the plain
/// floor, the amount over the half crown rounded up, so the game always has
/// an argument a player can check with one multiplication. Three of them are
/// amounts where taking the biggest coin that fits comes out a coin worse,
/// which the old coinage really did to people: two florins beat a half crown
/// and change at four shillings, and nobody behind a counter reached for two
/// florins first.
class Rounds {
  const Rounds._();

  static final List<Round> all = [
    Round(name: 'Half a Crown', till: Tills.old, amount: 30, fewest: 1),
    Round(name: 'Four and Six', till: Tills.old, amount: 54, fewest: 2),
    Round(name: 'Four Bob', till: Tills.old, amount: 48, fewest: 2),
    Round(name: 'Six and Six', till: Tills.old, amount: 78, fewest: 3),
    Round(name: 'Nine Bob', till: Tills.old, amount: 108, fewest: 4),
    Round(name: 'Nineteen Bob', till: Tills.old, amount: 228, fewest: 8),
    Round(name: 'The New Till', till: Tills.decimal, amount: 88, fewest: 6),
  ];

  static int get count => all.length;

  static Round at(int number) => all[number.clamp(0, all.length - 1)];

  /// One table per till, kept between screens.
  static final _fewests = <Till, Fewests>{};

  static Fewests fewestsFor(int number) => _fewests.putIfAbsent(
        at(number).till,
        () => Fewests(at(number).till),
      );

  /// Empties what the tables have kept. For the tests.
  static void forget() => _fewests.clear();
}
