import 'package:flutter_test/flutter_test.dart';
import 'package:lampfield/lamp/levels.dart';

import 'support/fonts.dart';
import 'support/lampland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task', (tester) async {
    await open(tester);
    expect(find.text('Lampfield'), findsOneWidget);
    expect(
      find.textContaining(
          'any one lamp can go out without the message being lost'),
      findsOneWidget,
    );
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
      expect(find.textContaining(level.task.substring(1)), findsWidgets);
    }
  });

  testWidgets('the hopeless ask says so on its tile', (tester) async {
    await open(tester);
    expect(find.textContaining('when a lamp goes out. Hopeless.'),
        findsOneWidget);
  });

  testWidgets('a message writes its fewest onto the sham', (tester) async {
    await open(tester);
    await tester.tap(find.text('In the Code'));
    await tester.pumpAndSettle();
    await sendByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 2'), findsOneWidget);
  });
}
