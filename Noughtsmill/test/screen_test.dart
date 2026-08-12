import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/millstead.dart';

/// The screen, worked the way a finger would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a fresh grind names itself and its count', (tester) async {
    await open(tester, which: 0);
    expect(find.text('The First Nought'), findsOneWidget);
    expect(
      find.textContaining('ends in exactly 1 nought'),
      findsOneWidget,
    );
    expect(
      find.text('1 factorial ends in 0 noughts; 1 asked.'),
      findsOneWidget,
    );
  });

  testWidgets('winding turns the count', (tester) async {
    await open(tester, which: 0);
    await press(tester, '+10');
    expect(state(tester).play.wound, 11);
    expect(
      find.text('11 factorial ends in 2 noughts; 1 asked.'),
      findsOneWidget,
    );
  });

  testWidgets('the first nought lands and records', (tester) async {
    await open(tester, which: 0);
    await windTo(tester, 5);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Ground.'), findsOneWidget);
    expect(find.textContaining('The fewest yet'), findsOneWidget);
  });

  testWidgets('back takes back a winding and unfreezes',
      (tester) async {
    await open(tester, which: 0);
    await windTo(tester, 5);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'Back');
    expect(state(tester).play.isDone, isFalse);
    expect(find.text('Ground.'), findsNothing);
  });

  testWidgets('show me names the winding', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Show me');
    expect(state(tester).pointing, isNotNull);
    expect(
      find.text('Wind the mill to ${state(tester).pointing}.'),
      findsOneWidget,
    );
  });

  testWidgets('why speaks the two counts', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Why');
    expect(
      find.textContaining('grinds the factorial whole'),
      findsOneWidget,
    );
    expect(
      find.textContaining('agree on every winding to two hundred'),
      findsOneWidget,
    );
  });

  testWidgets('the hopeless grind admits it and names the jump',
      (tester) async {
    await open(tester, which: 4);
    for (var winding = 0; winding < 24; winding++) {
      await press(tester, winding.isEven ? '+1' : '-1');
    }
    expect(state(tester).play.moves, 24);
    expect(
      find.text('The fifth nought never falls.'),
      findsOneWidget,
    );
    expect(
      find.textContaining('twenty-five brings its second five'),
      findsOneWidget,
    );
    await press(tester, 'Why');
    expect(
      find.textContaining('the ledger jumps by two'),
      findsOneWidget,
    );
  });

  testWidgets('again starts the grind over', (tester) async {
    await open(tester, which: 0);
    await windTo(tester, 5);
    await press(tester, 'Again');
    expect(state(tester).play.moves, 0);
    expect(find.text('Ground.'), findsNothing);
  });
}
