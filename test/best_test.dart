import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cinderplot/best.dart';

Future<Best> fresh([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('knows nothing to begin with', () async {
    final best = await fresh();
    expect(best.secondsFor('The paddock'), isNull);
    expect(best.clearedOn('The paddock'), 0);
    expect(best.cleared, 0);
  });

  test('writes down a clear', () async {
    final best = await fresh();
    expect(await best.record('The paddock', 92), isTrue);

    expect(best.secondsFor('The paddock'), 92);
    expect(best.clearedOn('The paddock'), 1);
    expect(best.cleared, 1);
  });

  test('keeps the quickest time, and counts every clear', () async {
    final best = await fresh();
    await best.record('The commons', 200);

    expect(await best.record('The commons', 240), isFalse);
    expect(best.secondsFor('The commons'), 200);
    expect(best.clearedOn('The commons'), 2,
        reason: 'a slower clear is still a clear');

    expect(await best.record('The commons', 150), isTrue);
    expect(best.secondsFor('The commons'), 150);
  });

  test('counts across plots, and ignores everything else in the file',
      () async {
    final best = await fresh({
      'sound': true,
      'cleared.The paddock': 3,
      'cleared.The quarry': 2,
      'best.The quarry': 400,
    });
    expect(best.cleared, 5);
    expect(best.secondsFor('The quarry'), 400);
  });
}
