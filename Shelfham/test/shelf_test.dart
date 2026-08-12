import 'package:flutter_test/flutter_test.dart';
import 'package:shelfham/shelf/play.dart';
import 'package:shelfham/shelf/rules.dart';
import 'package:shelfham/shelf/shelves.dart';

/// The law of the shelf, held to.
void main() {
  group('the rules', () {
    test('steps down sit where a book beats its neighbour', () {
      expect(Rules.stepsDown([0, 1, 2, 3]), isEmpty);
      expect(Rules.stepsDown([3, 2, 1, 0]), [0, 1, 2]);
      expect(Rules.stepsDown([1, 0, 2, 3]), [0]);
      expect(Rules.stepsDown([0, 2, 1, 3]), [1]);
    });

    test('the sweep matches the recurrence at every size', () {
      for (final books in [4, 5]) {
        final rules = Rules(books);
        for (var steps = 0; steps < books; steps++) {
          expect(rules.waysTo(steps), Rules.eulerian(books, steps),
              reason: '$books, $steps');
        }
      }
    });

    test('every label\'s ways is what the sweep finds', () {
      for (final shelf in Shelves.all) {
        expect(Rules(shelf.books).waysTo(shelf.asked), shelf.ways,
            reason: shelf.name);
      }
    });

    test('the reversal pairs steps with the gaps left over', () {
      for (final books in [4, 5]) {
        expect(Rules(books).reversalPairs(), isTrue,
            reason: '$books');
      }
    });

    test('the rows read the same both ways', () {
      final four = Rules(4);
      expect(four.waysTo(0), four.waysTo(3));
      expect(four.waysTo(1), four.waysTo(2));
      final five = Rules(5);
      expect(five.waysTo(1), five.waysTo(3));
    });

    test('an ordering lands what it promises', () {
      final found = Rules(4).ordering(3)!;
      expect(found, [3, 2, 1, 0]);
      expect(Rules(4).ordering(4), isNull);
    });
  });

  group('the play', () {
    test('the shelf opens sorted and unlanded', () {
      final play = Play.of(Shelves.at(0));
      expect(play.order, [0, 1, 2, 3]);
      expect(play.stepsDown, isEmpty);
      expect(play.isDone, isFalse);
    });

    test('two picks swap two books', () {
      var play = Play.of(Shelves.at(0));
      play = play.tapAt(0);
      expect(play.picked, 0);
      play = play.tapAt(1);
      expect(play.order, [1, 0, 2, 3]);
      expect(play.moves, 1);
    });

    test('picking a place twice lets it go', () {
      var play = Play.of(Shelves.at(0)).tapAt(2);
      play = play.tapAt(2);
      expect(play.picked, isNull);
      expect(play.moves, 0);
    });

    test('one swap lands the one step', () {
      final play = Play.of(Shelves.at(0)).tapAt(0).tapAt(1);
      expect(play.stepsDown, [0]);
      expect(play.isDone, isTrue);
      expect(play.tapAt(2), same(play));
    });

    test('the stair down lands on the full reverse', () {
      var play = Play.of(Shelves.at(1));
      play = play.tapAt(0).tapAt(3);
      play = play.tapAt(1).tapAt(2);
      expect(play.order, [3, 2, 1, 0]);
      expect(play.stepsDown, hasLength(3));
      expect(play.isDone, isTrue);
      expect(play.moves, 2);
    });

    test('back takes back a swap', () {
      var play = Play.of(Shelves.at(1)).tapAt(0).tapAt(1);
      expect(play.moves, 1);
      expect(play.back.order, [0, 1, 2, 3]);
      expect(play.back.moves, 0);
      expect(Play.of(Shelves.at(1)).back.moves, 0);
    });

    test('show me walks the shelf to its asking', () {
      var play = Play.of(Shelves.at(2));
      var guard = 0;
      while (!play.isDone && guard++ < 12) {
        final aim = play.next;
        expect(aim, isNotNull);
        final (place, book) = aim!;
        final at = play.order.indexOf(book);
        play = play.tapAt(place).tapAt(at);
      }
      expect(play.isDone, isTrue);
      expect(play.stepsDown, hasLength(2));
    });

    test('the hopeless shelf has nothing to point at', () {
      expect(Play.of(Shelves.at(4)).next, isNull);
    });

    test('the hopeless shelf admits it after twelve swaps', () {
      var play = Play.of(Shelves.at(4));
      for (var swap = 0; swap < Play.gaveUpAt; swap++) {
        expect(play.gaveUp, isFalse);
        play = play.tapAt(0).tapAt(1);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.isDone, isFalse);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
    });

    test('a winnable shelf never gives up', () {
      // The sixty-six asks two steps; swapping the same pair
      // forever gives one step, never two.
      var play = Play.of(Shelves.at(2));
      for (var swap = 0; swap < Play.gaveUpAt; swap++) {
        play = play.tapAt(0).tapAt(1);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.gaveUp, isFalse);
    });
  });
}
