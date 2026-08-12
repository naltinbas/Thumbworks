import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tussockmere/best.dart';
import 'package:tussockmere/mere/fields.dart';

import '../support/mere.dart';

Future<Best> keeper([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  group('the mere of fields', () {
    testWidgets('names the game and every field', (tester) async {
      await open(tester);
      expect(find.text('Tussockmere'), findsOne);
      for (var number = 0; number < Fields.count; number++) {
        expect(find.text(Fields.at(number).name), findsOne);
      }
    });

    testWidgets('the second chair is labelled dead on the way in',
        (tester) async {
      await open(tester);
      expect(
        find.textContaining('every line loses'),
        findsOne,
      );
    });

    testWidgets('a linked field wears its steps', (tester) async {
      await open(tester,
          best: await keeper({'linked.The Three Field': 3}));
      expect(find.text('linked in 3'), findsOne);
    });

    testWidgets('a row opens its field', (tester) async {
      await open(tester);
      await tester.tap(find.text(Fields.at(1).name));
      await tester.pump();
      expect(state(tester).play.field.name, Fields.at(1).name);
    });

    testWidgets('leaving a field lands back on the mere',
        (tester) async {
      await open(tester, which: 0);
      await tester.tap(find.byTooltip('Back to the fields'));
      await tester.pump();
      expect(find.text('Tussockmere'), findsOne);
    });
  });
}
