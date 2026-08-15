import 'package:flutter_test/flutter_test.dart';
import 'package:candleford/party/levels.dart';

import 'support/fonts.dart';
import 'support/partyland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every party by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Candleford'), findsOneWidget);
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
      expect(
        find.textContaining(level.task.substring(1)),
        findsWidgets,
      );
    }
  });

  testWidgets('a party opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Even Chance'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Add guests or send them home'),
      findsOneWidget,
    );
  });

  testWidgets('a gathering writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Shared Month'));
    await tester.pumpAndSettle();
    await gather(tester, 5);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 4'), findsOneWidget);
  });
}
