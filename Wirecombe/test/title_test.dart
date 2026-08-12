import 'package:flutter_test/flutter_test.dart';
import 'package:wirecombe/wire/combes.dart';

import 'support/combeland.dart';
import 'support/fonts.dart';

/// The combeland, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the combeland lists every combe by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Wirecombe'), findsOneWidget);
    for (final combe in Combes.all) {
      expect(find.text(combe.name), findsOneWidget);
      expect(find.textContaining(combe.task), findsOneWidget);
    }
  });

  testWidgets('a combe opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Star'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap two cottages to wire them'),
      findsOneWidget,
    );
  });

  testWidgets('a run writes its fewest onto the combeland',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Three Cottages'));
    await tester.pumpAndSettle();
    await wireAll(tester, const [(0, 1), (1, 2)]);
    await press(tester, 'The combe');
    expect(find.textContaining('Fewest: 2'), findsOneWidget);
  });
}
