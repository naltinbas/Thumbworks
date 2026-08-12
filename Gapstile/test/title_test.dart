import 'package:flutter_test/flutter_test.dart';
import 'package:gapstile/gap/stiles.dart';

import 'support/fence.dart';
import 'support/fonts.dart';

/// The fence, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the fence lists every stile by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Gapstile'), findsOneWidget);
    for (final stile in Stiles.all) {
      expect(find.text(stile.name), findsOneWidget);
      expect(find.textContaining(stile.task), findsOneWidget);
    }
  });

  testWidgets('a stile opens from its tile and comes back',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Two of Nine'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Dial a stride: peg 9'),
      findsOneWidget,
    );
  });

  testWidgets('a landing writes its fewest onto the fence',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Even Fence'));
    await tester.pumpAndSettle();
    await dialTo(tester, 1, 5);
    await press(tester, 'The fence');
    expect(find.textContaining('Fewest: 3'), findsOneWidget);
  });
}
