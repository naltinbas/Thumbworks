import 'package:flutter_test/flutter_test.dart';
import 'package:latchword/game/board.dart';
import 'package:latchword/game/lexicon.dart';
import 'package:latchword/game/round.dart';

import 'support/tracing.dart';

/// The shipped list, because a round is about a real board and building this
/// takes long enough to be worth doing once.
final _lexicon = Lexicon.standard();

Round _round([int seed = 1234]) => Round.of(seed, lexicon: _lexicon);

/// Takes [word] on the round the way a player tracing it would.
Round _take(Round round, String word) {
  final path = pathFor(round.board, word);
  expect(path, isNotNull, reason: '$word is not on this board');
  return round.on(round.board.take(path!));
}

void main() {
  test('the same seed is the same board every time', () {
    final one = _round();
    final again = _round();

    for (var row = 0; row < 5; row++) {
      for (var col = 0; col < 5; col++) {
        final spot = Spot(row, col);
        expect(again.board.letterAt(spot), one.board.letterAt(spot),
            reason: 'square $spot');
      }
    }
    expect(again.words, one.words);
  });

  test('a different seed is a different board', () {
    final one = _round(1);
    final other = _round(2);
    final same = [
      for (var row = 0; row < 5; row++)
        for (var col = 0; col < 5; col++)
          if (one.board.letterAt(Spot(row, col)) ==
              other.board.letterAt(Spot(row, col)))
            1,
    ];
    expect(same.length, lessThan(25));
  });

  test('a round starts with nothing found and everything missed', () {
    final round = _round();

    expect(round.score, 0);
    expect(round.found, isEmpty);
    expect(round.words, isNotEmpty);
    expect(round.missed.length, round.words.length);
    expect(round.possible, greaterThan(0));
  });

  test('a word found is scored and taken off the missed list', () {
    final round = _round();
    final word = round.missed.first;

    final after = _take(round, word);

    expect(after.found, [word]);
    expect(after.score, Board.scoreOf(word));
    expect(after.missed, isNot(contains(word)));
    expect(after.missed.length, round.words.length - 1);
  });

  test('the words a round holds do not change as they are found', () {
    final round = _round();
    final after = _take(round, round.missed.first);

    expect(after.words, round.words);
    expect(after.possible, round.possible);
    expect(after.seed, round.seed);
    expect(after.length, round.length);
  });

  test('the missed list puts the longest words first', () {
    final missed = _round().missed;

    for (var i = 1; i < missed.length; i++) {
      expect(missed[i].length, lessThanOrEqualTo(missed[i - 1].length));
    }
  });

  test('the words found are kept in the order they were found', () {
    var round = _round();
    final wanted = round.missed.reversed.take(3).toList();
    for (final word in wanted) {
      round = _take(round, word);
    }

    expect(round.found, wanted);
  });

  test('a fresh seed is small enough to read out and play again', () {
    for (var i = 0; i < 200; i++) {
      final seed = Round.freshSeed();
      expect(seed, greaterThan(0));
      expect(seed, lessThanOrEqualTo(99999));
    }
  });

  test('every board a round is played on holds enough to find', () {
    // The maker promises this and the round is what the promise is for: a
    // player who stares at a board and finds nothing blames themselves.
    for (final seed in [1, 2, 3, 77, 4096, 99999]) {
      final round = Round.of(seed, lexicon: _lexicon);
      expect(round.words.length, greaterThanOrEqualTo(25),
          reason: 'seed $seed');
    }
  });
}
