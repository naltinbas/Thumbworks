import 'package:flutter_test/flutter_test.dart';
import 'package:trebleworth/heap/play.dart';

import 'support/fonts.dart';
import 'support/heapland.dart';

/// One ask on the screen, heaped as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('make 20 by adding three triangular numbers, nought allowed'), findsOneWidget);
    expect(find.text('sum 0 of 20'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(find.text('Nothing in the slots: take heaps from the shelf, 3 of them, to make 20.'), findsOneWidget);
  });

  testWidgets('takes fill the slots, a drop empties one, and back undoes', (tester) async {
    await open(tester, which: 0);
    await takeHeap(tester, 6);
    expect(state(tester).play.slots, [6, null, null]);
    expect(find.text('1 of 3 slots filled, 6 so far, 14 to go.'), findsOneWidget);
    await takeAll(tester, [6, 3]);
    expect(find.text('6 + 6 + 3 = 15, 5 short: empty a slot and try another heap.'), findsOneWidget);
    expect(find.text('sum 15 of 20'), findsOneWidget);
    await dropSlot(tester, 2);
    expect(state(tester).play.slots, [6, 6, null]);
    expect(find.text('taps 4'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.slots, [6, 6, 3]);
  });

  testWidgets('the twenty lands and the card is shown', (tester) async {
    await open(tester, which: 0);
    await takeAll(tester, [10, 0, 10]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Heaped.'), findsOneWidget);
    expect(find.text('As asked. 10 + 0 + 10 = 20.'), findsOneWidget);
    expect(find.textContaining('20 = 10 + 10 + 0, one of 1 heap of three; 8 times 20 plus 3 is 163, which is 1 squared + 9 squared + 9 squared, one for each heap of three; 3 taps.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Heaped.'), findsNothing);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('show me names the heap, and calls a stray to be emptied', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');
    expect(find.text('Take 1 from the shelf.'), findsOneWidget);
    expect(state(tester).pointing, (Aim.shelf, 1));
    await takeHeap(tester, 28);
    await press(tester, 'Show me');
    expect(find.text('Empty the ringed slot.'), findsOneWidget);
  });

  testWidgets('the pointer heaps the hundred', (tester) async {
    await open(tester, which: 2);
    await heapByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 3);
    expect(find.text('As asked. 0 + 45 + 55 = 100.'), findsOneWidget);
  });

  testWidgets('the twelve from two, by hand, and an overshoot told', (tester) async {
    await open(tester, which: 3);
    await takeAll(tester, [10, 3]);
    expect(find.text('10 + 3 = 13, 1 over: empty a slot and try another heap.'), findsOneWidget);
    await dropSlot(tester, 0);
    await dropSlot(tester, 1);
    await takeAll(tester, [6, 6]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. 6 + 6 = 12.'), findsOneWidget);
  });

  testWidgets('the five admits it at four from two heaps', (tester) async {
    await open(tester, which: 4);
    await takeAll(tester, [3, 1]);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Two heaps never make five.'), findsOneWidget);
    expect(find.text('4 from two heaps, and five falls between: 0, 1 and 3 pair to 0, 1, 2, 3, 4 and 6, never five.'), findsOneWidget);
    expect(find.textContaining('every number three heaps and 212 of them no two'), findsOneWidget);
  });

  testWidgets('the why tells Gauss and the sweep', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('Eureka: num = triangle + triangle + triangle'), findsOneWidget);
    expect(find.textContaining('tried in full'), findsOneWidget);
  });
}
