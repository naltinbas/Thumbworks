import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/wickland.dart';

/// One line on the screen, called down as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a line opens on its task and its chips',
      (tester) async {
    await open(tester, which: 2);
    expect(
      find.textContaining('save all but the first of the line of five'),
      findsOneWidget,
    );
    expect(find.text('called 0 of 5'), findsOneWidget);
    expect(find.text('right 0'), findsOneWidget);
    expect(find.text('ahead 3 black, odd'), findsOneWidget);
    expect(find.text('Man 1 to call: 3 black caps ahead, 0 called black behind.'), findsOneWidget);
  });

  testWidgets('a call is judged, the line moves on, back undoes', (tester) async {
    await open(tester, which: 2);
    await call(tester, true);
    expect(state(tester).play.calls, [true]);
    expect(find.text('called 1 of 5'), findsOneWidget);
    expect(find.text('right 0'), findsOneWidget);
    expect(find.text('ahead 2 black, even'), findsOneWidget);
    expect(find.text('Man 2 to call: 2 black caps ahead, 1 called black behind. Man 1 said black, and his cap is white.'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.calls, isEmpty);
  });

  testWidgets('the plan lands the five and shows the card', (tester) async {
    await open(tester, which: 2);
    await callThePlan(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Landed.'), findsOneWidget);
    expect(find.text('Saved 4 of 5: the ask is met.'), findsOneWidget);
    expect(find.text('right 4'), findsOneWidget);
    expect(
      find.textContaining('Every man but the first was right, 4 of 5 saved; 5 calls.'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(find.text('Landed.'), findsNothing);
  });

  testWidgets('a slip loses a man', (tester) async {
    await open(tester, which: 0);
    await callAll(tester, [true, true, true]);
    expect(state(tester).play.missed, isTrue);
    expect(find.text('Saved 1 of 3, and the ask was all but the first.'), findsOneWidget);
    expect(find.text('A man lost.'), findsOneWidget);
  });

  testWidgets('show me rings the plan\'s cap', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Show me');
    expect(state(tester).pointing, ('black', 0));
    expect(find.text('The plan says black: tap the ringed cap.'), findsOneWidget);
  });

  testWidgets('the pointer calls the six down', (tester) async {
    await open(tester, which: 3);
    await callByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('called 6 of 6'), findsOneWidget);
  });

  testWidgets('the hopeless line cracks when the warden caps the first man', (tester) async {
    await open(tester, which: 4);
    await callThePlan(tester);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('right 4'), findsOneWidget);
    expect(find.text('The first man is never saved.'), findsOneWidget);
    expect(
      find.textContaining('he is right on half the deals and wrong on the other half, and the warden picks'),
      findsOneWidget,
    );
  });

  testWidgets('the why counts the first man\'s plans', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('his call can depend only on the caps ahead of him'),
      findsOneWidget,
    );
    expect(
      find.textContaining('every one of his 65,536 plans counted'),
      findsOneWidget,
    );
  });

  testWidgets('the why of the four tells the plan', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Why');
    expect(
      find.textContaining('The plan is one word of parity'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Sixteen deals, three saved on every one'),
      findsOneWidget,
    );
  });
}
