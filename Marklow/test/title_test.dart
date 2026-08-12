import 'package:flutter_test/flutter_test.dart';
import 'package:marklow/mark/lows.dart';

import 'support/fonts.dart';
import 'support/lowland.dart';

/// The lowland, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the lowland lists every low by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Marklow'), findsOneWidget);
    for (final low in Lows.all) {
      expect(find.text(low.name), findsOneWidget);
      expect(find.textContaining(low.task), findsWidgets);
    }
  });

  testWidgets('a low opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Square'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap a post to cycle its mark'),
      findsOneWidget,
    );
  });

  testWidgets('a numbering writes its fewest onto the lowland',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Path of Four'));
    await tester.pumpAndSettle();
    await markAll(tester, const [0, 3, 1, 2]);
    await press(tester, 'The low');
    expect(find.textContaining('Fewest:'), findsOneWidget);
  });
}
