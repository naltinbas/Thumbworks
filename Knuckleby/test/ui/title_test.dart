import 'package:flutter_test/flutter_test.dart';
import 'package:knuckleby/best.dart';
import 'package:knuckleby/bones/benches.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/bones.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  group('the tavern of benches', () {
    testWidgets('names the game and every bench', (tester) async {
      await open(tester);
      expect(find.text('Knuckleby'), findsOne);
      for (var number = 0; number < Benches.count; number++) {
        expect(find.text(Benches.at(number).name), findsOne);
      }
    });

    testWidgets('the even bones is labelled dead on the way in',
        (tester) async {
      await open(tester);
      expect(
        find.textContaining('no pair ever does'),
        findsOne,
      );
    });

    testWidgets('a traded bench wears its cuts', (tester) async {
      await open(tester,
          best: await keeper({'traded.The Little Pair': 9}));
      expect(find.text('traded in 9'), findsOne);
    });

    testWidgets('a row opens its bench', (tester) async {
      await open(tester);
      await tester.tap(find.text(Benches.at(1).name));
      await tester.pump();
      expect(state(tester).play.bench.name, Benches.at(1).name);
    });

    testWidgets('leaving a bench lands back on the tavern',
        (tester) async {
      await open(tester, which: 0);
      await tester.tap(find.byTooltip('Back to the benches'));
      await tester.pump();
      expect(find.text('Knuckleby'), findsOne);
    });
  });
}
