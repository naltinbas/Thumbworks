import 'package:bannford/banns/parties.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/banns.dart';

void main() {
  group('the hall of parties', () {
    testWidgets('names the game and every party', (tester) async {
      await open(tester);
      expect(find.text('Bannford'), findsOne);
      for (var number = 0; number < Parties.count; number++) {
        expect(find.text(Parties.at(number).name), findsOne);
      }
    });

    testWidgets('the odd house is labelled dead on the way in',
        (tester) async {
      await open(tester);
      expect(find.textContaining('no pairing of them settles'), findsOne);
    });

    testWidgets('a row opens its party', (tester) async {
      await open(tester);
      await tester.tap(find.text(Parties.at(2).name));
      await tester.pump();
      expect(state(tester).play.party.name, Parties.at(2).name);
    });

    testWidgets('leaving a party lands back on the hall', (tester) async {
      await open(tester, which: 0);
      await tester.tap(find.byTooltip('Back to the parties'));
      await tester.pump();
      expect(find.text('Bannford'), findsOne);
    });
  });
}
