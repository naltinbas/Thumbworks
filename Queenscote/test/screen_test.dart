import 'package:flutter_test/flutter_test.dart';
import 'package:queenscote/watch/play.dart';

import 'support/fonts.dart';
import 'support/watchland.dart';

/// One ask on the screen, watched as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('set two queens on the four by four so every square is seen'), findsOneWidget);
    expect(find.text('queens 0 of 2'), findsOneWidget);
    expect(find.text('unseen 16'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(find.text('No queen set yet: 2 to set, 16 squares to see.'), findsOneWidget);
  });

  testWidgets('a set, a lift, a full board, and back', (tester) async {
    await open(tester, which: 0);
    await tapSquare(tester, 0);
    expect(state(tester).play.placed, [0]);
    expect(find.text('unseen 6'), findsOneWidget);
    expect(find.text('1 of 2 set, 6 squares unseen.'), findsOneWidget);
    await tapSquare(tester, 1);
    expect(find.text('2 of 2 set, 2 squares unseen. All the queens are down: lift one and try another square.'), findsOneWidget);
    await tapSquare(tester, 2);
    expect(state(tester).play.placed, [0, 1]);
    await tapSquare(tester, 1);
    expect(state(tester).play.placed, [0]);
    expect(find.text('taps 3'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.placed, [0, 1]);
  });

  testWidgets('the four by four lands and the card is shown', (tester) async {
    await open(tester, which: 0);
    await setAll(tester, [0, 10]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Watched.'), findsOneWidget);
    expect(find.text('As asked. Every square seen with 2 queens.'), findsOneWidget);
    expect(find.textContaining('Queens at a4 c2: every square seen, one of 12 placings of 120; 2 taps.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Watched.'), findsNothing);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('show me names the square, and calls a stray to be lifted', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');
    expect(find.text('Set a queen at a6.'), findsOneWidget);
    expect(state(tester).pointing, (Aim.set, 0));
    await tapSquare(tester, 3);
    await press(tester, 'Show me');
    expect(find.text('Lift the queen at d6.'), findsOneWidget);
  });

  testWidgets('the pointer watches the chessboard with five', (tester) async {
    await open(tester, which: 2);
    await watchByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 5);
    expect(find.text('As asked. Every square seen with 5 queens.'), findsOneWidget);
    expect(find.textContaining('Queens at a8 b8 f7 a4 e3: every square seen, one of 4,860 placings of 7,624,512; 5 taps.'), findsOneWidget);
  });

  testWidgets('the nearest miss, by hand', (tester) async {
    await open(tester, which: 3);
    await setAll(tester, [0, 12, 39, 57]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. 2 squares unseen exactly with 4 queens.'), findsOneWidget);
    expect(find.textContaining('Queens at a8 e7 h4 b1: 2 squares unseen, as asked, one of 64 placings of 635,376; 4 taps.'), findsOneWidget);
  });

  testWidgets('the lone queen admits it on a middle square', (tester) async {
    await open(tester, which: 4);
    await tapSquare(tester, 5);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Twelve at the most.'), findsOneWidget);
    expect(find.text('Twelve seen and four unseen, the best a lone queen does on the four by four: she never sees all sixteen.'), findsOneWidget);
    expect(find.textContaining('the sweep of all 16 squares says so'), findsOneWidget);
  });

  testWidgets('the why tells the five and the sweep', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('five watch it in 4,860 ways, and four never'), findsOneWidget);
    expect(find.textContaining('tried in full'), findsOneWidget);
  });
}
