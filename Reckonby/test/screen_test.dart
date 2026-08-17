import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/reckonland.dart';

/// One ask on the screen, the wheels turned as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips', (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('turn the wheels until the house reads 42'),
        findsOneWidget);
    expect(find.text('reads 0'), findsOneWidget);
    expect(find.text('under the top 719'), findsOneWidget);
    expect(find.text('turns 0'), findsOneWidget);
    expect(find.text('The house reads 0, 719 under the top.'), findsOneWidget);
  });

  testWidgets('a wheel turns a notch, and back undoes', (tester) async {
    await open(tester, which: 4);
    await turn(tester, 3, 1);
    expect(state(tester).play.wheels, [0, 0, 1, 0, 0]);
    expect(find.text('reads 6'), findsOneWidget);
    await press(tester, 'Back');
    expect(find.text('reads 0'), findsOneWidget);
    expect(find.text('turns 0'), findsOneWidget);
  });

  testWidgets('a wheel will not turn past its stop', (tester) async {
    await open(tester, which: 4);
    await turn(tester, 1, -1);
    expect(state(tester).play.wheels, [0, 0, 0, 0, 0]);
    expect(find.text('turns 0'), findsOneWidget);
  });

  testWidgets('forty-two lands in four turns and the card is shown',
      (tester) async {
    await open(tester, which: 0);
    await setWheels(tester, [0, 0, 3, 1, 0]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Read.'), findsOneWidget);
    expect(find.text('As asked. The house reads 42, 677 under the top.'),
        findsOneWidget);
    expect(
        find.textContaining(
            'The wheels stand 0 1 3 0 0, which is 1 times 24 and 3 times 6, '
            'and the house reads 42. No other setting of the wheels reads it, '
            'and none of the 720 reads the same number twice; 4 turns.'),
        findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Read.'), findsNothing);
    expect(find.text('turns 0'), findsOneWidget);
  });

  testWidgets('show me names the wheel, and the pointer lands a hundred',
      (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');
    expect(find.text('Turn the 2! wheel up one.'), findsOneWidget);
    expect(state(tester).pointing, (2, 1));
    await readByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.reading, 100);
    expect(state(tester).play.moves, 6);
  });

  testWidgets('every wheel full reads seven hundred and nineteen',
      (tester) async {
    await open(tester, which: 3);
    await readByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.wheels, [1, 2, 3, 4, 5]);
    expect(state(tester).play.moves, 15);
    expect(find.text('under the top 0'), findsNothing);
    expect(
        find.textContaining('the house reads 719. No other setting of the '
            'wheels reads it'),
        findsOneWidget);
  });

  testWidgets('a reading short of the ask says how far under it is',
      (tester) async {
    await open(tester, which: 2);
    await setWheels(tester, [0, 0, 0, 0, 4]);
    expect(state(tester).play.isDone, isFalse);
    expect(find.text('reads 480'), findsOneWidget);
    expect(find.text('under the top 239'), findsOneWidget);
  });

  testWidgets('seven hundred and twenty gives itself up after four readings',
      (tester) async {
    await open(tester, which: 4);
    for (final wheel in [1, 2, 3, 4]) {
      await turn(tester, wheel, 1);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('The house stops at 719.'), findsOneWidget);
    expect(
        find.text('Every wheel at its top folds up to 6 factorial less one, '
            'so 719 is as high as the house reads.'),
        findsOneWidget);
    expect(
        find.textContaining(
            'so the five of them fold up to 6 factorial less one and there is '
            'nothing above it to read'),
        findsOneWidget);
  });

  testWidgets('the why tells the folding sum and the two voices',
      (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('6 factorial less 1 factorial'), findsOneWidget);
    expect(
        find.textContaining(
            'once by counting the house up a tick at a time from nothing'),
        findsOneWidget);
  });
}
