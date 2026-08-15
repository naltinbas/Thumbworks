import 'package:flutter_test/flutter_test.dart';
import 'package:trickmere/deck/levels.dart';
import 'package:trickmere/deck/play.dart';
import 'package:trickmere/deck/rules.dart';

/// The law of the trick, held to.
void main() {
  group('the rules', () {
    test('cards are named by rank and suit', () {
      expect(Rules.name(27), '2H');
      expect(Rules.name(32), '7H');
      expect(Rules.name(12), 'KC');
      expect(Rules.name(13), 'AD');
      expect(Rules.card(3, 11), 49);
      expect(Rules.suitOf(49), 3);
      expect(Rules.rankOf(49), 11);
    });

    test('steps round the ranks, and one way is within six', () {
      expect(Rules.stepsRound(2, 7), 5);
      expect(Rules.stepsRound(7, 2), 8);
      expect(Rules.stepsRound(8, 1), 6);
      expect(Rules.stepsRound(1, 8), 7);
      for (var a = 1; a <= 13; a++) {
        for (var b = 1; b <= 13; b++) {
          if (a == b) continue;
          expect(Rules.stepsRound(a, b) <= 6 || Rules.stepsRound(b, a) <= 6, isTrue, reason: '$a $b');
        }
      }
    });

    test('three cards tell one to six, round trip', () {
      const three = [47, 17, 12];
      for (var n = 1; n <= 6; n++) {
        expect(Rules.told(Rules.lay(three, n)), n);
      }
      expect(Rules.lay(three, 1), [17, 47, 12]);
      expect(Rules.lay(three, 5), [12, 17, 47]);
    });

    test('the partner names from the row', () {
      expect(Rules.named([27, 12, 17, 47]), 32);
      expect(Rules.named([20, 36, 4, 40]), 13);
    });

    test('the sweep of layouts and the rule agree on every hand', () {
      for (final level in Levels.all) {
        final working = Rules.working(level.hand, hiddenFixed: level.hiddenFixed);
        expect(working, hasLength(level.ways), reason: level.name);
        final rule = Rules.rule(level.hand, hiddenFixed: level.hiddenFixed);
        expect(rule == null, !level.winnable, reason: level.name);
        if (rule != null) {
          expect(Rules.named(rule.$2), rule.$1, reason: level.name);
        }
      }
      expect(Rules.working(Levels.at(4).hand), hasLength(1));
    });
  });

  group('the play', () {
    test('opens with nothing hidden, or the fixed card hidden', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.hidden, level.hiddenFixed, reason: level.name);
        expect(play.row, isEmpty);
        expect(play.isDone, isFalse);
      }
    });

    test('a tap hides, then lays; taps take back; back undoes', () {
      var play = Play.of(Levels.at(0));
      play = play.tap(32);
      expect(play.hidden, 32);
      expect(play.moves, 1);
      play = play.tap(27).tap(12);
      expect(play.row, [27, 12]);
      play = play.tap(12);
      expect(play.row, [27]);
      play = play.tap(32);
      expect(play.hidden, isNull);
      expect(play.moves, 5);
      expect(play.back.hidden, 32);
      expect(play.tap(0), same(play));
    });

    test('the fixed card stays hidden', () {
      final play = Play.of(Levels.at(4));
      expect(play.tap(3), same(play));
      expect(play.tap(31).row, [31]);
    });

    test('the hands by hand', () {
      final hearts = Play.of(Levels.at(0)).tap(32).tap(27).tap(12).tap(17).tap(47);
      expect(hearts.named, 32);
      expect(hearts.isDone, isTrue);
      expect(hearts.tap(9), same(hearts));
      final wrong = Play.of(Levels.at(0)).tap(32).tap(27).tap(17).tap(12).tap(47);
      expect(wrong.named, isNot(32));
      expect(wrong.isDone, isFalse);
      expect(wrong.isOver, isFalse);
      final wrap = Play.of(Levels.at(3)).tap(13).tap(20).tap(36).tap(4).tap(40);
      expect(wrap.isDone, isTrue);
    });

    test('the pointer lands every winnable hand', () {
      for (final number in [0, 1, 2, 3]) {
        var play = Play.of(Levels.at(number));
        var guard = 0;
        while (!play.isDone && guard++ < 12) {
          final (_, c) = play.next!;
          play = play.tap(c);
        }
        expect(play.isDone, isTrue, reason: '$number');
        expect(play.moves, 5, reason: '$number');
      }
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('the pointer unhides a wrong card and unlays a strayed row', () {
      expect(Play.of(Levels.at(0)).tap(27).next, ('unhide', 27));
      expect(Play.of(Levels.at(0)).tap(32).tap(12).next, ('unlay', 12));
      expect(Play.of(Levels.at(0)).tap(32).next, ('lay', 27));
    });

    test('the hopeless hand cracks when four are laid', () {
      final play = Play.of(Levels.at(4)).tap(31).tap(36).tap(47).tap(24);
      expect(play.full, isTrue);
      expect(play.named, isNot(3));
      expect(play.gaveUp, isTrue);
      expect(play.isOver, isTrue);
      expect(play.tap(31), same(play));
    });

    test('the mark stands laid', () {
      final mark = Play.standing(Levels.at(0), 32, const [27, 12, 17, 47]);
      expect(mark.isDone, isTrue);
    });
  });
}
