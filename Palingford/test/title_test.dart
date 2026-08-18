import 'package:flutter_test/flutter_test.dart';
import 'package:palingford/paling/levels.dart';

import 'support/fonts.dart';
import 'support/palingland.dart';

/// The fence line, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the fence line lists every ask by name and task', (tester) async {
    await open(tester);
    expect(find.text('Palingford'), findsOneWidget);
    expect(find.textContaining('the tenth paling will not have it'),
        findsOneWidget);
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
    }
  });

  testWidgets('the hopeless ask says so on its tile', (tester) async {
    await open(tester);
    expect(
      find.text('Slide the palings about until no climb runs to four and no '
          'drop runs to four. Hopeless.'),
      findsOneWidget,
    );
  });

  testWidgets('a landed ask writes its fewest onto the fence line',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Matched Fence'));
    await tester.pumpAndSettle();
    await fenceByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 5);
    await press(tester, 'The fence line');
    expect(find.textContaining('Fewest: 5'), findsOneWidget);
  });
}
