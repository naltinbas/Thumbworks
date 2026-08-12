import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/ham.dart';

/// The screen, worked the way a finger would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a fresh shelf names itself and its task', (tester) async {
    await open(tester, which: 0);
    expect(find.text('The One Step'), findsOneWidget);
    expect(
      find.textContaining('shelve 4 books with exactly 1 step'),
      findsOneWidget,
    );
    expect(find.text('0 steps down; 1 asked.'), findsOneWidget);
  });

  testWidgets('a pick lifts a book and a swap lands', (tester) async {
    await open(tester, which: 0);
    await tapPlace(tester, 0);
    expect(
      find.text('Book at place 1 in hand; tap another to swap.'),
      findsOneWidget,
    );
    await tapPlace(tester, 1);
    expect(state(tester).play.order, [1, 0, 2, 3]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Shelved.'), findsOneWidget);
    expect(find.textContaining('The fewest yet'), findsOneWidget);
  });

  testWidgets('the steps chip counts as the shelf changes',
      (tester) async {
    await open(tester, which: 2);
    await swap(tester, 0, 1);
    expect(find.text('steps down 1'), findsOneWidget);
    await swap(tester, 2, 3);
    expect(find.text('steps down 2'), findsOneWidget);
    expect(state(tester).play.isDone, isTrue);
  });

  testWidgets('back takes back a swap and unfreezes', (tester) async {
    await open(tester, which: 0);
    await swap(tester, 0, 1);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'Back');
    expect(state(tester).play.isDone, isFalse);
    expect(find.text('Shelved.'), findsNothing);
  });

  testWidgets('show me names the book and the place', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');
    final aim = state(tester).pointing;
    expect(aim, isNotNull);
    expect(
      find.text('Put book ${aim!.$2 + 1} at place ${aim.$1 + 1}.'),
      findsOneWidget,
    );
  });

  testWidgets('why speaks the recurrence and the reversal',
      (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Why');
    expect(
      find.textContaining('Euler\'s recurrence builds the row'),
      findsOneWidget,
    );
    expect(
      find.textContaining('reversing any ordering swaps'),
      findsOneWidget,
    );
    expect(find.textContaining('26 orderings land'), findsOneWidget);
  });

  testWidgets('the hopeless shelf admits it and speaks the gaps',
      (tester) async {
    await open(tester, which: 4);
    for (var round = 0; round < 12; round++) {
      await swap(tester, 0, 1);
    }
    expect(state(tester).play.moves, 12);
    expect(find.text('The fourth step never lands.'), findsOneWidget);
    expect(
      find.textContaining('a step down needs a gap of its own'),
      findsOneWidget,
    );
    await press(tester, 'Why');
    expect(
      find.textContaining('nowhere to stand'),
      findsOneWidget,
    );
  });

  testWidgets('again starts the shelf over', (tester) async {
    await open(tester, which: 0);
    await swap(tester, 0, 1);
    await press(tester, 'Again');
    expect(state(tester).play.moves, 0);
    expect(find.text('Shelved.'), findsNothing);
  });
}
