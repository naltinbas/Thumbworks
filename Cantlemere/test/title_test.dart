import 'package:cantlemere/plot/levels.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/plotland.dart';

/// The field, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the field lists every ask by name and task', (tester) async {
    await open(tester);
    expect(find.text('Cantlemere'), findsOneWidget);
    expect(
      find.textContaining('never into three equal ones, nor any odd number'),
      findsOneWidget,
    );
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
    }
  });

  testWidgets('the hopeless ask says so on its tile', (tester) async {
    await open(tester);
    expect(find.textContaining('3 plots of the same size. Hopeless.'),
        findsOneWidget);
  });

  testWidgets('a cut writes its fewest onto the field', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Two Plots'));
    await tester.pumpAndSettle();
    await cutByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The field');
    expect(find.textContaining('Fewest: 6'), findsOneWidget);
  });
}
