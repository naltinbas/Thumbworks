import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/mereland.dart';

/// One lighting on the screen, set as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a lighting opens on its task and its chips',
      (tester) async {
    await open(tester, which: 1);
    expect(
      find.textContaining('light exactly five lanterns so the mere lies still'),
      findsOneWidget,
    );
    expect(find.text('lit 0 of 5'), findsOneWidget);
    expect(find.text('will light 0'), findsOneWidget);
    expect(find.text('will go out 0'), findsOneWidget);
    expect(find.text('Nothing lit yet; 5 lanterns asked.'), findsOneWidget);
  });

  testWidgets('lights show the next turn, and back undoes', (tester) async {
    await open(tester, which: 0);
    await lightAll(tester, [(1, 1), (2, 1), (1, 2)]);
    expect(find.text('will light 1'), findsOneWidget);
    expect(find.text('will go out 0'), findsOneWidget);
    expect(find.text('Next turn 1 spot lights and 0 lanterns go out.'), findsOneWidget);
    await tapSpot(tester, (2, 2));
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'Again');
    await lightAll(tester, [(0, 0)]);
    expect(find.text('will go out 1'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.lit, isEmpty);
  });

  testWidgets('a fifth lantern is refused where four are asked', (tester) async {
    await open(tester, which: 0);
    await lightAll(tester, [(0, 0), (4, 0), (0, 4), (4, 4), (2, 2)]);
    expect(state(tester).play.lit, hasLength(4));
  });

  testWidgets('the block lies still and shows the card', (tester) async {
    await open(tester, which: 0);
    await lightAll(tester, [(1, 1), (2, 1), (1, 2), (2, 2)]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Still.'), findsOneWidget);
    expect(find.text('Still: nothing lights and nothing goes out.'), findsOneWidget);
    expect(
      find.textContaining('The mere lies still; 4 moves.'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(find.text('Still.'), findsNothing);
  });

  testWidgets('show me rings a spot', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Show me');
    expect(state(tester).pointing, isNotNull);
    expect(state(tester).pointing!.$1, 'light');
    expect(find.text('Light the ringed spot.'), findsOneWidget);
  });

  testWidgets('the pointer stills the seven', (tester) async {
    await open(tester, which: 3);
    await lightByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.moves, 7);
  });

  testWidgets('the hopeless lighting cracks at eleven moves', (tester) async {
    await open(tester, which: 4);
    await lightAll(tester, [(1, 1), (2, 1), (1, 2)]);
    expect(find.text('will light 1'), findsOneWidget);
    for (var dither = 0; dither < 4; dither++) {
      await lightAll(tester, [(1, 2), (1, 2)]);
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Three lights never lie still.'), findsOneWidget);
    expect(
      find.textContaining('the fourth corner lights'),
      findsOneWidget,
    );
  });

  testWidgets('the why reads the corner', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('three lanterns in one corner of a two-by-two square'),
      findsOneWidget,
    );
    expect(
      find.textContaining('exactly 64 such lightings'),
      findsOneWidget,
    );
  });

  testWidgets('the why of the four names the block and the tub', (tester) async {
    await open(tester, which: 0);
    await press(tester, 'Why');
    expect(
      find.textContaining('the block and the tub are seen to be the only fours'),
      findsOneWidget,
    );
    expect(
      find.textContaining('sixteen places for the block'),
      findsOneWidget,
    );
  });
}
