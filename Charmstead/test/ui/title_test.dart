import 'package:charmstead/charm/charms.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/charm.dart';

void main() {
  group('the hearth of charms', () {
    testWidgets('names the game and every charm', (tester) async {
      await open(tester);
      expect(find.text('Charmstead'), findsOne);
      for (var number = 0; number < Charms.count; number++) {
        expect(find.text(Charms.at(number).name), findsOne);
      }
    });

    testWidgets('the dead charms are labelled on the way in',
        (tester) async {
      await open(tester);
      expect(find.textContaining('no charm holds'), findsNWidgets(2));
    });

    testWidgets('a row opens its charm', (tester) async {
      await open(tester);
      await tester.tap(find.text(Charms.at(2).name));
      await tester.pump();
      expect(state(tester).play.charm.name, Charms.at(2).name);
    });

    testWidgets('leaving a charm lands back on the hearth',
        (tester) async {
      await open(tester, which: 0);
      await tester.tap(find.byTooltip('Back to the charms'));
      await tester.pump();
      expect(find.text('Charmstead'), findsOne);
    });
  });
}
