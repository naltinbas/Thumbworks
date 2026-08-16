import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/pairland.dart';

/// One ask on the screen, the dials stepped as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips',
      (tester) async {
    await open(tester, which: 3);
    expect(find.textContaining('set the two numbers S knows too, all four things said'), findsOneWidget);
    expect(find.text('sum 7'), findsOneWidget);
    expect(find.text('product 12'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(find.text('3 and 4, sum 7 and product 12: P in the dark, but S could not have known.'), findsOneWidget);
  });

  testWidgets('the dials step the numbers, a bad step does nothing, and back undoes', (tester) async {
    await open(tester, which: 3);
    await turn(tester, 'x', 1);
    expect((state(tester).play.x, state(tester).play.y), (3, 4));
    expect(find.text('taps 0'), findsOneWidget);
    await turn(tester, 'y', 1);
    expect((state(tester).play.x, state(tester).play.y), (3, 5));
    expect(find.text('3 and 5, sum 8 and product 15: the product tells P at once.'), findsOneWidget);
    expect(find.text('sum 8'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.y, 4);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('the sum then knew lands at 4 and 13 and the card is shown', (tester) async {
    await open(tester, which: 3);
    await setPair(tester, 4, 13);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Said.'), findsOneWidget);
    expect(find.text('As asked. 4 and 13, sum 17 and product 52: P in the dark, S knew it, P now knows, S now knows too.'), findsOneWidget);
    expect(find.textContaining('4 and 13, sum 17 and product 52: P in the dark, S knew it, P now knows, S now knows too, by the four things asked and by the narrowing of the whole set; one of 1 pair of the 2,352; 10 taps.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Said.'), findsNothing);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('show me names the step, and the pointer reaches 4 and 13', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Show me');
    expect(find.text('Step y up.'), findsOneWidget);
    expect(state(tester).pointing, ('y', 1));
    await pairByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect((state(tester).play.x, state(tester).play.y, state(tester).play.moves), (4, 13, 10));
  });

  testWidgets('the product tells at 2 and 4', (tester) async {
    await open(tester, which: 0);
    await turn(tester, 'x', -1);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. 2 and 4, sum 6 and product 8: the product tells P at once.'), findsOneWidget);
    expect(find.textContaining('one of 605 pairs of the 2,352; 1 tap.'), findsOneWidget);
  });

  testWidgets('the sum that knew, at 3 and 8', (tester) async {
    await open(tester, which: 1);
    await setPair(tester, 2, 9);
    expect(state(tester).play.isDone, isTrue);
    expect((state(tester).play.x, state(tester).play.y), (3, 8));
    expect(find.text('As asked. 3 and 8, sum 11 and product 24: P in the dark, S knew it, P now knows.'), findsOneWidget);
    expect(find.textContaining('one of 145 pairs of the 2,352; 4 taps.'), findsOneWidget);
  });

  testWidgets('the product then knew, at 2 and 9', (tester) async {
    await open(tester, which: 2);
    await turn(tester, 'x', -1);
    for (var k = 0; k < 5; k++) {
      await turn(tester, 'y', 1);
    }
    expect((state(tester).play.x, state(tester).play.y), (2, 9));
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. 2 and 9, sum 11 and product 18: P in the dark, S knew it, P now knows.'), findsOneWidget);
    expect(find.textContaining('one of 86 pairs of the 2,352; 6 taps.'), findsOneWidget);
  });

  testWidgets('the even sum admits it after three even sums', (tester) async {
    await open(tester, which: 4);
    for (var k = 0; k < 5; k++) {
      await turn(tester, 'y', 1);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Two primes, every time.'), findsOneWidget);
    expect(find.text('3 and 9, sum 12 and product 27: the product tells P at once. Two primes, every time.'), findsOneWidget);
    expect(find.textContaining('Here 12 is 5 + 7, and 35 tells P.'), findsOneWidget);
  });

  testWidgets('the why tells Freudenthal and the sieve', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('Freudenthal set it in 1969'), findsOneWidget);
    expect(find.textContaining('asked in full'), findsOneWidget);
  });
}
