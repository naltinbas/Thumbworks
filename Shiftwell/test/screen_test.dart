import 'package:flutter_test/flutter_test.dart';
import 'package:shiftwell/rota/rotas.dart';
import 'package:shiftwell/rota/rules.dart';

import 'support/fonts.dart';
import 'support/wellland.dart';

/// One rota on the screen, filled as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a rota opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(
      find.textContaining('finish the four-rota from four fixed shifts'),
      findsOneWidget,
    );
    expect(find.text('open 12'), findsOneWidget);
    expect(find.text('clashes 0'), findsOneWidget);
    expect(find.text('no shift stuck'), findsOneWidget);
    expect(find.text('Shifts open 12, no clash.'), findsOneWidget);
  });

  testWidgets('a tap turns a shift, clashes show, back undoes',
      (tester) async {
    await open(tester, which: 0);
    await tapShift(tester, (1, 0));
    expect(state(tester).play.filled[(1, 0)], 1);
    expect(find.text('clashes 2'), findsOneWidget);
    expect(find.text('2 shifts clash.'), findsOneWidget);
    await tapShift(tester, (1, 0));
    expect(find.text('clashes 0'), findsOneWidget);
    expect(find.text('open 11'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.filled[(1, 0)], 1);
  });

  testWidgets('a fixed shift takes no tap', (tester) async {
    await open(tester, which: 0);
    await tapShift(tester, (0, 0));
    expect(state(tester).play.moves, 0);
  });

  testWidgets('the four fixed finish by hand and show the card',
      (tester) async {
    await open(tester, which: 3);
    final aim = Rules(4, Rotas.at(3).fixed).landing()!;
    for (final entry in aim.entries) {
      if (Rotas.at(3).fixed.containsKey(entry.key)) continue;
      await setHand(tester, entry.key, entry.value);
    }
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Finished.'), findsOneWidget);
    expect(
      find.textContaining('Every hand at every station once and every day once;'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(find.text('Finished.'), findsNothing);
    expect(state(tester).play.moves, 0);
  });

  testWidgets('show me rings a shift with its hand', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Show me');
    expect(state(tester).pointing, isNotNull);
    expect(
      find.textContaining('Tap the ringed shift round to hand'),
      findsOneWidget,
    );
  });

  testWidgets('the pointer finishes the three fixed', (tester) async {
    await open(tester, which: 1);
    await fillByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
  });

  testWidgets('the stuck shift shows as stuck from the start', (tester) async {
    await open(tester, which: 4);
    expect(find.text('a shift stuck'), findsOneWidget);
    expect(find.text('Day 1, station 4 has no hand left.'), findsOneWidget);
  });

  testWidgets('the hopeless rota cracks at fourteen taps', (tester) async {
    await open(tester, which: 4);
    for (var tap = 0; tap < 14; tap++) {
      await tapShift(tester, (0, 3));
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('The stuck shift spoils it.'), findsOneWidget);
    expect(
      find.textContaining('the last shift of the first day has no hand left'),
      findsOneWidget,
    );
  });

  testWidgets('the why reads the stuck shift', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('marked with a cross'),
      findsOneWidget,
    );
    expect(
      find.textContaining('no hand is left for it'),
      findsOneWidget,
    );
  });

  testWidgets('the why of the first day counts by symmetry', (tester) async {
    await open(tester, which: 0);
    await press(tester, 'Why');
    expect(
      find.textContaining('renaming the hands turns any rota'),
      findsOneWidget,
    );
    expect(
      find.textContaining('24 times the 24 orders of the first day is 576'),
      findsOneWidget,
    );
  });
}
