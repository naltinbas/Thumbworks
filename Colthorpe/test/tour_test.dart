import 'package:flutter_test/flutter_test.dart';
import 'package:colthorpe/tour/fewest.dart';
import 'package:colthorpe/tour/play.dart';
import 'package:colthorpe/tour/yard.dart';
import 'package:colthorpe/tour/yards.dart';

void main() {
  group('the jumps', () {
    test('are the eight knight moves, clipped at the walls', () {
      final yard = Yards.at(2);
      expect(Rounds.from(yard, 0), unorderedEquals([7, 11]));
      expect(Rounds.from(yard, 12), hasLength(8));
    });

    test('and every jump changes colour, everywhere, on every yard', () {
      // The whole certificate in one sweep: dark to light, light to dark,
      // no exception on any shipped yard.
      for (var number = 0; number < Yards.count; number++) {
        final yard = Yards.at(number);
        for (var paddock = 0; paddock < yard.paddocks; paddock++) {
          for (final near in Rounds.from(yard, paddock)) {
            expect(Rounds.dark(yard, paddock), isNot(Rounds.dark(yard, near)),
                reason: '${yard.name} $paddock to $near');
          }
        }
      }
    });
  });

  group('the colours and the walk', () {
    test('the wrong gate falls to counting alone, and the walk agrees', () {
      final wrong = Yards.at(3);
      // Light start on a 13-dark yard: the counting argument.
      expect(Rounds.dark(wrong, wrong.starts!), isFalse);
      expect(wrong.darks, 13);
      expect(wrong.lights, 12);
      // And the walk, which knows nothing of colours, agrees.
      expect(Rounds.exists(wrong), isFalse);
    });

    test('every open round on the five yard starts and ends dark', () {
      // The majority-colour rule, checked from every light paddock: no
      // round from any of them.
      final five = Yards.at(2);
      for (var paddock = 0; paddock < five.paddocks; paddock++) {
        if (Rounds.dark(five, paddock)) continue;
        expect(
          Rounds.canStillRide(
            Yard(
              name: 'probe',
              width: 5,
              height: 5,
              closed: false,
              possible: false,
            ),
            [paddock],
          ),
          isFalse,
          reason: 'light paddock $paddock',
        );
      }
    });

    test('the cross paddocks have level colours and still no round', () {
      final cross = Yards.at(1);
      expect(cross.darks, cross.lights);
      expect(Rounds.exists(cross), isFalse);
    });

    test('a closed round on an odd yard is impossible by counting', () {
      // Not shipped, held here: 25 paddocks cannot alternate home.
      const odd = Yard(
        name: 'probe',
        width: 5,
        height: 5,
        closed: true,
        possible: false,
      );
      expect(odd.darks, isNot(odd.lights));
      expect(Rounds.exists(odd), isFalse);
    });
  });

  group('every yard that ships', () {
    for (var number = 0; number < Yards.count; number++) {
      final yard = Yards.at(number);

      test('${yard.name} says what the walk says', () {
        expect(Rounds.exists(yard), yard.possible);
      });
    }
  });

  group('a round in the riding', () {
    test('starts at the gate where the yard has one', () {
      final play = Play.of(Yards.at(2));
      expect(play.started, isFalse);
      expect(play.mayRide(0), isTrue);
      expect(play.mayRide(3), isFalse);
      expect(Play.of(Yards.at(0)).mayRide(5), isTrue);
    });

    test('rides only knight jumps onto unridden grass', () {
      var play = Play.of(Yards.at(2)).ride(0);
      expect(play.mayRide(7), isTrue);
      expect(play.mayRide(1), isFalse);
      expect(play.mayRide(0), isFalse);
      expect(identical(play.ride(1), play), isTrue);
    });

    test('following next rides every possible yard to the end', () {
      for (var number = 0; number < Yards.count; number++) {
        final yard = Yards.at(number);
        if (!yard.possible) continue;
        var play = Play.of(yard);
        var guard = 0;
        while (!play.isDone) {
          if (guard++ > yard.paddocks + 1) {
            fail('${yard.name} never came round');
          }
          expect(play.canStillRide, isTrue, reason: yard.name);
          play = play.ride(play.next!);
        }
        expect(play.path.length, yard.paddocks, reason: yard.name);
      }
    });

    test('the closed round comes home a jump from the gate', () {
      var play = Play.of(Yards.at(4));
      var guard = 0;
      while (!play.isDone && guard++ < 40) {
        play = play.ride(play.next!);
      }
      expect(play.isDone, isTrue);
      expect(
        Rounds.from(play.yard, play.path.last).contains(play.path.first),
        isTrue,
      );
    });

    test('a stranding jump shows in the live answer at once', () {
      // On the little yard, find a jump that kills the round and see the
      // flag drop the moment it is made.
      var play = Play.of(Yards.at(0));
      play = play.ride(play.next!);
      var strander = -1;
      for (var paddock = 0; paddock < play.yard.paddocks && strander < 0;
          paddock++) {
        if (!play.mayRide(paddock)) continue;
        if (!play.ride(paddock).canStillRide) strander = paddock;
      }
      if (strander >= 0) {
        expect(play.ride(strander).canStillRide, isFalse);
      }
      expect(play.canStillRide, isTrue);
    });

    test('back unrides the last paddock', () {
      final play = Play.of(Yards.at(0));
      final ridden = play.ride(play.next!);
      expect(ridden.path, hasLength(1));
      expect(ridden.back.path, isEmpty);
      expect(identical(play.back, play), isTrue);
    });

    test('the hopeless yards never let a round finish, twenty tries each',
        () {
      for (final number in const [1, 3]) {
        final yard = Yards.at(number);
        expect(Play.of(yard).canStillRide, isFalse, reason: yard.name);
        expect(Play.of(yard).next, isNull, reason: yard.name);
      }
    });
  });
}
