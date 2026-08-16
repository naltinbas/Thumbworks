import 'package:flutter_test/flutter_test.dart';
import 'package:trebleworth/heap/levels.dart';
import 'package:trebleworth/heap/play.dart';
import 'package:trebleworth/heap/rules.dart';

/// The heaps, the odd squares, the asks and the play, checked at the
/// domain: nothing here touches a widget.
void main() {
  group('the heaps', () {
    test('triangles, heaps and odd squares', () {
      expect(Rules.triangles.take(6).toList(), [0, 1, 3, 6, 10, 15]);
      expect(Rules.isTriangular(21), isTrue);
      expect(Rules.isTriangular(20), isFalse);
      expect(Rules.heaps(20, 3), [
        [0, 10, 10]
      ]);
      expect(Rules.heaps(47, 3), hasLength(2));
      expect(Rules.heaps(100, 3), hasLength(6));
      expect(Rules.heaps(5, 2), isEmpty);
      expect(Rules.heaps(5, 3), [
        [1, 1, 3]
      ]);
      expect(Rules.heaps(12, 2), [
        [6, 6]
      ]);
      expect(Rules.oddSquares(20), [
        [1, 9, 9]
      ]);
      expect(Rules.oddSquares(5), [
        [3, 3, 5]
      ]);
      expect(Rules.told([0, 10, 10]), '10 + 10 + 0');
      for (var n = 0; n <= 500; n++) {
        expect(Rules.heaps(n, 3), isNotEmpty, reason: '$n');
        expect(Rules.heaps(n, 3).length, Rules.oddSquares(n).length, reason: '$n');
      }
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The Five']);
      for (final level in Levels.all) {
        expect(Rules.heaps(level.number, level.slots).length, level.ways, reason: level.name);
        final aim = level.aim;
        if (aim != null) expect(level.meets(List<int?>.of(aim)), isTrue, reason: level.name);
        if (!level.winnable) expect(aim, isNull);
      }
      expect(Levels.at(0).shelf, [0, 1, 3, 6, 10, 15]);
      expect(Levels.at(4).shelf, [0, 1, 3]);
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'make 20 by adding three triangular numbers, nought allowed');
      expect(Levels.at(3).task, 'make 12 by adding two triangular numbers, nought allowed');
    });

    test('an ask is met by full slots that add up', () {
      expect(Levels.at(0).meets([10, 0, 10]), isTrue);
      expect(Levels.at(0).meets([10, 10, null]), isFalse);
      expect(Levels.at(0).meets([10, 6, 3]), isFalse);
      expect(Levels.at(3).meets([6, 6]), isTrue);
      expect(Levels.at(4).meets([3, 3]), isFalse);
    });
  });

  group('the play', () {
    test('opens with the slots empty', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.slots, List<int?>.filled(level.slots, null));
        expect((play.sum, play.moves), (0, 0));
        expect(play.isOver, isFalse, reason: level.name);
      }
    });

    test('a take fills the next slot, a drop empties one, and the shelf is the limit', () {
      var play = Play.of(Levels.at(0)).take(10);
      expect(play.slots, [10, null, null]);
      expect(play.moves, 1);
      play = play.take(6).take(3);
      expect(play.slots, [10, 6, 3]);
      expect(play.isFull, isTrue);
      expect(play.take(1), same(play));
      expect(play.take(21), same(play));
      play = play.drop(1);
      expect(play.slots, [10, null, 3]);
      expect(play.moves, 4);
      expect(play.drop(1), same(play));
      play = play.take(0);
      expect(play.slots, [10, 0, 3]);
    });

    test('back undoes one tap', () {
      final play = Play.of(Levels.at(0)).take(10).take(10);
      expect(play.back.slots, [10, null, null]);
      expect(play.back.back.slots, [null, null, null]);
    });

    test('the twenty lands, and it takes no more taps', () {
      final play = Play.of(Levels.at(0)).take(10).take(0).take(10);
      expect(play.isDone, isTrue);
      expect(play.take(1), same(play));
      expect(play.drop(0), same(play));
    });

    test('the pointer takes the aim and drops strays', () {
      var play = Play.of(Levels.at(1));
      expect(play.next, (Aim.shelf, 1));
      play = play.take(45);
      expect(play.next, (Aim.shelf, 1));
      play = play.take(6);
      expect(play.next, (Aim.slot, 1));
      play = play.drop(1).take(1).take(1);
      expect(play.isDone, isTrue);
      expect(play.next, isNull);
      expect(Play.pointed((Aim.shelf, 45)), 'Take 45 from the shelf.');
      expect(Play.pointed((Aim.slot, 1)), 'Empty the ringed slot.');
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('following the pointer heaps every winnable ask', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var steps = 0;
        while (!play.isDone && steps < 12) {
          final (aim, what) = play.next!;
          play = aim == Aim.shelf ? play.take(what) : play.drop(what);
          steps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
        expect(play.moves, level.slots, reason: level.name);
      }
    });

    test('the five admits it at four or six from two heaps, or after twenty taps', () {
      var play = Play.of(Levels.at(4)).take(1).take(1);
      expect(play.gaveUp, isFalse);
      play = play.drop(0).take(3);
      expect(play.slots, [3, 1]);
      expect(play.sum, 4);
      expect(play.gaveUp, isTrue);
      expect(play.next, isNull);
      var wander = Play.of(Levels.at(4));
      for (var k = 0; k < 20; k++) {
        wander = wander.take(0).drop(0);
      }
      expect(wander.gaveUp, isTrue);
    });

    test('the why tells Gauss and the sweep', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('Eureka'));
      expect(words, contains('This is ask 5, The Five.'));
      expect(words, contains('tried in full'));
    });
  });
}
