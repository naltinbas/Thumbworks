import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/greenland.dart';

/// One ask on the screen, walked as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('stand where the three distances to the sides are all alike'), findsOneWidget);
    expect(find.text('rungs 3, 3, 6'), findsOneWidget);
    expect(find.text('sum 12'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(find.text('Standing floor 3, right slope 3, left slope 6: 3 + 3 + 6 = 12 rungs, the height.'), findsOneWidget);
  });

  testWidgets('a tap moves the walker, and back undoes', (tester) async {
    await open(tester, which: 0);
    await tapPoint(tester, (5, 5, 2));
    expect(state(tester).play.at, (5, 5, 2));
    expect(find.text('rungs 5, 5, 2'), findsOneWidget);
    expect(find.text('Standing floor 5, right slope 5, left slope 2: 5 + 5 + 2 = 12 rungs, the height.'), findsOneWidget);
    await tapPoint(tester, (0, 0, 12));
    expect(find.text('rungs 0, 0, 12'), findsOneWidget);
    expect(find.text('taps 2'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.at, (5, 5, 2));
  });

  testWidgets('the middle lands and the card is shown', (tester) async {
    await open(tester, which: 0);
    await tapPoint(tester, (4, 4, 4));
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Stood.'), findsOneWidget);
    expect(find.text('As asked. Standing floor 4, right slope 4, left slope 4: 4 + 4 + 4 = 12 rungs, the height.'), findsOneWidget);
    expect(find.textContaining('the three triangles come to 96, 96 and 96 of the green\'s 288; one of 1 points of the 91; 1 tap.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Stood.'), findsNothing);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('show me rings the point', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Show me');
    expect(find.text('Stand on the ringed point, floor 2, right slope 4, left slope 6.'), findsOneWidget);
    expect(state(tester).pointing, (2, 4, 6));
  });

  testWidgets('the pointer stands the one two nine', (tester) async {
    await open(tester, which: 1);
    await standByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. Standing floor 1, right slope 2, left slope 9: 1 + 2 + 9 = 12 rungs, the height.'), findsOneWidget);
  });

  testWidgets('the edge, by hand', (tester) async {
    await open(tester, which: 2);
    await tapPoint(tester, (6, 6, 0));
    expect(state(tester).play.isDone, isTrue);
    expect(find.textContaining('the three triangles come to 144, 144 and 0 of the green\'s 288'), findsOneWidget);
  });

  testWidgets('the longer walk admits it at a corner', (tester) async {
    await open(tester, which: 4);
    await tapPoint(tester, (12, 0, 0));
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('The height, always.'), findsOneWidget);
    expect(find.text('At a corner: 12 + 0 + 0 = 12 rungs still, the height, as at every point.'), findsOneWidget);
    expect(find.textContaining('288 + 0 + 0 = 288 here'), findsOneWidget);
  });

  testWidgets('the why tells Viviani and the sweep', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('Viviani saw why in the 1600s'), findsOneWidget);
    expect(find.textContaining('tried in full'), findsOneWidget);
  });
}
