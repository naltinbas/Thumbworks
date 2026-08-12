import 'package:flutter_test/flutter_test.dart';

import 'support/fieldland.dart';
import 'support/fonts.dart';

/// One field on the screen, tapped as a thumb would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a field opens on its task and its chips', (tester) async {
    await open(tester, which: 0);
    expect(
      find.textContaining('fence half an acre with 3 posts'),
      findsOneWidget,
    );
    expect(find.text('posts 0 of 3'), findsOneWidget);
    expect(find.text('rim so far: 0'), findsOneWidget);
  });

  testWidgets('taps string the fence and the chips keep count',
      (tester) async {
    await open(tester, which: 0);
    await tapPost(tester, (0, 0));
    await tapPost(tester, (2, 1));
    expect(find.text('posts 2 of 3'), findsOneWidget);
    expect(find.text('rim so far: 2'), findsOneWidget);
    expect(find.textContaining('Posts 2 of 3 walked'), findsOneWidget);
    expect(state(tester).play.walk, [(0, 0), (2, 1)]);
  });

  testWidgets('the full walk asks for its closing tap',
      (tester) async {
    await open(tester, which: 0);
    await tapPost(tester, (0, 0));
    await tapPost(tester, (1, 0));
    await tapPost(tester, (0, 1));
    expect(
      find.textContaining('tap the first again to close'),
      findsOneWidget,
    );
  });

  testWidgets('landing speaks both counts and shows the card',
      (tester) async {
    await open(tester, which: 0);
    await fence(tester, const [(0, 0), (1, 0), (0, 1)]);
    expect(state(tester).play.isDone, isTrue);
    expect(
      find.text('rails 1 · Pick 1'),
      findsOneWidget,
    );
    expect(find.text('Fenced.'), findsOneWidget);
    expect(
      find.textContaining('rails and Pick agreeing'),
      findsOneWidget,
    );
    await press(tester, 'Again');
    expect(state(tester).play.walk, isEmpty);
    expect(find.text('Fenced.'), findsNothing);
  });

  testWidgets('closed off the asking says what stands wrong',
      (tester) async {
    await open(tester, which: 1);
    await fence(tester, const [(0, 0), (1, 0), (2, 1), (0, 1)]);
    expect(
      find.textContaining('holds an acre and a half where a '
          'whole acre was asked'),
      findsOneWidget,
    );
  });

  testWidgets('show me points a post and the verdict says so',
      (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Show me');
    expect(state(tester).pointing, isNotNull);
    expect(
      find.textContaining('Walk the fence to the ringed post'),
      findsOneWidget,
    );
    await tapPost(tester, state(tester).pointing!.$1);
    expect(state(tester).pointing, isNull);
  });

  testWidgets('the pointer fences the post within home',
      (tester) async {
    await open(tester, which: 2);
    await fenceByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.inside, 1);
  });

  testWidgets('back opens the fence and unwinds it', (tester) async {
    await open(tester, which: 0);
    await fence(tester, const [(0, 0), (2, 1), (1, 1)]);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'Back');
    expect(state(tester).play.closed, isFalse);
    await press(tester, 'Back');
    expect(state(tester).play.walk, hasLength(2));
  });

  testWidgets('the hopeless field cracks at twenty-one moves',
      (tester) async {
    await open(tester, which: 4);
    await fence(tester, const [(0, 0), (1, 0), (1, 1), (0, 1)]);
    for (var dither = 0; dither < 8; dither++) {
      await press(tester, 'Back');
      await tapPost(tester, (0, 0));
    }
    expect(state(tester).play.gaveUp, isTrue);
    expect(find.text('The rim refuses the half.'), findsOneWidget);
    expect(
      find.textContaining('pays even halves alone'),
      findsOneWidget,
    );
  });

  testWidgets('the why speaks Pick and the sweep', (tester) async {
    await open(tester, which: 4);
    await press(tester, 'Why');
    expect(
      find.textContaining('twice the posts within plus the rim'),
      findsOneWidget,
    );
    expect(find.textContaining('1,758'), findsOneWidget);
  });
}
