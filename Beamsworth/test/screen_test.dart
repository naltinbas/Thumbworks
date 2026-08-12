import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/yard.dart';

/// The screen, worked the way a finger would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a fresh worth names itself and its task', (tester) async {
    await open(tester, which: 0);
    expect(find.text('The Three'), findsOneWidget);
    expect(
      find.textContaining('choose 3 weights with no two parcels'),
      findsOneWidget,
    );
    expect(
      find.text('0 chosen, 3 to go; the beam hangs empty.'),
      findsOneWidget,
    );
  });

  testWidgets('a choosing counts and a balance levels the beam',
      (tester) async {
    await open(tester, which: 0);
    await chooseAll(tester, const [1, 2]);
    expect(find.text('chosen 2 of 3'), findsOneWidget);
    await tapWeight(tester, 3);
    // The balance may accuse either way round; match the shape.
    expect(
      find.textContaining('put something back.'),
      findsOneWidget,
    );
    expect(find.text('the beam is level'), findsOneWidget);
  });

  testWidgets('a clean three lands and records', (tester) async {
    await open(tester, which: 0);
    await chooseAll(tester, const [1, 2, 4]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Weighed clean.'), findsOneWidget);
    expect(find.textContaining('3 choosings'), findsOneWidget);
    expect(find.textContaining('The fewest yet'), findsOneWidget);
  });

  testWidgets('back takes back a choosing and unfreezes',
      (tester) async {
    await open(tester, which: 0);
    await chooseAll(tester, const [1, 2, 4]);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'Back');
    expect(state(tester).play.isDone, isFalse);
    expect(find.text('Weighed clean.'), findsNothing);
  });

  testWidgets('show me names the weight', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Show me');
    final aim = state(tester).pointing;
    expect(aim, isNotNull);
    expect(
      find.text('Choose the ${aim!.$1} pound weight.'),
      findsOneWidget,
    );
  });

  testWidgets('why speaks the balance and the sweep', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Why');
    expect(
      find.textContaining('strips the shared weights before it '
          'accuses'),
      findsOneWidget,
    );
    expect(find.textContaining('1 come clean'), findsOneWidget);
  });

  testWidgets('the hopeless worth admits it and counts the crates',
      (tester) async {
    await open(tester, which: 4);
    for (var choosing = 0; choosing < 14; choosing++) {
      await tapWeight(tester, 1);
    }
    expect(state(tester).play.moves, 14);
    expect(find.text('The beam finds its level.'), findsOneWidget);
    expect(
      find.textContaining('127 parcels'),
      findsOneWidget,
    );
    await press(tester, 'Why');
    expect(
      find.textContaining('cannot take 125 readings'),
      findsOneWidget,
    );
  });

  testWidgets('again starts the worth over', (tester) async {
    await open(tester, which: 0);
    await chooseAll(tester, const [1, 2, 4]);
    await press(tester, 'Again');
    expect(state(tester).play.moves, 0);
    expect(find.text('Weighed clean.'), findsNothing);
  });
}
