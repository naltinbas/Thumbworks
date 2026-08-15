import 'package:flutter_test/flutter_test.dart';
import 'package:muxholme/miu/levels.dart';

import 'support/fonts.dart';
import 'support/muxland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every supper by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Muxholme'), findsOneWidget);
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
      expect(
        find.textContaining(level.task.substring(1)),
        findsWidgets,
      );
    }
  });

  testWidgets('a supper opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('MIU'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('The buttons for rules I and II'),
      findsOneWidget,
    );
  });

  testWidgets('a landing writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('MIU'));
    await tester.pumpAndSettle();
    await press(tester, 'Rule I: add U');
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 1'), findsOneWidget);
  });
}
