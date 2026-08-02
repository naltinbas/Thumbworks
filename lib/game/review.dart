import 'odds.dart';
import 'play.dart';
import 'rules.dart';

/// One decision somebody made, and what it was worth.
class Choice {
  const Choice({
    required this.yours,
    required this.theirs,
    required this.turn,
    required this.took,
    required this.best,
    required this.cost,
  });

  final int yours;
  final int theirs;
  final int turn;

  /// What was done, and what would have won most often.
  final Move took;
  final Move best;

  /// The share of the game it cost, between nothing and everything.
  final double cost;

  bool get wasBest => cost <= 0.00005;

  @override
  String toString() => '$yours-$theirs on $turn: ${took.name} '
      '(${best.name}, ${(cost * 100).toStringAsFixed(1)}%)';
}

/// Everything one player decided in a game, and what it all cost.
///
/// The point of this is not to tell somebody off. It is that the cost of a
/// decision in this game is a real number that can be worked out exactly, and
/// a game where you can be told you gave away four per cent of it by rolling
/// once too often is a game you can actually get better at.
class Review {
  Review(this.odds);

  final Odds odds;
  final _choices = <Choice>[];

  List<Choice> get choices => List.unmodifiable(_choices);

  /// Writes down a decision, from the position it was made in.
  void note(Play play, Move took) {
    final chance = odds.chanceAt(play.mine, play.others, play.turn);
    _choices.add(Choice(
      yours: play.mine,
      theirs: play.others,
      turn: play.turn,
      took: took,
      best: chance.best,
      cost: chance.bestChance - chance.of(took),
    ));
  }

  /// How much of the game was given away, all told.
  ///
  /// Not a sum of probabilities that means anything on its own — every cost
  /// is measured from a different position, and the second one is measured
  /// from a position the first one led to. It is a tally of mistakes, and it
  /// reads as one.
  double get given => _choices.fold(0, (all, one) => all + one.cost);

  int get mistakes => _choices.where((one) => !one.wasBest).length;

  /// The decisions that cost the most, worst first.
  List<Choice> get worst {
    final sorted = [..._choices]..sort((a, b) => b.cost.compareTo(a.cost));
    return sorted.where((one) => !one.wasBest).toList();
  }

  /// How near the whole game was to being played perfectly, as a share.
  double get sharpness =>
      _choices.isEmpty ? 1 : (_choices.length - mistakes) / _choices.length;
}
