import 'package:flutter_test/flutter_test.dart';
import 'package:tetherdown/down/downs.dart';

import 'support/downland.dart';
import 'support/fonts.dart';

/// The downland, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the downland lists every down by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Tetherdown'), findsOneWidget);
    for (final down in Downs.all) {
      expect(find.text(down.name), findsOneWidget);
      expect(find.textContaining(down.task), findsOneWidget);
    }
  });

  testWidgets('a down opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Nine'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap two posts to rope them'),
      findsOneWidget,
    );
  });

  testWidgets('a tethering writes its fewest onto the downland',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Square'));
    await tester.pumpAndSettle();
    await tieAll(tester, const [(0, 1), (1, 2), (2, 3), (0, 3)]);
    await press(tester, 'The down');
    expect(find.textContaining('Fewest: 4'), findsOneWidget);
  });
}
