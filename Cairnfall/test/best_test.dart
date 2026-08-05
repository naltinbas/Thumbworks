import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cairnfall/best.dart';

Future<Best> fresh([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('knows nothing to begin with', () async {
    final best = await fresh();
    expect(best.has('Two heaps'), isFalse);
    expect(best.isClean('Two heaps'), isFalse);
    expect(best.won, 0);
  });

  test('writes down a win', () async {
    final best = await fresh();
    await best.record('Two heaps', win: true, wrong: 2);

    expect(best.has('Two heaps'), isTrue);
    expect(best.isClean('Two heaps'), isFalse, reason: 'it was given away');
    expect(best.won, 1);
  });

  test('and keeps the clean one when it comes', () async {
    final best = await fresh();
    expect(await best.record('Two heaps', win: true, wrong: 1), isFalse);
    expect(await best.record('Two heaps', win: true, wrong: 0), isTrue);
    expect(best.isClean('Two heaps'), isTrue);

    expect(await best.record('Two heaps', win: true, wrong: 3), isFalse,
        reason: 'a scrappier win afterwards does not take it away');
    expect(best.isClean('Two heaps'), isTrue);
  });

  test('and writes down nothing for a round that was lost', () async {
    final best = await fresh();
    expect(await best.record('Two heaps', win: false, wrong: 0), isFalse);
    expect(best.won, 0);
  });
}
