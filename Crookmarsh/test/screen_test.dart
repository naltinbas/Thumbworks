import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/marshland.dart';

/// The screen, worked the way a finger would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a fresh marsh names itself and its task', (tester) async {
    await open(tester, which: 0);
    expect(find.text('The Crooked Four'), findsOneWidget);
    expect(
      find.textContaining('stand 4 posts, none three to a line'),
      findsOneWidget,
    );
    expect(
      find.text('0 set, 4 to go; 0 frames so far.'),
      findsOneWidget,
    );
  });

  testWidgets('a tucked setting lands the crooked four',
      (tester) async {
    await open(tester, which: 0);
    await setAll(tester, const [(0, 0), (3, 0), (1, 3), (1, 1)]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Standing.'), findsOneWidget);
    expect(find.textContaining('4 touches'), findsOneWidget);
    expect(find.textContaining('The fewest yet'), findsOneWidget);
  });

  testWidgets('a shared line is called out and counted',
      (tester) async {
    await open(tester, which: 1);
    await setAll(tester, const [(0, 0), (1, 1), (2, 2)]);
    expect(
      find.text('Three posts share a line: lift one of them.'),
      findsOneWidget,
    );
    expect(find.text('lined 1'), findsOneWidget);
  });

  testWidgets('back takes back a touch and unfreezes', (tester) async {
    await open(tester, which: 0);
    await setAll(tester, const [(0, 0), (3, 0), (1, 3), (1, 1)]);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'Back');
    expect(state(tester).play.isDone, isFalse);
    expect(find.text('Standing.'), findsNothing);
  });

  testWidgets('show me rings a crossing and says which way',
      (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Show me');
    expect(state(tester).pointing, isNotNull);
    expect(
      find.text('Set a post on the ringed crossing.'),
      findsOneWidget,
    );
  });

  testWidgets('why speaks the two tests and the ways', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Why');
    expect(
      find.textContaining('the tuck test'),
      findsOneWidget,
    );
    expect(
      find.textContaining('the hull walk'),
      findsOneWidget,
    );
    expect(
      find.textContaining('12 clear settings landing'),
      findsOneWidget,
    );
  });

  testWidgets('the hopeless marsh admits it and speaks the theorem',
      (tester) async {
    await open(tester, which: 4);
    for (var touch = 0; touch < 16; touch++) {
      await tapCross(tester, 0, 0);
    }
    expect(state(tester).play.moves, 16);
    expect(find.text('The frame always comes.'), findsOneWidget);
    expect(
      find.textContaining('happy ending theorem let none'),
      findsOneWidget,
    );
    await press(tester, 'Why');
    expect(
      find.textContaining('always hold four standing true'),
      findsOneWidget,
    );
  });

  testWidgets('again starts the marsh over', (tester) async {
    await open(tester, which: 0);
    await setAll(tester, const [(0, 0), (3, 0), (1, 3), (1, 1)]);
    await press(tester, 'Again');
    expect(state(tester).play.moves, 0);
    expect(find.text('Standing.'), findsNothing);
  });
}
