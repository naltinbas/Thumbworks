import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:haulyard/best.dart';

Future<Best> fresh([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('knows nothing to begin with', () async {
    final best = await fresh();
    expect(best.has('The first one'), isFalse);
    expect(best.shovesFor('The first one'), isNull);
    expect(best.done, 0);
  });

  test('writes down a finish', () async {
    final best = await fresh();
    expect(await best.record('The first one', 4), isTrue);
    expect(best.shovesFor('The first one'), 4);
    expect(best.done, 1);
  });

  test('keeps the fewest shoves, not the latest', () async {
    final best = await fresh();
    await best.record('The pinch', 8);

    expect(await best.record('The pinch', 9), isFalse);
    expect(best.shovesFor('The pinch'), 8);

    expect(await best.record('The pinch', 6), isTrue);
    expect(best.shovesFor('The pinch'), 6);
  });

  test('is keyed on the name, so a new yard in the middle shifts nothing',
      () async {
    final best = await fresh({'sound': true, 'best.Last out': 10});
    expect(best.shovesFor('Last out'), 10);
    expect(best.has('The yard'), isFalse);
    expect(best.done, 1, reason: 'the other setting is not a yard');
  });
}
