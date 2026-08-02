import 'package:flutter_test/flutter_test.dart';
import 'package:haulyard/yard/haul.dart';
import 'package:haulyard/yard/levels.dart';
import 'package:haulyard/yard/yard.dart';

/// A yard written out as a picture, for the tests that want an exact one.
Yard yardOf(List<String> rows) =>
    Level(name: 'test', about: '', rows: rows, par: 0).start;

Ground groundOf(List<String> rows) =>
    Level(name: 'test', about: '', rows: rows, par: 0).ground;

void main() {
  group('the ground', () {
    final ground = groundOf(const [
      '#####',
      '#. @#',
      '#####',
    ]);

    test('knows where a step goes, and where it does not', () {
      expect(ground.beyond(6, Way.right), 7);
      expect(ground.beyond(6, Way.left), -1, reason: 'that is a wall');
      expect(ground.beyond(6, Way.up), -1);
    });

    test('makes no difference between a wall and the edge', () {
      // Nothing goes into either, and keeping them apart would mean every
      // caller checking two things instead of one.
      expect(ground.isWall(ground.beyond(6, Way.up)), isTrue);
      expect(ground.isWall(-1), isTrue);
    });
  });

  group('a step', () {
    test('walks into an empty square', () {
      final yard = yardOf(const [
        '#####',
        '#@ .#',
        '#####',
      ]);
      final walked = yard.step(Way.right)!;
      expect(walked.hauler, yard.hauler + 1);
      expect(walked.pushes, 0, reason: 'walking about is free');
    });

    test('shoves a crate, and counts it', () {
      final yard = yardOf(const [
        '######',
        '#@\$ .#',
        '######',
      ]);
      final shoved = yard.step(Way.right)!;
      expect(shoved.pushes, 1);
      expect(shoved.crates, [yard.crates.single + 1]);
      expect(shoved.hauler, yard.crates.single);
    });

    test('will not walk into a wall', () {
      final yard = yardOf(const ['####', '#@.#', '####']);
      expect(yard.step(Way.up), isNull);
      expect(yard.step(Way.left), isNull);
    });

    test('will not shove a crate into a wall or into another crate', () {
      expect(
        yardOf(const ['####', '#@\$#', '####']).step(Way.right),
        isNull,
        reason: 'there is a wall right behind it',
      );
      expect(
        yardOf(const ['#######', '#@\$\$ .#', '#######']).step(Way.right),
        isNull,
        reason: 'crates do not shove each other along',
      );
    });

    test('and a shove that cannot be walked to is not a shove', () {
      // The hauler is shut in the left pocket; the crate on the right can be
      // shoved by nobody.
      final yard = yardOf(const [
        '########',
        '#@ #\$ .#',
        '########',
      ]);
      expect(yard.after(Shove(yard.crates.single, Way.right)), isNull);
    });
  });

  group('a picture', () {
    test('reads walls, marks, crates and the hauler', () {
      final yard = yardOf(const [
        '#####',
        '#@\$.#',
        '#####',
      ]);
      expect(yard.ground.walls, hasLength(12));
      expect(yard.ground.marks, {8});
      expect(yard.crates, [7]);
      expect(yard.hauler, 6);
    });

    test('reads a crate already on a mark, and the hauler on one', () {
      final yard = yardOf(const [
        '#####',
        '#+*.#',
        '#####',
      ]);
      expect(yard.ground.marks, {6, 7, 8});
      expect(yard.crates, [7]);
      expect(yard.hauler, 6);
      expect(yard.onMarks, 1);
    });

    test('walls off the end of a row written short', () {
      final ground = groundOf(const ['####', '#@.', '####']);
      expect(ground.isWall(7), isTrue, reason: 'the row stopped before here');
    });
  });

  group('every yard', () {
    test('has as many crates as marks, one hauler, and room to stand', () {
      for (var i = 0; i < Levels.count; i++) {
        final level = Levels.at(i);
        final start = level.start;
        expect(start.crates, hasLength(level.ground.marks.length),
            reason: '${level.name} has crates and marks in different numbers');
        expect(
          level.rows.join().split('').where((c) => c == '@' || c == '+').length,
          1,
          reason: '${level.name} does not have exactly one hauler',
        );
        expect(level.ground.isFloor(start.hauler), isTrue);
        expect(start.isDone, isFalse,
            reason: '${level.name} is finished before it starts');
      }
    });

    test('is finished in the number of shoves it says it is', () {
      // The claim on every yard. The par is not a designer's guess: this
      // searches the whole yard and fails if the shortest way through is not
      // the number printed on the level.
      for (var i = 0; i < Levels.count; i++) {
        final level = Levels.at(i);
        final haul = Hauler(level.ground).from(level.start);
        expect(haul.pushes, level.par,
            reason: '${level.name} says ${level.par} and takes ${haul.pushes}');
      }
    });

    test('and the way through it actually works when it is played', () {
      // A number out of a search is one thing; a list of shoves that a hauler
      // could really make is another. This replays it, checking at every step
      // that the hauler could walk to where they would have to stand.
      for (var i = 0; i < Levels.count; i++) {
        final level = Levels.at(i);
        final haul = Hauler(level.ground).from(level.start);

        var yard = level.start;
        for (final shove in haul.line) {
          final next = yard.after(shove);
          expect(next, isNotNull,
              reason: '${level.name}: $shove cannot be made from here');
          yard = next!;
        }
        expect(yard.isDone, isTrue, reason: '${level.name} was not finished');
        expect(yard.pushes, level.par);
      }
    });
  });

  group('a yard that has been spoiled', () {
    final ground = groundOf(const [
      '######',
      '#    #',
      '# .  #',
      '#  \$ #',
      '#  @ #',
      '######',
    ]);
    final hauler = Hauler(ground);

    test('is spotted the moment a crate reaches a corner', () {
      // Shoved up twice and then right, the crate ends in the top right
      // corner and nothing will ever move it again.
      final yard = Yard.of(ground, 27, [21]);
      final once = yard.after(const Shove(21, Way.up))!;
      final twice = once.after(const Shove(15, Way.up))!;
      final stuck = twice.after(const Shove(9, Way.right))!;

      expect(hauler.isLostAt(stuck, [stuck.moved!]), isTrue);
      expect(hauler.from(stuck).canBeDone, isFalse);
    });

    test('and a corner that is a mark is not spoiled at all', () {
      final onAMark = groundOf(const [
        '#####',
        '#.  #',
        '# \$ #',
        '# @ #',
        '#####',
      ]);
      final yard = Yard.of(onAMark, 17, [12]);
      final up = yard.after(const Shove(12, Way.up))!;
      final home = up.after(Shove(up.crates.single, Way.left))!;
      expect(home.isDone, isTrue);
      expect(Hauler(onAMark).isLostAt(home, home.crates), isFalse);
    });

    test('and a wall a crate can never come off is never worth entering', () {
      // The squares along the top wall are dead: a crate there can only slide
      // along the wall, and there is no mark on it to slide to.
      expect(hauler.live.contains(7), isFalse, reason: 'against the top wall');
      expect(hauler.live.contains(14), isTrue, reason: 'that one is the mark');
    });
  });

  group('two positions', () {
    test('are the same when the hauler is shut in the same pocket', () {
      // Both crates in the middle, the hauler above them either way. The same
      // shoves are possible from both, so the search must not do the work
      // twice.
      final ground = groundOf(const [
        '#####',
        '#   #',
        '#\$\$ #',
        '#  .#',
        '#####',
      ]);
      final left = Yard.of(ground, 6, [11, 12]);
      final right = Yard.of(ground, 8, [11, 12]);
      expect(left.sameness, right.sameness);
    });

    test('and different when the crates shut them into different ones', () {
      final ground = groundOf(const [
        '#####',
        '#  .#',
        '#\$\$\$#',
        '#   #',
        '#####',
      ]);
      final above = Yard.of(ground, 6, [11, 12, 13]);
      final below = Yard.of(ground, 16, [11, 12, 13]);
      expect(above.sameness, isNot(below.sameness));
    });
  });
}
