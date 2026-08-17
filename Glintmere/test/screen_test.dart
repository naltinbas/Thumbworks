import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/glintland.dart';

/// One ask on the screen, the bounce slid as a thumb would slide it.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips', (tester) async {
    await open(tester, which: 3);
    expect(find.textContaining('comes within 10 paces'), findsWidgets);
    expect(find.text('within 10'), findsOneWidget);
    expect(find.text('angles differ'), findsOneWidget);
    expect(find.text('slides 0'), findsOneWidget);
    expect(state(tester).play.bounce, 0);
  });

  testWidgets('a tap beside the bounce slides it one peg, and back undoes it',
      (tester) async {
    await open(tester, which: 3);
    await slideTowards(tester, 12);
    expect(state(tester).play.bounce, 1);
    expect(find.text('slides 1'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.bounce, 0);
    expect(find.text('slides 0'), findsOneWidget);
  });

  testWidgets('the bounce will not slide off the glass', (tester) async {
    await open(tester, which: 3);
    await slideTowards(tester, 0);
    expect(state(tester).play.bounce, 0);
    expect(find.textContaining('as far that way as the glass goes'),
        findsOneWidget);
  });

  testWidgets('the thirteen is landed in one slide and the card is shown',
      (tester) async {
    await open(tester, which: 0);
    await catchByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.slides, 1);
    expect(find.text('Caught.'), findsOneWidget);
    expect(find.textContaining('one of 9 pegs of the 13'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Caught.'), findsNothing);
    expect(find.text('slides 0'), findsOneWidget);
  });

  testWidgets('the even angles lands on the one peg, with legs of five',
      (tester) async {
    await open(tester, which: 3);
    await catchByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.bounce, 5);
    expect(state(tester).play.slides, 5);
    expect(state(tester).play.even, isTrue);
    expect(state(tester).play.paces, 10);
    expect(find.text('angles match'), findsNothing);
    expect(find.textContaining('The angles match here'), findsOneWidget);
    expect(find.textContaining('one of 1 peg of the 13'), findsOneWidget);
  });

  testWidgets('show me says which way to slide', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Show me');
    expect(find.textContaining('Slide the bounce right'), findsOneWidget);
  });

  testWidgets('the nine gives itself up and folds the board open',
      (tester) async {
    await open(tester, which: 4);
    for (var k = 0; k < 10; k++) {
      if (state(tester).play.gaveUp) break;
      await slideTowards(tester, 12);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Nothing beats the straight run.'), findsOneWidget);
    expect(find.textContaining('no bent path is shorter than a straight one'),
        findsWidgets);
  });

  testWidgets('the why names Hero and the folding', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('Hero of Alexandria'), findsOneWidget);
    expect(find.textContaining('54,925'), findsOneWidget);
  });
}
