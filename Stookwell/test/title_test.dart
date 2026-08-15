import 'package:flutter_test/flutter_test.dart';
import 'package:stookwell/stook/levels.dart';

import 'support/fonts.dart';
import 'support/wellland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every harvest by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Stookwell'), findsOneWidget);
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
      expect(
        find.textContaining(level.task.substring(1)),
        findsWidgets,
      );
    }
  });

  testWidgets('a harvest opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Seven Apart'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap the pool to begin a stook'),
      findsOneWidget,
    );
  });

  testWidgets('a landing writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Seven Apart'));
    await tester.pumpAndSettle();
    await stand(tester, [4, 2, 1]);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 7'), findsOneWidget);
  });
}
