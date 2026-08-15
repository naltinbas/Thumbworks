import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/slateland.dart';

/// One slate on the screen, played as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a level opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(
      find.textContaining('draw as crosses from the open slate'),
      findsOneWidget,
    );
    expect(find.text('moves 0'), findsOneWidget);
    expect(find.text('tree: level'), findsOneWidget);
    expect(find.text('book: waiting'), findsOneWidget);
    expect(find.text('Your move as crosses; the tree says level.'), findsOneWidget);
  });

  testWidgets('a mark is answered by the book, and back undoes both', (tester) async {
    await open(tester, which: 0);
    await tapCell(tester, 0);
    expect(state(tester).play.board, [1, 0, 0, 0, 2, 0, 0, 0, 0]);
    expect(find.text('moves 1'), findsOneWidget);
    expect(find.text('book: centre'), findsOneWidget);
    expect(find.text('The book: centre. Your move as crosses; the tree says level.'), findsOneWidget);
    await tapCell(tester, 4);
    expect(state(tester).play.moves, 1);
    await press(tester, 'Back');
    expect(state(tester).play.moves, 0);
    expect(find.text('book: waiting'), findsOneWidget);
  });

  testWidgets('the book opens the second hand in the middle', (tester) async {
    await open(tester, which: 1);
    expect(state(tester).play.board, [0, 0, 0, 0, 1, 0, 0, 0, 0]);
    expect(find.text('book: centre'), findsOneWidget);
    expect(find.text('The book: centre. Your move as noughts; the tree says level.'), findsOneWidget);
  });

  testWidgets('the tree draws the open slate and shows the card', (tester) async {
    await open(tester, which: 0);
    await playByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Landed.'), findsOneWidget);
    expect(find.text('Level: the slate is full and no line is made.'), findsOneWidget);
    expect(find.text('moves 5'), findsOneWidget);
    expect(
      find.textContaining('The slate stands as asked; 5 moves.'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(find.text('Landed.'), findsNothing);
  });

  testWidgets('show me rings a cell', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Show me');
    expect(state(tester).pointing, isNotNull);
    expect(find.text('Mark the ringed cell.'), findsOneWidget);
  });

  testWidgets('the corner trap wins by the pointer', (tester) async {
    await open(tester, which: 2);
    expect(find.text('tree: a win for you'), findsOneWidget);
    await playByPointer(tester);
    expect(state(tester).play.won, isTrue);
    expect(find.text('Won: three crosses in a row.'), findsOneWidget);
    expect(find.text('Landed.'), findsOneWidget);
  });

  testWidgets('a side reply to the middle is lost, and the book holds it', (tester) async {
    await open(tester, which: 1);
    await tapCell(tester, 1);
    expect(find.text('tree: a win for the book'), findsOneWidget);
    await fillIn(tester);
    expect(state(tester).play.lost, isTrue);
    expect(find.text('The book has three in a row.'), findsOneWidget);
    expect(find.text('The book held it.'), findsOneWidget);
    expect(find.textContaining('The book made three in a row.'), findsOneWidget);
  });

  testWidgets('the hopeless level cracks when the slate is played out', (tester) async {
    await open(tester, which: 4);
    await tapCell(tester, 0);
    await fillIn(tester);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('The book never loses.'), findsOneWidget);
    expect(
      find.textContaining('If noughts had a winning way, crosses could take it first'),
      findsOneWidget,
    );
  });

  testWidgets('the why walks the tree', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('255,168 games over 5,478 slates'),
      findsOneWidget,
    );
    expect(
      find.textContaining('holds the slate level or better'),
      findsOneWidget,
    );
  });

  testWidgets('the why of the two corners counts the sides', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Why');
    expect(
      find.textContaining('4 of the 28 land it'),
      findsOneWidget,
    );
    expect(
      find.textContaining('only the four sides'),
      findsOneWidget,
    );
  });
}
