import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/nineland.dart';

/// One ask on the screen, dialled as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('dial three different digits whose number has root nine'), findsOneWidget);
    expect(find.text('hundreds 0'), findsOneWidget);
    expect(find.text('tens 0'), findsOneWidget);
    expect(find.text('units 0'), findsOneWidget);
    expect(find.text('root 0'), findsOneWidget);
    expect(find.text('digits add to 0'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(find.text('Nought on the dials: root 0, and no nines to cast.'), findsOneWidget);
  });

  testWidgets('a tap turns a dial and back undoes it', (tester) async {
    await open(tester, which: 0);
    await turn(tester, 'units', 1);
    expect(state(tester).play.number, 1);
    expect(find.text('units 1'), findsOneWidget);
    expect(find.text('root 1'), findsOneWidget);
    expect(find.text('1: 1 stands alone, root 1; 0 nines and 1 over.'), findsOneWidget);
    await turn(tester, 'tens', 1);
    await turn(tester, 'tens', 1);
    expect(state(tester).play.number, 21);
    expect(find.text('21: 2 + 1 = 3, root 3; 2 nines and 3 over.'), findsOneWidget);
    expect(find.text('digits add to 3'), findsOneWidget);
    expect(find.text('taps 3'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.number, 11);
    expect(find.text('taps 2'), findsOneWidget);
  });

  testWidgets('the nine lands on 738 and the card is shown', (tester) async {
    await open(tester, which: 0);
    // The digit sum moves by one a tap, so it passes nine on the way to
    // eighteen; it must pass at a number with a digit twice, 711 here,
    // or land there.
    await dial(tester, 701);
    await dial(tester, 731);
    await dial(tester, 738);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Cast.'), findsOneWidget);
    expect(find.text('As asked. 738: 7 + 3 + 8 = 18, 1 + 8 = 9, root 9; 82 nines and 0 over.'), findsOneWidget);
    expect(find.textContaining('738: 7 + 3 + 8 = 18, 1 + 8 = 9; 82 nines and 0 over; one of 84 numbers of the 1,000; 18 taps.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Cast.'), findsNothing);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('show me names the dial and the way, and the pointer dials the square seven', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');
    expect(find.text('Turn the tens up.'), findsOneWidget);
    expect(state(tester).pointing, (1, 1));
    await dialByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect((state(tester).play.number, state(tester).play.moves), (16, 7));
    expect(find.text('As asked. 16: 1 + 6 = 7, root 7; 1 nine and 7 over.'), findsOneWidget);
    expect(find.textContaining('16: 1 + 6 = 7; 1 nine and 7 over; one of 7 numbers of the 1,000; 7 taps.'), findsOneWidget);
  });

  testWidgets('the cube eight lands on 512', (tester) async {
    await open(tester, which: 2);
    await dial(tester, 512);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. 512: 5 + 1 + 2 = 8, root 8; 56 nines and 8 over.'), findsOneWidget);
    expect(find.textContaining('one of 3 numbers of the 1,000'), findsOneWidget);
  });

  testWidgets('the slip lands on the first multiple of nine the dials pass', (tester) async {
    // The digit sum moves by one a tap, so from nought it must pass nine
    // before it can reach eighteen: 846 itself is out of reach without
    // a slip landing first, and 864 dialled hundreds first lands 810.
    await open(tester, which: 3);
    await dial(tester, 864);
    expect(state(tester).play.isDone, isTrue);
    expect((state(tester).play.number, state(tester).play.moves), (810, 9));
    expect(find.text('As asked. 810: 8 + 1 + 0 = 9, root 9; 90 nines and 0 over.'), findsOneWidget);
    expect(find.textContaining('810: 8 + 1 + 0 = 9; 90 nines and 0 over; one of 110 numbers of the 1,000; 9 taps.'), findsOneWidget);
  });

  testWidgets('the square five admits it at 25', (tester) async {
    await open(tester, which: 4);
    await dial(tester, 25);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('No square roots five.'), findsOneWidget);
    expect(find.text('25 is 5 times 5, root 7: a square roots 1, 4, 7 or 9, never five.'), findsOneWidget);
    expect(find.textContaining('25, 5 squared, roots 7, as near as a square comes to five.'), findsOneWidget);
    expect(find.textContaining('the sweep of the 32 squares to 961 finds roots 0, 1, 4, 7 and 9 alone'), findsOneWidget);
  });

  testWidgets('the why tells the nines and the sweep', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('one more than a multiple of nine'), findsOneWidget);
    expect(find.textContaining('rooted both ways'), findsOneWidget);
  });
}
