import 'package:flutter_test/flutter_test.dart';
import 'package:notchfield/ruler/cuts.dart';

import '../support/ruler.dart';

void main() {
  group('the drawer of rulers', () {
    testWidgets('names the game and every ruler', (tester) async {
      await open(tester);
      expect(find.text('Notchfield'), findsOne);
      for (var number = 0; number < Cuts.count; number++) {
        expect(find.text(Cuts.at(number).name), findsOne);
      }
    });

    testWidgets('the perfect ten is labelled dead on the way in',
        (tester) async {
      await open(tester);
      expect(find.textContaining('no cutting avoids a repeat'),
          findsOne);
    });

    testWidgets('a row opens its ruler', (tester) async {
      await open(tester);
      await tester.tap(find.text(Cuts.at(2).name));
      await tester.pump();
      expect(state(tester).play.cut.name, Cuts.at(2).name);
    });

    testWidgets('leaving a ruler lands back on the drawer',
        (tester) async {
      await open(tester, which: 0);
      await tester.tap(find.byTooltip('Back to the rulers'));
      await tester.pump();
      expect(find.text('Notchfield'), findsOne);
    });
  });
}
