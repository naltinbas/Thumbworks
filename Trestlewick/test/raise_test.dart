import 'package:flutter_test/flutter_test.dart';
import 'package:trestlewick/raise/fewest.dart';
import 'package:trestlewick/raise/frame.dart';
import 'package:trestlewick/raise/frames.dart';
import 'package:trestlewick/raise/play.dart';

Frame _ladder(int rungs, int crews) => Frame(
      name: 'ladder',
      crews: crews,
      days: rungs,
      timbers: [
        for (var rung = 0; rung < rungs; rung++)
          Timber('$rung', 0.2, 0.9 - rung * 0.1, 0.8, 0.9 - rung * 0.1),
      ],
      rests: [
        for (var rung = 0; rung < rungs; rung++)
          if (rung == 0) <int>{} else {rung - 1},
      ],
    );

Frame _heap(int timbers, int crews) => Frame(
      name: 'heap',
      crews: crews,
      days: 0,
      timbers: [
        for (var timber = 0; timber < timbers; timber++)
          Timber('$timber', 0.1, 0.5, 0.9, 0.5),
      ],
      rests: [for (var timber = 0; timber < timbers; timber++) <int>{}],
    );

void main() {
  group('the frame', () {
    final frame = Frames.at(0);

    test('nothing can go up before what it rests on', () {
      expect(frame.readyFrom(0), [0]);
      expect(frame.readyFrom(1), [1, 2]);
      expect(frame.waitingOn(3, 1), [1, 2]);
      expect(frame.waitingOn(3, 1 | 2 | 4), isEmpty);
    });

    test('and every frame that ships stands up', () {
      for (var number = 0; number < Frames.count; number++) {
        expect(Frames.at(number).isSound, isTrue,
            reason: Frames.at(number).name);
      }
    });

    test('a frame that rests on itself does not', () {
      final silly = Frame(
        name: 'silly',
        crews: 1,
        days: 0,
        timbers: const [
          Timber('a', 0, 0, 1, 0),
          Timber('b', 0, 1, 1, 1),
        ],
        rests: const [
          {1},
          {0},
        ],
      );
      expect(silly.isSound, isFalse);
    });
  });

  group('the floors', () {
    test('a ladder takes as many days as it has rungs, however many crews', () {
      for (final crews in const [1, 2, 5]) {
        final raising = Raisings.forFrame(_ladder(6, crews));
        expect(raising.days, 6, reason: '$crews crews');
        expect(raising.chain, hasLength(6));
        expect(raising.chainIsTight, isTrue);
      }
    });

    test('a heap takes the work divided by the crews, rounded up', () {
      expect(Raisings.forFrame(_heap(7, 2)).days, 4);
      expect(Raisings.forFrame(_heap(7, 2)).byWork, 4);
      expect(Raisings.forFrame(_heap(7, 2)).workIsTight, isTrue);
      expect(Raisings.forFrame(_heap(7, 3)).days, 3);
      expect(Raisings.forFrame(_heap(9, 3)).days, 3);
    });

    test('and neither floor is ever above the answer', () {
      for (var number = 0; number < Frames.count; number++) {
        final raising = Raisings.forFrame(Frames.at(number));
        expect(raising.chain.length, lessThanOrEqualTo(raising.days),
            reason: Frames.at(number).name);
        expect(raising.byWork, lessThanOrEqualTo(raising.days),
            reason: Frames.at(number).name);
      }
    });

    test('the longest run really is a run', () {
      for (var number = 0; number < Frames.count; number++) {
        final frame = Frames.at(number);
        final chain = Raisings.longestChain(frame);
        for (var at = 1; at < chain.length; at++) {
          expect(frame.rests[chain[at]], contains(chain[at - 1]),
              reason: '${frame.name}: ${chain[at]} does not rest on '
                  '${chain[at - 1]}');
        }
      }
    });
  });

  group('the way it lays out', () {
    for (var number = 0; number < Frames.count; number++) {
      final frame = Frames.at(number);

      test('${frame.name} really can be raised that way', () {
        final raising = Raisings.forFrame(frame);
        expect(raising.eachDay, hasLength(raising.days));

        var standing = 0;
        for (final day in raising.eachDay) {
          expect(day.length, lessThanOrEqualTo(frame.crews),
              reason: '${frame.name}: too many in a day');
          for (final timber in day) {
            expect(frame.waitingOn(timber, standing), isEmpty,
                reason: '${frame.name}: ${frame.timbers[timber].name} went up '
                    'before what it rests on');
          }
          for (final timber in day) {
            standing |= 1 << timber;
          }
        }
        expect(standing, frame.whole, reason: frame.name);
      });
    }
  });

  group('every frame that ships', () {
    setUp(Frames.forget);

    for (var number = 0; number < Frames.count; number++) {
      final frame = Frames.at(number);

      test('${frame.name} says the number the working out says', () {
        expect(Raisings.forFrame(frame).days, frame.days);
      });

      test('${frame.name} carries a floor that proves it', () {
        final raising = Raisings.forFrame(frame);
        expect(raising.floorSaysSo, isTrue,
            reason: '${frame.name}: the run is ${raising.chain.length} and the '
                'work is ${raising.byWork}, against ${raising.days} days');
      });

      test('${frame.name} has timbers that are named and lie on the site', () {
        expect(frame.timbers.map((timber) => timber.name).toSet(),
            hasLength(frame.count));
        for (final timber in frame.timbers) {
          for (final at in [timber.fromX, timber.fromY, timber.toX,
              timber.toY]) {
            expect(at, inInclusiveRange(0.02, 0.98));
          }
        }
      });
    }

    test('and on three of them, raising in the order written costs a day', () {
      final costly = [
        for (var number = 0; number < Frames.count; number++)
          if (Raisings.byOrder(Frames.at(number)) > Frames.at(number).days)
            Frames.at(number).name,
      ];
      expect(costly, hasLength(3));
    });
  });

  group('raising one', () {
    late Play play;

    setUp(() {
      Frames.forget();
      play = Play.of(Frames.at(1), Frames.raiserFor(1), Frames.raisingFor(1));
    });

    test('starts on an empty site', () {
      expect(play.day, 0);
      expect(play.standing, 0);
      expect(play.today, isEmpty);
      expect(play.couldFinishIn, play.answer.days);
    });

    test('only the sill is ready on the first day', () {
      expect(play.ready, [0]);
      expect(play.isReady(1), isFalse);
    });

    test('putting a timber to the crews and taking it off again', () {
      expect(play.put(0).today, {0});
      expect(play.put(0).put(0).today, isEmpty);
    });

    test('a timber that is not ready cannot be put to anybody', () {
      expect(identical(play.put(1), play), isTrue);
    });

    test('and no more can be put on than there are crews', () {
      var walk = play.put(0).raise();
      walk = walk.put(1).put(2).put(3);
      expect(walk.today, hasLength(2));
    });

    test('raising ends the day and puts them up', () {
      play = play.put(0).raise();
      expect(play.day, 1);
      expect(play.isUp(0), isTrue);
      expect(play.today, isEmpty);
    });

    test('it says when a day has been wasted', () {
      // Two crews idle on the first day is a day gone that nothing gets back.
      final slow = Play.of(
        Frames.at(3),
        Frames.raiserFor(3),
        Frames.raisingFor(3),
      );
      expect(slow.couldFinishIn, Frames.at(3).days);
      final after = slow.put(0).raise().put(1).raise();
      expect(after.couldFinishIn, greaterThan(Frames.at(3).days));
    });

    test('again clears the site', () {
      play = play.put(0).raise().again;
      expect(play.day, 0);
      expect(play.standing, 0);
    });

    test('show me raises every frame in the fewest days there are', () {
      for (var number = 0; number < Frames.count; number++) {
        final frame = Frames.at(number);
        var walk = Play.of(
          frame,
          Frames.raiserFor(number),
          Frames.raisingFor(number),
        );
        var guard = 0;
        while (!walk.isDone) {
          if (guard++ > 30) fail('${frame.name} never went up');
          for (final timber in walk.next) {
            walk = walk.put(timber);
          }
          walk = walk.raise();
        }
        expect(walk.day, frame.days, reason: frame.name);
        expect(walk.isFewest, isTrue, reason: frame.name);
      }
    });
  });
}
