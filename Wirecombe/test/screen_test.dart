import 'package:flutter_test/flutter_test.dart';

import 'support/combeland.dart';
import 'support/fonts.dart';

/// The screen, worked the way a finger would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a fresh combe names itself and its task', (tester) async {
    await open(tester, which: 2);
    expect(find.text('The Long Lane'), findsOneWidget);
    expect(
      find.textContaining('wire 5 cottages into one run keeping 2'),
      findsOneWidget,
    );
    expect(
      find.text('0 wired, 4 to go; 0 windows lit.'),
      findsOneWidget,
    );
  });

  testWidgets('two taps wire a line and the chips count it',
      (tester) async {
    await open(tester, which: 2);
    await tapCottage(tester, 0);
    expect(
      find.text('Picked cottage 1; tap another to wire them.'),
      findsOneWidget,
    );
    await tapCottage(tester, 2);
    expect(state(tester).play.lines, [(0, 2)]);
    expect(find.text('lines 1 of 4'), findsOneWidget);
    expect(find.text('ends 2'), findsOneWidget);
  });

  testWidgets('a loop is called out', (tester) async {
    await open(tester, which: 1);
    await wireAll(tester, const [(0, 1), (1, 2), (0, 2)]);
    expect(
      find.text('The wire loops: unwire something.'),
      findsOneWidget,
    );
  });

  testWidgets('a lane lands the three cottages and records',
      (tester) async {
    await open(tester, which: 0);
    await wireAll(tester, const [(0, 1), (1, 2)]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Wired.'), findsOneWidget);
    expect(find.textContaining('2 wirings all told'), findsOneWidget);
    expect(find.textContaining('The fewest yet'), findsOneWidget);
  });

  testWidgets('a star refuses the long lane', (tester) async {
    await open(tester, which: 2);
    await wireAll(tester, const [(0, 1), (0, 2), (0, 3), (0, 4)]);
    expect(state(tester).play.isDone, isFalse);
    expect(find.text('ends 4'), findsOneWidget);
  });

  testWidgets('back takes back a wiring and unfreezes', (tester) async {
    await open(tester, which: 0);
    await wireAll(tester, const [(0, 1), (1, 2)]);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'Back');
    expect(state(tester).play.isDone, isFalse);
    expect(find.text('Wired.'), findsNothing);
  });

  testWidgets('show me names the line to wire', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Show me');
    final aim = state(tester).pointing;
    expect(aim, isNotNull);
    final ((a, b), wire) = aim!;
    expect(wire, isTrue);
    expect(
      find.text('Wire cottages ${a + 1} and ${b + 1}.'),
      findsOneWidget,
    );
  });

  testWidgets('why speaks Cayley and the code', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Why');
    expect(
      find.textContaining('exactly as Cayley\'s count says'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Prufer word'),
      findsOneWidget,
    );
    expect(
      find.textContaining('16 runs land'),
      findsOneWidget,
    );
  });

  testWidgets('the hopeless combe admits it and counts the ends',
      (tester) async {
    await open(tester, which: 4);
    for (var round = 0; round < 6; round++) {
      await wireLine(tester, (0, 1));
      await wireLine(tester, (0, 1));
    }
    expect(state(tester).play.moves, 12);
    expect(find.text('The ring never rounds.'), findsOneWidget);
    expect(
      find.textContaining('four lines carry eight ends'),
      findsOneWidget,
    );
    await press(tester, 'Why');
    expect(
      find.textContaining('two ends apiece'),
      findsOneWidget,
    );
  });

  testWidgets('again starts the combe over', (tester) async {
    await open(tester, which: 0);
    await wireAll(tester, const [(0, 1), (1, 2)]);
    await press(tester, 'Again');
    expect(state(tester).play.moves, 0);
    expect(find.text('Wired.'), findsNothing);
  });
}
