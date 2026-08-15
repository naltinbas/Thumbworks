import 'package:flutter_test/flutter_test.dart';
import 'package:framley/wall/level.dart';
import 'package:framley/wall/levels.dart';
import 'package:framley/wall/play.dart';
import 'package:framley/wall/rules.dart';

/// The search, the walls and the play, checked at the domain: nothing
/// here touches a widget.
void main() {
  group('the search', () {
    test('finds the four hangings of the nine on thirty-two by thirty-three', () {
      final found = Rules.hangings(32, 33, Levels.nine);
      expect(found, hasLength(4));
      expect(found.first, {18: (0, 0), 14: (18, 0), 4: (18, 14), 10: (22, 14), 15: (0, 18), 7: (15, 18), 1: (22, 24), 9: (23, 24), 8: (15, 25)});
      expect(Rules.hangings(32, 33, Levels.nine, byColumns: true), hasLength(4));
    });

    test('finds four on the other two walls, and none with the smallest on the rim', () {
      expect(Rules.hangings(61, 69, Levels.otherNine), hasLength(4));
      expect(Rules.hangings(47, 65, Levels.ten), hasLength(4));
      expect(Rules.hangings(32, 33, Levels.nine, smallestOnRim: true), isEmpty);
      expect(Rules.hangings(61, 69, Levels.otherNine, smallestOnRim: true), isEmpty);
    });

    test('the four are one hanging turned and mirrored', () {
      final found = Rules.hangings(32, 33, Levels.nine);
      final images = Rules.images(32, 33, found.first).map((i) => i.told).toSet();
      expect(images, hasLength(4));
      expect(found.map((f) => f.told).toSet(), images);
    });

    test('reads the Bouwkamp code and the smallest frame\'s neighbours', () {
      final first = Rules.hangings(32, 33, Levels.nine).first;
      expect(Rules.bouwkamp(32, 33, first), '(18,14)(4,10)(15,7)(1,9)(8)');
      expect(Rules.neighbours(32, 33, first, 1), [7, 8, 9, 10]);
      final other = Rules.hangings(61, 69, Levels.otherNine).first;
      expect(Rules.bouwkamp(61, 69, other), '(36,25)(9,16)(2,7)(33,5)(28)');
      expect(Rules.neighbours(61, 69, other, 2), [5, 7, 9, 36]);
    });

    test('with the four largest fixed the last five go one way', () {
      final level = Levels.at(0);
      final found = Rules.hangings(32, 33, level.sizes, fixed: level.fixed);
      expect(found, hasLength(1));
      expect(found.first[1], (22, 24));
    });

    test('touching the rim', () {
      expect(Rules.touchesRim(32, 33, 1, 0, 5), isTrue);
      expect(Rules.touchesRim(32, 33, 1, 31, 5), isTrue);
      expect(Rules.touchesRim(32, 33, 9, 23, 24), isTrue);
      expect(Rules.touchesRim(32, 33, 1, 22, 24), isFalse);
    });
  });

  group('the walls', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The One on the Rim']);
      expect(Levels.at(4).smallestOnRim, isTrue);
    });

    test('the areas add up and no two frames are alike', () {
      for (final level in Levels.all) {
        expect(level.sizes.fold(0, (sum, s) => sum + s * s), level.area, reason: level.name);
        expect(level.sizes.toSet().length, level.sizes.length);
      }
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'hang the last five frames on the thirty-two by thirty-three wall, the four largest hung already');
      expect(Levels.at(1).task, 'hang nine frames, 1 to 18, no two alike, to fill the thirty-two by thirty-three wall');
      expect(Levels.at(3).task, 'hang ten frames, 3 to 25, no two alike, to fill the forty-seven by sixty-five wall');
      expect(Levels.at(4).task, 'hang the nine frames, 1 to 18, to fill the thirty-two by thirty-three wall with the smallest on the rim');
    });

    test('an ask is met by a full wall, the rim ask by the 1 on the rim', () {
      final Level nine = Levels.at(1);
      final full = Rules.hangings(32, 33, Levels.nine).first;
      expect(nine.meets(full), isTrue);
      expect(nine.meets(Map.of(full)..remove(1)), isFalse);
      expect(Levels.at(4).meets(full), isFalse);
    });
  });

  group('the play', () {
    test('opens with the fixed frames hung and the tray full otherwise', () {
      final play = Play.of(Levels.at(0));
      expect(play.hung.length, 4);
      expect(play.tray, [9, 8, 7, 4, 1]);
      expect(play.bareCells, 32 * 33 - (18 * 18 + 15 * 15 + 14 * 14 + 10 * 10));
      expect(Play.of(Levels.at(1)).tray, [18, 15, 14, 10, 9, 8, 7, 4, 1]);
    });

    test('a frame is taken, hung where it fits, and lifted again', () {
      var play = Play.of(Levels.at(1));
      play = play.hold(18);
      expect(play.held, 18);
      play = play.tap(0, 0);
      expect(play.hung[18], (0, 0));
      expect(play.held, isNull);
      expect(play.moves, 1);
      play = play.hold(14).tap(10, 0);
      expect(play.refused, isTrue);
      expect(play.hung.containsKey(14), isFalse);
      expect(play.held, 14);
      play = play.tap(18, 0);
      expect(play.hung[14], (18, 0));
      expect(play.moves, 2);
      play = play.tap(5, 5);
      expect(play.hung.containsKey(18), isFalse);
      expect(play.moves, 2);
      expect(play.tray, [18, 15, 10, 9, 8, 7, 4, 1]);
    });

    test('a frame does not hang past the wall\'s edge', () {
      final play = Play.of(Levels.at(1)).hold(18).tap(20, 0);
      expect(play.refused, isTrue);
      expect(play.fits(18, 14, 15), isTrue);
      expect(play.fits(18, 15, 15), isFalse);
      expect(play.fits(18, 14, 16), isFalse);
    });

    test('fixed frames are not lifted', () {
      final play = Play.of(Levels.at(0)).tap(0, 0);
      expect(play.hung[18], (0, 0));
    });

    test('back undoes one action', () {
      final play = Play.of(Levels.at(1)).hold(18).tap(0, 0);
      expect(play.back.hung, isEmpty);
      expect(play.back.held, 18);
      expect(play.back.back.held, isNull);
    });

    test('the last five land by hand', () {
      var play = Play.of(Levels.at(0));
      play = play.hold(4).tap(18, 14).hold(7).tap(15, 18).hold(1).tap(22, 24).hold(9).tap(23, 24).hold(8).tap(15, 25);
      expect(play.isDone, isTrue);
      expect(play.bareCells, 0);
      expect(play.moves, 5);
    });

    test('the pointer walks the search\'s first hanging', () {
      var play = Play.of(Levels.at(1));
      expect(play.next, (Aim.tray, 18, 0));
      play = play.hold(18);
      expect(play.next, (Aim.cell, 0, 0));
      play = play.tap(0, 0);
      expect(play.next, (Aim.tray, 14, 0));
      // A frame in the way is lifted first.
      play = play.hold(10).tap(18, 0);
      expect(play.next, (Aim.lift, 18, 0));
    });

    test('following the pointer hangs every winnable wall', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var steps = 0;
        while (!play.isDone && steps < 40) {
          final (aim, a, b) = play.next!;
          play = aim == Aim.tray ? play.hold(a) : play.tap(a, b);
          steps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
        expect(play.moves, level.sizes.length - level.fixed.length);
      }
    });

    test('the one on the rim gives up when the wall is full, or after twenty-four', () {
      final full = Rules.hangings(32, 33, Levels.nine).first;
      var play = Play.of(Levels.at(4));
      for (final e in full.entries) {
        play = play.hold(e.key).tap(e.value.$1, e.value.$2);
      }
      expect(play.isFull, isTrue);
      expect(play.isDone, isFalse);
      expect(play.gaveUp, isTrue);
      expect(play.next, isNull);
      var dither = Play.of(Levels.at(4));
      for (var k = 0; k < 24; k++) {
        dither = dither.hold(1).tap(0, 0).tap(0, 0);
      }
      expect(dither.moves, 24);
      expect(dither.gaveUp, isTrue);
    });
  });
}
