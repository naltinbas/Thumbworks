import 'package:flutter_test/flutter_test.dart';
import 'package:hookmere/shape/levels.dart';

import 'support/fonts.dart';
import 'support/hookland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task', (tester) async {
    await open(tester);
    expect(find.text('Hookmere'), findsOneWidget);
    expect(
      find.textContaining(
          'it is always eight factorial over the hooks multiplied'),
      findsOneWidget,
    );
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
      expect(find.textContaining(level.task.substring(1)), findsWidgets);
    }
  });

  testWidgets('the hopeless ask says so on its tile', (tester) async {
    await open(tester);
    expect(find.textContaining('the hooks get wrong. Hopeless.'),
        findsOneWidget);
  });

  testWidgets('a staircase writes its fewest onto the sham', (tester) async {
    await open(tester);
    await tester.tap(find.text('Seventy'));
    await tester.pumpAndSettle();
    await shift(tester, 2, 0);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 1'), findsOneWidget);
  });
}
