import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/stubland.dart';

/// One ask on the screen, the dials turned as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('turn the dials to a ticket that passes'), findsOneWidget);
    expect(find.text('sum 1'), findsOneWidget);
    expect(find.text('fails'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(find.text('Ticket 0 0 0 0 1: sum 1, ends in 1, fails.'), findsOneWidget);
  });

  testWidgets('a dial turns a digit, and back undoes', (tester) async {
    await open(tester, which: 0);
    await turn(tester, 4, 1);
    expect(state(tester).play.digits, [0, 0, 0, 0, 2]);
    expect(find.text('Ticket 0 0 0 0 2: sum 2, ends in 2, fails.'), findsOneWidget);
    expect(find.text('sum 2'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.digits, [0, 0, 0, 0, 1]);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('the check passes at 0 0 0 0 0 and the card is shown', (tester) async {
    await open(tester, which: 0);
    await turn(tester, 4, -1);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Passed.'), findsOneWidget);
    expect(find.text('As asked. Ticket 0 0 0 0 0: sum 0, ends in nought, passes.'), findsOneWidget);
    expect(find.textContaining('Ticket 0 0 0 0 0: adds 0, 0, 0, 0 and 0, sum 0, passes, by Luhn\'s doubling and by the table of doubles; one of 10,000 tickets of the 100,000; 1 tap.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Passed.'), findsNothing);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('show me names the dial, and the pointer reaches the twin slip', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Show me');
    expect(find.text('Turn dial 3 up.'), findsOneWidget);
    expect(state(tester).pointing, (2, 1));
    await ticketByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.digits, [0, 0, 1, 3, 3]);
    expect(state(tester).play.moves, 6);
    expect(find.text('As asked. Ticket 0 0 1 3 3: sum 10, ends in nought, passes.'), findsOneWidget);
    expect(find.textContaining('3 3 in it, so 6 6 in their place passes still; one of 2,132 tickets of the 100,000; 6 taps.'), findsOneWidget);
  });

  testWidgets('the swap unseen at 4 0 9 2 3', (tester) async {
    await open(tester, which: 1);
    await setTicket(tester, [4, 0, 9, 2, 3]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. Ticket 4 0 9 2 3: sum 20, ends in nought, passes.'), findsOneWidget);
    expect(find.textContaining('a 0 by a 9, so swapped it passes still; one of 732 tickets of the 100,000'), findsOneWidget);
  });

  testWidgets('the palindrome at 1 2 0 2 1', (tester) async {
    await open(tester, which: 3);
    await setTicket(tester, [1, 2, 0, 2, 1]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. Ticket 1 2 0 2 1: sum 10, ends in nought, passes.'), findsOneWidget);
    expect(find.textContaining('one of 100 tickets of the 100,000'), findsOneWidget);
  });

  testWidgets('a ticket short of the ask says its sum', (tester) async {
    await open(tester, which: 3);
    await setTicket(tester, [1, 2, 3, 2, 1]);
    expect(state(tester).play.isDone, isFalse);
    expect(find.text('Ticket 1 2 3 2 1: sum 13, ends in 3, fails.'), findsOneWidget);
    expect(find.text('fails'), findsOneWidget);
    expect(find.text('sum 13'), findsOneWidget);
  });

  testWidgets('the slip unseen admits it after three slips', (tester) async {
    await open(tester, which: 4);
    await turn(tester, 4, -1);
    expect(state(tester).play.passes, isTrue);
    await turn(tester, 0, 1);
    expect(find.text('Ticket 1 0 0 0 0: sum 1, ends in 1, fails. Caught: 0 0 0 0 0 passed and one digit turned.'), findsOneWidget);
    await turn(tester, 0, -1);
    await turn(tester, 1, 1);
    await turn(tester, 1, -1);
    await turn(tester, 2, 1);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Caught, every time.'), findsOneWidget);
    expect(find.text('Ticket 0 0 1 0 0: sum 1, ends in 1, fails. One slip, always caught.'), findsOneWidget);
    expect(find.textContaining('Here 0 0 0 0 0 passed with a sum of 0, and one digit turned it to 0 0 1 0 0, sum 1.'), findsOneWidget);
  });

  testWidgets('the why tells Luhn and the sweep', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('Hans Peter Luhn'), findsOneWidget);
    expect(find.textContaining('summed in full'), findsOneWidget);
  });
}
