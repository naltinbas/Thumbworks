import 'package:flutter_test/flutter_test.dart';
import 'package:packwold/fit/boxes.dart';
import 'package:packwold/fit/play.dart';

import '../support/fit.dart';

void main() {
  testWidgets('a puzzle opens with every piece in the tray', (tester) async {
    await open(tester, which: 0);
    final play = state(tester).play;

    expect(play.laid, 0);
    expect(find.text(Puzzles.at(0).name), findsOneWidget);
    expect(find.textContaining('${play.pieces} laid'), findsOneWidget);
    for (final letter in play.letters) {
      expect(find.bySemanticsLabel(RegExp('^the $letter piece')),
          findsOneWidget);
    }
  });

  testWidgets('taking a piece from the tray puts it in hand', (tester) async {
    await open(tester, which: 0);
    await pick(tester, 'L');
    expect(state(tester).holding, state(tester).play.letters.indexOf('L'));

    // And tapping it again puts it back.
    await pick(tester, 'L');
    expect(state(tester).holding, -1);
  });

  testWidgets('and it goes down where the box is tapped', (tester) async {
    await open(tester, which: 0);
    final want = state(tester).guide.answer.first;
    await lay(tester, want);

    final play = state(tester).play;
    expect(play.isLaid(want.piece), isTrue);
    expect(play.placed(want.piece)!.cells.toSet(), want.cells.toSet());
    expect(state(tester).holding, -1, reason: 'and is out of hand');
    expect(find.bySemanticsLabel(RegExp('^the ${want.letter} piece')),
        findsNothing, reason: 'and out of the tray');
  });

  testWidgets('turning changes the shape in hand', (tester) async {
    await open(tester, which: 0);
    await pick(tester, 'L');
    final piece = state(tester).play.letters.indexOf('L');
    final first = state(tester).play.shapeOf(piece).picture;

    await press(tester, 'Turn');
    expect(state(tester).play.shapeOf(piece).picture, isNot(first));

    await press(tester, 'Turn');
    await press(tester, 'Turn');
    await press(tester, 'Turn');
    expect(state(tester).play.shapeOf(piece).picture, first,
        reason: 'four turns is all the way round');
  });

  testWidgets('and flipping changes it the other way', (tester) async {
    await open(tester, which: 0);
    await pick(tester, 'L');
    final piece = state(tester).play.letters.indexOf('L');
    final first = state(tester).play.shapeOf(piece).picture;

    await press(tester, 'Flip');
    expect(state(tester).play.shapeOf(piece).picture, isNot(first));
    await press(tester, 'Flip');
    expect(state(tester).play.shapeOf(piece).picture, first);
  });

  testWidgets('with nothing in hand it says to take a piece first',
      (tester) async {
    await open(tester, which: 0);
    await press(tester, 'Turn');
    expect(find.textContaining('Take a piece'), findsOneWidget);
  });

  testWidgets('a piece that does not fit says why', (tester) async {
    await open(tester, which: 0);
    await pick(tester, 'L');

    // The top left of the first box is a hole.
    await touch(tester, 0, 0);
    expect(state(tester).play.laid, 0);
    expect(find.textContaining('ground the box does not have'), findsOneWidget);

    // And the far corner leaves it hanging over the edge.
    final box = state(tester).play.box;
    await touch(tester, box.deep - 1, box.wide - 1);
    expect(state(tester).play.laid, 0);
    expect(find.textContaining('over the edge'), findsOneWidget);
  });

  testWidgets('and one that lands on another says that instead',
      (tester) async {
    await open(tester, which: 0);
    final want = state(tester).guide.answer;
    await lay(tester, want[0]);

    // A bare square where the second piece would still reach across the
    // first. Tapping the first piece itself would pick it up rather than
    // refuse anything, which is the other rule.
    await pick(tester, want[1].letter);
    final box = state(tester).play.box;
    var found = false;
    for (var row = 0; row < box.deep && !found; row++) {
      for (var column = 0; column < box.wide && !found; column++) {
        if (state(tester).play.at(row, column) >= 0) continue;
        if (state(tester).play.whyNot(want[1].piece, row, column) !=
            Refusal.onAnother) {
          continue;
        }
        await touch(tester, row, column);
        found = true;
      }
    }
    expect(found, isTrue, reason: 'nowhere it would land on the other');
    expect(state(tester).play.laid, 1);
    expect(find.textContaining('already lying there'), findsOneWidget);
  });

  testWidgets('tapping a piece on the box picks it up again', (tester) async {
    await open(tester, which: 0);
    final want = state(tester).guide.answer.first;
    await lay(tester, want);

    final (row, column) = squareOf(tester, want.cells.first);
    await touch(tester, row, column);

    expect(state(tester).play.isLaid(want.piece), isFalse);
    expect(state(tester).holding, want.piece);
    expect(find.bySemanticsLabel(RegExp('^the ${want.letter} piece')),
        findsOneWidget, reason: 'and is back in the tray');
  });

  testWidgets('Again tips the whole box out', (tester) async {
    await open(tester, which: 0);
    await lay(tester, state(tester).guide.answer.first);
    expect(state(tester).play.laid, 1);

    await press(tester, 'Again');
    expect(state(tester).play.laid, 0);
    expect(state(tester).holding, -1);
  });

  testWidgets('Show me names a piece and points at where it goes',
      (tester) async {
    await open(tester, which: 0);
    await press(tester, 'Show me');

    final screen = state(tester);
    expect(screen.pointing, hasLength(5));
    expect(screen.hints, 1);
    expect(screen.holding, isNonNegative, reason: 'and hands it over');
    expect(find.textContaining('covers those five squares'), findsOneWidget);
    expect(find.textContaining('pieces to go'), findsOneWidget);
  });

  testWidgets('and says which piece is in the wrong place', (tester) async {
    await open(tester, which: 0);
    final guide = state(tester).guide;

    // The first piece, put somewhere it fits that the answer does not use.
    final want = guide.answer[0];
    await pick(tester, want.letter);
    var put = false;
    final box = state(tester).play.box;
    for (var row = 0; row < box.deep && !put; row++) {
      for (var column = 0; column < box.wide && !put; column++) {
        if (!state(tester).play.canLay(0, row, column)) continue;
        await touch(tester, row, column);
        final laid = state(tester).play.placed(0);
        if (laid == null) continue;
        if (laid.cells.toSet().containsAll(want.cells)) {
          // That is where it belongs; take it off and keep looking.
          await touch(tester, row, column);
          continue;
        }
        put = true;
      }
    }
    expect(put, isTrue, reason: 'nowhere wrong to put it');

    await press(tester, 'Show me');
    expect(find.textContaining('is not where it belongs'), findsOneWidget);
    expect(state(tester).pointing.toSet(),
        state(tester).play.placed(0)!.cells.toSet());
  });

  testWidgets('every puzzle can be packed through the screen', (tester) async {
    // The proof that the game is playable: every box packed by asking what
    // goes next and doing it with the same taps a finger makes.
    for (var which = 0; which < Puzzles.count; which++) {
      await open(tester, which: which);
      await packIt(tester);

      final play = state(tester).play;
      expect(play.isDone, isTrue, reason: Puzzles.at(which).name);
      expect(play.empty, 0, reason: Puzzles.at(which).name);
      expect(find.bySemanticsLabel('box packed'), findsOneWidget,
          reason: Puzzles.at(which).name);
    }
  });
}
