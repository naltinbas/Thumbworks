import 'package:flutter_test/flutter_test.dart';
import 'package:brackenside/hill/hills.dart';

import 'support/fonts.dart';
import 'support/hillside.dart';

/// The hillside, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the hillside lists every hill by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Brackenside'), findsOneWidget);
    for (final hill in Hills.all) {
      expect(find.text(hill.name), findsOneWidget);
      expect(find.textContaining(hill.task), findsOneWidget);
    }
  });

  testWidgets('a hill opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Nine'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap a spot to swap its plant'),
      findsOneWidget,
    );
  });

  testWidgets('a planting writes its fewest onto the hillside',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The First Patch'));
    await tester.pumpAndSettle();
    final spot = state(tester).play.rules.inner.single;
    await tapSpot(tester, spot.$1, spot.$2);
    await press(tester, 'The hillside');
    expect(find.textContaining('Fewest: 1'), findsOneWidget);
  });
}
