import 'package:flutter_test/flutter_test.dart';
import 'package:wardhall/hall/halls.dart';
import 'package:wardhall/hall/play.dart';
import 'package:wardhall/hall/rules.dart';

void main() {
  group('the light', () {
    test('a ward lights what no wall blocks', () {
      final ell = Halls.at(0).corners;
      // The inner corner sees both arms.
      expect(Rules.lights(ell, (2, 2), (5, 1)), isTrue);
      expect(Rules.lights(ell, (2, 2), (1, 4)), isTrue);
      // An arm's end cannot see round the bend.
      expect(Rules.lights(ell, (6, 0), (1, 5)), isFalse);
    });

    test('the floor counts its flags', () {
      expect(Rules.floorOf(Halls.at(0).corners), hasLength(30));
    });

    test('the sweep finds the fewest on every hall', () {
      for (final hall in Halls.all) {
        expect(Rules.fewestWards(hall.corners), hall.fewest,
            reason: hall.name);
      }
    });

    test('the triangles cut clean and the colours never repeat',
        () {
      for (final hall in Halls.all) {
        final cut = Rules.triangles(hall.corners);
        expect(cut, hasLength(hall.corners.length - 2),
            reason: hall.name);
        final colours = Rules.threeColours(hall.corners);
        for (final (a, b, c) in cut) {
          expect(colours[a] == colours[b], isFalse);
          expect(colours[b] == colours[c], isFalse);
          expect(colours[a] == colours[c], isFalse);
        }
      }
    });

    test('the colouring\'s watch lights every hall within a third',
        () {
      for (final hall in Halls.all) {
        final watch = Rules.fiskWatch(hall.corners);
        expect(watch.length,
            lessThanOrEqualTo(hall.corners.length ~/ 3),
            reason: hall.name);
        expect(Rules.unlit(hall.corners, watch), isEmpty,
            reason: hall.name);
      }
    });

    test('the roof and the floor: where they meet and where they '
        'part', () {
      // The Ell: colouring 2, sweep 1. The Comb: both 3.
      expect(Rules.fiskWatch(Halls.at(0).corners), hasLength(2));
      expect(Halls.at(0).fewest, 1);
      expect(Rules.fiskWatch(Halls.at(3).corners), hasLength(3));
      expect(Halls.at(3).fewest, 3);
    });
  });

  group('a watch', () {
    test('wards post and lift at corners', () {
      var play = Play.of(Halls.at(1));
      play = play.post(3);
      expect(play.wards, [3]);
      expect(play.mayPost(3), isFalse);
      play = play.lift(3);
      expect(play.wards, isEmpty);
      expect(play.back.wards, [3]);
    });

    test('the unlit flags shrink as the watch grows', () {
      var play = Play.of(Halls.at(0));
      final dark = play.unlit.length;
      expect(dark, greaterThan(0));
      play = play.post(3);
      expect(play.unlit, isEmpty);
      expect(play.isDone, isTrue);
    });

    test('a full watch that leaves dark flags is short', () {
      // Found, not guessed: a pair of corners that leaves dark.
      final play = Play.of(Halls.at(1));
      Play? shortWatch;
      for (var one = 0; one < 8 && shortWatch == null; one++) {
        for (var two = one + 1; two < 8 && shortWatch == null; two++) {
          final posted = play.post(one).post(two);
          if (posted.unlit.isNotEmpty) shortWatch = posted;
        }
      }
      expect(shortWatch, isNotNull,
          reason: 'every pair lights the zigzag');
      expect(shortWatch!.short, isTrue);
      // A winnable hall lets the watch lift and try again.
      expect(shortWatch.isOver, isFalse);
    });

    test('following the pointer lights every winnable hall', () {
      for (final hall in Halls.all.where((hall) => hall.winnable)) {
        var play = Play.of(hall);
        var guard = 0;
        while (!play.isDone) {
          if (guard++ > 6) fail('${hall.name} never lit');
          final watch = play.finished;
          expect(watch, isNotNull, reason: hall.name);
          play = play.post(play.nextOf(watch!)!);
        }
        expect(play.wards.length, lessThanOrEqualTo(hall.asked));
      }
    });

    test('the comb short never lights: every pair leaves dark', () {
      final hall = Halls.at(4);
      expect(hall.winnable, isFalse);
      final play = Play.of(hall);
      expect(play.finished, isNull);
      // Every pair of corners, swept through the play itself.
      for (var one = 0; one < 12; one++) {
        for (var two = one + 1; two < 12; two++) {
          final posted = play.post(one).post(two);
          expect(posted.unlit, isNotEmpty,
              reason: 'wards $one and $two');
        }
      }
    });
  });
}
