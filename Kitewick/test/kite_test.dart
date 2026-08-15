import 'package:flutter_test/flutter_test.dart';
import 'package:kitewick/kite/levels.dart';
import 'package:kitewick/kite/play.dart';
import 'package:kitewick/kite/rules.dart';

/// The kite, the sweep, the asks and the play, checked at the domain:
/// nothing here touches a widget.
void main() {
  group('the kite', () {
    test('cells, rows and neighbours', () {
      final k = Kite(2);
      expect(k.count, 12);
      expect(k.cells.first, (-1, -2));
      expect(k.cells.last, (0, 1));
      expect(k.rows, [-2, -1, 0, 1]);
      expect(k.right(0), 1);
      expect(k.right(1), isNull);
      expect(k.below(0), 3);
      expect(k.beside(0, 1), isTrue);
      expect(k.beside(0, 3), isTrue);
      expect(k.beside(0, 2), isFalse);
      expect(k.across(0, 1), isTrue);
      expect(k.across(0, 3), isFalse);
      expect(Kite(1).count, 4);
      expect(Kite(3).count, 24);
    });

    test('the slatings laid out and the formula agree, orders one to five', () {
      for (var order = 1; order <= 5; order++) {
        expect(Kite(order).countSlatings(), Kite.byFormula(order), reason: 'order $order');
      }
      expect(Kite.byFormula(3), 64);
      final s = Kite(2).slatings();
      expect(s, hasLength(8));
      expect(s.map((t) => t.toString()).toSet(), hasLength(8));
      for (final t in s) {
        expect(Kite(2).covers(t), isTrue);
        expect(Kite(2).acrossCount(t).isEven, isTrue);
      }
      expect(s.map(Kite(2).acrossCount).toList()..sort(), [0, 2, 2, 2, 4, 4, 4, 6]);
    });

    test('covers refuses the wrong slates', () {
      final k = Kite(1);
      expect(k.covers([(0, 1), (2, 3)]), isTrue);
      expect(k.covers([(0, 2), (1, 3)]), isTrue);
      expect(k.covers([(0, 3), (1, 2)]), isFalse);
      expect(k.covers([(0, 1)]), isFalse);
      expect(k.covers([(0, 1), (0, 1)]), isFalse);
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The One Across']);
      for (final level in Levels.all) {
        expect(level.slatings.where(level.meets).length, level.ways, reason: level.name);
        final aim = level.aim;
        if (aim != null) expect(level.meets(aim), isTrue, reason: level.name);
        if (!level.winnable) expect(aim, isNull);
      }
    });

    test('each ask says what it wants', () {
      expect(Levels.at(1).task, 'slate the kite of order two, 12 cells');
      expect(Levels.at(2).task, 'slate the kite of order two, 12 cells, with exactly two slates lying across');
      expect(Levels.at(4).task, 'slate the kite of order two, 12 cells, with exactly one slate lying across');
    });

    test('an ask is met by a slating, whole, with the count across asked', () {
      final level = Levels.at(2);
      final two = level.slatings.where((s) => level.kite.acrossCount(s) == 2).first;
      expect(level.meets(two), isTrue);
      final six = level.slatings.where((s) => level.kite.acrossCount(s) == 6).first;
      expect(level.meets(six), isFalse);
      expect(Levels.at(1).meets(six), isTrue);
      expect(Levels.at(1).meets(six.sublist(1)), isFalse);
    });
  });

  group('the play', () {
    test('opens bare', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect((play.laid, play.picked, play.moves), (const <(int, int)>[], null, 0));
        expect(play.isOver, isFalse, reason: level.name);
      }
    });

    test('a pick, a lay, a lift, and letting go', () {
      var play = Play.of(Levels.at(1)).tap(0);
      expect((play.picked, play.moves), (0, 0));
      play = play.tap(0);
      expect(play.picked, isNull);
      play = play.tap(0).tap(1);
      expect(play.laid, [(0, 1)]);
      expect(play.moves, 1);
      expect(play.acrossCount, 1);
      // A far cell picks afresh instead of laying.
      play = play.tap(2).tap(9);
      expect((play.laid.length, play.picked), (1, 9));
      play = play.tap(9);
      // Lifting.
      play = play.tap(1);
      expect(play.laid, isEmpty);
      expect(play.moves, 2);
      expect(play.tap(99), same(play));
    });

    test('back undoes one laying', () {
      final play = Play.of(Levels.at(1)).tap(0).tap(1).tap(2).tap(3);
      expect(play.back.laid, [(0, 1)]);
      expect(play.back.back.laid, isEmpty);
    });

    test('the two lands whole, and it takes no more taps', () {
      final play = Play.of(Levels.at(0)).tap(0).tap(1).tap(2).tap(3);
      expect(play.isFull, isTrue);
      expect(play.isDone, isTrue);
      expect(play.tap(0), same(play));
    });

    test('stuck: a bare cell with no bare neighbour', () {
      // On the order two, cover the top row and cell 3's other neighbours.
      final play = Play.of(Levels.at(1)).tap(0).tap(1).tap(2).tap(6).tap(4).tap(5).tap(7).tap(8);
      expect(play.stuck, isTrue);
      expect(Play.of(Levels.at(1)).stuck, isFalse);
    });

    test('the pointer picks, lays and lifts towards the aim', () {
      var play = Play.of(Levels.at(1));
      expect(play.next, (Aim.pick, 0));
      play = play.tap(0);
      expect(play.next, (Aim.lay, 1));
      play = play.tap(3);
      expect(play.laid, [(0, 3)]);
      expect(play.next, (Aim.lift, 0));
      expect(Play.pointed((Aim.lift, 0)), 'Lift the ringed slate.');
      expect(Play.pointed((Aim.pick, 0)), 'Tap the ringed cell.');
      expect(Play.pointed((Aim.lay, 1)), 'Now tap the ringed cell beside it.');
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('following the pointer slates every winnable ask', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var steps = 0;
        while (!play.isDone && steps < 60) {
          play = play.tap(play.next!.$2);
          steps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
        expect(play.moves, level.kite.count ~/ 2, reason: level.name);
      }
    });

    test('the one across admits it once the kite is slated whole, or after thirty layings', () {
      final full = Levels.at(4).slatings.first;
      var play = Play.of(Levels.at(4));
      for (final (a, b) in full) {
        play = play.tap(a).tap(b);
      }
      expect(play.isFull, isTrue);
      expect(play.gaveUp, isTrue);
      expect(play.acrossCount.isEven, isTrue);
      expect(play.next, isNull);
      var wander = Play.of(Levels.at(4));
      for (var k = 0; k < 30; k++) {
        wander = wander.tap(0).tap(1).tap(0);
      }
      expect(wander.gaveUp, isTrue);
    });

    test('the why tells the even rows and the sweep', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('Every row is even'));
      expect(words, contains('This is ask 5, The One Across.'));
      expect(words, contains('laid out in full'));
    });
  });
}
