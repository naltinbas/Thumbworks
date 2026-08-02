import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hazardwell/best.dart';

Future<Best> fresh([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('knows nothing to begin with', () async {
    final best = await fresh();
    expect(best.won, 0);
    expect(best.lost, 0);
    expect(best.played, 0);
    expect(best.sharpest, 0);
  });

  test('counts games won and lost', () async {
    final best = await fresh();
    await best.record(win: true, sharpness: 0.8);
    await best.record(win: false, sharpness: 0.6);
    await best.record(win: false, sharpness: 0.5);

    expect(best.won, 1);
    expect(best.lost, 2);
    expect(best.played, 3);
  });

  test('keeps the sharpest game, not the last one', () async {
    final best = await fresh();
    expect(await best.record(win: false, sharpness: 0.9), isTrue);
    expect(best.sharpest, 0.9);

    expect(await best.record(win: true, sharpness: 0.7), isFalse,
        reason: 'winning is mostly the dice; playing well is not');
    expect(best.sharpest, 0.9);

    expect(await best.record(win: false, sharpness: 1), isTrue);
    expect(best.sharpest, 1);
  });
}
