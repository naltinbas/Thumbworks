import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/sliverland.dart';

/// One ask on the screen, the marks stepped as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('set the marks so that the sliver is a seventh of the field'), findsOneWidget);
    expect(find.text('sliver 4/13'), findsOneWidget);
    expect(find.text('ratios make 1/27'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(find.text('Marks 3, 3 and 3 twelfths: the ratios 1/3, 1/3 and 1/3 multiply to 1/27, and the sliver takes 4/13 of the field.'), findsOneWidget);
  });

  testWidgets('a mark steps along its side, and back undoes', (tester) async {
    await open(tester, which: 0);
    await stepMark(tester, 0, 1);
    expect(state(tester).play.marks, [4, 3, 3]);
    expect(find.text('Marks 4, 3 and 3 twelfths: the ratios 1/2, 1/3 and 1/3 multiply to 1/18, and the sliver takes 289/1170 of the field.'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.marks, [3, 3, 3]);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('the seventh lands at four, four and four and the card is shown', (tester) async {
    await open(tester, which: 0);
    await setMarks(tester, [4, 4, 4]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Cut.'), findsOneWidget);
    expect(find.text('As asked. Marks 4, 4 and 4 twelfths: the ratios 1/2, 1/2 and 1/2 multiply to 1/8, and the sliver takes 1/7 of the field.'), findsOneWidget);
    expect(find.textContaining('Marks 4, 4 and 4 twelfths: the ratios 1/2, 1/2 and 1/2, multiplying to 1/8, and the sliver takes 1/7 of the field, by the corners and by Routh\'s rule; one of 2 settings of the 1,331; 3 taps.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Cut.'), findsNothing);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('show me names the mark, and the pointer lands the vanishing', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');
    expect(find.text('Step mark D back.'), findsOneWidget);
    expect(state(tester).pointing, (0, -1));
    await marksByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.marks, [1, 6, 11]);
    expect(find.text('As asked. Marks 1, 6 and 11 twelfths: the ratios 1/11, 1 and 11 multiply to one, so the three cuts meet at (132/13, 12/13) and there is no sliver.'), findsOneWidget);
    expect(find.textContaining('one of 31 settings of the 1,331'), findsOneWidget);
  });

  testWidgets('the middle marks make the cuts meet', (tester) async {
    await open(tester, which: 1);
    await setMarks(tester, [6, 6, 6]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. Marks 6, 6 and 6 twelfths: the ratios 1, 1 and 1 multiply to one, so the three cuts meet at (4, 4) and there is no sliver.'), findsOneWidget);
    expect(find.textContaining('the ratios 1, 1 and 1, multiplying to one, so the three cuts meet at one point and the sliver comes to nothing'), findsOneWidget);
  });

  testWidgets('the widest sliver at one, one and one', (tester) async {
    await open(tester, which: 3);
    await setMarks(tester, [1, 1, 1]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. Marks 1, 1 and 1 twelfths: the ratios 1/11, 1/11 and 1/11 multiply to 1/1331, and the sliver takes 100/133 of the field.'), findsOneWidget);
    expect(find.textContaining('multiplying to 1/1331, and the sliver takes 100/133 of the field, by the corners and by Routh\'s rule; one of 2 settings of the 1,331'), findsOneWidget);
  });

  testWidgets('a setting short of the ask says its share', (tester) async {
    await open(tester, which: 0);
    await setMarks(tester, [8, 8, 4]);
    expect(state(tester).play.isDone, isFalse);
    expect(find.text('Marks 8, 8 and 4 twelfths: the ratios 2, 2 and 1/2 multiply to 2, and the sliver takes 1/70 of the field.'), findsOneWidget);
    expect(find.text('sliver 1/70'), findsOneWidget);
  });

  testWidgets('the sly vanishing admits it after three meetings', (tester) async {
    await open(tester, which: 4);
    await setMarks(tester, [6, 6, 6]);
    await setMarks(tester, [1, 6, 11]);
    await setMarks(tester, [2, 6, 10]);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Together or not at all.'), findsOneWidget);
    expect(find.textContaining('Gone only when they meet.'), findsOneWidget);
    expect(find.textContaining('No setting empties the sliver while the cuts miss one another.'), findsOneWidget);
  });

  testWidgets('the why tells Routh and the sweep', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('Routh\'s rule, published in 1891'), findsOneWidget);
    expect(find.textContaining('cut in full'), findsOneWidget);
  });
}
