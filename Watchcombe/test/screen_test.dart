import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/combeland.dart';

/// One yard on the screen, watched as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a yard opens on its task and its chips',
      (tester) async {
    await open(tester, which: 0);
    expect(
      find.textContaining('post four watchmen on the four by four yard so every flag is watched'),
      findsOneWidget,
    );
    expect(find.text('watchmen 0 of 4'), findsOneWidget);
    expect(find.text('unwatched 16'), findsOneWidget);
    expect(find.text('far flags 4'), findsOneWidget);
    expect(find.text('Posted 0 of 4; 16 flags unwatched.'), findsOneWidget);
  });

  testWidgets('watchmen post and lift, and back undoes', (tester) async {
    await open(tester, which: 0);
    await tapFlag(tester, 5);
    expect(find.text('watchmen 1 of 4'), findsOneWidget);
    expect(find.text('unwatched 7'), findsOneWidget);
    await tapFlag(tester, 5);
    expect(find.text('unwatched 16'), findsOneWidget);
    await press(tester, 'Back');
    expect(state(tester).play.watchmen, [5]);
  });

  testWidgets('the four yard watched and the card shown', (tester) async {
    await open(tester, which: 0);
    await tapAll(tester, [5, 6, 9, 10]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Landed.'), findsOneWidget);
    expect(find.text('Watched: every flag, by 4 watchmen.'), findsOneWidget);
    expect(
      find.textContaining('Every flag is watched; 4 taps.'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(find.text('Landed.'), findsNothing);
  });

  testWidgets('show me says post, or lift', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Show me');
    expect(state(tester).pointing, ('set', 7));
    expect(find.text('Post a watchman on the ringed flag.'), findsOneWidget);
    await tapFlag(tester, 0);
    await press(tester, 'Show me');
    expect(state(tester).pointing, ('lift', 0));
    expect(find.text('Lift the ringed watchman; he is off the posting.'), findsOneWidget);
  });

  testWidgets('the pointer watches the nine yard', (tester) async {
    await open(tester, which: 3);
    await postByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('watchmen 9 of 9'), findsOneWidget);
    expect(find.text('unwatched 0'), findsOneWidget);
  });

  testWidgets('the hopeless yard cracks at thirteen taps', (tester) async {
    await open(tester, which: 4);
    await tapAll(tester, [7, 10, 25]);
    expect(find.textContaining('flags unwatched.'), findsOneWidget);
    await tapAll(tester, [28, 28, 28, 28, 28, 28, 28, 28, 28, 28]);
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('Four corners, three watchmen.'), findsOneWidget);
    expect(
      find.textContaining('three watchmen leave a corner dark'),
      findsOneWidget,
    );
  });

  testWidgets('the why chalks the far flags', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('4 of them on this yard and chalked on the board'),
      findsOneWidget,
    );
    expect(
      find.textContaining('a third of the side rounded up and squared'),
      findsOneWidget,
    );
  });

  testWidgets('the why of the six yard counts one posting', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Why');
    expect(
      find.textContaining('1 of the 58905'),
      findsOneWidget,
    );
  });
}
