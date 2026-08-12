import 'package:flutter_test/flutter_test.dart';
import 'package:squarholt/hoard/hoards.dart';

import 'support/fonts.dart';
import 'support/holtland.dart';

/// The holt, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the holt lists every hoard by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Squarholt'), findsOneWidget);
    for (final hoard in Hoards.all) {
      expect(find.text(hoard.name), findsOneWidget);
      expect(
        find.text(
          '${hoard.task[0].toUpperCase()}${hoard.task.substring(1)}',
        ),
        findsOneWidget,
      );
    }
  });

  testWidgets('a hoard opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Five'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Turn the dials to grow or shrink'),
      findsOneWidget,
    );
  });

  testWidgets('a paying writes its fewest onto the holt',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Five'));
    await tester.pumpAndSettle();
    await press(tester, 'slate +');
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The holt');
    expect(find.textContaining('Fewest: 1'), findsOneWidget);
  });
}
