import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slingwell/best_run.dart';

Future<BestRun> _open() async =>
    BestRun(await SharedPreferences.getInstance());

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  test('a player who has not finished a run has no best to beat', () async {
    final best = await _open();
    expect(best.hasRun, isFalse);
    expect(best.score, 0);
    expect(best.seed, isNull);
  });

  test('the first run worth anything becomes the best', () async {
    final best = await _open();
    expect(await best.record(score: 12, seed: 4711), isTrue);
    expect(best.score, 12);
    expect(best.seed, 4711);
  });

  test('a worse run leaves the best where it was', () async {
    final best = await _open();
    await best.record(score: 12, seed: 4711);
    expect(await best.record(score: 5, seed: 88), isFalse);
    expect(best.score, 12);
    expect(best.seed, 4711);
  });

  test('matching the best is not beating it', () async {
    final best = await _open();
    await best.record(score: 12, seed: 4711);
    expect(await best.record(score: 12, seed: 88), isFalse);
    expect(best.seed, 4711);
  });

  test('a better run brings its own seed with it', () async {
    final best = await _open();
    await best.record(score: 12, seed: 4711);
    expect(await best.record(score: 40, seed: 91234), isTrue);
    expect(best.score, 40);
    expect(best.seed, 91234);
  });

  test('a run that caught nothing is not worth keeping', () async {
    final best = await _open();
    expect(await best.record(score: 0, seed: 7), isFalse);
    expect(best.hasRun, isFalse);
  });

  test('the best is still there on the next launch', () async {
    await (await _open()).record(score: 23, seed: 555);

    // Everything the app holds in memory goes away, and the next launch reads
    // what was written rather than what it happened to remember.
    SharedPreferences.resetStatic();

    final reopened = await _open();
    expect(reopened.score, 23);
    expect(reopened.seed, 555);
  });

  test('a saved value that is not a number reads as no best at all', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'best.score': 'twelve',
      'best.seed': 4711,
    });
    final best = await _open();
    expect(best.hasRun, isFalse);
    expect(best.seed, isNull);
  });

  test('a best score with no seed beside it still counts', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{'best.score': 9});
    final best = await _open();
    expect(best.score, 9);
    expect(best.seed, isNull);
  });
}
