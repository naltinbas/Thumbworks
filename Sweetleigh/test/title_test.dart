import 'package:flutter_test/flutter_test.dart';
import 'package:sweetleigh/string/shares.dart';

import 'support/fonts.dart';
import 'support/leighland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every share by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Sweetleigh'), findsOneWidget);
    for (final share in Shares.all) {
      expect(find.text(share.name), findsOneWidget);
      expect(
        find.textContaining(share.task.substring(1)),
        findsWidgets,
      );
    }
  });

  testWidgets('a share opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The One Cut'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap a gap to cut the string'),
      findsOneWidget,
    );
  });

  testWidgets('a share writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The One Cut'));
    await tester.pumpAndSettle();
    await tapGap(tester, 4);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 1'), findsOneWidget);
  });
}
