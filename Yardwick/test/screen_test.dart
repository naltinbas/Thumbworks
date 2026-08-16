import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/yardland.dart';

/// One ask on the screen, the dials stepped as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('set the two counts so that the yardstick is five'), findsOneWidget);
    expect(find.text('yardstick 2'), findsOneWidget);
    expect(find.text('counts measure by 3'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(find.text('Counts 6 and 9: hedges 8 and 34, yardstick 2, the counts measuring by 3.'), findsOneWidget);
  });

  testWidgets('a dial steps a count, and back undoes', (tester) async {
    await open(tester, which: 0);
    await turn(tester, 'm', 1);
    expect((state(tester).play.first, state(tester).play.second), (7, 9));
    expect(find.text('Counts 7 and 9: hedges 13 and 34, yardstick 1, the counts measuring by 1.'), findsOneWidget);
    expect(find.text('yardstick 1'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.first, 6);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('the yardstick of five lands at 5 and 5 and the card is shown', (tester) async {
    await open(tester, which: 0);
    await setCounts(tester, 5, 5);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Measured.'), findsOneWidget);
    expect(find.text('As asked. Counts 5 and 5: hedges 5 and 5, yardstick 5, the counts measuring by 5.'), findsOneWidget);
    expect(find.textContaining('Counts 5 and 5, hedges 5 and 5: the yardstick 5, by Euclid on the hedges and by the counts, which measure by 5, the first hedge measuring the second exactly; one of 23 settings of the 900; 5 taps.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Measured.'), findsNothing);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('show me names the step, and the pointer reaches the long yardstick', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Show me');
    expect(find.text('Step the first count up.'), findsOneWidget);
    expect(state(tester).pointing, ('m', 1));
    await countsByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect((state(tester).play.first, state(tester).play.second, state(tester).play.moves), (10, 10, 5));
    expect(find.text('As asked. Counts 10 and 10: hedges 55 and 55, yardstick 55, the counts measuring by 10.'), findsOneWidget);
    expect(find.textContaining('one of 37 settings of the 900; 5 taps.'), findsOneWidget);
  });

  testWidgets('the sly pair at 4 and 6', (tester) async {
    await open(tester, which: 1);
    await setCounts(tester, 4, 6);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. Counts 4 and 6: hedges 3 and 8, yardstick 1, the counts measuring by 2.'), findsOneWidget);
    expect(find.textContaining('one of 114 settings of the 900; 5 taps.'), findsOneWidget);
  });

  testWidgets('the whole measure lands on the way to 3 and 6', (tester) async {
    await open(tester, which: 2);
    await setCounts(tester, 3, 6);
    expect(state(tester).play.isDone, isTrue);
    expect((state(tester).play.first, state(tester).play.second), (3, 9));
    expect(find.text('As asked. Counts 3 and 9: hedges 2 and 34, yardstick 2, the counts measuring by 3.'), findsOneWidget);
    expect(find.textContaining('the first hedge measuring the second exactly; one of 38 settings of the 900; 3 taps.'), findsOneWidget);
  });

  testWidgets('a setting short of the ask says its yardstick', (tester) async {
    await open(tester, which: 0);
    await setCounts(tester, 6, 8);
    expect(state(tester).play.isDone, isFalse);
    expect(find.text('Counts 6 and 8: hedges 8 and 21, yardstick 1, the counts measuring by 2.'), findsOneWidget);
    expect(find.text('counts measure by 2'), findsOneWidget);
  });

  testWidgets('the odd share admits it after three coprime settings', (tester) async {
    await open(tester, which: 4);
    await turn(tester, 'm', 1);
    await turn(tester, 'm', 1);
    await turn(tester, 'm', 1);
    await turn(tester, 'n', 1);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('As the counts go, always.'), findsOneWidget);
    expect(find.text('Counts 9 and 10: hedges 34 and 55, yardstick 1, the counts measuring by 1. As the counts go, so go the hedges.'), findsOneWidget);
    expect(find.textContaining('Here the counts 9 and 10 measure by 1, and the yardstick is 1.'), findsOneWidget);
  });

  testWidgets('the why tells Lucas and the sweep', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('as Lucas set down in 1876'), findsOneWidget);
    expect(find.textContaining('measured in full'), findsOneWidget);
  });
}
