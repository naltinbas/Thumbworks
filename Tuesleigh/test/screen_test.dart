import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/familyland.dart';

/// One ask on the screen, wound as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips',
      (tester) async {
    await open(tester, which: 2);
    expect(find.textContaining('dial the tags so that the chance of two boys is 13 in 27'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('chance 3/7'), findsOneWidget);
    expect(find.text('3 of 7 told'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(find.text('One of the two a boy born under the first of 2 tags: 7 families of the 16 have such a boy, 3 of them two boys, chance 3/7; told which child it is, 1/2.'), findsOneWidget);
  });

  testWidgets('a wind moves the tags, and back undoes it', (tester) async {
    await open(tester, which: 2);
    await wind(tester, 1);
    expect(state(tester).play.tags, 3);
    expect(find.text('chance 5/11'), findsOneWidget);
    expect(find.text('One of the two a boy born under the first of 3 tags: 11 families of the 36 have such a boy, 5 of them two boys, chance 5/11; told which child it is, 1/2.'), findsOneWidget);
    await wind(tester, 10);
    expect(state(tester).play.tags, 13);
    expect(find.text('chance 25/51'), findsOneWidget);
    expect(find.text('taps 2'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.tags, 3);
    expect(find.text('taps 1'), findsOneWidget);
  });

  testWidgets('the third lands at one tag and the card is shown', (tester) async {
    await open(tester, which: 0);
    await wind(tester, -1);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Counted.'), findsOneWidget);
    expect(find.text('As asked. One of the two a boy, no tags: 3 families of the 4 have such a boy, 1 of them two boys, chance 1/3; told which child it is, 1/2.'), findsOneWidget);
    expect(find.textContaining('1 tag, no tag at all: 4 families alike, 3 of them with a boy of the first tag and 1 of those two boys, chance 1/3, a half less 1/6; told which child, 1/2; one of 1 tag count of the 30; 1 tap.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Counted.'), findsNothing);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('show me names the wind, and the pointer lands the Tuesday', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Show me');
    expect(find.text('Wind up by 1.'), findsOneWidget);
    expect(state(tester).pointing, 1);
    await countByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect((state(tester).play.tags, state(tester).play.moves), (7, 5));
    expect(find.text('As asked. One of the two a boy born under the first of 7 tags: 27 families of the 196 have such a boy, 13 of them two boys, chance 13/27; told which child it is, 1/2.'), findsOneWidget);
    expect(find.textContaining('7 tags: 196 families alike, 27 of them with a boy of the first tag and 13 of those two boys, chance 13/27, a half less 1/54; told which child, 1/2; one of 1 tag count of the 30; 5 taps.'), findsOneWidget);
  });

  testWidgets('the nine in nineteen', (tester) async {
    await open(tester, which: 1);
    await setTags(tester, 5);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. One of the two a boy born under the first of 5 tags: 19 families of the 100 have such a boy, 9 of them two boys, chance 9/19; told which child it is, 1/2.'), findsOneWidget);
    expect(find.textContaining('one of 1 tag count of the 30; 3 taps.'), findsOneWidget);
  });

  testWidgets('the nearer half at thirteen tags', (tester) async {
    await open(tester, which: 3);
    await setTags(tester, 13);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. One of the two a boy born under the first of 13 tags: 51 families of the 676 have such a boy, 25 of them two boys, chance 25/51; told which child it is, 1/2.'), findsOneWidget);
    expect(find.textContaining('one of 18 tag counts of the 30; 2 taps.'), findsOneWidget);
  });

  testWidgets('the half admits it at the dial\'s end', (tester) async {
    await open(tester, which: 4);
    await setTags(tester, 30);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('One family short.'), findsOneWidget);
    expect(find.text('One of the two a boy born under the first of 30 tags: 119 families of the 3600 have such a boy, 59 of them two boys, chance 59/119; told which child it is, 1/2. One family in 238 short of a half, as near as the dial comes.'), findsOneWidget);
    expect(find.textContaining('1/238 here at 30, and the sweep of all 30 finds none at a half'), findsOneWidget);
  });

  testWidgets('the why tells the Tuesday and the sweep', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('two boys are two chances of a Tuesday'), findsOneWidget);
    expect(find.textContaining('counted out in full'), findsOneWidget);
  });
}
