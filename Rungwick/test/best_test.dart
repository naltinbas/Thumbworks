import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rungwick/best.dart';

Future<Best> fresh([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Best(await SharedPreferences.getInstance());
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('knows nothing to begin with', () async {
    final best = await fresh();
    expect(best.has('rake', 'cons'), isFalse);
    expect(best.rungsFor('rake', 'cons'), isNull);
    expect(best.climbed, 0);
  });

  test('writes down a climb', () async {
    final best = await fresh();
    expect(await best.record('rake', 'cons', 5), isTrue);
    expect(best.rungsFor('rake', 'cons'), 5);
    expect(best.climbed, 1);
  });

  test('keeps the fewest rungs, not the latest', () async {
    final best = await fresh();
    await best.record('bush', 'fire', 7);

    expect(await best.record('bush', 'fire', 8), isFalse);
    expect(best.rungsFor('bush', 'fire'), 7);

    expect(await best.record('bush', 'fire', 5), isTrue);
    expect(best.rungsFor('bush', 'fire'), 5);
  });

  test('is keyed on the two words, so a new climb shifts nothing', () async {
    final best = await fresh({'sound': true, 'best.gown-give': 7});
    expect(best.rungsFor('gown', 'give'), 7);
    expect(best.has('rake', 'cons'), isFalse);
    expect(best.climbed, 1, reason: 'the other setting is not a climb');
  });
}
