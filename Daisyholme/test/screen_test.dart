import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/holmeland.dart';

/// One circle on the screen, tapped as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a circle opens on its task and its chips',
      (tester) async {
    await open(tester, which: 4);
    expect(
      find.textContaining('befriend 4 people till every pair'),
      findsOneWidget,
    );
    expect(find.text('settled 0 of 6'), findsOneWidget);
    expect(find.text('friendships 0'), findsOneWidget);
  });

  testWidgets('a tapped wire befriends and the chips follow',
      (tester) async {
    await open(tester, which: 4);
    await tapWire(tester, 0);
    expect(state(tester).play.wired[0], isTrue);
    expect(find.text('friendships 1'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.wired[0], isFalse);
  });

  testWidgets('three wires settle the three friends',
      (tester) async {
    await open(tester, which: 0);
    for (var pair = 0; pair < 3; pair++) {
      await tapWire(tester, pair);
    }
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Settled.'), findsOneWidget);
    expect(
      find.textContaining('the daisy standing'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(find.text('Settled.'), findsNothing);
  });

  testWidgets('the given hub refuses its held wires',
      (tester) async {
    await open(tester, which: 1);
    await tapWire(tester, 0);
    expect(state(tester).play.moves, 0);
    expect(state(tester).play.wired[0], isTrue);
  });

  testWidgets('show me rings a pair and says which way',
      (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');
    expect(state(tester).pointing, isNotNull);
    expect(
      find.textContaining('Befriend the ringed pair'),
      findsOneWidget,
    );
  });

  testWidgets('the pointer settles the five', (tester) async {
    await open(tester, which: 2);
    await settleByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
  });

  testWidgets('the hopeless circle cracks at twelve moves',
      (tester) async {
    await open(tester, which: 4);
    for (var dither = 0; dither < 12; dither++) {
      await tapWire(tester, dither % 3);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(
      find.text('The crowd must come odd.'),
      findsOneWidget,
    );
    expect(
      find.textContaining('neighbours share nobody'),
      findsOneWidget,
    );
  });

  testWidgets('the why speaks the pairing lemma and the sweep',
      (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('every friend count comes even'),
      findsOneWidget,
    );
    expect(find.textContaining('64 circles'), findsOneWidget);
  });
}
