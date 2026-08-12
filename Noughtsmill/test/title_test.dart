import 'package:flutter_test/flutter_test.dart';
import 'package:noughtsmill/mill/grinds.dart';

import 'support/fonts.dart';
import 'support/millstead.dart';

/// The mill, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the mill lists every grind by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Noughtsmill'), findsOneWidget);
    for (final grind in Grinds.all) {
      expect(find.text(grind.name), findsOneWidget);
      expect(find.textContaining(grind.task), findsOneWidget);
    }
  });

  testWidgets('a grind opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Six'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Wind the mill so the factorial'),
      findsOneWidget,
    );
  });

  testWidgets('a grinding writes its fewest onto the mill',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The First Nought'));
    await tester.pumpAndSettle();
    await windTo(tester, 5);
    await press(tester, 'The mill');
    expect(find.textContaining('Fewest:'), findsOneWidget);
  });
}
