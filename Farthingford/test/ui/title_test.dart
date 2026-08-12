import 'package:flutter_test/flutter_test.dart';
import 'package:farthingford/best.dart';
import 'package:farthingford/ford/reaches.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/ford.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  group('the stream of reaches', () {
    testWidgets('names the game and every reach', (tester) async {
      await open(tester);
      expect(find.text('Farthingford'), findsOne);
      for (var number = 0; number < Reaches.count; number++) {
        expect(find.text(Reaches.at(number).name), findsOne);
      }
    });

    testWidgets('the shallow ford is labelled dead on the way in',
        (tester) async {
      await open(tester);
      expect(
        find.textContaining('no ford of any depth does'),
        findsOne,
      );
    });

    testWidgets('a crossed reach wears its wades', (tester) async {
      await open(tester,
          best: await keeper({'crossed.The First Ford': 1}));
      expect(find.text('crossed in 1'), findsOne);
    });

    testWidgets('a row opens its reach', (tester) async {
      await open(tester);
      await tester.tap(find.text(Reaches.at(2).name));
      await tester.pump();
      expect(state(tester).play.reach.name, Reaches.at(2).name);
    });

    testWidgets('leaving a reach lands back on the stream',
        (tester) async {
      await open(tester, which: 0);
      await tester.tap(find.byTooltip('Back to the reaches'));
      await tester.pump();
      expect(find.text('Farthingford'), findsOne);
    });
  });
}
