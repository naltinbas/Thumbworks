import 'package:flutter_test/flutter_test.dart';

import 'support/fen.dart';
import 'support/fonts.dart';

/// The screen, worked the way a finger would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a fresh village names itself and its debts',
      (tester) async {
    await open(tester, which: 0);
    expect(find.text('The Lane'), findsOneWidget);
    expect(
      find.textContaining('settle 2 pounds of debt with 0 clear'),
      findsOneWidget,
    );
    expect(
      find.text('2 houses owing 2 pounds; 0 moves taken.'),
      findsOneWidget,
    );
  });

  testWidgets('one lending at the mill settles the lane',
      (tester) async {
    await open(tester, which: 0);
    await tapHouse(tester, 1);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Settled.'), findsOneWidget);
    expect(
      find.textContaining(
          'Every house clear in 1 move; the proven fewest is 1'),
      findsOneWidget,
    );
    expect(find.textContaining('The fewest yet'), findsOneWidget);
  });

  testWidgets('the borrow toggle turns a tap around', (tester) async {
    await open(tester, which: 0);
    await press(tester, 'Borrow');
    await tapHouse(tester, 0);
    expect(state(tester).play.pounds, [0, 1, -1]);
    expect(state(tester).play.moves, 1);
  });

  testWidgets('back takes back a move', (tester) async {
    await open(tester, which: 0);
    await tapHouse(tester, 1);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'Back');
    expect(state(tester).play.isDone, isFalse);
    expect(state(tester).play.moves, 0);
    expect(find.text('Settled.'), findsNothing);
  });

  testWidgets('show me points the search\'s move and arms the toggle',
      (tester) async {
    await open(tester, which: 1);
    final aim = state(tester).play.next!;
    await press(tester, 'Show me');
    final name = state(tester).play.village.houseNames[aim.$1];
    expect(
      find.text(aim.$2 ? 'Lend from $name.' : 'Borrow at $name.'),
      findsOneWidget,
    );
    expect(state(tester).lending, aim.$2);
  });

  testWidgets('why speaks the census and the genus', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Why');
    expect(
      find.textContaining('8 classes of spread against 8 spanning '
          'trees'),
      findsOneWidget,
    );
    expect(find.textContaining('The genus here is 2'), findsOneWidget);
  });

  testWidgets('the hopeless village admits it and speaks the law',
      (tester) async {
    await open(tester, which: 4);
    for (var move = 0; move < 12; move++) {
      await tapHouse(tester, move % 3);
    }
    expect(state(tester).play.moves, 12);
    expect(find.text('The pound stays short.'), findsOneWidget);
    expect(
      find.textContaining('no move changes a spread\'s class'),
      findsOneWidget,
    );
    await press(tester, 'Why');
    expect(
      find.textContaining('only 1 of them settles'),
      findsOneWidget,
    );
  });

  testWidgets('again starts the village over', (tester) async {
    await open(tester, which: 0);
    await tapHouse(tester, 1);
    await press(tester, 'Again');
    expect(state(tester).play.moves, 0);
    expect(find.text('Settled.'), findsNothing);
  });
}
