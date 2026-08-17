import 'package:flutter_test/flutter_test.dart';
import 'package:rodwell/rod/levels.dart';

import 'support/fonts.dart';
import 'support/rodland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task', (tester) async {
    await open(tester);
    expect(find.text('Rodwell'), findsOneWidget);
    expect(find.textContaining('A rod marked off in hands'), findsOneWidget);
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
    }
  });

  testWidgets('an ask opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Twelve'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Tap between two hands to cut the rod'),
        findsOneWidget);
  });

  testWidgets('a cutting writes its fewest onto the sham', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Twelve'));
    await tester.pumpAndSettle();
    await cutByPointerAll(tester);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 3'), findsOneWidget);
  });
}
