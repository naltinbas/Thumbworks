// A command line tool whose whole job is to print. It is not part of the game.
// ignore_for_file: avoid_print

import 'package:hazardwell/game/odds.dart';
import 'package:hazardwell/game/rules.dart';

/// Works out the whole table of odds and says what it cost and what it found.
///
/// Run with: dart run tool/reckon.dart
void main() {
  final clock = Stopwatch()..start();
  final odds = Odds.reckon();
  final took = clock.elapsedMilliseconds;

  print('${odds.sweeps} sweeps, ${took}ms, settled to ${odds.drift}');
  print('the player to move at nothing all: '
      '${odds.winning(0, 0, 0).toStringAsFixed(4)}');

  print('');
  print('what to do at a standing start, as the turn grows:');
  for (final turn in [0, 4, 8, 12, 16, 20, 24, 28]) {
    final chance = odds.chanceAt(0, 0, turn);
    print('  turn ${turn.toString().padLeft(2)}  '
        'bank ${chance.bank.toStringAsFixed(6)}  '
        'one ${chance.one.toStringAsFixed(6)}  '
        'two ${chance.two.toStringAsFixed(6)}  '
        '-> ${chance.best.name}');
  }

  print('');
  print('the turn to bank at, by score, when they have the same:');
  for (var score = 0; score < Rules.target; score += 10) {
    var bankAt = 0;
    while (bankAt < Rules.target - score &&
        odds.bestAt(score, score, bankAt) != Move.bank) {
      bankAt++;
    }
    print('  at ${score.toString().padLeft(2)} all, bank on $bankAt');
  }
}
