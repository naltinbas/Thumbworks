import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/hamland.dart';

/// One share on the screen, cut as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a share opens on its task and its chips',
      (tester) async {
    await open(tester, which: 1);
    expect(
      find.textContaining('cut 4/5 of a loaf as at most three unit cuts'),
      findsOneWidget,
    );
    expect(find.text('cuts 0 of 3'), findsOneWidget);
    expect(find.text('sum 0 of 4/5'), findsOneWidget);
    expect(find.text('left 4/5'), findsOneWidget);
    expect(find.text('Nothing cut yet; 4/5 to make.'), findsOneWidget);
  });

  testWidgets('cuts add up on the chips, and back undoes',
      (tester) async {
    await open(tester, which: 1);
    await takeAll(tester, [2, 4]);
    expect(find.text('sum 3/4 of 4/5'), findsOneWidget);
    expect(find.text('left 1/20'), findsOneWidget);
    expect(find.text('1/2 + 1/4 = 3/4, 1/20 still to cut.'), findsOneWidget);
    await tapCut(tester, 4);
    expect(state(tester).play.cuts, [2]);
    await press(tester, 'Back');
    expect(state(tester).play.cuts, [2, 4]);
  });

  testWidgets('over the share reads rust', (tester) async {
    await open(tester, which: 0);
    await takeAll(tester, [2, 3]);
    expect(find.text('over the mark'), findsOneWidget);
    expect(find.text('Over the share by 1/6.'), findsOneWidget);
  });

  testWidgets('the four of five lands and shows the card', (tester) async {
    await open(tester, which: 1);
    await takeAll(tester, [2, 4, 20]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Cut.'), findsOneWidget);
    expect(find.text('Cut: 1/2 + 1/4 + 1/20 = 4/5.'), findsOneWidget);
    expect(
      find.textContaining('The share is cut, no two cuts alike; 3 moves.'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(find.text('Cut.'), findsNothing);
  });

  testWidgets('a fourth cut is refused where three are allowed',
      (tester) async {
    await open(tester, which: 3);
    await takeAll(tester, [3, 4, 5, 6]);
    expect(state(tester).play.cuts, [3, 4, 5]);
  });

  testWidgets('show me rings a cut', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Show me');
    expect(state(tester).pointing, ('take', 2));
    expect(find.text('Take the ringed cut.'), findsOneWidget);
  });

  testWidgets('the pointer cuts the five of seven', (tester) async {
    await open(tester, which: 3);
    await cutByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.cuts, [2, 6, 21]);
  });

  testWidgets('the hopeless share cracks at ten moves', (tester) async {
    await open(tester, which: 4);
    await takeAll(tester, [2, 4]);
    expect(find.text('left 1/20'), findsOneWidget);
    for (var dither = 0; dither < 4; dither++) {
      await takeAll(tester, [4, 4]);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Four fifths never comes in two.'), findsOneWidget);
    expect(
      find.textContaining('a half leaves three tenths, which is no unit cut'),
      findsOneWidget,
    );
  });

  testWidgets('the why reads the two cases', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('Either one of them is a half'),
      findsOneWidget,
    );
    expect(
      find.textContaining('seven twelfths, short of four fifths'),
      findsOneWidget,
    );
  });

  testWidgets('the why of the five of seven names the seventieth', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Why');
    expect(
      find.textContaining('Fibonacci\'s greedy cut'),
      findsOneWidget,
    );
    expect(
      find.textContaining('a seventieth is off the board'),
      findsOneWidget,
    );
  });
}
