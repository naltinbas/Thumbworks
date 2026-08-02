import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lockstead/best.dart';

Future<Best> fresh([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('knows nothing to begin with', () async {
    final best = await fresh();
    expect(best.has('The garden gate'), isFalse);
    expect(best.guessesFor('The garden gate'), isNull);
    expect(best.opened, 0);
  });

  test('writes down an opening', () async {
    final best = await fresh();
    expect(await best.record('The garden gate', 4), isTrue);
    expect(best.guessesFor('The garden gate'), 4);
    expect(best.opened, 1);
  });

  test('keeps the fewest guesses, not the latest', () async {
    final best = await fresh();
    await best.record('The vault', 5);

    expect(await best.record('The vault', 6), isFalse);
    expect(best.guessesFor('The vault'), 5);

    expect(await best.record('The vault', 3), isTrue);
    expect(best.guessesFor('The vault'), 3);
  });

  test('is keyed on the name, so a new lock in the middle shifts nothing',
      () async {
    final best = await fresh({'sound': true, 'best.The strongbox': 6});
    expect(best.guessesFor('The strongbox'), 6);
    expect(best.has('The vault'), isFalse);
    expect(best.opened, 1, reason: 'the other setting is not a lock');
  });
}
