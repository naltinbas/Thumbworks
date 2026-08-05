import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wickfell/best.dart';

Future<Best> fresh([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('knows nothing to begin with', () async {
    final best = await fresh();
    expect(best.has('First light'), isFalse);
    expect(best.pressesFor('First light'), isNull);
    expect(best.done, 0);
  });

  test('writes down a board', () async {
    final best = await fresh();
    expect(await best.record('First light', 5), isTrue);
    expect(best.pressesFor('First light'), 5);
    expect(best.done, 1);
  });

  test('keeps the fewest presses, not the latest', () async {
    final best = await fresh();
    await best.record('Sixteen', 9);

    expect(await best.record('Sixteen', 11), isFalse);
    expect(best.pressesFor('Sixteen'), 9);

    expect(await best.record('Sixteen', 7), isTrue);
    expect(best.pressesFor('Sixteen'), 7);
  });

  test('is keyed on the name, so a new board in the middle shifts nothing',
      () async {
    final best = await fresh({'sound': true, 'best.The middle': 9});
    expect(best.pressesFor('The middle'), 9);
    expect(best.has('Sixteen'), isFalse);
    expect(best.done, 1, reason: 'the other setting is not a board');
  });
}
