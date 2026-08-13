import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/holmering.dart';

/// One tour on the screen, walked as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a tour opens on its task and its chips',
      (tester) async {
    await open(tester, which: 4);
    expect(
      find.textContaining('through exactly 10 posts'),
      findsOneWidget,
    );
    expect(find.text('posts 0 of 10'), findsOneWidget);
    expect(find.text('open'), findsOneWidget);
  });

  testWidgets('taps walk the lanes and the chips follow',
      (tester) async {
    await open(tester, which: 0);
    await tapPost(tester, 0);
    await tapPost(tester, 5);
    expect(state(tester).play.walk, [0, 5]);
    expect(find.text('posts 2 of 5'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.walk, [0]);
  });

  testWidgets('the pentagon closes and shows the card',
      (tester) async {
    await open(tester, which: 0);
    await walkRound(tester, const [0, 1, 2, 3, 4]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Closed.'), findsOneWidget);
    expect(
      find.textContaining('A round of 5 stands closed'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(find.text('Closed.'), findsNothing);
  });

  testWidgets('show me points post by post', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');
    expect(state(tester).pointing, isNotNull);
    expect(
      find.textContaining('Walk to the ringed post'),
      findsOneWidget,
    );
  });

  testWidgets('the pointer closes the eight round', (tester) async {
    await open(tester, which: 2);
    await roundByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.walk, hasLength(8));
  });

  testWidgets('the hopeless tour cracks at twenty-four moves',
      (tester) async {
    await open(tester, which: 4);
    for (final post in [0, 1, 2, 3, 4]) {
      await tapPost(tester, post);
    }
    for (var dither = 0; dither < 19; dither++) {
      if (dither.isEven) {
        await press(tester, 'Back');
      } else {
        await tapPost(tester, 4);
      }
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(
      find.text('One post always stands.'),
      findsOneWidget,
    );
    expect(
      find.textContaining('one post always left standing'),
      findsOneWidget,
    );
  });

  testWidgets('the why speaks the census and the misses',
      (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('twelve pentagons, ten hexagons'),
      findsOneWidget,
    );
    expect(
      find.textContaining('the tenth post never joins'),
      findsOneWidget,
    );
  });
}
