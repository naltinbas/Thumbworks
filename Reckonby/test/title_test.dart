import 'package:flutter_test/flutter_test.dart';
import 'package:reckonby/count/levels.dart';

import 'support/fonts.dart';
import 'support/reckonland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task', (tester) async {
    await open(tester);
    expect(find.text('Reckonby'), findsOneWidget);
    expect(
      find.textContaining(
          'every number up to 719 reads exactly one way, and 720 does not '
          'read at all'),
      findsOneWidget,
    );
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
      expect(find.textContaining(level.task.substring(1)), findsWidgets);
    }
  });

  testWidgets('the hopeless ask says so on its tile', (tester) async {
    await open(tester);
    expect(find.textContaining('reads 720. Hopeless.'), findsOneWidget);
  });

  testWidgets('a reading writes its fewest onto the sham', (tester) async {
    await open(tester);
    await tester.tap(find.text('Forty-Two'));
    await tester.pumpAndSettle();
    await setWheels(tester, [0, 0, 3, 1, 0]);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 4'), findsOneWidget);
  });
}
