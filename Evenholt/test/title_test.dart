import 'package:evenholt/share/shares.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/holtland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every share by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Evenholt'), findsOneWidget);
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
    await tester.tap(find.text('The Four'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap a token to carry it'),
      findsOneWidget,
    );
  });

  testWidgets('a share writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Four'));
    await tester.pumpAndSettle();
    await carry(tester, [2, 3]);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 2'), findsOneWidget);
  });
}
