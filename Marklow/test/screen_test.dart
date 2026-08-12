import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/lowland.dart';

/// The screen, worked the way a finger would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a fresh low names itself and its bare posts',
      (tester) async {
    await open(tester, which: 0);
    expect(find.text('The Path of Four'), findsOneWidget);
    expect(
      find.textContaining('so the 3 gaps run 1 to 3'),
      findsOneWidget,
    );
    expect(find.text('4 posts still bare.'), findsOneWidget);
  });

  testWidgets('a tap marks a post and the gaps follow',
      (tester) async {
    await open(tester, which: 0);
    await tapPost(tester, 0);
    expect(state(tester).play.numbering[0], 0);
    await markTo(tester, 1, 3);
    expect(find.text('gaps 1 of 3'), findsOneWidget);
  });

  testWidgets('a clash is called out', (tester) async {
    await open(tester, which: 0);
    await markTo(tester, 0, 2);
    await markTo(tester, 1, 2);
    expect(
      find.text('Two posts share a mark: renumber one.'),
      findsOneWidget,
    );
    expect(find.textContaining('doubles'), findsOneWidget);
  });

  testWidgets('a graceful path lands and records', (tester) async {
    await open(tester, which: 0);
    await markAll(tester, const [0, 3, 1, 2]);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Graced.'), findsOneWidget);
    expect(find.textContaining('The fewest yet'), findsOneWidget);
  });

  testWidgets('back takes back a marking and unfreezes',
      (tester) async {
    await open(tester, which: 0);
    await markAll(tester, const [0, 3, 1, 2]);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'Back');
    expect(state(tester).play.isDone, isFalse);
    expect(find.text('Graced.'), findsNothing);
  });

  testWidgets('show me names the post and the mark', (tester) async {
    await open(tester, which: 1);
    await press(tester, 'Show me');
    final aim = state(tester).pointing;
    expect(aim, isNotNull);
    expect(
      find.text('Mark post ${aim!.$1 + 1} with ${aim.$2}.'),
      findsOneWidget,
    );
  });

  testWidgets('why speaks the sweep and the complements',
      (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Why');
    expect(
      find.textContaining('every complement of one graceful too'),
      findsOneWidget,
    );
    expect(find.textContaining('finding 16 graceful'), findsOneWidget);
  });

  testWidgets('the hopeless low admits it and speaks the parity',
      (tester) async {
    await open(tester, which: 4);
    for (var marking = 0; marking < 12; marking++) {
      await tapPost(tester, marking % 5);
    }
    expect(state(tester).play.moves, 12);
    expect(find.text('The ring stays sullen.'), findsOneWidget);
    expect(
      find.textContaining('gaps of 1 to 5 must sum to fifteen'),
      findsOneWidget,
    );
    await press(tester, 'Why');
    expect(
      find.textContaining('every post is counted twice'),
      findsOneWidget,
    );
  });

  testWidgets('again starts the low over', (tester) async {
    await open(tester, which: 0);
    await markAll(tester, const [0, 3, 1, 2]);
    await press(tester, 'Again');
    expect(state(tester).play.moves, 0);
    expect(find.text('Graced.'), findsNothing);
  });
}
