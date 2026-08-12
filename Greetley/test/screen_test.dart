import 'package:flutter_test/flutter_test.dart';

import 'support/fete.dart';
import 'support/fonts.dart';

/// The screen, worked the way a finger would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a fresh lawn names itself and its task', (tester) async {
    await open(tester, which: 1);
    expect(find.text('The Quiet Lawn'), findsOneWidget);
    expect(
      find.textContaining('until exactly 0 are odd-handed'),
      findsOneWidget,
    );
    expect(
      find.text('0 odd-handed of 4; 0 asked.'),
      findsOneWidget,
    );
  });

  testWidgets('a pick offers a hand and a shake lands', (tester) async {
    await open(tester, which: 1);
    await tapGuest(tester, 0);
    expect(
      find.text('Guest 1 offers a hand; tap another guest.'),
      findsOneWidget,
    );
    await tapGuest(tester, 1);
    expect(state(tester).play.shakes, [(0, 1)]);
    expect(find.text('shakes 1'), findsOneWidget);
    expect(find.text('odd-handed 2'), findsOneWidget);
  });

  testWidgets('one shake lands the two odd and records',
      (tester) async {
    await open(tester, which: 0);
    await shake(tester, (0, 1));
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Greeted.'), findsOneWidget);
    expect(find.textContaining('1 greeting all told'), findsOneWidget);
    expect(find.textContaining('The fewest yet'), findsOneWidget);
  });

  testWidgets('a triangle lands the quiet lawn', (tester) async {
    await open(tester, which: 1);
    await shakeAll(tester, const [(0, 1), (1, 2), (0, 2)]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Greeted: 0 odd-handed, as asked.'),
        findsOneWidget);
  });

  testWidgets('back takes back a greeting and unfreezes',
      (tester) async {
    await open(tester, which: 0);
    await shake(tester, (0, 1));
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'Back');
    expect(state(tester).play.isDone, isFalse);
    expect(find.text('Greeted.'), findsNothing);
  });

  testWidgets('show me names the pair to shake', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Show me');
    final aim = state(tester).pointing;
    expect(aim, isNotNull);
    final ((a, b), wants) = aim!;
    expect(wants, isTrue);
    expect(
      find.text('Shake guests ${a + 1} and ${b + 1} together.'),
      findsOneWidget,
    );
  });

  testWidgets('why speaks the doubling and the sweep', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Why');
    expect(
      find.textContaining('twice the shakes on every lawn'),
      findsOneWidget,
    );
    expect(
      find.textContaining('all 1,024 lawns of 5'),
      findsOneWidget,
    );
    expect(find.textContaining('64 landing'), findsOneWidget);
  });

  testWidgets('the hopeless lawn admits it and speaks the pair',
      (tester) async {
    await open(tester, which: 4);
    for (var round = 0; round < 6; round++) {
      await shake(tester, (0, 1));
      await shake(tester, (0, 1));
    }
    expect(state(tester).play.moves, 12);
    expect(find.text('The lone hand never rises.'), findsOneWidget);
    expect(
      find.textContaining('one odd-handed guest alone'),
      findsOneWidget,
    );
    await press(tester, 'Why');
    expect(
      find.textContaining('the odd-handed must pair off'),
      findsOneWidget,
    );
  });

  testWidgets('again starts the lawn over', (tester) async {
    await open(tester, which: 0);
    await shake(tester, (0, 1));
    await press(tester, 'Again');
    expect(state(tester).play.moves, 0);
    expect(find.text('Greeted.'), findsNothing);
  });
}
