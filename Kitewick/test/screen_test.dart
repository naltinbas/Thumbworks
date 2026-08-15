import 'package:flutter_test/flutter_test.dart';
import 'package:kitewick/kite/levels.dart';
import 'package:kitewick/kite/play.dart';

import 'support/fonts.dart';
import 'support/kiteland.dart';

/// One ask on the screen, slated as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips',
      (tester) async {
    await open(tester, which: 1);
    expect(find.textContaining('slate the kite of order two, 12 cells'), findsOneWidget);
    expect(find.text('across 0'), findsOneWidget);
    expect(find.text('down 0'), findsOneWidget);
    expect(find.text('layings 0'), findsOneWidget);
    expect(find.text('0 slates laid, 0 across and 0 down, 12 cells bare.'), findsOneWidget);
  });

  testWidgets('a pick, a lay, a lift, and back', (tester) async {
    await open(tester, which: 1);
    await tapCell(tester, 0);
    expect(state(tester).play.picked, 0);
    expect(find.text('A cell picked: tap a bare cell beside it to lay a slate, or tap it again to let go.'), findsOneWidget);
    await tapCell(tester, 1);
    expect(state(tester).play.laid, [(0, 1)]);
    expect(find.text('across 1'), findsOneWidget);
    expect(find.text('1 slate laid, 1 across and 0 down, 10 cells bare.'), findsOneWidget);
    await lay(tester, 2, 6);
    expect(find.text('down 1'), findsOneWidget);
    expect(find.text('layings 2'), findsOneWidget);
    await tapCell(tester, 6);
    expect(state(tester).play.laid, [(0, 1)]);
    expect(find.text('layings 3'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.laid, [(0, 1), (2, 6)]);
  });

  testWidgets('the two lands and the card is shown', (tester) async {
    await open(tester, which: 0);
    await layAll(tester, [(0, 2), (1, 3)]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Slated.'), findsOneWidget);
    expect(find.text('As asked. The kite is slated whole, 0 across and 2 down.'), findsOneWidget);
    expect(find.textContaining('The kite of order 1, 4 cells, slated whole: 0 across and 2 down, one of its 2 slatings; 2 layings.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Slated.'), findsNothing);
    expect(find.text('layings 0'), findsOneWidget);
  });

  testWidgets('show me rings a cell, then the cell beside it', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');
    expect(find.text('Tap the ringed cell.'), findsOneWidget);
    expect(state(tester).pointing, (Aim.pick, 0));
    await tapCell(tester, 0);
    await press(tester, 'Show me');
    expect(find.text('Now tap the ringed cell beside it.'), findsOneWidget);
    await lay(tester, 3, 7);
    await press(tester, 'Show me');
    expect(find.text('Lift the ringed slate.'), findsOneWidget);
  });

  testWidgets('the pointer slates the sixty-four', (tester) async {
    await open(tester, which: 3);
    await slateByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 12);
    expect(find.text('As asked. The kite is slated whole, 12 across and 0 down.'), findsOneWidget);
  });

  testWidgets('the two across, by hand, and stuck is told', (tester) async {
    await open(tester, which: 2);
    final aim = Levels.at(2).aim!;
    await layAll(tester, aim);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. The kite is slated whole, 2 across and 4 down.'), findsOneWidget);
    await press(tester, 'Again');
    await layAll(tester, [(0, 1), (2, 6), (4, 5), (7, 8)]);
    expect(state(tester).play.stuck, isTrue);
    expect(find.textContaining('A bare cell has no bare neighbour: lift a slate.'), findsOneWidget);
  });

  testWidgets('the one across admits it once the kite is slated whole', (tester) async {
    await open(tester, which: 4);
    await layAll(tester, Levels.at(4).slatings.first);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Even across, always.'), findsOneWidget);
    expect(find.text('Slated whole with 6 across: every row is even, so the count across is always even, and one across never comes.'), findsOneWidget);
    expect(find.textContaining('this slating lays 6 across, and the eight slatings lay nought, two, four or six.'), findsOneWidget);
  });

  testWidgets('the why tells the even rows and the sweep', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('two to the n(n+1)/2: 2, 8, 64, 1,024, 32,768'), findsOneWidget);
    expect(find.textContaining('laid out in full'), findsOneWidget);
  });
}
