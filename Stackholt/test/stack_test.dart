import 'package:flutter_test/flutter_test.dart';
import 'package:stackholt/stack/boxsets.dart';
import 'package:stackholt/stack/play.dart';
import 'package:stackholt/stack/rules.dart';

/// The law of the stack, held to.
void main() {
  group('the rules', () {
    test('a settled stack shows every paint once a wall', () {
      const stood = [
        ('R', 'G', 'B', 'W'),
        ('G', 'R', 'W', 'B'),
        ('B', 'W', 'R', 'G'),
        ('W', 'B', 'G', 'R'),
      ];
      expect(Rules.settled(stood), isTrue);
      const doubled = [
        ('R', 'G', 'B', 'W'),
        ('R', 'W', 'G', 'B'),
      ];
      expect(Rules.settled(doubled), isFalse);
    });

    test('every label\'s ways is what the sweep finds', () {
      for (final set in BoxSets.all) {
        expect(Rules.settlings(set.boxes), set.ways,
            reason: set.name);
      }
    });

    test('the old four: 24 settlings, 3 classes, 3 factorings', () {
      final old = BoxSets.at(3);
      expect(Rules.settlings(old.boxes), 24);
      expect(Rules.settlingClasses(old.boxes), 3);
      expect(Rules.fairPickCount(old.boxes), 5);
      expect(Rules.factorings(old.boxes), 3);
      expect(Rules.factors(old.boxes), isTrue);
    });

    test('the red stack is doomed by the count', () {
      final red = BoxSets.at(4);
      expect(Rules.facesWearing(red.boxes, 'R'), 13);
      expect(Rules.roomFor(4), 12);
      expect(Rules.settlings(red.boxes), 0);
      expect(Rules.factors(red.boxes), isFalse);
      expect(Rules.settling(red.boxes), isNull);
    });

    test('a settling extends to the walls it promises', () {
      for (final set in BoxSets.all.where((s) => s.winnable)) {
        final stood = Rules.settling(set.boxes)!;
        expect(Rules.settled(stood), isTrue, reason: set.name);
        expect(stood, hasLength(set.count));
      }
    });
  });

  group('the play', () {
    test('spins cycle a box\'s walls and count moves', () {
      var play = Play.of(BoxSets.at(3));
      final before = play.walls[0];
      play = play.spinAt(0);
      expect(play.moves, 1);
      expect(play.walls[0], isNot(before));
      play = play.spinAt(0).spinAt(0).spinAt(0);
      expect(play.walls[0], before);
      expect(play.moves, 4);
    });

    test('tips walk every turning of a box', () {
      var play = Play.of(BoxSets.at(3));
      final seen = <(String, String, String, String)>{play.walls[2]};
      for (var turn = 0; turn < 48; turn++) {
        var tipped = play.tipAt(2);
        for (var s = 0; s < 4; s++) {
          seen.add(tipped.walls[2]);
          tipped = tipped.spinAt(2);
        }
        play = play.tipAt(2);
      }
      expect(seen, containsAll(Rules.turnings(play.set.boxes[2])));
    });

    test('no stack opens settled, and the openings clash', () {
      for (final set in BoxSets.all) {
        final play = Play.of(set);
        expect(play.isDone, isFalse, reason: set.name);
        expect(play.clashes, isNotEmpty, reason: set.name);
      }
    });

    test('back takes back one turn', () {
      final play = Play.of(BoxSets.at(3)).spinAt(0).tipAt(1);
      expect(play.moves, 2);
      expect(play.back.moves, 1);
      expect(Play.of(BoxSets.at(3)).back.moves, 0);
    });

    test('show me points a box off the found settling', () {
      final play = Play.of(BoxSets.at(3));
      final aim = play.next;
      expect(aim, isNotNull);
      final (box, wants) = aim!;
      expect(play.walls[box], isNot(wants));
      expect(
        Rules.settling(play.set.boxes)![box],
        wants,
      );
    });

    test('the hopeless stack has nothing to point at', () {
      expect(Play.of(BoxSets.at(4)).next, isNull);
    });

    test('the hopeless stack admits it after sixteen turns', () {
      var play = Play.of(BoxSets.at(4));
      for (var turn = 0; turn < Play.gaveUpAt; turn++) {
        expect(play.gaveUp, isFalse);
        play = turn.isEven ? play.spinAt(0) : play.tipAt(1);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.isDone, isFalse);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.spinAt(0), same(play));
    });

    test('a winnable stack never gives up', () {
      var play = Play.of(BoxSets.at(3));
      for (var turn = 0; turn < Play.gaveUpAt; turn++) {
        play = play.spinAt(turn % 4);
      }
      // Sixteen turns that may or may not have settled: if some
      // wander settled it, the stack is over by winning, never by
      // giving up.
      expect(play.gaveUp, isFalse);
    });
  });
}
