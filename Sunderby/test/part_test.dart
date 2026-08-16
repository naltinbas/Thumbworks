import 'package:flutter_test/flutter_test.dart';
import 'package:sunderby/part/levels.dart';
import 'package:sunderby/part/play.dart';
import 'package:sunderby/part/rules.dart';

/// The partitions, the folding, the turning, the asks and the play,
/// checked at the domain: nothing here touches a widget.
void main() {
  group('the parts', () {
    test('partitions, kinds, the folding and the turning', () {
      expect(Rules.partitions(4).map(Rules.told).toList(), ['4', '3 + 1', '2 + 2', '2 + 1 + 1', '1 + 1 + 1 + 1']);
      expect(Rules.partitions(8), hasLength(22));
      expect(Rules.allDifferent([5, 2, 1]), isTrue);
      expect(Rules.allDifferent([3, 3, 2]), isFalse);
      expect(Rules.allOdd([5, 1, 1, 1]), isTrue);
      expect(Rules.allEven([6, 2]), isTrue);
      expect(Rules.fold([5, 1, 1, 1]), [5, 2, 1]);
      expect(Rules.fold([3, 3, 1, 1]), [6, 2]);
      expect(Rules.fold([1, 1, 1, 1, 1, 1, 1, 1]), [8]);
      expect(Rules.turned([4, 3, 1]), [3, 2, 2, 1]);
      expect(Rules.turned([3, 3, 3]), [3, 3, 3]);
      expect(Rules.told([5, 2, 1]), '5 + 2 + 1');
      for (var n = 1; n <= 20; n++) {
        final all = Rules.partitions(n);
        final different = all.where(Rules.allDifferent).length, odd = all.where(Rules.allOdd).toList();
        expect(odd.length, different, reason: '$n');
        expect(odd.map(Rules.fold).map(Rules.told).toSet(), hasLength(different), reason: '$n');
        for (final p in all) {
          expect(Rules.told(Rules.turned(Rules.turned(p))), Rules.told(p), reason: '$n $p');
        }
      }
    });
  });

  group('the asks', () {
    test('five asks, the last of them hopeless', () {
      expect(Levels.all, hasLength(5));
      expect(Levels.all.where((l) => !l.winnable).map((l) => l.name), ['The Odd Evens']);
      for (final level in Levels.all) {
        expect(level.all.where(level.meets).length, level.ways, reason: level.name);
        final aim = level.aim;
        if (aim != null) expect(level.meets(aim), isTrue, reason: level.name);
        if (!level.winnable) expect(aim, isNull);
      }
    });

    test('each ask says what it wants', () {
      expect(Levels.at(0).task, 'sunder 8 into parts all different, three parts or more');
      expect(Levels.at(3).task, 'sunder 9 into three parts exactly, the largest of them 3');
      expect(Levels.at(4).task, 'sunder 9 into even parts all different');
    });

    test('an ask is met in any order of the parts', () {
      expect(Levels.at(0).meets([1, 5, 2]), isTrue);
      expect(Levels.at(0).meets([5, 3]), isFalse);
      expect(Levels.at(0).meets([4, 4]), isFalse);
      expect(Levels.at(1).meets([1, 5, 1, 1]), isTrue);
      expect(Levels.at(1).meets([3, 3, 2]), isFalse);
      expect(Levels.at(2).meets([4, 3, 2, 1]), isTrue);
      expect(Levels.at(3).meets([3, 3, 3]), isTrue);
      expect(Levels.at(3).meets([4, 3, 2]), isFalse);
      expect(Levels.at(4).meets([8, 1]), isFalse);
      expect(Levels.at(4).meets([]), isFalse);
    });
  });

  group('the play', () {
    test('opens with no parts', () {
      for (final level in Levels.all) {
        final play = Play.of(level);
        expect(play.parts, isEmpty);
        expect((play.sum, play.moves), (0, 0));
        expect(play.isOver, isFalse, reason: level.name);
      }
    });

    test('adds and drops, and a part too big is refused', () {
      var play = Play.of(Levels.at(0)).add(5).add(2);
      expect(play.parts, [5, 2]);
      expect(play.sum, 7);
      expect(play.add(2), same(play));
      expect(play.add(0), same(play));
      play = play.drop(0);
      expect(play.parts, [2]);
      expect(play.moves, 3);
      expect(play.drop(5), same(play));
      play = play.add(5).add(1);
      expect(play.sorted, [5, 2, 1]);
      expect(play.isDone, isTrue);
      expect(play.add(1), same(play));
    });

    test('back undoes one tap', () {
      final play = Play.of(Levels.at(0)).add(5).add(2);
      expect(play.back.parts, [5]);
      expect(play.back.back.parts, isEmpty);
    });

    test('the pointer adds the aim and drops strays', () {
      var play = Play.of(Levels.at(3));
      expect(play.next, (Aim.add, 3));
      play = play.add(4);
      expect(play.next, (Aim.drop, 0));
      play = play.drop(0).add(3).add(3).add(3);
      expect(play.isDone, isTrue);
      expect(play.next, isNull);
      expect(Play.pointed((Aim.add, 3)), 'Add a part of 3.');
      expect(Play.pointed((Aim.drop, 0)), 'Drop the ringed part.');
      expect(Play.of(Levels.at(4)).next, isNull);
    });

    test('following the pointer sunders every winnable ask', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        var steps = 0;
        while (!play.isDone && steps < 12) {
          final (aim, what) = play.next!;
          play = aim == Aim.add ? play.add(what) : play.drop(what);
          steps++;
        }
        expect(play.isDone, isTrue, reason: level.name);
      }
    });

    test('the odd evens admit it once nine is made whole, or after twenty taps', () {
      var play = Play.of(Levels.at(4)).add(8);
      expect(play.gaveUp, isFalse);
      play = play.add(1);
      expect(play.isFull, isTrue);
      expect(play.gaveUp, isTrue);
      expect(play.next, isNull);
      var wander = Play.of(Levels.at(4));
      for (var k = 0; k < 20; k++) {
        wander = wander.add(2).drop(0);
      }
      expect(wander.gaveUp, isTrue);
    });

    test('the why tells Euler and the sweep', () {
      final words = whyWords(Play.of(Levels.at(4)));
      expect(words, contains('Euler found in 1748'));
      expect(words, contains('This is ask 5, The Odd Evens.'));
      expect(words, contains('laid out in full'));
    });
  });
}
