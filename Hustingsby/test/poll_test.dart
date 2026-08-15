import 'package:flutter_test/flutter_test.dart';
import 'package:hustingsby/poll/levels.dart';
import 'package:hustingsby/poll/play.dart';
import 'package:hustingsby/poll/rules.dart';

/// The count, the sweep, the asks and the play, checked at the domain:
/// nothing here touches a widget.
void main() {
  const a = true, b = false;

  group('the count', () {
    test('orders, leads and their readings', () {
      expect(Rules.orders(2, 1).map(Rules.told).toList(), ['A A B', 'A B A', 'B A A']);
      expect(Rules.orders(3, 2), hasLength(10));
      expect(Rules.leads([a, a, b, b, a]), [1, 2, 1, 0, 1]);
      expect(Rules.aheadThroughout([a, a, b, a, b]), isTrue);
      expect(Rules.aheadThroughout([a, b, a, a, b]), isFalse);
      expect(Rules.aheadThroughout([]), isFalse);
      expect(Rules.neverBehind([a, b, a, b]), isTrue);
      expect(Rules.neverBehind([a, b, b, a]), isFalse);
      expect(Rules.levels([a, b, a, b]), 2);
      expect(Rules.changesOfHands([a, b, b, a, a]), 2);
      expect(Rules.changesOfHands([a, a, b, b, b, a]), 1);
      expect(Rules.changesOfHands([a, b, a, b]), 0);
      expect(Rules.choose(5, 2), 10);
      expect(Rules.choose(8, 4), 70);
    });

    test('the three voices agree, polls to eight and eight', () {
      for (var ash = 0; ash <= 8; ash++) {
        for (var birch = 0; birch <= 8; birch++) {
          final os = Rules.orders(ash, birch);
          final ahead = os.where(Rules.aheadThroughout).length;
          if (ash > birch) {
            expect(ahead, Rules.aheadByBertrand(ash, birch), reason: '$ash v $birch');
            expect(ahead, Rules.aheadByReflection(ash, birch), reason: '$ash v $birch');
            expect(os.where(Rules.neverBehind).length, Rules.neverBehindByFormula(ash, birch), reason: '$ash v $birch');
          } else {
            expect(ahead, 0, reason: '$ash v $birch');
          }
        }
      }
      expect(Rules.aheadByBertrand(3, 2), 2);
      expect(Rules.neverBehindByFormula(4, 4), 14);
      expect(Rules.neverBehindByFormula(3, 3), 5);
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The Level Poll']);
      for (final level in Levels.all) {
        expect(level.orders.where(level.meets).length, level.ways, reason: level.name);
        final aim = level.aim;
        if (aim != null) expect(level.meets(aim), isTrue, reason: level.name);
        if (!level.winnable) expect(aim, isNull);
      }
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'count three Ash and two Birch in an order that keeps Ash ahead after every ballot');
      expect(Levels.at(1).task, 'count four Ash and three Birch in an order that stands level exactly twice');
      expect(Levels.at(3).task, 'count four Ash and four Birch in an order that never puts Ash behind, level allowed');
    });

    test('an ask is met by a complete order of the right kind', () {
      expect(Levels.at(0).meets([a, a, b, a, b]), isTrue);
      expect(Levels.at(0).meets([a, b, a, a, b]), isFalse);
      expect(Levels.at(0).meets([a, a, b, a]), isFalse);
      expect(Levels.at(0).meets([a, a, a, a, b]), isFalse);
      expect(Levels.at(3).meets([a, b, a, b, a, b, a, b]), isTrue);
      expect(Levels.at(4).meets([a, a, a, a, b, b, b, b]), isFalse);
    });
  });

  group('the play', () {
    test('opens with nothing drawn', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.drawn, isEmpty);
        expect((play.ashLeft, play.birchLeft, play.moves), (level.ash, level.birch, 0));
        expect(play.isOver, isFalse, reason: level.name);
      }
    });

    test('a draw takes a ballot from the box, and none once they are out', () {
      var play = Play.of(Levels.at(0)).draw(a).draw(b);
      expect(play.drawn, [a, b]);
      expect((play.lead, play.moves), (0, 2));
      play = play.draw(b);
      expect(play.birchLeft, 0);
      expect(play.draw(b), same(play));
      expect(play.lead, -1);
      play = play.draw(a).draw(a);
      expect(play.isComplete, isTrue);
      expect(play.isDone, isFalse);
      expect(play.draw(a), same(play));
    });

    test('back undoes one draw', () {
      final play = Play.of(Levels.at(0)).draw(a).draw(a);
      expect(play.back.drawn, [a]);
      expect(play.back.back.drawn, isEmpty);
    });

    test('the clean lead lands, and it takes no more draws', () {
      final play = Play.of(Levels.at(0)).draw(a).draw(a).draw(b).draw(a).draw(b);
      expect(play.isDone, isTrue);
      expect(play.aheadSoFar, isTrue);
      expect(play.draw(a), same(play));
    });

    test('the pointer draws the aim, and calls for back when the count strays', () {
      var play = Play.of(Levels.at(0));
      expect(play.next, 0);
      play = play.draw(b);
      expect(play.next, 2);
      play = play.back.draw(a).draw(a);
      expect(play.next, 0);
      expect(Play.pointed(0), 'Draw an Ash ballot.');
      expect(Play.pointed(1), 'Draw a Birch ballot.');
      expect(Play.pointed(2), 'Take the last ballot back.');
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('following the pointer counts every winnable ask', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var steps = 0;
        while (!play.isDone && steps < 30) {
          final n = play.next!;
          play = n == 2 ? play.back : play.draw(n == 0);
          steps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
        expect(play.moves, level.ballots, reason: level.name);
      }
    });

    test('the level poll admits it once the count is through', () {
      var play = Play.of(Levels.at(4));
      for (final x in [a, a, a, a, b, b, b]) {
        play = play.draw(x);
      }
      expect(play.gaveUp, isFalse);
      play = play.draw(b);
      expect(play.gaveUp, isTrue);
      expect(play.lead, 0);
      expect(play.next, isNull);
      var wander = Play.of(Levels.at(4));
      for (var k = 0; k < 30; k++) {
        wander = wander.draw(a).back;
      }
      expect(wander.moves, 0);
      var draws = Play.of(Levels.at(4));
      for (var k = 0; k < 30 && !draws.gaveUp; k++) {
        draws = draws.draw(k.isEven ? a : b);
      }
      expect(draws.gaveUp, isTrue);
    });

    test('the why tells Bertrand and the sweep', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('Bertrand answered in 1887'));
      expect(words, contains('This is ask 5, The Level Poll.'));
      expect(words, contains('read through in full'));
    });
  });
}
