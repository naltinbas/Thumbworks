import 'package:flutter_test/flutter_test.dart';
import 'package:stackholt/stack/boxsets.dart';

import 'support/fonts.dart';
import 'support/holt.dart';

/// The holt, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the holt lists every stack by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Stackholt'), findsOneWidget);
    for (final set in BoxSets.all) {
      expect(find.text(set.name), findsOneWidget);
    }
    expect(
      find.textContaining('stand 4 boxes'),
      findsNWidgets(3),
    );
    expect(
      find.textContaining('stand 2 boxes'),
      findsOneWidget,
    );
  });

  testWidgets('a stack opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Quads'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Spin turns a box\'s walls'),
      findsOneWidget,
    );
  });

  testWidgets('a settling writes its fewest onto the holt',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Two Boxes'));
    await tester.pumpAndSettle();
    await spin(tester, 1);
    if (!state(tester).play.isDone) {
      await spin(tester, 1);
    }
    await press(tester, 'The holt');
    expect(find.textContaining('Fewest:'), findsOneWidget);
  });
}
