import 'package:flutter_test/flutter_test.dart';
import 'package:hollowmarch/pegs/boards.dart';
import 'package:hollowmarch/pegs/play.dart';
import 'package:hollowmarch/pegs/runs.dart';

import '../support/pegs.dart';

void main() {
  testWidgets('a board opens full but for one hollow', (tester) async {
    await open(tester, which: 0);
    final play = state(tester).play;

    expect(play.left, play.field.hollows - 1);
    expect(play.moves, 0);
    expect(find.text(Boards.at(0).name), findsOneWidget);
    expect(find.textContaining('${play.left} pegs'), findsOneWidget);
  });

  testWidgets('tapping a peg picks it up, and tapping it again puts it down',
      (tester) async {
    await open(tester, which: 0);
    final field = state(tester).play.field;

    await touch(tester, field.at(0, 2));
    expect(state(tester).holding, field.at(0, 2));

    await touch(tester, field.at(0, 2));
    expect(state(tester).holding, -1);
  });

  testWidgets('and then a hollow two along jumps it there', (tester) async {
    await open(tester, which: 0);
    final field = state(tester).play.field;

    await touch(tester, field.at(0, 2));
    await touch(tester, field.at(0, 0));

    final play = state(tester).play;
    expect(play.has(field.at(0, 0)), isTrue);
    expect(play.has(field.at(0, 1)), isFalse, reason: 'and took the middle');
    expect(play.has(field.at(0, 2)), isFalse);
    expect(play.moves, 1);
  });

  testWidgets('a tap that is not a jump says why', (tester) async {
    await open(tester, which: 0);
    final field = state(tester).play.field;

    // The board starts empty at (0,0), and (2,3) is nowhere near it.
    await touch(tester, field.at(2, 3));
    await touch(tester, field.at(0, 0));
    expect(find.textContaining('two hollows'), findsOneWidget);
    expect(state(tester).play.moves, 0);
  });

  testWidgets('and a jump with nothing to take says that', (tester) async {
    await open(tester, which: 0);
    final field = state(tester).play.field;

    // (0,2) jumps to (0,0) over (0,1). Going back has nothing in the middle.
    await touch(tester, field.at(0, 2));
    await touch(tester, field.at(0, 0));
    expect(state(tester).play.moves, 1);

    await touch(tester, field.at(0, 0));
    await touch(tester, field.at(0, 2));
    expect(find.textContaining('nothing in between'), findsOneWidget);
  });

  testWidgets('a peg that can jump again stays on the move', (tester) async {
    // The rule that makes the count worth anything: carrying on is one move.
    await open(tester, which: 0);
    final board = state(tester).board;
    final fewest = Runs.fewest(board.field, board.start)!.$2;

    var at = 0;
    while (at + 1 < fewest.length && fewest[at + 1].from != fewest[at].to) {
      await hop(tester, fewest[at]);
      at++;
    }
    await hop(tester, fewest[at]);

    expect(state(tester).play.carrying, fewest[at].to);
    expect(find.text('Let go'), findsOneWidget,
        reason: 'and the button says so');

    final was = state(tester).play.moves;
    await hop(tester, fewest[at + 1]);
    expect(state(tester).play.moves, was, reason: 'still the same move');
  });

  testWidgets('and nothing else may move until it is let go', (tester) async {
    await open(tester, which: 0);
    final board = state(tester).board;
    final fewest = Runs.fewest(board.field, board.start)!.$2;

    var at = 0;
    while (at + 1 < fewest.length && fewest[at + 1].from != fewest[at].to) {
      await hop(tester, fewest[at]);
      at++;
    }
    await hop(tester, fewest[at]);

    final other = state(tester)
        .play
        .field
        .jumps
        .firstWhere((jump) => jump.from != state(tester).play.carrying);
    await touch(tester, other.from);
    expect(find.textContaining('in the middle of its move'), findsOneWidget);
  });

  testWidgets('Take back undoes a jump', (tester) async {
    await open(tester, which: 0);
    await playSome(tester, 2);
    final was = state(tester).play.left;

    await letGo(tester);
    await press(tester, 'Take back');
    expect(state(tester).play.left, was + 1);
  });

  testWidgets('Again fills the board back up', (tester) async {
    await open(tester, which: 0);
    await playSome(tester, 3);
    await letGo(tester);
    await press(tester, 'Again');

    final play = state(tester).play;
    expect(play.left, play.field.hollows - 1);
    expect(play.moves, 0);
  });

  testWidgets('Show me points at a jump worth making', (tester) async {
    await open(tester, which: 0);
    await press(tester, 'Show me');

    final screen = state(tester);
    expect(screen.pointing, hasLength(2));
    expect(screen.hints, 1);
    expect(find.textContaining('jumps that way'), findsOneWidget);
  });

  testWidgets('and the game says when a board can no longer be finished',
      (tester) async {
    // The one thing a player cannot see for themselves. Not every board can
    // be spoiled with one jump, so this looks for a board that can.
    var found = false;
    for (var which = 0; which < Boards.count && !found; which++) {
      await open(tester, which: which);
      final board = state(tester).board;
      final guide = state(tester).guide;

      for (final jump in state(tester).play.canJump) {
        final after = Play.of(board).jump(jump.from, jump.to);
        if (guide.canStillFinish(after.pegs) != false) continue;
        await hop(tester, jump);
        found = true;
        break;
      }
    }
    expect(found, isTrue, reason: 'no board here can be spoiled in one jump');
    expect(find.textContaining('no longer come down to one peg'),
        findsOneWidget);
  });

  testWidgets('and says when nothing can jump at all', (tester) async {
    await open(tester, which: 0);
    final board = state(tester).board;
    final field = board.field;

    // Play until nothing can move, taking whatever jump is first each time.
    var guard = 0;
    while (state(tester).play.canJump.isNotEmpty && guard++ < 30) {
      final jump = state(tester).play.canJump.first;
      await hop(tester, jump);
      await letGo(tester);
    }
    final play = state(tester).play;
    if (play.isDone) return; // it happened to finish, which is not a failure
    expect(play.isStuck, isTrue);
    expect(find.textContaining('Nothing can jump'), findsOneWidget);
    expect(field.hollows, greaterThan(0));
  });

  testWidgets('every board can be played down to one peg through the screen',
      (tester) async {
    // The proof that the game is playable: each board finished in its par by
    // the same taps a finger makes.
    for (var which = 0; which < Boards.count; which++) {
      await open(tester, which: which);
      await playItOut(tester);

      final play = state(tester).play;
      expect(play.isDone, isTrue, reason: Boards.at(which).name);
      expect(play.left, 1, reason: Boards.at(which).name);
      if (Boards.at(which).par != null) {
        expect(play.moves, Boards.at(which).par, reason: Boards.at(which).name);
      }
      expect(find.bySemanticsLabel('board finished'), findsOneWidget,
          reason: Boards.at(which).name);
    }
  });
}
