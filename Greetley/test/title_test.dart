import 'package:flutter_test/flutter_test.dart';
import 'package:greetley/shake/lawns.dart';

import 'support/fete.dart';
import 'support/fonts.dart';

/// The fete, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the fete lists every lawn by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Greetley'), findsOneWidget);
    for (final fete in Lawns.all) {
      expect(find.text(fete.name), findsOneWidget);
      expect(find.textContaining(fete.task), findsOneWidget);
    }
  });

  testWidgets('a lawn opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Even Sixty-Four'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap two guests to shake hands'),
      findsOneWidget,
    );
  });

  testWidgets('a greeting writes its fewest onto the fete',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Two Odd'));
    await tester.pumpAndSettle();
    await shake(tester, (0, 1));
    await press(tester, 'The fete');
    expect(find.textContaining('Fewest: 1'), findsOneWidget);
  });
}
