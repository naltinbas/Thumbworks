import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/worthland.dart';

/// One lane on the screen, marked as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a lane opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(
      find.textContaining('mark a run of two or more milestones adding to fifteen'),
      findsOneWidget,
    );
    expect(find.text('marks 0 of 2'), findsOneWidget);
    expect(find.text('sum waiting'), findsOneWidget);
    expect(find.text('odd divisors 3'), findsOneWidget);
    expect(find.text('Marks 0 of 2 set; tap a milestone.'), findsOneWidget);
  });

  testWidgets('marks set, the run reads, back undoes', (tester) async {
    await open(tester, which: 0);
    await markAll(tester, [2, 5]);
    expect(find.text('run 2 to 5'), findsOneWidget);
    expect(find.text('sum 14 of 15'), findsOneWidget);
    expect(find.text('2 to 5, 4 stones, add to 14, 1 short.'), findsOneWidget);
    await tapStone(tester, 5);
    expect(state(tester).play.marks, [2]);
    expect(find.text('marks 1 of 2'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.marks, [2, 5]);
  });

  testWidgets('a run over the count says so', (tester) async {
    await open(tester, which: 0);
    await markAll(tester, [7, 9]);
    expect(find.text('7 to 9, 3 stones, add to 24, 9 over.'), findsOneWidget);
  });

  testWidgets('the fifteen lands and shows the card', (tester) async {
    await open(tester, which: 0);
    await markAll(tester, [4, 6]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Landed.'), findsOneWidget);
    expect(find.text('Landed: 4 to 6, 3 stones, add to 15.'), findsOneWidget);
    expect(find.text('sum 15 of 15'), findsOneWidget);
    expect(
      find.textContaining('The run adds up; 2 moves.'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(find.text('Landed.'), findsNothing);
  });

  testWidgets('show me rings a milestone', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Show me');
    expect(state(tester).pointing, isNotNull);
    expect(find.text('Mark the ringed milestone.'), findsOneWidget);
  });

  testWidgets('show me rings a mark off the run to lift', (tester) async {
    await open(tester, which: 3);
    await markAll(tester, [12]);
    await press(tester, 'Show me');
    expect(state(tester).pointing, ('lift', 12));
    expect(find.text('Lift the ringed mark: it is off the run.'), findsOneWidget);
  });

  testWidgets('the pointer lands the forty-five', (tester) async {
    await open(tester, which: 3);
    await markByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('sum 45 of 45'), findsOneWidget);
  });

  testWidgets('the hopeless lane cracks at twelve moves', (tester) async {
    await open(tester, which: 4);
    await markAll(tester, [1, 5]);
    for (var dither = 0; dither < 5; dither++) {
      await markAll(tester, [5, 5]);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('A power of two is no run.'), findsOneWidget);
    expect(
      find.textContaining('a power of two has none'),
      findsOneWidget,
    );
  });

  testWidgets('the why finds the odd factor', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('two neighbours add to an odd number'),
      findsOneWidget,
    );
    expect(
      find.textContaining('the counts with no run are exactly the powers of two'),
      findsOneWidget,
    );
  });

  testWidgets('the why of the thirteen reads the divisors', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Why');
    expect(
      find.textContaining('one run for each odd divisor past 1'),
      findsOneWidget,
    );
    expect(
      find.textContaining('a prime is nothing else'),
      findsOneWidget,
    );
  });
}
