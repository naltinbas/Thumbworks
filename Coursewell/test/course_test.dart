import 'package:coursewell/course/play.dart';
import 'package:coursewell/course/rules.dart';
import 'package:coursewell/course/yards.dart';
import 'package:flutter_test/flutter_test.dart';

/// The law of the yard, held to.
void main() {
  /// The 4x4 laying of rows only: two bricks to a course.
  const flatFour = [
    (0, 1), (2, 3), (4, 5), (6, 7),
    (8, 9), (10, 11), (12, 13), (14, 15),
  ];

  group('the rules', () {
    test('every label\'s ways is what the sweep finds', () {
      for (final yard in Yards.all) {
        expect(
          Rules(yard.width, yard.height).waysTo(yard.asked),
          yard.ways,
          reason: yard.name,
        );
      }
    });

    test('the whole counts stand where they were pinned', () {
      expect(Rules(4, 4).waysTo(null), 36);
      expect(Rules(6, 5).waysTo(null), 1183);
      expect(Rules(6, 6).waysTo(null), 6728);
    });

    test('seams read straight off a laying', () {
      // Rows only on the four-square: the bricks cross the
      // first and third upright lines and nothing else, so the
      // middle upright and all three lying lines run free.
      final seams = Rules(4, 4).seams(flatFour);
      expect(seams, hasLength(4));
      expect(seams, contains((true, 2)));
      expect(seams, isNot(contains((true, 1))));
      expect(seams, containsAll(const [(false, 1), (false, 2), (false, 3)]));
    });

    test('bricked demands the whole yard', () {
      final rules = Rules(4, 4);
      expect(rules.bricked(flatFour), isTrue);
      expect(rules.bricked(flatFour.sublist(1)), isFalse);
    });

    test('crossings come in pairs on every full four-square laying',
        () {
      final rules = Rules(4, 4);
      var layings = 0;
      rules.layings((laying) {
        layings++;
        final upright = List.filled(4, 0);
        final level = List.filled(4, 0);
        for (final (a, b) in laying) {
          if (b - a == 1) {
            upright[b % 4]++;
          } else {
            level[b ~/ 4]++;
          }
        }
        for (var line = 1; line < 4; line++) {
          expect(upright[line].isEven, isTrue);
          expect(level[line].isEven, isTrue);
        }
      });
      expect(layings, 36);
    });

    test('no yard below thirty cells lays sound', () {
      for (var w = 2; w * w < 30; w++) {
        for (var h = w; w * h < 30; h++) {
          if ((w * h).isOdd) continue;
          expect(Rules(w, h).waysTo(0), 0, reason: '$w by $h');
        }
      }
    });

    test('the two seven-seam layings are the plain stacks', () {
      final rules = Rules(6, 6);
      final stacks = <List<(int, int)>>[];
      rules.layings((laying) {
        if (rules.seams(laying).length == 7) {
          stacks.add(List.of(laying));
        }
      });
      expect(stacks, hasLength(2));
      for (final stack in stacks) {
        final lying = stack.every((brick) => brick.$2 - brick.$1 == 1);
        final upright =
            stack.every((brick) => brick.$2 - brick.$1 == 6);
        expect(lying || upright, isTrue);
      }
      expect(
        stacks.where((stack) => stack.first.$2 - stack.first.$1 == 1),
        hasLength(1),
      );
    });

    test('a laying to an asking is real and lands it', () {
      final rules = Rules(6, 5);
      final sound = rules.laying(0);
      expect(sound, isNotNull);
      expect(rules.bricked(sound!), isTrue);
      expect(rules.seams(sound), isEmpty);
      expect(Rules(6, 6).laying(0), isNull);
    });
  });

  group('the play', () {
    test('opens empty and unsettled on every yard', () {
      for (final yard in Yards.all) {
        final play = Play.of(yard);
        expect(play.laid, isEmpty, reason: yard.name);
        expect(play.isDone, isFalse, reason: yard.name);
        expect(play.isOver, isFalse, reason: yard.name);
      }
    });

    test('picks a cell, then bricks over to its neighbour', () {
      var play = Play.of(Yards.at(0)).tapAt(0);
      expect(play.picked, 0);
      expect(play.moves, 0);
      play = play.tapAt(1);
      expect(play.laid, [(0, 1)]);
      expect(play.picked, isNull);
      expect(play.moves, 1);
    });

    test('the same cell twice unpicks without a move', () {
      final play = Play.of(Yards.at(0)).tapAt(5).tapAt(5);
      expect(play.picked, isNull);
      expect(play.moves, 0);
    });

    test('cells apart refuse to carry one brick', () {
      // 0 and 2 sit in one course with a cell between; 0 and 5
      // sit corner to corner.
      var play = Play.of(Yards.at(0)).tapAt(0).tapAt(2);
      expect(play.laid, isEmpty);
      expect(play.picked, isNull);
      play = Play.of(Yards.at(0)).tapAt(0).tapAt(5);
      expect(play.laid, isEmpty);
    });

    test('a covered cell takes no second brick', () {
      final play =
          Play.of(Yards.at(0)).tapAt(0).tapAt(1).tapAt(1).tapAt(5);
      expect(play.laid, [(0, 1)]);
      expect(play.moves, 1);
    });

    test('the laid brick lifts from its own two cells', () {
      final play =
          Play.of(Yards.at(0)).tapAt(0).tapAt(1).tapAt(1).tapAt(0);
      expect(play.laid, isEmpty);
      expect(play.moves, 2);
    });

    test('back takes back one laying', () {
      final play = Play.of(Yards.at(0)).tapAt(0).tapAt(1);
      expect(play.back.laid, isEmpty);
      expect(play.back.moves, 0);
      expect(play.back.back.laid, isEmpty);
    });

    test('rows only land the four-square with its four seams', () {
      var play = Play.of(Yards.at(0));
      for (var brick = 0; brick < 8; brick++) {
        play = play.tapAt(brick * 2).tapAt(brick * 2 + 1);
      }
      expect(play.isDone, isTrue);
      expect(play.isOver, isTrue);
      expect(play.seams, hasLength(4));
      expect(play.moves, 8);
      // A landed yard refuses further taps.
      expect(play.tapAt(0), same(play));
    });

    test('the pointer lays the sound course home', () {
      var play = Play.of(Yards.at(2));
      var guard = 0;
      while (!play.isDone && guard++ < 20) {
        final (brick, lay) = play.next!;
        expect(lay, isTrue);
        play = play.tapAt(brick.$1).tapAt(brick.$2);
      }
      expect(play.isDone, isTrue);
      expect(play.seams, isEmpty);
      expect(play.moves, 15);
    });

    test('bricked wrong is not done, and the pointer mends it', () {
      // Rows only on the six-square wear seven seams; the One
      // Seam yard asks one.
      var play = Play.of(Yards.at(1));
      for (var brick = 0; brick < 18; brick++) {
        play = play.tapAt(brick * 2).tapAt(brick * 2 + 1);
      }
      expect(play.bricked, isTrue);
      expect(play.seams, hasLength(7));
      expect(play.isDone, isFalse);
      final (_, lay) = play.next!;
      expect(lay, isFalse);
    });

    test('the hopeless yard admits it at eighteen moves', () {
      var play = Play.of(Yards.at(4));
      for (var dither = 0; dither < 9; dither++) {
        play = play.tapAt(0).tapAt(1).tapAt(1).tapAt(0);
      }
      expect(play.moves, Play.gaveUpAt);
      expect(play.isDone, isFalse);
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.next, isNull);
    });

    test('a winnable yard never gives up', () {
      var play = Play.of(Yards.at(0));
      for (var dither = 0; dither < 9; dither++) {
        play = play.tapAt(0).tapAt(1).tapAt(1).tapAt(0);
      }
      expect(play.moves, 18);
      expect(play.gaveUp, isFalse);
      expect(play.isOver, isFalse);
    });
  });
}
