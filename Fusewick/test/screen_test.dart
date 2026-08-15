import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/wickland.dart';

/// One time on the screen, struck as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a time opens on its task and its chips',
      (tester) async {
    await open(tester, which: 1);
    expect(
      find.textContaining('strike 45 minutes with two fuses'),
      findsOneWidget,
    );
    expect(find.text('clock 0 minutes'), findsOneWidget);
    expect(find.text('asked 45 minutes'), findsOneWidget);
    expect(find.text('ends lit 0'), findsOneWidget);
    expect(find.text('Nothing alight; light an end.'), findsOneWidget);
  });

  testWidgets('ends light, the clock burns on, back undoes', (tester) async {
    await open(tester, which: 1);
    await light(tester, 0, false);
    await light(tester, 1, false);
    await light(tester, 1, true);
    expect(find.text('ends lit 3'), findsOneWidget);
    expect(find.text('Next burnout in 30 minutes, at 30 minutes.'), findsOneWidget);
    await burn(tester);
    expect(state(tester).play.now, 120);
    expect(find.text('clock 30 minutes'), findsOneWidget);
    expect(state(tester).play.left, [120, 0]);
    await press(tester, 'Back');
    expect(state(tester).play.now, 0);
  });

  testWidgets('the forty-five is struck and shows the card', (tester) async {
    await open(tester, which: 1);
    await light(tester, 0, false);
    await light(tester, 1, false);
    await light(tester, 1, true);
    await burn(tester);
    await light(tester, 0, true);
    await burn(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Landed.'), findsOneWidget);
    expect(find.text('Struck: a burnout at 45 minutes exactly.'), findsOneWidget);
    expect(
      find.textContaining('The time is struck to the burnout; 4 ends lit.'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(find.text('Landed.'), findsNothing);
  });

  testWidgets('a time gone by is missed', (tester) async {
    await open(tester, which: 0);
    await light(tester, 0, false);
    await burn(tester);
    expect(state(tester).play.missed, isTrue);
    expect(find.text('Past it: 60 minutes on the clock, 30 minutes asked.'), findsOneWidget);
    expect(find.text('The time went by.'), findsOneWidget);
  });

  testWidgets('show me rings an end, then the clock', (tester) async {
    await open(tester, which: 0);
    await press(tester, 'Show me');
    expect(state(tester).pointing, ('light', 0, false));
    expect(find.text('Light the ringed end.'), findsOneWidget);
    await light(tester, 0, false);
    await light(tester, 0, true);
    await press(tester, 'Show me');
    expect(state(tester).pointing, ('burn', 0, false));
    expect(find.text('Let the fuses burn: tap the clock.'), findsOneWidget);
  });

  testWidgets('the pointer strikes the fifty-two and a half', (tester) async {
    await open(tester, which: 3);
    await strikeByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('clock 52 and a half minutes'), findsOneWidget);
  });

  testWidgets('the hopeless time is passed by the first burnout', (tester) async {
    await open(tester, which: 4);
    await light(tester, 0, false);
    await light(tester, 0, true);
    await burn(tester);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Twenty is never struck.'), findsOneWidget);
    expect(
      find.textContaining('it came at thirty at the soonest, as it always does'),
      findsOneWidget,
    );
  });

  testWidgets('the why halves the hour', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('the first burnout comes at thirty or sixty'),
      findsOneWidget,
    );
    expect(
      find.textContaining('the burnouts fall only at 30, 45, 60, 90 and 120'),
      findsOneWidget,
    );
  });

  testWidgets('the why of the forty-five reads the plans', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Why');
    expect(
      find.textContaining('2 of the 19 plans strike 45 minutes'),
      findsOneWidget,
    );
    expect(
      find.textContaining('that half hour burns in a quarter'),
      findsOneWidget,
    );
  });
}
