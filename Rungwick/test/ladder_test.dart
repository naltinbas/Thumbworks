import 'package:flutter_test/flutter_test.dart';
import 'package:rungwick/ladder/climbs.dart';
import 'package:rungwick/ladder/graph.dart';
import 'package:rungwick/ladder/play.dart';
import 'package:rungwick/ladder/words.dart';

void main() {
  late Ladder four;

  setUpAll(() => four = Ladder.of(kFour));

  group('the list', () {
    test('is every four letter word, in order and without repeats', () {
      expect(kFour, hasLength(2442));
      expect(kFour.every((word) => word.length == 4), isTrue);
      expect(kFour.toSet(), hasLength(kFour.length));
      expect(List.of(kFour)..sort(), kFour);
    });

    test('and the five letter one is the same', () {
      expect(kFive.every((word) => word.length == 5), isTrue);
      expect(kFive.toSet(), hasLength(kFive.length));
    });
  });

  group('the graph', () {
    test('puts a word next to the ones a letter away from it', () {
      final cat = four.numberOf('cost');
      final near = four.nextTo(cat).map(four.wordAt).toSet();

      expect(near, contains('cast'));
      expect(near, contains('coat'));
      expect(near, contains('cost'.replaceFirst('c', 'l')));
      expect(near, isNot(contains('cost')), reason: 'not next to itself');
      expect(near, isNot(contains('coats')));
    });

    test('and every neighbour really is one letter away, both ways round',
        () {
      // Checked by hand against the definition, on a good slice of the list.
      for (var word = 0; word < four.count; word += 7) {
        for (final other in four.nextTo(word)) {
          var different = 0;
          for (var at = 0; at < 4; at++) {
            if (four.wordAt(word)[at] != four.wordAt(other)[at]) different++;
          }
          expect(different, 1,
              reason: '${four.wordAt(word)} and ${four.wordAt(other)}');
          expect(four.nextTo(other), contains(word),
              reason: 'being next to each other has to go both ways');
        }
      }
    });

    test('finds nobody next to a word nothing else touches', () {
      // Some words have no neighbour at all, and the walk has to cope with
      // them rather than assume every word is on the graph somewhere.
      final lonely = [
        for (var word = 0; word < four.count; word++)
          if (four.howManyNextTo(word) == 0) word,
      ];
      expect(lonely, isNotEmpty, reason: 'the list should have a few');
      for (final word in lonely) {
        expect(four.climb(word, four.numberOf('cost')), isNull);
      }
    });
  });

  group('the walk outwards', () {
    test('says a word is nought steps from itself', () {
      final from = four.numberOf('word');
      expect(four.stepsFrom(from)[from], 0);
    });

    test('and counts every step of the way there', () {
      // Walked from one end, the distances have to agree with the ladder
      // walked from the other: a word three from the end is three from it.
      final to = four.numberOf('cons');
      final away = four.stepsFrom(to);
      final climb = four.climb(four.numberOf('rake'), to)!;

      for (var i = 0; i < climb.length; i++) {
        expect(away[climb[i]], climb.length - 1 - i,
            reason: '${four.wordAt(climb[i])} is not where it should be');
      }
    });

    test('and says -1 for what it cannot reach', () {
      final away = four.stepsFrom(four.numberOf('cost'));
      final stranded = [
        for (var word = 0; word < four.count; word++)
          if (away[word] < 0) word,
      ];
      expect(stranded, isNotEmpty);
      for (final word in stranded.take(20)) {
        expect(four.climb(four.numberOf('cost'), word), isNull);
      }
    });
  });

  group('every climb', () {
    test('takes the number of rungs it says it takes', () {
      // The claim on every level. This walks the whole list of words outwards
      // from one end of the climb, which answers for every word at once, and
      // fails if the shortest way through is not the number on the level.
      for (var i = 0; i < Climbs.count; i++) {
        final climb = Climbs.at(i);
        final ladder = climb.letters == 5 ? Ladder.of(kFive) : four;
        final found = ladder.climb(
          ladder.numberOf(climb.from),
          ladder.numberOf(climb.to),
        );

        expect(found, isNotNull, reason: '$climb cannot be climbed at all');
        expect(found!.length - 1, climb.rungs, reason: '$climb is wrong');
      }
    });

    test('and the way through it is words all the way up', () {
      for (var i = 0; i < Climbs.count; i++) {
        final climb = Climbs.at(i);
        final ladder = climb.letters == 5 ? Ladder.of(kFive) : four;
        final found = ladder.climb(
          ladder.numberOf(climb.from),
          ladder.numberOf(climb.to),
        )!;

        for (final rung in found) {
          expect(ladder.has(ladder.wordAt(rung)), isTrue);
        }
        expect(ladder.wordAt(found.first), climb.from);
        expect(ladder.wordAt(found.last), climb.to);
      }
    });

    test('starts and ends on words that are in the list', () {
      for (var i = 0; i < Climbs.count; i++) {
        final climb = Climbs.at(i);
        final ladder = climb.letters == 5 ? Ladder.of(kFive) : four;
        expect(ladder.has(climb.from), isTrue, reason: climb.from);
        expect(ladder.has(climb.to), isTrue, reason: climb.to);
        expect(climb.from, isNot(climb.to));
      }
    });
  });

  group('a climb', () {
    Play start([int which = 0]) => Play.of(Climbs.at(which), four);

    test('begins on the first word with nothing climbed', () {
      final play = start();
      expect(play.here, 'rake');
      expect(play.taken, 0);
      expect(play.stepsLeft, 4);
      expect(play.onShortest, isTrue);
      expect(play.isDone, isFalse);
    });

    test('takes a word that is one letter away', () {
      final play = start().tried('cake');
      expect(play.here, 'cake');
      expect(play.taken, 1);
      expect(play.refused, isNull);
      expect(play.words, ['rake', 'cake']);
    });

    test('refuses one that is not a word', () {
      final play = start().tried('rakz');
      expect(play.refused, Refusal.notAWord);
      expect(play.taken, 0);
    });

    test('refuses one that changes nothing, or more than one letter', () {
      expect(start().tried('rake').refused, Refusal.notOneLetter,
          reason: 'the same word again changes nothing');
      expect(start().tried('cans').refused, Refusal.notOneLetter,
          reason: 'two letters at once');
      expect(start().tried('cake').refused, isNull);
    });

    test('refuses to go back to a word already on the ladder', () {
      final play = start().tried('cake').tried('rake');
      expect(play.refused, Refusal.beenThere);
      expect(play.taken, 1);
    });

    test('takes a rung back off again', () {
      final play = start().tried('cake').tried('cane').back;
      expect(play.here, 'cake');
      expect(play.taken, 1);
      expect(play.back.back.taken, 0, reason: 'and stops at the bottom');
    });

    test('knows when a rung has gone nowhere', () {
      // rake -> lake is a word and a rung, and it is not on any shortest way
      // to cons — the game says so at once rather than after five more.
      final play = start().tried('lake');
      expect(play.taken, 1);
      expect(play.onShortest, isFalse);
      expect(play.wasted, greaterThan(0));

      expect(start().tried('cake').onShortest, isTrue);
    });

    test('is done when it reaches the far end', () {
      var play = start();
      for (final word in ['cake', 'cane', 'cans', 'cons']) {
        play = play.tried(word);
      }
      expect(play.isDone, isTrue);
      expect(play.taken, 4);
      expect(play.taken, Climbs.at(0).rungs, reason: 'in par');
      expect(play.tried('cons').taken, 4, reason: 'nothing happens after');
    });

    test('and points at a next rung that is really one step nearer', () {
      for (var which = 0; which < Climbs.count; which++) {
        var play = Play.of(Climbs.at(which), four);
        var guard = 0;
        while (!play.isDone && guard++ < 20) {
          final next = play.nextRung;
          expect(next, isNotNull, reason: '${Climbs.at(which)} ran out');
          final was = play.stepsLeft;
          play = play.tried(next!);
          expect(play.refused, isNull);
          expect(play.stepsLeft, was - 1);
        }
        expect(play.isDone, isTrue);
        expect(play.taken, Climbs.at(which).rungs,
            reason: 'following the pointer should climb it in par');
      }
    });
  });
}
