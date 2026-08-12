import 'package:flutter_test/flutter_test.dart';
import 'package:tanglemere/web/webs.dart';

import '../support/web.dart';

void main() {
  group('the mere of webs', () {
    testWidgets('names the game and every web', (tester) async {
      await open(tester);
      expect(find.text('Tanglemere'), findsOne);
      for (var number = 0; number < Webs.count; number++) {
        expect(find.text(Webs.at(number).name), findsOne);
      }
    });

    testWidgets('the first thread is labelled lost on the way in',
        (tester) async {
      await open(tester);
      expect(find.textContaining('lost before the first thread'),
          findsOne);
    });

    testWidgets('a row opens its web', (tester) async {
      await open(tester);
      await tester.tap(find.text(Webs.at(2).name));
      await tester.pump();
      expect(state(tester).play.web.name, Webs.at(2).name);
    });

    testWidgets('leaving a web lands back on the mere', (tester) async {
      await open(tester, which: 0);
      await tester.tap(find.byTooltip('Back to the webs'));
      await tester.pump();
      expect(find.text('Tanglemere'), findsOne);
    });
  });
}
