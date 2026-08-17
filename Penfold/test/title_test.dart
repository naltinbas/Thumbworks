import 'package:flutter_test/flutter_test.dart';
import 'package:penfold/fold/levels.dart';

import 'support/fonts.dart';
import 'support/foldland.dart';

/// The sham, as first seen.
void main() {
  setUpAll(useRealFonts);

  testWidgets('the sham lists every ask by name and task', (tester) async {
    await open(tester);
    expect(find.text('Penfold'), findsOneWidget);
    expect(find.textContaining('Four fields, four sheep and two whistles'),
        findsOneWidget);
    for (final level in Levels.all) {
      expect(find.text(level.name), findsOneWidget);
    }
    expect(find.textContaining('ather the flock in the near fold'), findsWidgets);
  });

  testWidgets('an ask opens from its tile', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Two Whistles'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Blow a whistle and every sheep moves'),
        findsOneWidget);
  });

  testWidgets('a gathering writes its fewest onto the sham', (tester) async {
    await open(tester);
    await tester.tap(find.text('The Two Whistles'));
    await tester.pumpAndSettle();
    await blowCall(tester, [0, 1]);
    expect(state(tester).play.isDone, isTrue);
    await press(tester, 'The sham');
    expect(find.textContaining('Fewest: 2'), findsOneWidget);
  });
}
