import 'package:flutter_test/flutter_test.dart';
import 'package:ringmarsh/ring/watches.dart';

import '../support/ring.dart';

void main() {
  group('the marsh of watches', () {
    testWidgets('names the game and every watch', (tester) async {
      await open(tester);
      expect(find.text('Ringmarsh'), findsOne);
      for (var number = 0; number < Watches.count; number++) {
        expect(find.text(Watches.at(number).name), findsOne);
      }
    });

    testWidgets('the short ring is labelled dead on the way in',
        (tester) async {
      await open(tester);
      expect(find.textContaining('no ring sets it'), findsOne);
    });

    testWidgets('a row opens its watch', (tester) async {
      await open(tester);
      await tester.tap(find.text(Watches.at(2).name));
      await tester.pump();
      expect(state(tester).play.watch.name, Watches.at(2).name);
    });

    testWidgets('leaving a watch lands back on the marsh', (tester) async {
      await open(tester, which: 0);
      await tester.tap(find.byTooltip('Back to the watches'));
      await tester.pump();
      expect(find.text('Ringmarsh'), findsOne);
    });
  });
}
