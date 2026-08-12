import 'package:flutter_test/flutter_test.dart';
import 'package:quirebeck/quire/play.dart';
import 'package:quirebeck/quire/quires.dart';
import 'package:quirebeck/quire/rules.dart';

void main() {
  const bound8 = [0, 1, 2, 3, 4, 5, 6, 7];

  group('the weaves', () {
    test('the out-weave keeps the first leaf and the in buries it',
        () {
      expect(Rules.weaveOut(bound8), [0, 4, 1, 5, 2, 6, 3, 7]);
      expect(Rules.weaveIn(bound8), [4, 0, 5, 1, 6, 2, 7, 3]);
    });

    test('the seat words read the seat in binary', () {
      expect(Rules.seatWord(0), isEmpty);
      expect(Rules.seatWord(1), [true]);
      expect(Rules.seatWord(4), [true, false, false]);
      expect(Rules.seatWord(6), [true, true, false]);
      expect(Rules.seatWord(11), [true, false, true, true]);
    });

    test(
        'the word and the walk agree on every seat of eight leaves '
        'and of sixteen', () {
      for (final leaves in const [8, 16]) {
        final bound = [for (var at = 0; at < leaves; at++) at];
        for (var seat = 0; seat < leaves; seat++) {
          final word = Rules.seatWord(seat);
          var stack = bound;
          for (final inward in word) {
            stack = Rules.weave(stack, inward);
          }
          expect(stack[seat], 0, reason: 'seat $seat of $leaves');
          expect(
            Rules.fewest(bound, (stack) => stack[seat] == 0),
            word.length,
            reason: 'seat $seat of $leaves',
          );
        }
      }
    });

    test('both weaves are even and a turned pair is odd', () {
      for (final leaves in const [8, 16]) {
        final bound = [for (var at = 0; at < leaves; at++) at];
        expect(Rules.isEven(Rules.weaveOut(bound)), isTrue);
        expect(Rules.isEven(Rules.weaveIn(bound)), isTrue);
      }
      expect(Rules.isEven(Quires.at(5).start), isFalse);
    });

    test(
        'a quire of eight reaches twenty-four stacks and the turned '
        'pair is none of them', () {
      final world = Rules.orbit(bound8);
      expect(world, hasLength(24));
      expect(world.containsKey(Quires.at(5).start.join(',')), isFalse);
    });

    test('coming round: the walk and the figures agree, pack '
        'included', () {
      for (final leaves in const [8, 16, 52]) {
        expect(Rules.comeRound(leaves),
            Rules.comeRoundByFigures(leaves));
      }
      expect(Rules.comeRound(8), 3);
      expect(Rules.comeRound(16), 4);
      expect(Rules.comeRound(52), 8);
    });
  });

  group('the quires that ship', () {
    for (final quire in Quires.all) {
      test(quire.name, () {
        final walked = Rules.fewest(quire.start, quire.isDone);
        expect(walked == -1, !quire.winnable);
        if (quire.winnable) expect(walked, quire.weaves);
      });
    }

    test('the broken stitch is beyond the outs alone', () {
      var stack = Quires.at(4).start;
      for (var round = 0; round < 3; round++) {
        stack = Rules.weaveOut(stack);
        expect(Quires.at(4).isDone(stack), isFalse);
      }
      expect(stack, Quires.at(4).start);
    });

    test('no stack of the turned pair\'s weaving is ever bound', () {
      final world = Rules.orbit(Quires.at(5).start);
      expect(world, hasLength(24));
      for (final key in world.keys) {
        final stack = key.split(',').map(int.parse).toList();
        expect(Quires.at(5).isDone(stack), isFalse, reason: key);
      }
    });
  });

  group('a play', () {
    test('opens at the off with nothing woven', () {
      final play = Play.of(Quires.at(1));
      expect(play.stack, Quires.at(1).start);
      expect(play.weaves, 0);
      expect(play.plateAt, 0);
      expect(play.isOver, isFalse);
    });

    test('one in-weave settles the second leaf', () {
      final play = Play.of(Quires.at(0)).step(true);
      expect(play.isDone, isTrue);
      expect(play.weaves, 1);
      expect(play.plateAt, 1);
    });

    test('back unweaves', () {
      final play = Play.of(Quires.at(1)).step(true).step(false);
      expect(play.weaves, 2);
      expect(play.back.weaves, 1);
      expect(play.back.back.stack, Quires.at(1).start);
    });

    test('following the pointer settles every winnable quire in its '
        'written weaves', () {
      for (final quire in Quires.all.where((quire) => quire.winnable)) {
        var play = Play.of(quire);
        var guard = 0;
        while (!play.isDone) {
          if (guard++ > 8) fail('${quire.name} never settled');
          play = play.step(play.next!);
        }
        expect(play.weaves, quire.weaves, reason: quire.name);
      }
    });

    test('a wandered weave fails to shorten the task', () {
      final play = Play.of(Quires.at(1));
      final could = play.toDone;
      // Found, not guessed: the weave the walk does not take.
      final wander = !play.next!;
      final woven = play.step(wander);
      expect(woven.toDone, greaterThanOrEqualTo(could));
    });

    test('the turned pair gives up at the line', () {
      var play = Play.of(Quires.at(5));
      expect(play.toDone, -1);
      var weave = false;
      while (!play.isOver) {
        play = play.step(weave);
        weave = !weave;
        expect(play.weaves, lessThanOrEqualTo(Play.gaveUpAt));
      }
      expect(play.gaveUp, isTrue);
      expect(play.isDone, isFalse);
      expect(play.next, isNull);
    });
  });
}
