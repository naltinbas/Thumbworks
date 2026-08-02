// This is a command line tool whose whole job is to print a table.
// ignore_for_file: avoid_print

import 'dart:math';

import 'package:thornguard/game/board.dart';
import 'package:thornguard/game/game.dart';
import 'package:thornguard/game/search.dart';

/// Plays the opponent against itself and reports who wins.
///
/// Run with: dart run tool/balance.dart [depth] [games]
///
/// This is how the opening was settled. A siege game can look perfectly
/// sensible on the board and be decided before anyone moves, and the only way
/// to find out is to play it several hundred times. Three arrangements were
/// tried:
///
///   sixteen raiders, four to an edge   raiders won four games in five
///   eight raiders, two to an edge      guards won every single game
///   twelve raiders, three to an edge   about even, at every depth
///
/// The numbers below are the third one. Nothing here is random except the
/// opening moves — the search is deterministic — so a run is repeatable and a
/// change that unbalances the game shows up as a different table.
void main(List<String> args) {
  final depth = args.isEmpty ? 3 : int.parse(args.first);
  final games = args.length < 2 ? 40 : int.parse(args[1]);

  var raiders = 0, guards = 0, drawn = 0, unfinished = 0;
  var plies = 0;
  final watch = Stopwatch()..start();

  for (var seed = 0; seed < games; seed++) {
    final random = Random(seed);
    var game = Game.fresh();

    // A few random moves each side, so the games are not all the same game.
    for (var i = 0; i < 4 && !game.isOver; i++) {
      final moves = game.board.moves;
      game = game.play(moves[random.nextInt(moves.length)]);
    }

    while (!game.isOver) {
      final thought = Search(depth: depth).think(game.board);
      if (thought.move == null) break;
      game = game.play(thought.move!);
    }

    plies += game.played;
    switch (game.board.winner) {
      case Side.raiders:
        raiders++;
      case Side.guards:
        guards++;
      case null:
        if (game.isOver) {
          drawn++;
        } else {
          unfinished++;
        }
    }
  }

  watch.stop();
  print('depth $depth, $games games');
  print('  raiders    $raiders');
  print('  guards     $guards');
  print('  drawn      $drawn');
  print('  unfinished $unfinished');
  print('  ${(plies / games).toStringAsFixed(1)} moves a game, '
      '${(watch.elapsedMilliseconds / games).toStringAsFixed(0)}ms a game');
}
