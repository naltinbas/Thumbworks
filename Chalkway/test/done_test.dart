import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chalkway/done.dart';

Future<Done> fresh([Map<String, Object> from = const {}]) async {
  SharedPreferences.setMockInitialValues(from);
  return Done(await SharedPreferences.getInstance());
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('knows nothing to begin with', () async {
    final done = await fresh();
    expect(done.has('A slope'), isFalse);
    expect(done.chalkFor('A slope'), isNull);
    expect(done.count, 0);
  });

  test('writes down a win', () async {
    final done = await fresh();
    expect(await done.record('A slope', 2.4), isTrue);

    expect(done.has('A slope'), isTrue);
    expect(done.chalkFor('A slope'), 2.4);
    expect(done.count, 1);
  });

  test('keeps the tidiest answer, not the latest', () async {
    final done = await fresh();
    await done.record('The gap', 3.0);

    expect(await done.record('The gap', 3.4), isFalse);
    expect(done.chalkFor('The gap'), 3.0);

    expect(await done.record('The gap', 1.9), isTrue);
    expect(done.chalkFor('The gap'), 1.9);
  });

  test('counts only levels, not everything else in the file', () async {
    // Somebody else's settings live in the same box.
    final done = await fresh({'sound': true, 'done.A slope': 2.0});
    expect(done.count, 1);
  });

  test('is keyed on the name, so a new level in the middle shifts nothing',
      () async {
    // The reason for the name rather than the number. Levels get inserted;
    // records should not slide sideways onto puzzles nobody has seen.
    final done = await fresh({'done.The hole': 3.3});
    expect(done.chalkFor('The hole'), 3.3);
    expect(done.has('Two steps'), isFalse);
  });
}
