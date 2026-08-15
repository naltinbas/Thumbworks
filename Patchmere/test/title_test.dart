import 'package:flutter_test/flutter_test.dart';
import 'package:patchmere/quilt/levels.dart';

import 'support/fonts.dart';
import 'support/mereland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every level by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Patchmere'), findsOneWidget);
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
      expect(
        find.textContaining(level.task.substring(1)),
        findsWidgets,
      );
    }
  });

  testWidgets('a level opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Two by Six'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Tap two neighbouring cells to sew a patch'),
      findsOneWidget,
    );
  });

  testWidgets('a landing writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Two by Six'));
    await tester.pumpAndSettle();
    await sewByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 3'), findsOneWidget);
  });
}
