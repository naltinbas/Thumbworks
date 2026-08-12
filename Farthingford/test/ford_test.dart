import 'package:flutter_test/flutter_test.dart';
import 'package:farthingford/ford/play.dart';
import 'package:farthingford/ford/reaches.dart';
import 'package:farthingford/ford/rules.dart';

void main() {
  group('the stream', () {
    test('crossing numbers and mediants, by hand', () {
      expect(Rules.crossing(0, 1, 1, 1), 1);
      expect(Rules.crossing(1, 2, 2, 3), 1);
      expect(Rules.crossing(1, 3, 2, 5), 1);
      expect(Rules.crossing(1, 4, 3, 4), 8);
      expect(Rules.mediant(1, 2, 2, 3), (3, 5));
      expect(Rules.mediant(0, 1, 1, 1), (1, 2));
    });

    test('the stream to depth eight holds twenty-three fords', () {
      expect(Rules.fords(8), hasLength(23));
    });

    test('circles kiss exactly when the crossing number is one', () {
      final fords = Rules.fords(8);
      for (var one = 0; one < fords.length; one++) {
        for (var two = one + 1; two < fords.length; two++) {
          final (p, q) = fords[one];
          final (r, s) = fords[two];
          expect(
            Rules.circlesKiss(p, q, r, s),
            Rules.crossing(p, q, r, s).abs() == 1,
            reason: '$p/$q against $r/$s',
          );
        }
      }
    });

    test('between kissing banks the one shallowest ford is the '
        'mediant', () {
      expect(Rules.shallowestBetween(0, 1, 1, 1, 2), [(1, 2)]);
      expect(Rules.shallowestBetween(1, 2, 2, 3, 5), [(3, 5)]);
      expect(Rules.shallowestBetween(2, 5, 1, 2, 7), [(3, 7)]);
      // And nothing shallower exists at all.
      expect(Rules.shallowestBetween(1, 2, 2, 3, 4), isEmpty);
    });

    test('the walk lands every shipped ford in its written wades',
        () {
      expect(Rules.wadesTo(1, 2), 1);
      expect(Rules.wadesTo(3, 5), 3);
      expect(Rules.wadesTo(3, 7), 4);
      expect(Rules.wadesTo(3, 8), 4);
    });
  });

  group('the reaches that ship', () {
    for (final reach in Reaches.all) {
      test(reach.name, () {
        if (reach.winnable) {
          final target = reach.target!;
          expect(Rules.wadesTo(target.$1, target.$2), reach.wades);
        } else {
          final (a, b) = reach.startA;
          final (c, d) = reach.startC;
          final shallowest =
              Rules.shallowestBetween(a, b, c, d, 12);
          expect(shallowest.first.$2,
              greaterThanOrEqualTo(reach.shallowerThan!));
        }
      });
    }
  });

  group('a wade', () {
    test('opens on the whole stream with the half mid-water', () {
      final play = Play.of(Reaches.at(1));
      expect(play.bankA, (0, 1));
      expect(play.bankC, (1, 1));
      expect(play.stone, (1, 2));
      expect(play.wades, 0);
      expect(play.holdsTarget, isTrue);
    });

    test('wading keeps one bank and takes the stone', () {
      final play = Play.of(Reaches.at(1)).wadeRight();
      expect(play.bankA, (1, 2));
      expect(play.bankC, (1, 1));
      expect(play.wades, 1);
      expect(play.stone, (2, 3));
    });

    test('the crossing number holds at one down every wade', () {
      var play = Play.of(Reaches.at(3));
      for (var wade = 0; wade < 6; wade++) {
        expect(
          Rules.crossing(play.bankA.$1, play.bankA.$2,
              play.bankC.$1, play.bankC.$2),
          1,
        );
        play = wade.isEven ? play.wadeLeft() : play.wadeRight();
      }
    });

    test('crossing lands only on the ford asked', () {
      var play = Play.of(Reaches.at(0));
      expect(play.stoneIsTarget, isTrue);
      expect(play.cross().isDone, isTrue);
      play = Play.of(Reaches.at(1));
      expect(play.stoneIsTarget, isFalse);
      expect(play.cross(), same(play));
    });

    test('a wrong wade loses the ford and the walk says nothing',
        () {
      final play = Play.of(Reaches.at(1)).wadeLeft();
      expect(play.holdsTarget, isFalse);
      expect(play.next, isNull);
      expect(play.back.holdsTarget, isTrue);
    });

    test('following the walk lands every winnable reach in its '
        'written wades', () {
      for (final reach in Reaches.all.where((reach) => reach.winnable)) {
        var play = Play.of(reach);
        var guard = 0;
        while (!play.isDone) {
          if (guard++ > 8) fail('${reach.name} never landed');
          play = switch (play.next!) {
            'left' => play.wadeLeft(),
            'right' => play.wadeRight(),
            _ => play.cross(),
          };
        }
        expect(play.wades, reach.wades, reason: reach.name);
      }
    });

    test('the shallow ford only ever deepens, and gives up at the '
        'line', () {
      var play = Play.of(Reaches.at(4));
      expect(play.next, isNull);
      for (var wade = 0; wade < Play.gaveUpAt; wade++) {
        expect(play.isOver, isFalse);
        expect(play.stone.$2, greaterThanOrEqualTo(5));
        play = wade.isEven ? play.wadeLeft() : play.wadeRight();
      }
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
    });
  });
}
