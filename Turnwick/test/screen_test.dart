import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/turnland.dart';

/// One pattern on the screen, cut and turned as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a pattern opens on its task and its chips',
      (tester) async {
    await open(tester, which: 3);
    expect(
      find.textContaining('cut and turn the four cards till every card lies face up'),
      findsOneWidget,
    );
    expect(find.text('moves 0'), findsOneWidget);
    expect(find.text('up at even 0'), findsOneWidget);
    expect(find.text('up at odd 0'), findsOneWidget);
    expect(find.text('Up at even places 0, at odd 0; 0 moves so far.'), findsOneWidget);
  });

  testWidgets('a turn and a cut, and back undoes', (tester) async {
    await open(tester, which: 3);
    await turnTwo(tester);
    expect(state(tester).play.faces, [true, true, false, false]);
    expect(find.text('moves 1'), findsOneWidget);
    expect(find.text('up at even 1'), findsOneWidget);
    await cut(tester);
    expect(state(tester).play.faces, [true, false, false, true]);
    await press(tester, 'Back');
    expect(state(tester).play.faces, [true, true, false, false]);
  });

  testWidgets('all four up in four and the card shown', (tester) async {
    await open(tester, which: 3);
    await makeAll(tester, [true, false, false, true]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Landed.'), findsOneWidget);
    expect(find.text('As asked, in 4 moves.'), findsOneWidget);
    expect(find.textContaining('The pack lies as asked after 4 moves.'), findsOneWidget);
    await press(tester, 'Again');
    expect(find.text('Landed.'), findsNothing);
  });

  testWidgets('show me says turn, or cut', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');
    expect(state(tester).pointing, isTrue);
    expect(find.text('Turn the top two over as one.'), findsOneWidget);
    await turnTwo(tester);
    await press(tester, 'Show me');
    expect(state(tester).pointing, isFalse);
    expect(find.text('Cut: the top card to the bottom.'), findsOneWidget);
  });

  testWidgets('the pointer reaches the middle two', (tester) async {
    await open(tester, which: 2);
    await playByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('moves 4'), findsOneWidget);
  });

  testWidgets('one card up never comes', (tester) async {
    await open(tester, which: 4);
    await makeAll(tester, [true, false, true, false, true, false, true, false, true, false, true, false]);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('One against nought never comes.'), findsOneWidget);
    expect(
      find.textContaining('one card up is one against nought'),
      findsOneWidget,
    );
  });

  testWidgets('the why counts even against odd', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('They start nought and nought and stay equal for ever'),
      findsOneWidget,
    );
    expect(
      find.textContaining('has 1 up at even places and 0 at odd, so it never comes'),
      findsOneWidget,
    );
  });

  testWidgets('the why of the ends counts the sequences', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Why');
    expect(
      find.textContaining('reaches it in 2 moves at the fewest, 1 of the 4 sequences of that many'),
      findsOneWidget,
    );
  });
}
