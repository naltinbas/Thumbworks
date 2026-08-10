import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:linacre/wire/game.dart';
import 'package:linacre/wire/net.dart';
import 'package:linacre/wire/play.dart';
import 'package:linacre/wire/rounds.dart';
import 'package:linacre/wire/webs.dart';

/// A net made up at random: a run joining every post, then some more wire.
Net _madeUp(Random random, {int posts = 5, int extra = 3}) {
  final wires = <Wire>[];
  final taken = <String>{};

  void join(int one, int other) {
    final key = one < other ? '$one-$other' : '$other-$one';
    if (one == other || !taken.add(key)) return;
    wires.add(Wire(one, other));
  }

  for (var post = 1; post < posts; post++) {
    join(random.nextInt(post), post);
  }
  for (var more = 0; more < posts + extra; more++) {
    join(random.nextInt(posts), random.nextInt(posts));
  }

  return Net(
    name: 'made up',
    posts: [
      for (var post = 0; post < posts; post++)
        Post('P$post', random.nextDouble(), random.nextDouble()),
    ],
    wires: wires,
    stationA: 0,
    stationB: posts - 1,
  );
}

void main() {
  group('the net', () {
    final net = Rounds.at(2).net;

    test('knows when braced wire alone joins the stations', () {
      expect(net.bracedJoin(0), isFalse);
      // Aldergate to North Post, North Post to Zeal End.
      expect(net.bracedJoin(1 | 4), isTrue);
    });

    test('and when nothing joins them any more', () {
      expect(net.anythingJoins(0), isTrue);
      // Cut both wires out of Aldergate.
      expect(net.anythingJoins(1 | 2), isFalse);
    });

    test('shrinking merges braced posts and drops cut wire', () {
      // Brace Aldergate to North Post: four posts become three.
      final small = net.shrunk(0, 1);
      expect(small.net.count, 3);
      expect(small.net.many, 4);
      // Cut the bridge as well: three posts, three wires.
      final smaller = net.shrunk(1 << 4, 1);
      expect(smaller.net.many, 3);
      // Every small wire names a real wire of the whole net.
      for (final wire in smaller.wireOf) {
        expect(wire, inInclusiveRange(0, net.many - 1));
      }
    });
  });

  group('the search', () {
    test('one wire: the cutter first cuts it, the linesman first holds it', () {
      final one = Net(
        name: 'one',
        posts: const [Post('A', 0, 0), Post('Z', 1, 0)],
        wires: const [Wire(0, 1)],
        stationA: 0,
        stationB: 1,
      );
      expect(Game(one).settle(0, 0, Part.cutter).cutterWins, isTrue);
      expect(Game(one).settle(0, 0, Part.linesman).cutterWins, isFalse);
    });

    test('two wires side by side: the linesman holds either way', () {
      final twin = Net(
        name: 'twin',
        posts: const [Post('A', 0, 0), Post('Z', 1, 0)],
        wires: const [Wire(0, 1), Wire(0, 1)],
        stationA: 0,
        stationB: 1,
      );
      expect(Game(twin).settle(0, 0, Part.cutter).cutterWins, isFalse);
      expect(Game(twin).settle(0, 0, Part.linesman).cutterWins, isFalse);
    });
  });

  group('Lehman', () {
    test('the linesman moving second holds exactly when two webs exist, on '
        'two hundred nets made up at random', () {
      // The anchor. The game search knows nothing about webs and the web
      // search knows nothing about turns, and they have to agree about every
      // net there is. Lehman proved they do in 1964.
      final random = Random(1964);
      var held = 0;
      for (var go = 0; go < 200; go++) {
        final net = _madeUp(
          random,
          posts: 4 + random.nextInt(3),
          extra: random.nextInt(4),
        );
        if (net.many > 11) continue;

        final linesmanHolds =
            !Game(net).settle(0, 0, Part.cutter).cutterWins;
        final webs = Webs.findTwoWebs(net);
        expect(linesmanHolds, webs != null,
            reason: 'on ${net.wires.map((w) => '${w.from}-${w.to}')}');
        if (webs != null) held++;
      }
      expect(held, greaterThan(20));
    });

    test('and the webs it finds are real: no shared wire, both join the '
        'stations', () {
      final random = Random(43);
      for (var go = 0; go < 60; go++) {
        final net = _madeUp(random, posts: 4 + random.nextInt(2));
        if (net.many > 10) continue;
        final webs = Webs.findTwoWebs(net);
        if (webs == null) continue;

        expect(webs.one & webs.other, 0);
        expect(net.bracedJoin(webs.one), isTrue);
        expect(net.bracedJoin(webs.other), isTrue);
      }
    });
  });

  group('every round that ships', () {
    setUp(Rounds.forget);

    for (var number = 0; number < Rounds.count; number++) {
      final round = Rounds.at(number);

      test('${round.name} says what the search says', () {
        final settled = Rounds.gameFor(number).settle(0, 0, round.part);
        final playerWins =
            settled.cutterWins == (round.part == Part.cutter);
        if (round.hopeless) {
          expect(playerWins, isFalse);
        } else {
          expect(playerWins, isTrue);
          expect((settled.inMoves + 1) ~/ 2, round.fewest);
        }
      });
    }

    test('the hopeless round is hopeless because of two webs', () {
      final hopeless = Rounds.all.indexWhere((round) => round.hopeless);
      expect(Webs.findTwoWebs(Rounds.at(hopeless).net), isNotNull);
    });

    test('the bridge net is won by whoever moves first', () {
      final net = Rounds.at(2).net;
      expect(Game(net).settle(0, 0, Part.cutter).cutterWins, isTrue);
      expect(Game(net).settle(0, 0, Part.linesman).cutterWins, isFalse);
    });
  });

  group('a round against the machine', () {
    late Play play;

    setUp(() {
      Rounds.forget();
      play = Play.of(Rounds.at(2), Rounds.gameFor(2));
    });

    test('starts untouched, and the player can still win at par', () {
      expect(play.made, 0);
      expect(play.isOver, isFalse);
      expect(play.couldFinishIn, Rounds.at(2).fewest);
    });

    test('touching a wire cuts it and the machine braces back', () {
      play = play.touch(4);
      expect(play.isCut(4), isTrue);
      expect(play.theirLast, isNot(-1));
      expect(play.isBraced(play.theirLast), isTrue);
      expect(play.made, 1);
    });

    test('a wire already spoken for cannot be touched', () {
      play = play.touch(4);
      final held = play.theirLast;
      expect(identical(play.touch(4), play), isTrue);
      expect(identical(play.touch(held), play), isTrue);
    });

    test('the wrong wire costs, and the game knows at once', () {
      // On the loop road the winning first cuts are the two loop wires.
      // Cutting along the run instead still wins, but not at par, and the
      // game says so the moment it happens rather than at the end.
      var slow = Play.of(Rounds.at(0), Rounds.gameFor(0));
      expect(slow.couldFinishIn, Rounds.at(0).fewest);
      slow = slow.touch(0);
      expect(slow.couldFinishIn, greaterThan(Rounds.at(0).fewest!));
    });

    test('take back undoes the whole exchange', () {
      play = play.touch(4);
      expect(play.back.made, 0);
      expect(play.back.cut, 0);
      expect(play.back.braced, 0);
    });

    test('following the search wins every round that can be won, at par', () {
      for (var number = 0; number < Rounds.count; number++) {
        final round = Rounds.at(number);
        if (round.hopeless) continue;
        var walk = Play.of(round, Rounds.gameFor(number));
        var guard = 0;
        while (!walk.isOver) {
          if (guard++ > 12) fail('${round.name} never ended');
          walk = walk.touch(walk.next!);
        }
        expect(walk.won, isTrue, reason: round.name);
        expect(walk.made, round.fewest, reason: round.name);
        expect(walk.isFewest, isTrue, reason: round.name);
      }
    });

    test('the machine never loses the hopeless round, however it is played',
        () {
      final hopeless = Rounds.all.indexWhere((round) => round.hopeless);
      final random = Random(7);
      for (var go = 0; go < 30; go++) {
        var walk = Play.of(Rounds.at(hopeless), Rounds.gameFor(hopeless));
        var guard = 0;
        while (!walk.isOver) {
          if (guard++ > 12) fail('it never ended');
          final free = [
            for (var wire = 0; wire < walk.net.many; wire++)
              if (walk.isFree(wire)) wire,
          ];
          walk = walk.touch(free[random.nextInt(free.length)]);
        }
        expect(walk.won, isFalse);
        expect(walk.isHeld, isTrue);
      }
    });

    test('the live webs appear the moment they settle the rest', () {
      // On the doubled line as linesman, the webs are there from the start.
      final doubled = Rounds.all.indexWhere(
          (round) => round.part == Part.linesman && round.name == 'The Doubled Line');
      final walk = Play.of(Rounds.at(doubled), Rounds.gameFor(doubled));
      expect(walk.websNow, isNotNull);

      // On the bridge as cutter there are none, at any point.
      expect(play.websNow, isNull);
    });
  });
}
