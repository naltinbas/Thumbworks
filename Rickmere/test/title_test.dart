import 'package:flutter_test/flutter_test.dart';
import 'package:rickmere/rick/levels.dart';

import 'support/fonts.dart';
import 'support/rickland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task', (tester) async {
    await open(tester);
    expect(find.text('Rickmere'), findsOneWidget);
    expect(
      find.textContaining('the three markers make a perfectly even triangle'),
      findsOneWidget,
    );
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
      expect(find.textContaining(level.task.substring(1)), findsWidgets);
    }
  });

  testWidgets('the hopeless ask says so on its tile', (tester) async {
    await open(tester);
    expect(find.textContaining('not evenly spread. Hopeless.'), findsOneWidget);
  });

  testWidgets('a field writes its fewest onto the sham', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Square Corner'));
    await tester.pumpAndSettle();
    await standByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 1'), findsOneWidget);
  });
}
