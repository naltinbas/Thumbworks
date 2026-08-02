import 'package:flutter_test/flutter_test.dart';
import 'package:latchword/best_score.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<BestScore> _saved([Map<String, Object> values = const {}]) async {
  SharedPreferences.setMockInitialValues(Map<String, Object>.from(values));
  return BestScore(await SharedPreferences.getInstance());
}

void main() {
  test('a player who has finished nothing has no best round', () async {
    final best = await _saved();

    expect(best.hasRound, isFalse);
    expect(best.points, 0);
    expect(best.seed, isNull);
  });

  test('the first round worth anything becomes the best', () async {
    final best = await _saved();

    expect(await best.record(points: 12, seed: 77), isTrue);
    expect(best.points, 12);
    expect(best.seed, 77);
  });

  test('a better round takes the record and its seed with it', () async {
    final best = await _saved({'best.points': 12, 'best.seed': 77});

    expect(await best.record(points: 30, seed: 9), isTrue);
    expect(best.points, 30);
    expect(best.seed, 9);
  });

  test('a worse round leaves the record alone', () async {
    final best = await _saved({'best.points': 30, 'best.seed': 9});

    expect(await best.record(points: 8, seed: 4), isFalse);
    expect(best.points, 30);
    expect(best.seed, 9);
  });

  test('matching the record is not beating it', () async {
    final best = await _saved({'best.points': 30, 'best.seed': 9});

    expect(await best.record(points: 30, seed: 4), isFalse);
    expect(best.seed, 9);
  });

  test('a round that scored nothing is not worth keeping', () async {
    final best = await _saved();

    expect(await best.record(points: 0, seed: 5), isFalse);
    expect(best.hasRound, isFalse);
  });

  test('a best round survives being read again', () async {
    final best = await _saved();
    await best.record(points: 21, seed: 512);

    final relaunched = BestScore(await SharedPreferences.getInstance());
    expect(relaunched.points, 21);
    expect(relaunched.seed, 512);
  });

  test('a saved value that is not a number reads as no best round', () async {
    // Whatever wrote this, it was not this game. Reading it as absent keeps a
    // player out of a crash on the only screen they have.
    final best = await _saved({'best.points': 'lots'});

    expect(best.hasRound, isFalse);
    expect(best.points, 0);
  });
}
