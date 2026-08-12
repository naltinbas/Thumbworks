import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/well.dart';

/// The screen, worked the way a finger would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a fresh purse names itself and its task', (tester) async {
    await open(tester, which: 0);
    expect(find.text('The Eleven'), findsOneWidget);
    expect(
      find.textContaining('pay 11 in coins with no two neighbours'),
      findsOneWidget,
    );
    expect(find.text('0 in the tray; 11 short.'), findsOneWidget);
  });

  testWidgets('a coin moves to the tray and counts', (tester) async {
    await open(tester, which: 0);
    await tapCoin(tester, 8);
    expect(state(tester).play.tray, [8]);
    expect(find.text('tray 8 of 11'), findsOneWidget);
    expect(find.text('8 in the tray; 3 short.'), findsOneWidget);
  });

  testWidgets('the eleven pays and records', (tester) async {
    await open(tester, which: 0);
    await payAll(tester, const [8, 3]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Paid.'), findsOneWidget);
    expect(find.textContaining('2 moves'), findsOneWidget);
    expect(find.textContaining('The fewest yet'), findsOneWidget);
  });

  testWidgets('neighbours are called out by name', (tester) async {
    await open(tester, which: 0);
    await payAll(tester, const [8, 2, 1]);
    expect(
      find.text('The 1 and the 2 are neighbours in the coinage: '
          'one must come out.'),
      findsOneWidget,
    );
    expect(find.text('neighbours 1'), findsOneWidget);
  });

  testWidgets('back takes back a coin and unfreezes', (tester) async {
    await open(tester, which: 0);
    await payAll(tester, const [8, 3]);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'Back');
    expect(state(tester).play.isDone, isFalse);
    expect(find.text('Paid.'), findsNothing);
  });

  testWidgets('show me names the coin and the way', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');
    final aim = state(tester).pointing;
    expect(aim, isNotNull);
    expect(
      find.text('Put the ${aim!.$1} in the tray.'),
      findsOneWidget,
    );
  });

  testWidgets('why speaks the sweep and the greedy', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Why');
    expect(
      find.textContaining('every purse to a hundred'),
      findsOneWidget,
    );
    expect(
      find.textContaining('greedy walk lands on the same coins'),
      findsOneWidget,
    );
  });

  testWidgets('the hopeless purse shows the way and refuses it',
      (tester) async {
    await open(tester, which: 4);
    await payAll(tester, const [8, 3, 1]);
    expect(
      find.text('Paid the shown way; the asking wants another.'),
      findsOneWidget,
    );
    for (var move = 3; move < 12; move++) {
      await tapCoin(tester, 21);
    }
    expect(state(tester).play.moves, 12);
    expect(
      find.text('The second way stays unfound.'),
      findsOneWidget,
    );
    await press(tester, 'Why');
    expect(
      find.textContaining('never found a second'),
      findsOneWidget,
    );
  });

  testWidgets('again starts the purse over', (tester) async {
    await open(tester, which: 0);
    await payAll(tester, const [8, 3]);
    await press(tester, 'Again');
    expect(state(tester).play.moves, 0);
    expect(find.text('Paid.'), findsNothing);
  });
}
