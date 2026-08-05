// A command line tool whose whole job is to print. It is not part of the game.
// ignore_for_file: avoid_print

import 'dart:math';

import 'package:rungwick/ladder/graph.dart';
import 'package:rungwick/ladder/words.dart';

/// Looks for pairs of words that make a good climb, and prints them.
///
/// Run with: dart run tool/find_ladders.dart [how many] [letters]
///
/// What makes a climb good is not just how long it is. A pair whose shortest
/// way through goes by a word nobody has heard of reads as impossible however
/// short it is, and a pair with fifty shortest ways through is a stroll. So
/// this reports the length, how many words are on some shortest ladder, and
/// how tight the middle is — the fewest words at any one distance from the
/// end, which is the narrowest part a player has to find.
void main(List<String> args) {
  final wanted = args.isEmpty ? 12 : int.parse(args.first);
  final letters = args.length > 1 ? int.parse(args[1]) : 4;
  final ladder = Ladder.of(letters == 5 ? kFive : kFour);

  print('${ladder.count} words of $letters letters');

  final dice = Random(7);
  final found = <String>[];
  for (var tried = 0; tried < 60000 && found.length < wanted; tried++) {
    final from = dice.nextInt(ladder.count);
    final to = dice.nextInt(ladder.count);
    if (from == to) continue;

    final climb = ladder.climb(from, to);
    if (climb == null) continue;
    final steps = climb.length - 1;
    if (steps < 4 || steps > 7) continue;

    // How many words sit on some shortest ladder, and how few there are at
    // the tightest point. One way through is a puzzle; twenty is a corridor.
    final fromStart = ladder.stepsFrom(from);
    final fromEnd = ladder.stepsFrom(to);
    final atDistance = List.filled(steps + 1, 0);
    var onAny = 0;
    for (var word = 0; word < ladder.count; word++) {
      if (fromStart[word] < 0 || fromEnd[word] < 0) continue;
      if (fromStart[word] + fromEnd[word] != steps) continue;
      onAny++;
      atDistance[fromStart[word]]++;
    }
    final tightest = atDistance.reduce(min);

    found.add('${ladder.wordAt(from)} -> ${ladder.wordAt(to)}  '
        '$steps steps  $onAny on a shortest ladder  '
        'tightest $tightest\n      '
        '${climb.map(ladder.wordAt).join(' ')}');
  }

  for (final one in found) {
    print('  $one');
  }
}
