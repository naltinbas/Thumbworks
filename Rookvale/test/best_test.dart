import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rookvale/best.dart';

Future<Best> fresh([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('knows nothing to begin with', () async {
    final best = await fresh();
    expect(best.has('Corner work'), isFalse);
    expect(best.isClean('Corner work'), isFalse);
    expect(best.done, 0);
  });

  test('writes down a finish, and whether it was unaided', () async {
    final best = await fresh();
    expect(await best.record('Corner work', clean: false), isFalse);
    expect(best.has('Corner work'), isTrue);
    expect(best.isClean('Corner work'), isFalse);
    expect(best.done, 1);
  });

  test('and keeps the clean one when it comes', () async {
    final best = await fresh();
    await best.record('Two knights', clean: false);

    expect(await best.record('Two knights', clean: true), isTrue);
    expect(best.isClean('Two knights'), isTrue);

    expect(await best.record('Two knights', clean: false), isFalse,
        reason: 'a scrappier go afterwards does not take it away');
    expect(best.isClean('Two knights'), isTrue);
  });
}
