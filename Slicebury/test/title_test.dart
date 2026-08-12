import 'package:flutter_test/flutter_test.dart';
import 'package:slicebury/slice/cakes.dart';

import 'support/buryland.dart';
import 'support/fonts.dart';

/// The bury, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the bury lists every cake by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Slicebury'), findsOneWidget);
    for (final cake in Cakes.all) {
      expect(find.text(cake.name), findsOneWidget);
      expect(
        find.text(
          '${cake.task[0].toUpperCase()}${cake.task.substring(1)}',
        ),
        findsOneWidget,
      );
    }
  });

  testWidgets('a cake opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Eight'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap a rim spot to set or lift'),
      findsOneWidget,
    );
  });

  testWidgets('a cutting writes its fewest onto the bury',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Eight'));
    await tester.pumpAndSettle();
    for (final spot in [0, 3, 6, 9]) {
      await tapSpot(tester, spot);
    }
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The bury');
    expect(find.textContaining('Fewest: 4'), findsOneWidget);
  });
}
