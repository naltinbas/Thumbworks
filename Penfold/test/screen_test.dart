import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/foldland.dart';

/// One ask on the screen, the whistles blown as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens with a sheep in every field', (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('gather the flock in the near fold'),
        findsOneWidget);
    expect(find.text('spread over 4 fields'), findsOneWidget);
    expect(find.text('no whistles yet'), findsOneWidget);
    expect(find.text('whistles 0'), findsOneWidget);
    expect(find.text('The flock stands in fields 1, 2, 3, 4.'), findsOneWidget);
  });

  testWidgets('a whistle moves every sheep, and back undoes it',
      (tester) async {
    await open(tester, which: 0);
    await blow(tester, 0);
    expect(state(tester).play.spread, 2);
    expect(find.text('After L the flock stands in fields 2, 4.'), findsOneWidget);
    expect(find.text('whistles 1'), findsOneWidget);
    await press(tester, 'Back');
    expect(find.text('whistles 0'), findsOneWidget);
  });

  testWidgets('the near fold comes in on two whistles', (tester) async {
    await open(tester, which: 0);
    await blowCall(tester, [0, 1]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Gathered.'), findsOneWidget);
    expect(
        find.textContaining('The call L R gathers the flock in field 1, in 2 whistles'),
        findsOneWidget);
    expect(find.textContaining('2 of the 4 calls of 2 gather it'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Gathered.'), findsNothing);
    expect(find.text('whistles 0'), findsOneWidget);
  });

  testWidgets('show me names the whistle, and the pointer gathers the nine',
      (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Show me');
    expect(find.text('Blow the right whistle.'), findsOneWidget);
    await gatherByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 9);
    expect(
        find.textContaining(
            'The call R L L L R L L L R gathers the flock in field 2, in 9 whistles'),
        findsOneWidget);
  });

  testWidgets('the five takes its one call', (tester) async {
    await open(tester, which: 2);
    await gatherByPointer(tester);
    expect(state(tester).play.moves, 5);
    expect(find.textContaining('1 of the 32 calls of 5 gathers it'),
        findsOneWidget);
  });

  testWidgets('the turning fold admits it', (tester) async {
    await open(tester, which: 4);
    await blowCall(tester, [0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1]);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Four wide, and staying that way.'), findsOneWidget);
    expect(find.textContaining('No call gathers this fold, however long'),
        findsOneWidget);
  });

  testWidgets('the why tells Cerny and the sweep', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('Jan Cerny gave the test'), findsOneWidget);
    expect(find.textContaining('walked in full'), findsOneWidget);
  });
}
