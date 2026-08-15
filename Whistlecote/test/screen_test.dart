import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/coteland.dart';

/// One set of calls on the screen, whistled as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a set of calls opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(
      find.textContaining('give the three calls whistles of one, two and two notes, none the start of another'),
      findsOneWidget,
    );
    expect(find.text('whistled 0 of 3'), findsOneWidget);
    expect(find.text('clashes 0'), findsOneWidget);
    expect(find.text('shares 0 of 8'), findsOneWidget);
    expect(find.text('Whistled 0 of 3; none the start of another so far.'), findsOneWidget);
  });

  testWidgets('whistles mark, a clash reads, back undoes', (tester) async {
    await open(tester, which: 0);
    await tapAll(tester, [2, 4]);
    expect(find.text('whistled 2 of 3'), findsOneWidget);
    expect(find.text('clashes 1'), findsOneWidget);
    expect(find.text('shares 6 of 8'), findsOneWidget);
    expect(find.text('Come-bye is the start of Away: the dog would go at the first.'), findsOneWidget);
    await tapNode(tester, 4);
    expect(find.text('clashes 0'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.marks, [2, 4]);
  });

  testWidgets('one whistle over is called out', (tester) async {
    await open(tester, which: 0);
    await tapAll(tester, [4, 5, 6]);
    expect(find.text('1 whistle more than the calls ask at that length; lift it.'), findsOneWidget);
    expect(find.text('whistled 2 of 3'), findsOneWidget);
  });

  testWidgets('the three calls whistle and show the card', (tester) async {
    await open(tester, which: 0);
    await tapAll(tester, [2, 6, 7]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Landed.'), findsOneWidget);
    expect(find.text('Whistled: every call has its notes and none is the start of another.'), findsOneWidget);
    expect(
      find.textContaining('Every call has its whistle and none is the start of another; 3 taps.'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(find.text('Landed.'), findsNothing);
  });

  testWidgets('show me names the call and the whistle', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');
    expect(state(tester).pointing, ('mark', 2));
    expect(find.text('Give Come-bye the whistle low.'), findsOneWidget);
    await tapNode(tester, 3);
    await press(tester, 'Show me');
    expect(state(tester).pointing, ('lift', 3));
    expect(find.text('Lift the whistle high; the shepherd has no call for it.'), findsOneWidget);
  });

  testWidgets('the pointer whistles the five calls', (tester) async {
    await open(tester, which: 3);
    await markByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('whistled 5 of 5'), findsOneWidget);
    expect(find.text('shares 6 of 8'), findsOneWidget);
  });

  testWidgets('the hopeless set cracks at thirteen taps', (tester) async {
    await open(tester, which: 4);
    await tapAll(tester, [2, 6, 14, 15, 12]);
    expect(find.text('Come-bye is the start of That\'ll do: the dog would go at the first.'), findsOneWidget);
    expect(find.text('shares 9 of 8'), findsOneWidget);
    await tapAll(tester, [12, 13, 13, 12, 12, 13, 13, 12]);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('The whistles do not fit.'), findsOneWidget);
    expect(
      find.textContaining('one note half of every tune and the rest more than the half left'),
      findsOneWidget,
    );
  });

  testWidgets('the why counts the shares', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('The calls asked take 9 shares of 8, more than the whole'),
      findsOneWidget,
    );
    expect(
      find.textContaining('209 sets, the sweep and the shares agree'),
      findsOneWidget,
    );
  });

  testWidgets('the why of the long calls names the theorem', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Why');
    expect(
      find.textContaining('which is Kraft\'s inequality'),
      findsOneWidget,
    );
    expect(
      find.textContaining('36 of the 168 land it'),
      findsOneWidget,
    );
  });
}
