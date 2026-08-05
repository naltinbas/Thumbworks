import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:weirbank/flow/most.dart';
import 'package:weirbank/flow/play.dart';
import 'package:weirbank/flow/works.dart';
import 'package:weirbank/flow/works_list.dart';

/// A works of a size, with pipes and amounts made up.
Works _scatter(Random dice, int ponds) {
  final pipes = <Pipe>[];
  for (var from = 0; from < ponds; from++) {
    for (var to = from + 1; to < ponds; to++) {
      if (dice.nextInt(100) < 45) pipes.add(Pipe(from, to, 1 + dice.nextInt(6)));
    }
  }
  return Works(
    ponds: [for (var i = 0; i < ponds; i++) Pond('$i', 0, 0)],
    pipes: pipes,
  );
}

void main() {
  group('a works', () {
    test('knows which pipes leave a pond and which arrive', () {
      final works = Works(
        ponds: const [Pond('a', 0, 0), Pond('b', 0, 0), Pond('c', 0, 0)],
        pipes: const [Pipe(0, 1, 2), Pipe(1, 2, 3), Pipe(0, 2, 1)],
      );
      expect(works.out(0), [0, 2]);
      expect(works.into(2), [1, 2]);
      expect(works.into(0), isEmpty);
      expect(works.isJoined, isTrue);
    });

    test('and says when nothing can reach the mill at all', () {
      expect(
        Works(
          ponds: const [Pond('a', 0, 0), Pond('b', 0, 0), Pond('c', 0, 0)],
          pipes: const [Pipe(0, 1, 2)],
        ).isJoined,
        isFalse,
      );
    });
  });

  group('the most that gets through', () {
    test('is what the tightest pipe takes, down one line', () {
      final works = Works(
        ponds: const [Pond('a', 0, 0), Pond('b', 0, 0), Pond('c', 0, 0)],
        pipes: const [Pipe(0, 1, 5), Pipe(1, 2, 2)],
      );
      final most = Flow(works).work();

      expect(most.amount, 2);
      expect(most.down, [2, 2]);
      expect(most.cut, [1]);
    });

    test('and adds up when there are two ways round', () {
      final works = Works(
        ponds: const [
          Pond('a', 0, 0),
          Pond('b', 0, 0),
          Pond('c', 0, 0),
          Pond('d', 0, 0),
        ],
        pipes: const [
          Pipe(0, 1, 3),
          Pipe(0, 2, 2),
          Pipe(1, 3, 3),
          Pipe(2, 3, 2),
        ],
      );
      expect(Flow(works).work().amount, 5);
    });

    test('and sends water back where a first choice was wrong', () {
      // The works everybody uses to show why a way back is needed. Fill the
      // middle pipe first and a search that cannot undo it answers 1; the
      // answer is 2.
      final works = Works(
        ponds: const [
          Pond('a', 0, 0),
          Pond('b', 0, 0),
          Pond('c', 0, 0),
          Pond('d', 0, 0),
        ],
        pipes: const [
          Pipe(0, 1, 1),
          Pipe(0, 2, 1),
          Pipe(1, 2, 1),
          Pipe(1, 3, 1),
          Pipe(2, 3, 1),
        ],
      );
      expect(Flow(works).work().amount, 2);
    });

    test('and is nothing at all when the mill cannot be reached', () {
      final works = Works(
        ponds: const [Pond('a', 0, 0), Pond('b', 0, 0), Pond('c', 0, 0)],
        pipes: const [Pipe(0, 1, 4)],
      );
      final most = Flow(works).work();
      expect(most.amount, 0);
      expect(most.cut, isEmpty);
    });
  });

  group('the cut', () {
    test('holds exactly what gets through, on every shipped works', () {
      // Ford and Fulkerson, 1956, made checkable: the amount that can be sent
      // and the amount the smallest cut holds are the same number. One says
      // this much can be done and the other says no more can.
      for (var i = 0; i < Waterworks.count; i++) {
        final one = Waterworks.at(i);
        final works = one.works;
        final most = Flow(works).work();

        expect(most.holdsOfCut(works), most.amount, reason: one.name);
      }
    });

    test('and on three hundred works made up at random', () {
      final dice = Random(20260805);
      var checked = 0;
      var gotThrough = 0;

      while (checked < 300) {
        final works = _scatter(dice, 4 + dice.nextInt(4));
        if (!works.isJoined) continue;
        checked++;

        final most = Flow(works).work();
        expect(most.holdsOfCut(works), most.amount, reason: '${works.pipes}');
        if (most.amount > 0) gotThrough++;

        // And cutting those pipes really does leave no way through.
        final left = Works(
          ponds: works.ponds,
          pipes: [
            for (var pipe = 0; pipe < works.pipes.length; pipe++)
              if (most.cut.contains(pipe))
                Pipe(works.pipes[pipe].from, works.pipes[pipe].to, 0)
              else
                works.pipes[pipe],
          ],
        );
        expect(Flow(left).work().amount, 0, reason: 'the cut does not cut');
      }
      expect(gotThrough, greaterThan(200));
    });

    test('and every pipe of it is full', () {
      // Which is why it is the reason and not merely a coincidence: the
      // bottleneck is where the water is already as much as it can be.
      for (var i = 0; i < Waterworks.count; i++) {
        final works = Waterworks.at(i).works;
        final most = Flow(works).work();
        for (final pipe in most.cut) {
          expect(most.down[pipe], works.pipes[pipe].holds,
              reason: '${Waterworks.at(i).name}: pipe $pipe is not full');
        }
      }
    });
  });

  group('every works', () {
    test('has the target it says, and it is the most there is', () {
      for (var i = 0; i < Waterworks.count; i++) {
        final one = Waterworks.at(i);
        expect(Flow(one.works).work().amount, one.target, reason: one.name);
      }
    });

    test('and the water it sends really obeys the pipes and the ponds', () {
      for (var i = 0; i < Waterworks.count; i++) {
        final one = Waterworks.at(i);
        final works = one.works;
        final most = Flow(works).work();

        for (var pipe = 0; pipe < works.pipes.length; pipe++) {
          expect(most.down[pipe], inInclusiveRange(0, works.pipes[pipe].holds),
              reason: '${one.name}: pipe $pipe holds too much');
        }
        for (var pond = 0; pond < works.count; pond++) {
          if (pond == works.spring || pond == works.mill) continue;
          var into = 0;
          var out = 0;
          for (final pipe in works.into(pond)) {
            into += most.down[pipe];
          }
          for (final pipe in works.out(pond)) {
            out += most.down[pipe];
          }
          expect(into, out, reason: '${one.name}: pond $pond spills');
        }
      }
    });

    test('and the bottleneck is not simply the last pipe', () {
      // A works whose smallest cut is the one pipe into the mill is a works
      // with nothing to work out.
      for (var i = 1; i < Waterworks.count; i++) {
        final one = Waterworks.at(i);
        final works = one.works;
        final most = Flow(works).work();
        final lastOnly = most.cut.length == 1 &&
            works.pipes[most.cut.first].to == works.mill;
        expect(lastOnly, isFalse, reason: one.name);
      }
    });

    test('and they get bigger', () {
      var last = 0;
      for (var i = 0; i < Waterworks.count; i++) {
        expect(Waterworks.at(i).works.count, greaterThanOrEqualTo(last));
        last = Waterworks.at(i).works.count;
      }
    });
  });

  group('setting the pipes', () {
    Play start([int which = 2]) {
      final one = Waterworks.at(which);
      return Play.of(one.works, one.target);
    }

    test('begins with every pipe empty', () {
      final play = start();
      expect(play.down.every((down) => down == 0), isTrue);
      expect(play.leaving, 0);
      expect(play.arriving, 0);
      expect(play.holds, isTrue, reason: 'nothing anywhere adds up fine');
      expect(play.isDone, isFalse);
    });

    test('turns a pipe up one at a time and round to nothing', () {
      var play = start();
      final holds = play.works.pipes[0].holds;

      for (var turn = 1; turn <= holds; turn++) {
        play = play.turn(0);
        expect(play.downPipe(0), turn);
      }
      play = play.turn(0);
      expect(play.downPipe(0), 0, reason: 'and round again to nothing');
      expect(play.turns, holds + 1);
    });

    test('and empties one outright', () {
      final play = start().turn(0).turn(0);
      expect(play.downPipe(0), 2);
      expect(play.empty(0).downPipe(0), 0);
    });

    test('says which pond spills, and how much', () {
      final works = Waterworks.at(2).works;
      final play = Play.of(works, 6).turn(0);

      expect(play.spills, hasLength(1));
      expect(play.spills.first.pond, works.pipes[0].to);
      expect(play.spills.first.over, 1, reason: 'one arrives and none leaves');
      expect(play.holds, isFalse);
      expect(play.isDone, isFalse);
    });

    test('and is finished when the answer is set and the mill has its water',
        () {
      for (var which = 0; which < Waterworks.count; which++) {
        final one = Waterworks.at(which);
        var play = Play.of(one.works, one.target);
        final most = play.answer;

        for (var pipe = 0; pipe < one.works.pipes.length; pipe++) {
          for (var turn = 0; turn < most.down[pipe]; turn++) {
            play = play.turn(pipe);
          }
        }
        expect(play.holds, isTrue, reason: one.name);
        expect(play.arriving, one.target, reason: one.name);
        expect(play.leaving, one.target, reason: one.name);
        expect(play.isDone, isTrue, reason: one.name);
      }
    });

    test('and Again empties everything', () {
      final play = start().turn(0).turn(1);
      expect(play.again.down.every((down) => down == 0), isTrue);
      expect(play.again.turns, 0);
    });
  });
}
