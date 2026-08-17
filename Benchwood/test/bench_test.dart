import 'package:flutter_test/flutter_test.dart';
import 'package:benchwood/bench/levels.dart';
import 'package:benchwood/bench/play.dart';
import 'package:benchwood/bench/rules.dart';

/// The bench, the card and the play, checked at the domain: nothing
/// here touches a widget.
void main() {
  group('the bench', () {
    test('a tool on the bench is free, and the rest are walks', () {
      const card = [0, 1, 2, 0, 1, 2];
      expect(Rules.nextCall(card, 0, 0), 3);
      expect(Rules.nextCall(card, 2, 3), 5);
      expect(Rules.nextCall(card, 2, 5), 6);
      expect(Rules.walksByRule(card, 2), 4);
      expect(Rules.fewestWalks(card, 2), 4);
      expect(Rules.walksByOldest(card, 2), 6);
      expect(Rules.walksByRule(card, 3), 3);
      expect(Rules.walksByRule(card, 1), 6);
      expect(Rules.furthest(card, [0, 1], 2), 1);
      expect(Rules.tellCard(card), 'A B C A B C');
      expect(Rules.tellTool(3), 'D');
    });

    test('Belady\'s rule takes the fewest walks on every card of eight', () {
      var cards = 0;
      for (final card in Rules.cards(8, 3)) {
        cards++;
        for (var slots = 1; slots <= 3; slots++) {
          expect(Rules.walksByRule(card, slots), Rules.fewestWalks(card, slots),
              reason: '${Rules.tellCard(card)} on $slots');
          expect(Rules.walksByOldest(card, slots),
              greaterThanOrEqualTo(Rules.walksByRule(card, slots)),
              reason: '${Rules.tellCard(card)} on $slots');
        }
      }
      // The cards of eight calls on at most three tools, tools named in
      // the order they are first called: S(8,1) + S(8,2) + S(8,3).
      expect(cards, 1 + 127 + 966);
    });

    test('more room never costs Belady\'s rule a walk', () {
      for (final card in Rules.cards(8, 3)) {
        for (var slots = 2; slots <= 3; slots++) {
          expect(Rules.walksByRule(card, slots),
              lessThanOrEqualTo(Rules.walksByRule(card, slots - 1)),
              reason: Rules.tellCard(card));
        }
      }
    });

    test('the anomaly is real on Belady\'s own card', () {
      const card = [0, 1, 2, 3, 0, 1, 4, 0, 1, 2, 3, 4];
      expect(Rules.walksByOldest(card, 3), 9);
      expect(Rules.walksByOldest(card, 4), 10);
      expect(Rules.walksByRule(card, 3), 7);
      expect(Rules.walksByRule(card, 4), 6);
      expect(Rules.fewestWalks(card, 3), 7);
      expect(Rules.fewestWalks(card, 4), 6);
    });

    test('every way of playing a card, counted', () {
      expect(Rules.plays([0, 1, 2, 0, 1, 2], 2, 4), (8, 1));
      expect(Rules.plays([0, 1, 2, 0, 1, 2], 2, 3), (8, 0));
      expect(Rules.cards(3, 2).length, 4);
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name),
          ['The Three Walks']);
      for (final level in Levels.all) {
        final (runs, good) =
            Rules.plays(level.card, level.slots, level.walks);
        expect(runs, level.runs, reason: level.name);
        expect(good, level.ways, reason: level.name);
        if (level.winnable) {
          expect(level.fewest, level.walks, reason: level.name);
        } else {
          expect(level.fewest, greaterThan(level.walks), reason: level.name);
        }
      }
      expect(Levels.all.map((l) => l.walks), [5, 4, 7, 6, 3]);
      expect(Levels.all.map((l) => l.slots), [2, 2, 3, 4, 2]);
      expect(Levels.all.map((l) => l.runs), [19, 8, 1377, 94, 8]);
      expect(Levels.all.map((l) => l.ways), [2, 1, 5, 6, 0]);
    });

    test('each ask says what it wants', () {
      expect(Levels.at(1).task,
          'work the card of 6 calls on a bench of 2 slots in 4 walks');
      expect(Levels.at(4).task,
          'work the card of 6 calls on a bench of 2 slots in 3 walks');
    });
  });

  group('the play', () {
    test('opens with the bench filling itself', () {
      final play = Play.of(Levels.at(1));
      // Two free slots take the first two tools without a choice.
      expect(play.at, 2);
      expect(play.bench, [0, 1]);
      expect(play.walks, 2);
      expect(play.waiting, isTrue);
      expect(play.wanted, 2);
      expect(play.finished, isFalse);
    });

    test('a carry puts the wanted tool in that slot', () {
      var play = Play.of(Levels.at(1));
      play = play.carry(0);
      expect(play.bench, [2, 1]);
      expect(play.walks, 3);
      expect(play.back.bench, [0, 1]);
      expect(play.carry(9), same(play));
    });

    test('the pointer works every card in the fewest walks', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var guard = 0;
        while (!play.finished && guard < 30) {
          final slot = play.next;
          expect(slot, isNotNull, reason: level.name);
          play = play.carry(slot!);
          guard++;
        }
        expect(play.isDone, isTrue, reason: level.name);
        expect(play.walks, level.walks, reason: level.name);
      }
      expect(Play.pointed(2), 'Carry C back to the store.');
    });

    test('the round is landed only by carrying C back', () {
      var play = Play.of(Levels.at(1));
      expect(play.next, 1);
      final wrong = play.carry(0);
      var wrongOut = wrong;
      var guard = 0;
      while (!wrongOut.finished && guard < 20) {
        wrongOut = wrongOut.carry(wrongOut.next!);
        guard++;
      }
      expect(wrongOut.walks, greaterThan(4));
      expect(wrongOut.isDone, isFalse);
      expect(wrongOut.gaveUp, isTrue);
    });

    test('the three walks ask cannot be landed, however it is played', () {
      var runs = 0;
      void walkOut(Play play) {
        if (play.finished) {
          runs++;
          expect(play.isDone, isFalse);
          expect(play.walks, greaterThanOrEqualTo(4));
          return;
        }
        for (var slot = 0; slot < play.bench.length; slot++) {
          walkOut(play.carry(slot));
        }
      }

      walkOut(Play.of(Levels.at(4)));
      expect(runs, 8);
    });

    test('the why tells Belady and the anomaly', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('Laszlo Belady'));
      expect(words, contains('1966'));
      expect(words, contains('1969'));
      expect(words, contains('This is ask 5, The Three Walks.'));
      expect(words, contains('worked in full'));
    });
  });
}
