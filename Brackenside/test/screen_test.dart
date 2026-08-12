import 'package:flutter_test/flutter_test.dart';

import 'support/fonts.dart';
import 'support/hillside.dart';

/// The screen, worked the way a finger would.
void main() {
  setUpAll(useRealFonts);

  testWidgets('a fresh hill names itself and its task', (tester) async {
    await open(tester, which: 1);
    expect(find.text('The Five'), findsOneWidget);
    expect(
      find.textContaining('plant the side-4 hill to show exactly 5'),
      findsOneWidget,
    );
    expect(find.text('1 patch shows; 5 asked.'), findsOneWidget);
  });

  testWidgets('a tap swaps a plant and recounts the patches',
      (tester) async {
    await open(tester, which: 1);
    final spot = state(tester).play.rules.inner.first;
    final before = state(tester).play.patches;
    await tapSpot(tester, spot.$1, spot.$2);
    expect(state(tester).play.moves, 1);
    expect(state(tester).play.planted[spot], 'B');
    expect(
      find.text('patches ${state(tester).play.patches}'),
      findsOneWidget,
    );
    expect(state(tester).play.patches, isNot(before));
  });

  testWidgets('the rim refuses the finger', (tester) async {
    await open(tester, which: 1);
    await tapSpot(tester, 0, 0);
    expect(state(tester).play.moves, 0);
  });

  testWidgets('the first patch lands in one swap', (tester) async {
    await open(tester, which: 0);
    final spot = state(tester).play.rules.inner.single;
    await tapSpot(tester, spot.$1, spot.$2);
    expect(state(tester).play.isDone, isTrue);
    expect(find.text('Planted.'), findsOneWidget);
    expect(find.textContaining('1 replanting'), findsOneWidget);
    expect(find.textContaining('The fewest yet'), findsOneWidget);
  });

  testWidgets('back takes back a replanting and unfreezes',
      (tester) async {
    await open(tester, which: 0);
    final spot = state(tester).play.rules.inner.single;
    await tapSpot(tester, spot.$1, spot.$2);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'Back');
    expect(state(tester).play.isDone, isFalse);
    expect(state(tester).play.moves, 0);
    expect(find.text('Planted.'), findsNothing);
  });

  testWidgets('show me names the spot and the plant', (tester) async {
    await open(tester, which: 3);
    await press(tester, 'Show me');
    final aim = state(tester).pointing;
    expect(aim, isNotNull);
    expect(
      find.textContaining('Plant the ringed spot with'),
      findsOneWidget,
    );
  });

  testWidgets('show me walks the eleven home', (tester) async {
    await open(tester, which: 3);
    await plantByPointer(tester);
    expect(state(tester).play.isDone, isTrue);
    expect(state(tester).play.patches, 11);
  });

  testWidgets('why speaks the rim walk and the sweep', (tester) async {
    await open(tester, which: 2);
    await press(tester, 'Why');
    expect(
      find.textContaining('rim walk, whose single bracken-gorse '
          'edge'),
      findsOneWidget,
    );
    expect(
      find.textContaining('all 729 ways'),
      findsOneWidget,
    );
    expect(
      find.textContaining('exactly 16 of them'),
      findsOneWidget,
    );
  });

  testWidgets('the hopeless hill admits it and speaks the parity',
      (tester) async {
    await open(tester, which: 4);
    final spot = state(tester).play.rules.inner.first;
    for (var replant = 0; replant < 12; replant++) {
      await tapSpot(tester, spot.$1, spot.$2);
    }
    expect(state(tester).play.moves, 12);
    expect(find.text('The hill stays odd.'), findsOneWidget);
    expect(
      find.textContaining('shares that walk\'s parity'),
      findsOneWidget,
    );
    await press(tester, 'Why');
    expect(
      find.textContaining('no even count, ever'),
      findsOneWidget,
    );
  });

  testWidgets('again starts the hill over', (tester) async {
    await open(tester, which: 0);
    final spot = state(tester).play.rules.inner.single;
    await tapSpot(tester, spot.$1, spot.$2);
    await press(tester, 'Again');
    expect(state(tester).play.moves, 0);
    expect(find.text('Planted.'), findsNothing);
  });
}
