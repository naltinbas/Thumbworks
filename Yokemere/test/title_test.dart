import 'package:flutter_test/flutter_test.dart';
import 'package:yokemere/yoke/levels.dart';

import 'support/fonts.dart';
import 'support/yokeland.dart';

/// The yard, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the yard lists every ask by name and task', (tester) async {
    await open(tester);
    expect(find.text('Yokemere'), findsOneWidget);
    expect(find.textContaining('a swap is the whole reason why'),
        findsOneWidget);
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
    }
  });

  testWidgets('the hopeless ask says so on its tile', (tester) async {
    await open(tester);
    expect(find.textContaining('pulls exactly 56. Hopeless.'), findsOneWidget);
  });

  testWidgets('a yoking writes its fewest onto the yard', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Slack Pull'));
    await tester.pumpAndSettle();
    await yokeByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The yard');
    expect(find.textContaining('Fewest: 1'), findsOneWidget);
  });
}
