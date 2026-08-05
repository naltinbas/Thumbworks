// A command line tool whose whole job is to print. It is not part of the game.
// ignore_for_file: avoid_print

import 'package:cairnfall/stones/play.dart';
import 'package:cairnfall/stones/rounds.dart';
import 'package:cairnfall/stones/worth.dart';

/// Says what every round is worth and how much room there is to get it wrong.
///
/// Run with: dart run tool/rounds.dart
///
/// Two numbers matter. What the position is worth, which must not be nothing
/// — a round worth nothing is lost before the player touches it. And how many
/// of the moves available win, out of how many there are: one winning move in
/// forty is a puzzle, and twenty in forty is a stroll.
void main() {
  final worth = Worth.upTo(60);

  for (var i = 0; i < Rounds.count; i++) {
    final round = Rounds.at(i);
    final play = Play(cairns: round.cairns, toMove: Who.you);
    final moves = play.moves;
    final winning = moves
        .where((move) => worth.ofAll(play.after(move).cairns) == 0)
        .length;

    print('${(i + 1).toString().padLeft(2)} ${round.name.padRight(18)} '
        '${round.cairns.length} cairns  '
        '${round.stones.toString().padLeft(3)} stones  '
        'worth ${worth.ofAll(round.cairns).toString().padLeft(2)}  '
        '$winning of ${moves.length} moves win  '
        '[${round.cairns.map((c) => '${c.rule.name}:${c.stones}=${worth.of(c)}').join(' ')}]');
  }
}
