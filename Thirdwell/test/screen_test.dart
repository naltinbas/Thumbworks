import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/wellland.dart';

/// One walk on the screen, dealt as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a walk opens on its task and its chips',
      (tester) async {
    await open(tester, which: 3);
    expect(
      find.textContaining('walk counter 17 to place 20 in three deals'),
      findsOneWidget,
    );
    expect(find.text('deals 0 of 3'), findsOneWidget);
    expect(find.text('place 17, asked 20'), findsOneWidget);
    expect(find.text('no placings yet'), findsOneWidget);
    expect(
      find.text('Deal 1 of 3: the counter is in column 2, at row 6.'),
      findsOneWidget,
    );
  });

  testWidgets('a gathering moves the counter, back undoes', (tester) async {
    await open(tester, which: 3);
    await tapPlacing(tester, 1);
    expect(state(tester).play.placings, [1]);
    expect(find.text('deals 1 of 3'), findsOneWidget);
    expect(find.text('placings middle'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.placings, isEmpty);
  });

  testWidgets('the twentieth walks by hand and shows the card',
      (tester) async {
    await open(tester, which: 3);
    await gatherAll(tester, [1, 0, 2]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Walked.'), findsOneWidget);
    expect(find.text('Walked: counter 17 sits at place 20.'), findsOneWidget);
    expect(
      find.textContaining('The counter sits where it was asked; 3 deals.'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(find.text('Walked.'), findsNothing);
  });

  testWidgets('a wrong walk says where the counter sits', (tester) async {
    await open(tester, which: 3);
    await gatherAll(tester, [2, 0, 1]);
    expect(state(tester).play.dealsDone, isTrue);
    expect(find.text('Dealt out: the counter sits at place 12, not 20.'), findsOneWidget);
    expect(find.text('place 12, asked 20'), findsOneWidget);
    await tapPlacing(tester, 0);
    expect(state(tester).play.placings, hasLength(3));
  });

  testWidgets('show me rings a placing', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');
    expect(state(tester).pointing, 1);
    expect(find.text('Gather with the gold column in the middle.'), findsOneWidget);
  });

  testWidgets('the pointer walks the bottom', (tester) async {
    await open(tester, which: 2);
    await walkByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.place, 26);
  });

  testWidgets('the hopeless walk cracks after two deals', (tester) async {
    await open(tester, which: 4);
    await gatherAll(tester, [0, 0]);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Two deals never reach the top.'), findsOneWidget);
    expect(
      find.textContaining('one more than a multiple of three'),
      findsOneWidget,
    );
  });

  testWidgets('the why counts in threes', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('the units are the start counted in nines'),
      findsOneWidget,
    );
    expect(
      find.textContaining('one nine and seven down'),
      findsOneWidget,
    );
  });

  testWidgets('the why of the twentieth reads the digits', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Why');
    expect(
      find.textContaining('Gergonne\'s arithmetic'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Nineteen is one and nought threes and two nines'),
      findsOneWidget,
    );
  });
}
