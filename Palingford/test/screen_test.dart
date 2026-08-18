import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/palingland.dart';

/// One ask on the screen, the palings moved as a thumb would move them.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips', (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('no climb runs to five'), findsWidgets);
    expect(find.text('climb 10 of 4'), findsOneWidget);
    expect(find.text('drop 1 of 4'), findsOneWidget);
    expect(find.text('moves 0'), findsOneWidget);
    expect(state(tester).play.fence, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
  });

  testWidgets('a tap lifts a paling and the next slides it in',
      (tester) async {
    await open(tester, which: 0);
    await lift(tester, 0);
    expect(state(tester).play.inHand, 1);
    expect(state(tester).play.standing.length, 9);
    expect(find.textContaining('The paling 1 tall is in hand'), findsOneWidget);
    await slideTo(tester, 9);
    expect(state(tester).play.moves, 1);
    expect(state(tester).play.fence, [2, 3, 4, 5, 6, 7, 8, 9, 10, 1]);
    await press(tester, 'Back');
    expect(state(tester).play.moves, 0);
  });

  testWidgets('a paling put back in its own gap is no move at all',
      (tester) async {
    await open(tester, which: 0);
    await move(tester, 4, 4);
    expect(state(tester).play.moves, 0);
    expect(state(tester).play.held, isNull);
  });

  testWidgets('tapping the air over the fence changes nothing and says so',
      (tester) async {
    await open(tester, which: 0);
    await tester.tapAt(skyAt(tester));
    await tester.pumpAndSettle();
    expect(state(tester).play.held, isNull);
    expect(state(tester).play.moves, 0);
    expect(find.textContaining('That is sky'), findsOneWidget);
  });

  testWidgets('the short drop lands in six moves and the card is shown',
      (tester) async {
    await open(tester, which: 3);
    await fenceByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 6);
    expect(state(tester).play.climb, 4);
    expect(state(tester).play.drop, 3);
    expect(find.text('Fenced.'), findsOneWidget);
    expect(find.textContaining('One of 107,604 fences of the 3,628,800'),
        findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Fenced.'), findsNothing);
    expect(find.text('moves 0'), findsOneWidget);
  });

  testWidgets('the matched fence comes out five and five', (tester) async {
    await open(tester, which: 1);
    await fenceByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.climb, 5);
    expect(state(tester).play.drop, 5);
    expect(find.textContaining('longest climb 5 and longest drop 5'),
        findsOneWidget);
    await press(tester, 'Again');
    // This ask sets no limit, so its chips carry the runs and no 'of'.
    expect(find.text('climb 10'), findsOneWidget);
    expect(find.text('drop 1'), findsOneWidget);
  });

  testWidgets('show me names the paling and then the gap', (tester) async {
    await open(tester, which: 0);
    await press(tester, 'Show me');
    expect(find.textContaining('Lift the paling at place'), findsOneWidget);
    final aim = state(tester).play.next!;
    await lift(tester, aim.$1);
    await press(tester, 'Show me');
    expect(find.textContaining('Now slide it into gap'), findsOneWidget);
  });

  testWidgets('the three and the three gives itself up', (tester) async {
    await open(tester, which: 4);
    for (final step in const [(0, 9), (0, 5), (3, 0), (8, 2), (1, 7),
      (4, 0)]) {
      if (state(tester).play.gaveUp) break;
      await move(tester, step.$1, step.$2);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Nine tags, ten palings.'), findsOneWidget);
    expect(find.textContaining('Nine palings can dodge it, in 1,764 ways'),
        findsOneWidget);
  });

  testWidgets('the why names the tags and both ways of counting',
      (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('all ten tags are different'), findsOneWidget);
    expect(find.textContaining('hook length formula'), findsOneWidget);
  });
}
