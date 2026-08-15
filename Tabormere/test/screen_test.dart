import 'package:flutter_test/flutter_test.dart';
import 'package:tabormere/drum/play.dart';

import 'support/fonts.dart';
import 'support/drumland.dart';

/// One ask on the screen, drummed as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('an ask opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(find.textContaining('set three hits in eight steps as evenly as they can go'), findsOneWidget);
    expect(find.text('hits 0 of 3'), findsOneWidget);
    expect(find.text('gaps none yet'), findsOneWidget);
    expect(find.text('taps 0'), findsOneWidget);
    expect(find.text('No hits set: 3 to set in 8 steps.'), findsOneWidget);
  });

  testWidgets('a set, a lift, too many, and back', (tester) async {
    await open(tester, which: 0);
    await tapStep(tester, 0);
    expect(state(tester).play.hitsAt, [0]);
    expect(find.text('1 of 3 hits set.'), findsOneWidget);
    await tapStep(tester, 4);
    expect(find.text('gaps 4 4'), findsOneWidget);
    expect(find.text('2 of 3 hits set, gaps of 4, 4: even so far.'), findsOneWidget);
    await tapStep(tester, 5);
    expect(state(tester).play.isDone, isFalse);
    expect(find.text('3 of 3 hits set, gaps of 4, 1, 3: not even.'), findsOneWidget);
    await tapStep(tester, 6);
    expect(find.text('4 of 3 hits set, gaps of 4, 1, 1, 2: not even. Too many: lift 1.'), findsOneWidget);
    await tapStep(tester, 6);
    expect(state(tester).play.hitsAt, [0, 4, 5]);
    expect(find.text('taps 5'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.hitsAt, [0, 4, 5, 6]);
  });

  testWidgets('the tresillo lands and the card is shown', (tester) async {
    await open(tester, which: 0);
    await setAll(tester, [0, 3, 6]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Drummed.'), findsOneWidget);
    expect(find.text('As asked. Even: gaps of 3, 3, 2.'), findsOneWidget);
    expect(find.textContaining('x..x..x., gaps of 3, 3, 2: even, a turning of Euclid\'s x.x..x.., one of 8 patterns of 56; 3 taps.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Drummed.'), findsNothing);
    expect(find.text('taps 0'), findsOneWidget);
  });

  testWidgets('show me names the step, and calls a stray to be lifted', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');
    expect(find.text('Set a hit at step 1.'), findsOneWidget);
    expect(state(tester).pointing, (Aim.set, 0));
    await tapStep(tester, 2);
    await press(tester, 'Show me');
    expect(find.text('Lift the hit at step 3.'), findsOneWidget);
  });

  testWidgets('the pointer drums the bossa', (tester) async {
    await open(tester, which: 2);
    await drumByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 5);
    expect(find.text('As asked. Even: gaps of 3, 3, 3, 3, 4.'), findsOneWidget);
  });

  testWidgets('the bembe, by hand', (tester) async {
    await open(tester, which: 3);
    await setAll(tester, [0, 2, 3, 5, 7, 8, 10]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('As asked. Even: gaps of 2, 1, 2, 2, 1, 2, 2.'), findsOneWidget);
  });

  testWidgets('the even tresillo admits it at the tresillo', (tester) async {
    await open(tester, which: 4);
    await setAll(tester, [1, 4, 7]);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Eight into three won\'t go.'), findsOneWidget);
    expect(find.text('Gaps of 3, 3, 2, as even as three in eight go: eight into three won\'t go, and the gaps never come out alike.'), findsOneWidget);
    expect(find.textContaining('the nearest is gaps of 3, 3 and 2, .x..x..x, the tresillo'), findsOneWidget);
  });

  testWidgets('the why tells Euclid and the sweep', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(find.textContaining('Toussaint\'s finding of 2005'), findsOneWidget);
    expect(find.textContaining('tried in full'), findsOneWidget);
  });
}
