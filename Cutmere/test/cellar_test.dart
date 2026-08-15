import 'package:flutter_test/flutter_test.dart';
import 'package:cutmere/cellar/levels.dart';
import 'package:cutmere/cellar/play.dart';
import 'package:cutmere/cellar/rules.dart';

/// The law of the cellar, held to.
void main() {
  group('the rules', () {
    test('the cellarman keeps the bigger part, the right when even', () {
      expect(Rules.kept(8, 4), (4, true));
      expect(Rules.kept(8, 3), (5, true));
      expect(Rules.kept(8, 5), (5, false));
      expect(Rules.kept(9, 4), (5, true));
      expect(Rules.middle(8), 4);
      expect(Rules.middle(9), 4);
    });

    test('the tree\'s fewest questions is the bound', () {
      expect([for (var n = 1; n <= 17; n++) Rules.questions(n)], [0, 1, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 5]);
      for (var n = 1; n <= 200; n++) {
        expect(Rules.questions(n), Rules.bound(n), reason: '$n');
      }
      expect(Rules.bound(128), 7);
      expect(Rules.bound(129), 8);
    });

    test('the first cuts swept', () {
      expect(Rules.sweep(8, 3), (1, 7));
      expect(Rules.sweep(16, 4), (1, 15));
      expect(Rules.sweep(20, 5), (13, 19));
      expect(Rules.sweep(100, 7), (29, 99));
      expect(Rules.sweep(9, 3), (0, 8));
    });

    test('every label\'s ways is what the sweep finds', () {
      for (final level in Levels.all) {
        expect(Rules.sweep(level.casks, level.questions), (level.ways, level.cuts), reason: level.name);
        expect(Rules.questions(level.casks) <= level.questions, level.winnable, reason: level.name);
      }
    });
  });

  group('the play', () {
    test('opens with every cask in doubt', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.from, 0);
        expect(play.size, level.casks);
        expect(play.asked, 0);
        expect(play.isDone, isFalse);
        expect(play.stillNeeded, Rules.questions(level.casks));
      }
    });

    test('a cut keeps the bigger part, counted; back undoes', () {
      var play = Play.of(Levels.at(0));
      play = play.cut(4);
      expect((play.from, play.size, play.asked), (4, 4, 1));
      expect(play.answers, [true]);
      expect(play.back.size, 8);
      play = play.cut(2);
      expect((play.from, play.size), (6, 2));
      play = play.cut(1);
      expect((play.from, play.size), (7, 1));
      expect(play.found, isTrue);
      expect(play.isDone, isTrue);
      expect(play.cut(1), same(play));
      final fresh = Play.of(Levels.at(0));
      expect(fresh.cut(0), same(fresh));
      expect(fresh.cut(8), same(fresh));
    });

    test('a cut by cask number on the whole row', () {
      final play = Play.of(Levels.at(0)).cutAt(3);
      expect((play.from, play.size), (4, 4));
      final left = Play.of(Levels.at(0)).cutAt(4);
      expect((left.from, left.size), (0, 5));
      expect(left.answers, [false]);
    });

    test('a cut off the middle spends the questions', () {
      var play = Play.of(Levels.at(0)).cut(3);
      expect(play.size, 5);
      expect(play.stillNeeded, 3);
      expect(play.next, isNull);
      play = play.cut(2).cut(1);
      expect(play.spent, isTrue);
      expect(play.found, isFalse);
      expect(play.missed, isTrue);
      expect(play.isOver, isTrue);
    });

    test('the pointer searches every winnable cellar', () {
      for (final number in [0, 1, 2, 3]) {
        var play = Play.of(Levels.at(number));
        var guard = 0;
        while (!play.isOver && guard++ < 12) {
          play = play.cut(play.next!);
        }
        expect(play.isDone, isTrue, reason: '$number');
        expect(play.asked, Rules.questions(Levels.at(number).casks), reason: '$number');
      }
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('the hopeless cellar admits it when the questions are spent', () {
      var play = Play.of(Levels.at(4)).cut(4).cut(2).cut(1);
      expect(play.size, 2);
      expect(play.spent, isTrue);
      expect(play.gaveUp, isTrue);
      expect(play.missed, isFalse);
      expect(play.cut(1), same(play));
    });

    test('the mark stands found', () {
      final mark = Play.of(Levels.at(0)).cut(4).cut(2).cut(1);
      expect(mark.isDone, isTrue);
      expect(mark.from, 7);
    });
  });
}
