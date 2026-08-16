import 'package:flutter_test/flutter_test.dart';
import 'package:stickerwick/album/levels.dart';

import 'support/fonts.dart';
import 'support/albumland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task',
      (tester) async {
    await open(tester);
    expect(find.text('Stickerwick'), findsOneWidget);
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
      expect(
        find.textContaining(level.task.substring(1)),
        findsWidgets,
      );
    }
  });

  testWidgets('an ask opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Half Dozen'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Set the stickers in the set and the packets bought'),
      findsOneWidget,
    );
  });

  testWidgets('a collecting writes its fewest onto the sham',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('The Half Dozen'));
    await tester.pumpAndSettle();
    await setDials(tester, 6, 13);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 3'), findsOneWidget);
  });
}
