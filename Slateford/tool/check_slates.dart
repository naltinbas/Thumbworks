import 'dart:io';

import 'package:slateford/slate/book.dart';
import 'package:slateford/slate/levels.dart';
import 'package:slateford/slate/play.dart';
import 'package:slateford/slate/rules.dart';

/// Walks the whole tree, plays every game against the book from
/// every start, holds the book to the tree at every move, and
/// refuses the bake on any disagreement: this is what `make slates`
/// runs, and the README quotes its ledger verbatim.
void main() {
  // The tree, whole.
  final census = Rules.census();
  if (census.positions.length != 5478 ||
      census.games != 255168 ||
      census.crossWins != 131184 ||
      census.noughtWins != 77904 ||
      census.draws != 46080 ||
      census.crossWins + census.noughtWins + census.draws != census.games) {
    stderr.writeln('THE TREE MOVED: ${census.positions.length} slates, '
        '${census.games} games, ${census.crossWins}/${census.noughtWins}/${census.draws}');
    exit(1);
  }
  const lengths = {5: 1440, 6: 5328, 7: 47952, 8: 72576, 9: 127872};
  for (final entry in lengths.entries) {
    if (census.byLength[entry.key] != entry.value) {
      stderr.writeln('GAMES OF ${entry.key} MOVES: ${census.byLength[entry.key]}');
      exit(1);
    }
  }
  if (census.byLength.length != 5) {
    stderr.writeln('GAME LENGTHS: ${census.byLength}');
    exit(1);
  }
  if (Rules.value(Rules.empty) != 0) {
    stderr.writeln('THE OPEN SLATE IS NOT LEVEL: ${Rules.value(Rules.empty)}');
    exit(1);
  }

  // Every level: every game against the book, and the book held to
  // the tree at each of its moves.
  final walked = <String, (int, int, int, int)>{};
  for (final level in Levels.all) {
    var games = 0, won = 0, drawn = 0, lost = 0, drops = 0, best = -2;
    void walk(Play play) {
      if (play.isOver) {
        games++;
        if (play.won) {
          won++;
          best = 1;
        } else if (play.drawn) {
          drawn++;
          if (best < 0) best = 0;
        } else {
          lost++;
          if (best < -1) best = -1;
        }
        return;
      }
      for (final cell in Rules.empties(play.board)) {
        final mid = Rules.played(play.board, cell, play.side);
        final after = play.tap(cell);
        if (!Rules.over(mid) && -Rules.value(after.board) < Rules.value(mid)) {
          drops++;
        }
        walk(after);
      }
    }

    walk(Play.of(level));
    final ways = level.win ? won : drawn;
    if (games != level.games || ways != level.ways) {
      stderr.writeln('${level.name}: walk finds $ways of $games, '
          'label says ${level.ways} of ${level.games}');
      exit(1);
    }
    if (drops != 0) {
      stderr.writeln('${level.name}: THE BOOK LET THE TREE\'S WORD DROP $drops TIMES');
      exit(1);
    }
    // The tree's word on the start, from your side, must be what the
    // walk against the book can reach at best.
    final start = Play.of(level);
    if (best != start.value) {
      stderr.writeln('${level.name}: best against the book $best, tree says ${start.value}');
      exit(1);
    }
    final canLand = level.win ? best == 1 : best >= 0;
    if (canLand != level.winnable) {
      stderr.writeln('${level.name}: winnable ${level.winnable} but best is $best');
      exit(1);
    }
    walked[level.name] = (games, won, drawn, lost);
  }

  // The book never loses from the open slate, playing either side.
  final open = walked['The Open Slate']!;
  final second = walked['The Second Hand']!;
  if (open.$2 != 0 || second.$2 != 0) {
    stderr.writeln('THE BOOK LOST: $open $second');
    exit(1);
  }
  if (open.$1 != 457 || open.$3 != 111 || second.$1 != 140 || second.$3 != 16) {
    stderr.writeln('THE GAMES AGAINST THE BOOK MOVED: $open $second');
    exit(1);
  }

  // The book's openings: the middle after a corner or a side, a corner
  // after the middle; and its own first move is the middle.
  for (var cell = 0; cell < 9; cell++) {
    final (reply, rule) = Book.advise(Rules.played(Rules.empty, cell, Rules.cross));
    final wanted = cell == Rules.centre ? (0, 'corner') : (Rules.centre, 'centre');
    if ((reply, rule) != wanted) {
      stderr.writeln('THE BOOK ANSWERS $cell WITH $reply BY $rule');
      exit(1);
    }
  }
  if (Book.advise(Rules.empty) != (Rules.centre, 'centre')) {
    stderr.writeln('THE BOOK OPENS ${Book.advise(Rules.empty)}');
    exit(1);
  }

  // The saving replies: after a cross in the corner only the middle
  // keeps the slate level; after a cross in the middle, the four
  // corners; after a cross on the side, four cells.
  Map<int, int> replies(int opening) {
    final b = Rules.played(Rules.empty, opening, Rules.cross);
    return {
      for (final c in Rules.empties(b)) c: -Rules.value(Rules.played(b, c, Rules.nought)),
    };
  }

  final afterCorner = replies(0);
  final afterMiddle = replies(4);
  final afterSide = replies(1);
  final savingAfterCorner = [for (final e in afterCorner.entries) if (e.value == 0) e.key];
  final savingAfterMiddle = [for (final e in afterMiddle.entries) if (e.value == 0) e.key];
  final savingAfterSide = [for (final e in afterSide.entries) if (e.value == 0) e.key];
  if ('$savingAfterCorner' != '[4]' ||
      '$savingAfterMiddle' != '[0, 2, 6, 8]' ||
      '$savingAfterSide' != '[0, 2, 4, 7]' ||
      afterCorner.values.any((v) => v == 1) ||
      afterMiddle.values.any((v) => v == 1) ||
      afterSide.values.any((v) => v == 1)) {
    stderr.writeln('THE SAVING REPLIES MOVED: $afterCorner $afterMiddle $afterSide');
    exit(1);
  }

  // The Corner Trap's five wins all pass through a fork; The Two
  // Corners' saving replies are the four sides.
  {
    var wins = 0, forked = 0;
    void walk(Play play, bool fork) {
      if (play.isOver) {
        if (play.won) {
          wins++;
          if (fork) forked++;
        }
        return;
      }
      for (final cell in Rules.empties(play.board)) {
        final mid = Rules.played(play.board, cell, play.side);
        walk(play.tap(cell), fork || Rules.winningCells(mid, play.side).length >= 2);
      }
    }

    walk(Play.of(Levels.at(2)), false);
    if (wins != 5 || forked != 5) {
      stderr.writeln('THE CORNER TRAP WINS $wins, FORKED $forked');
      exit(1);
    }
    final two = Play.of(Levels.at(3));
    final saving = [for (final c in Rules.empties(two.board)) if (two.tap(c).value == 0) c];
    if ('$saving' != '[1, 3, 5, 7]') {
      stderr.writeln('THE TWO CORNERS SAVE BY $saving');
      exit(1);
    }
  }

  // The mark: crosses by the tree against the book, drawn in five.
  var mark = Play.of(Levels.at(0));
  while (!mark.isOver) {
    mark = mark.tap(mark.next!);
  }
  if (!mark.drawn || '${mark.board}' != '[1, 1, 2, 2, 2, 1, 1, 1, 2]') {
    stderr.writeln('THE MARK MOVED: ${mark.board}');
    exit(1);
  }

  stdout.writeln(
      'every game of noughts and crosses walked from the open slate, '
      '255,168 of them over 5,478 slates, 131,184 to the crosses, '
      '77,904 to the noughts and 46,080 level, and the book of eight '
      'rules held to the tree\'s word at every move of every game '
      'against it: 457 games from the open slate, none lost by the '
      'book and 111 level, 140 against its opening in the middle, none '
      'lost and 16 level; a cross in a corner leaves the noughts one '
      'saving reply, the middle, a cross in the middle leaves four, the '
      'corners, and the open slate reads level for both sides');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(16);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${level.ways} of the '
            '${level.games} games against the book land it'
        : ' ${number + 1} $name ${level.task}: none of the '
            '${level.games}, and the tree said so first');
  }
}
