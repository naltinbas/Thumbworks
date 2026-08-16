import 'package:flutter_test/flutter_test.dart';
import 'package:sliverton/sliver/frac.dart';
import 'package:sliverton/sliver/level.dart';
import 'package:sliverton/sliver/levels.dart';
import 'package:sliverton/sliver/play.dart';
import 'package:sliverton/sliver/rules.dart';

/// The cuts, the sweep, the asks and the play, checked at the domain:
/// nothing here touches a widget.
void main() {
  group('the cuts', () {
    test('the field, the marks, the sliver and the two measures', () {
      expect(Rules.side, 12);
      expect(Rules.twiceField, Frac.of(144));
      expect(Rules.onBC(8), (Frac.of(4), Frac.of(8)));
      expect(Rules.onCA(8), (Frac.zero, Frac.of(4)));
      expect(Rules.onAB(8), (Frac.of(8), Frac.zero));
      expect(Rules.ratioX(8), Frac.of(2));
      expect(Rules.ratioY(4), Frac.of(1, 2));
      expect(Rules.sliver([8, 8, 8])!.map(Rules.tellSpot).toList(), ['(12/7, 24/7)', '(48/7, 12/7)', '(24/7, 48/7)']);
      expect(Rules.shareByCorners([8, 8, 8]), Frac.of(1, 7));
      expect(Rules.shareByRouth([8, 8, 8]), Frac.of(1, 7));
      expect(Rules.shareByRouth([4, 4, 4]), Frac.of(1, 7));
      expect(Rules.shareByRouth([6, 6, 6]), Frac.zero);
      expect(Rules.cutsMeet([6, 6, 6]), isTrue);
      expect(Rules.cutsMeet([8, 8, 8]), isFalse);
      expect(Rules.slivergone([6, 6, 6]), isTrue);
      expect(Rules.sliver([6, 6, 6])!.every((p) => p == (Frac.of(4), Frac.of(4))), isTrue);
      expect(Rules.shareByRouth([1, 1, 1]), Level.widest);
      expect(Rules.shareByRouth([4, 7, 7]), Frac.of(1, 74338));
      expect(Rules.valid([0, 5, 5]), isFalse);
      expect(Rules.valid([12, 5, 5]), isFalse);
      expect(Rules.tellMarks([8, 8, 8]), '8, 8 and 8 twelfths');
      expect(Rules.tellShare(Frac.zero), 'nothing');
      expect(Rules.tellShare(Frac.of(1, 7)), '1/7');
    });

    test('the sweep: the corners and Routh agree on every setting, and the sliver goes only when the cuts meet', () {
      var settings = 0, meet = 0, gone = 0, seventh = 0;
      final shares = <Frac>{};
      for (var d = 1; d <= 11; d++) {
        for (var e = 1; e <= 11; e++) {
          for (var f = 1; f <= 11; f++) {
            settings++;
            final m = [d, e, f];
            final byCorners = Rules.shareByCorners(m), byRouth = Rules.shareByRouth(m);
            expect(byCorners, byRouth, reason: '$m');
            expect(byRouth.compareTo(Frac.zero) >= 0 && byRouth.compareTo(Frac.one) < 0, isTrue, reason: '$m');
            expect(Rules.cutsMeet(m), Rules.slivergone(m), reason: '$m');
            expect(Rules.cutsMeet(m), byRouth == Frac.zero, reason: '$m');
            if (Rules.cutsMeet(m)) meet++;
            if (Rules.slivergone(m)) gone++;
            if (byRouth == Frac.of(1, 7)) seventh++;
            shares.add(byRouth);
          }
        }
      }
      expect((settings, meet, gone, seventh), (1331, 31, 31, 2));
      expect(shares.length, 219);
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The Sly Vanishing']);
      for (final level in Levels.all) {
        var ways = 0;
        for (var d = 1; d <= 11; d++) {
          for (var e = 1; e <= 11; e++) {
            for (var f = 1; f <= 11; f++) {
              if (level.meets([d, e, f])) ways++;
            }
          }
        }
        expect(ways, level.ways, reason: level.name);
        final aim = level.aim;
        if (aim != null) expect(level.meets(aim), isTrue, reason: level.name);
        if (!level.winnable) expect(aim, isNull);
      }
      expect(Levels.at(0).aim, [4, 4, 4]);
      expect(Levels.at(1).aim, [1, 6, 11]);
      expect(Levels.at(2).aim, [1, 8, 8]);
      expect(Levels.at(3).aim, [1, 1, 1]);
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'set the marks so that the sliver is a seventh of the field');
      expect(Levels.at(1).task, 'set the marks so that the sliver comes to nothing');
      expect(Levels.at(2).task, 'set the marks so that the sliver is a seventieth of the field');
      expect(Levels.at(3).task, 'set the marks so that the sliver is as big as it gets');
      expect(Levels.at(4).task, 'set the marks so that the sliver comes to nothing while the three cuts miss one another');
    });

    test('an ask is met by the marks', () {
      expect(Levels.at(0).meets([8, 8, 8]), isTrue);
      expect(Levels.at(0).meets([4, 4, 4]), isTrue);
      expect(Levels.at(0).meets([6, 6, 6]), isFalse);
      expect(Levels.at(1).meets([6, 6, 6]), isTrue);
      expect(Levels.at(1).meets([1, 6, 11]), isTrue);
      expect(Levels.at(1).meets([8, 8, 8]), isFalse);
      expect(Levels.at(2).meets([1, 8, 8]), isTrue);
      expect(Levels.at(3).meets([11, 11, 11]), isTrue);
      expect(Levels.at(3).meets([1, 1, 2]), isFalse);
      expect(Levels.at(4).meets([6, 6, 6]), isFalse);
      expect(Levels.at(0).meets([12, 8, 8]), isFalse);
    });
  });

  group('the play', () {
    test('opens at three, three and three', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.marks, [3, 3, 3]);
        expect((play.moves, play.gone), (0, false));
        expect(play.share, Frac.of(4, 13));
        expect(play.isOver, isFalse, reason: level.name);
      }
    });

    test('a step moves one mark along its side and stops at the ends', () {
      final play = Play.of(Levels.at(4));
      expect(play.step(0, 1).marks, [4, 3, 3]);
      expect(play.step(1, -1).marks, [3, 2, 3]);
      expect(play.step(3, 1), same(play));
      expect(play.step(0, 0), same(play));
      final atTheEnd = Play.standing(Levels.at(4), [11, 3, 3]);
      expect(atTheEnd.step(0, 1), same(atTheEnd));
      final atTheStart = Play.standing(Levels.at(4), [1, 3, 3]);
      expect(atTheStart.step(0, -1), same(atTheStart));
    });

    test('back undoes one step', () {
      final play = Play.of(Levels.at(0)).step(0, 1).step(1, 1);
      expect(play.back.marks, [4, 3, 3]);
      expect(play.back.back.marks, [3, 3, 3]);
    });

    test('the pointer steps the first mark off the aim towards it', () {
      expect(Play.of(Levels.at(0)).next, (0, 1));
      expect(Play.pointed((0, 1)), 'Step mark D on.');
      expect(Play.of(Levels.at(1)).next, (0, -1));
      expect(Play.pointed((0, -1)), 'Step mark D back.');
      expect(Play.standing(Levels.at(1), [1, 3, 3]).next, (1, 1));
      expect(Play.pointed((1, 1)), 'Step mark E on.');
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('following the pointer lands every winnable ask', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var steps = 0;
        while (!play.isDone && steps < 40) {
          final (which, by) = play.next!;
          play = play.step(which, by);
          steps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
      }
      var seventh = Play.of(Levels.at(0));
      while (!seventh.isDone) {
        final (which, by) = seventh.next!;
        seventh = seventh.step(which, by);
      }
      expect(seventh.marks, [4, 4, 4]);
      expect(seventh.moves, 3);
    });

    test('the sly vanishing admits it after three meetings, or twenty taps', () {
      var play = Play.of(Levels.at(4)).step(0, 3).step(1, 3).step(2, 3);
      expect(play.marks, [6, 6, 6]);
      expect(play.cutsMeet, isTrue);
      expect(play.seen, hasLength(1));
      expect(play.gaveUp, isFalse);
      play = play.step(0, -5).step(2, 5);
      expect(play.seen, hasLength(2));
      expect(play.gaveUp, isFalse);
      play = play.step(0, 1).step(2, -1);
      expect(play.seen, hasLength(3));
      expect(play.gaveUp, isTrue);
      expect(play.moves, 7);
      expect(play.next, isNull);
      var wander = Play.of(Levels.at(4));
      for (var k = 0; k < 20; k++) {
        wander = wander.step(0, k.isEven ? 1 : -1);
      }
      expect(wander.gaveUp, isTrue);
      expect(wander.moves, 20);
    });

    test('the why tells Routh, Ceva and the sweep', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('Routh\'s rule, published in 1891'));
      expect(words, contains('Ceva\'s condition of 1678'));
      expect(words, contains('1,331'));
      expect(words, contains('This is ask 5, The Sly Vanishing.'));
      expect(words, contains('cut in full'));
    });
  });
}
