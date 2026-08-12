import 'package:flutter_test/flutter_test.dart';

import 'support/fenland.dart';
import 'support/fonts.dart';

/// The screen, worked the way a finger would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a fresh fen names itself and its task', (tester) async {
    await open(tester, which: 0);
    expect(find.text('The Pair'), findsOneWidget);
    expect(
      find.textContaining('take 2 baskets with none swallowing'),
      findsOneWidget,
    );
    expect(
      find.text('0 taken, 2 to go; all free so far.'),
      findsOneWidget,
    );
  });

  testWidgets('a take and a swallowing called out', (tester) async {
    await open(tester, which: 0);
    await tapBasket(tester, 1);
    expect(find.text('taken 1 of 2'), findsOneWidget);
    await tapBasket(tester, 3);
    expect(
      find.text('One taken basket swallows another: hand one '
          'back.'),
      findsOneWidget,
    );
    expect(find.text('swallowings 1'), findsOneWidget);
  });

  testWidgets('a free pair lands and records', (tester) async {
    await open(tester, which: 0);
    await takeAll(tester, const [3, 5]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Taken.'), findsOneWidget);
    expect(find.textContaining('2 takings'), findsOneWidget);
    expect(find.textContaining('The fewest yet'), findsOneWidget);
  });

  testWidgets('back takes back a taking and unfreezes',
      (tester) async {
    await open(tester, which: 0);
    await takeAll(tester, const [3, 5]);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'Back');
    expect(state(tester).play.isDone, isFalse);
    expect(find.text('Taken.'), findsNothing);
  });

  testWidgets('show me rings a basket', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Show me');
    final aim = state(tester).pointing;
    expect(aim, isNotNull);
    expect(aim!.$2, isTrue);
    expect(
      find.text('Take the ringed basket.'),
      findsOneWidget,
    );
  });

  testWidgets('why speaks the sweep and the weighing', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Why');
    expect(
      find.textContaining('the weighing never past twelve'),
      findsOneWidget,
    );
    expect(
      find.textContaining('one family lands'),
      findsOneWidget,
    );
  });

  testWidgets('the hopeless fen admits it and speaks the weights',
      (tester) async {
    await open(tester, which: 4);
    for (var taking = 0; taking < 14; taking++) {
      await tapBasket(tester, 0);
    }
    expect(state(tester).play.moves, 14);
    expect(find.text('The seventh never fits.'), findsOneWidget);
    expect(
      find.textContaining('seven baskets weigh fourteen'),
      findsOneWidget,
    );
    await press(tester, 'Why');
    expect(
      find.textContaining('down any chain of swallowings'),
      findsOneWidget,
    );
  });

  testWidgets('again starts the fen over', (tester) async {
    await open(tester, which: 0);
    await takeAll(tester, const [3, 5]);
    await press(tester, 'Again');
    expect(state(tester).play.moves, 0);
    expect(find.text('Taken.'), findsNothing);
  });
}
