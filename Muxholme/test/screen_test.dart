import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/muxland.dart';

/// One string on the screen, derived as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a string opens on its task and its chips',
      (tester) async {
    await open(tester, which: 2);
    expect(
      find.textContaining('derive MUI from MI in three steps'),
      findsOneWidget,
    );
    expect(find.text('steps 0 of 3'), findsOneWidget);
    expect(find.text('letters 2 of 24'), findsOneWidget);
    expect(find.text('I count 1'), findsOneWidget);
    expect(find.text('MI: 1 I, leaving 1 by three; 2 moves apply.'), findsOneWidget);
  });

  testWidgets('the rules apply from the buttons and the letters, and back undoes', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Rule II: double');
    expect(state(tester).play.string, 'MII');
    expect(find.text('steps 1 of 3'), findsOneWidget);
    await press(tester, 'Rule II: double');
    expect(state(tester).play.string, 'MIIII');
    await tapLetter(tester, 2);
    expect(state(tester).play.string, 'MIU');
    await press(tester, 'Back');
    expect(state(tester).play.string, 'MIIII');
    await tapLetter(tester, 1);
    expect(state(tester).play.string, 'MUI');
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Landed.'), findsOneWidget);
    expect(find.text('Derived: MUI in 3 steps.'), findsOneWidget);
    expect(find.textContaining('MI became MUI in 3 steps.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Landed.'), findsNothing);
  });

  testWidgets('the steps spent is a miss', (tester) async {
    await open(tester, which: 0);
    await press(tester, 'Rule II: double');
    expect(state(tester).play.missed, isTrue);
    expect(find.text('Not derived.'), findsOneWidget);
    expect(find.text('1 steps spent, and the string is MII.'), findsOneWidget);
  });

  testWidgets('show me names the next rule', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Show me');
    expect(state(tester).pointing, (2, 0));
    expect(find.text('Next: rule two, the rest doubled.'), findsOneWidget);
    await makeAll(tester, [(2, 0), (2, 0), (2, 0)]);
    await press(tester, 'Show me');
    expect(state(tester).pointing!.$1, 3);
    expect(find.textContaining('Next: rule three, III to U at letter'), findsOneWidget);
  });

  testWidgets('the pointer derives MUIIU', (tester) async {
    await open(tester, which: 3);
    await deriveByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('steps 5 of 5'), findsOneWidget);
  });

  testWidgets('MU never comes, twelve steps', (tester) async {
    await open(tester, which: 4);
    while (!state(tester).play.isOver) {
      final ms = state(tester).play.moves;
      await make(tester, ms.contains((2, 0)) ? (2, 0) : ms.contains((1, 0)) ? (1, 0) : ms.first);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('MU never comes.'), findsOneWidget);
    expect(
      find.textContaining('MU has nought I, and nought is a multiple of three'),
      findsOneWidget,
    );
  });

  testWidgets('the why counts the I', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('rule two doubles it and rule three takes three away'),
      findsOneWidget,
    );
    expect(
      find.textContaining('106,389 strings, and the count of I is a multiple of three in none of them'),
      findsOneWidget,
    );
  });

  testWidgets('the why of MUIIU counts the derivations', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Why');
    expect(
      find.textContaining('57 of them, and 2 end at MUIIU'),
      findsOneWidget,
    );
  });
}
