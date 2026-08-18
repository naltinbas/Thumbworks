import 'package:flutter_test/flutter_test.dart';
import 'package:trestlemere/table/levels.dart';

import 'support/fonts.dart';
import 'support/tableland.dart';

/// The hall, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the hall lists every ask by name and task', (tester) async {
    await open(tester);
    expect(find.text('Trestlemere'), findsOneWidget);
    expect(
      find.textContaining('without writing a single one down'),
      findsOneWidget,
    );
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
    }
  });

  testWidgets('the hopeless ask says so on its tile', (tester) async {
    await open(tester);
    expect(find.textContaining('holding the same number. Hopeless.'),
        findsWidgets);
  });

  testWidgets('a seating writes its fewest onto the hall', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Three Tables'));
    await tester.pumpAndSettle();
    await seatByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The hall');
    expect(find.textContaining('Fewest: 2'), findsOneWidget);
  });
}
