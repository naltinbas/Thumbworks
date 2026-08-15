import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/stallland.dart';

/// One stall on the screen, set as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a stall opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('set the stall so the policy wins two in three exactly'), findsOneWidget);
    expect(find.text('doors 3, opens 1'), findsOneWidget);
    expect(find.text('stay 1 in 3'), findsOneWidget);
    expect(find.text('settings 0'), findsOneWidget);
    expect(find.text('3 doors, 1 opened: staying wins 1 in 3, switching 2 in 3, 66.66 in a hundred.'), findsOneWidget);
  });

  testWidgets('the dials turn, and back undoes', (tester) async {
    await open(tester, which: 1);
    await set(tester, 'doors+');
    expect(state(tester).play.doors, 4);
    expect(find.text('doors 4, opens 1'), findsOneWidget);
    await set(tester, 'opened+');
    expect(state(tester).play.opened, 2);
    expect(find.text('4 doors, 2 opened: staying wins 1 in 4, switching 3 in 4, 75.00 in a hundred.'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.opened, 1);
    expect(find.text('settings 1'), findsOneWidget);
  });

  testWidgets('switching on three doors lands two in three and the card is shown', (tester) async {
    await open(tester, which: 0);
    await set(tester, 'policy');
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Set.'), findsOneWidget);
    expect(find.text('As asked. 3 doors, 1 opened: staying wins 1 in 3, switching 2 in 3, 66.66 in a hundred.'), findsOneWidget);
    expect(find.textContaining('3 doors and the host opening 1: staying wins 1 in 3 and switching 2 in 3, every case counted; 1 setting.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Set.'), findsNothing);
  });

  testWidgets('show me names the dial', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Show me');
    expect(state(tester).pointing, 'doors+');
    expect(find.text('Add a door.'), findsOneWidget);
  });

  testWidgets('the pointer sets the least gain', (tester) async {
    await open(tester, which: 3);
    await settleByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. 10 doors, 1 opened: staying wins 1 in 10, switching 9 in 80, 11.25 in a hundred.'), findsOneWidget);
  });

  testWidgets('better than even, by hand on five doors', (tester) async {
    await open(tester, which: 2);
    await setStall(tester, 5, 3, true);
    expect(state(tester).play.isDone, isTrue);
    expect(find.textContaining('staying wins 1 in 5 and switching 4 in 5'), findsOneWidget);
  });

  testWidgets('the stay never wins', (tester) async {
    await open(tester, which: 4);
    for (var k = 0; k < 24; k++) {
      await set(tester, k.isEven ? 'doors+' : 'doors-');
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Staying never wins.'), findsOneWidget);
    expect(find.textContaining('more than 1/n whenever a door is opened at all'), findsOneWidget);
  });

  testWidgets('the why counts the cases', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('on all 72 settings of three to ten doors, and the count agrees with the formula every time'), findsOneWidget);
    expect(find.textContaining('in none of the 72 settings does staying win more, nor even as many'), findsOneWidget);
  });
}
