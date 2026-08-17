import 'package:flutter_test/flutter_test.dart';
import 'package:lampfield/lamp/levels.dart';
import 'package:lampfield/lamp/play.dart';
import 'package:lampfield/lamp/rules.dart';

/// The valley itself: the sums, the lost lamps and the reading back.
void main() {
  group('the lamps', () {
    test('send 256 messages, sorted into nine sums', () {
      final all = Rules.messages();
      expect(all.length, 256);
      expect(Rules.howManyMessages, 256);
      expect(all.map((m) => m.join()).toSet().length, 256);
      final sizes = <int, int>{};
      for (final m in all) {
        sizes[Rules.over9(m)] = (sizes[Rules.over9(m)] ?? 0) + 1;
      }
      expect(sizes.length, 9);
      expect(sizes[0], 30);
      expect(sizes.values.reduce((a, b) => a + b), 256);
      expect(sizes.values.reduce((a, b) => a > b ? a : b), 30);
    });

    test('a message is worth the places of its lit lamps', () {
      expect(Rules.weight([1, 1, 1, 1, 1, 1, 1, 1]), 36);
      expect(Rules.weight([0, 0, 0, 0, 0, 0, 0, 0]), 0);
      expect(Rules.weight(Rules.opening), 21);
      expect(Rules.over9(Rules.opening), 3);
      expect(Rules.inCode([1, 1, 1, 1, 1, 1, 1, 1]), isTrue);
      expect(Rules.inCode([0, 0, 0, 0, 0, 0, 0, 0]), isTrue);
      expect(Rules.inCode(Rules.opening), isFalse);
    });

    test('a lost lamp leaves seven', () {
      expect(Rules.lost([1, 0, 1, 0, 1, 0, 1, 0], 1), [0, 1, 0, 1, 0, 1, 0]);
      expect(Rules.lost([1, 0, 1, 0, 1, 0, 1, 0], 8), [1, 0, 1, 0, 1, 0, 1]);
      expect(Rules.lost(Rules.opening, 6).length, 7);
    });
  });

  group('the two voices', () {
    test('the reader gets every message in the code back, whichever lamp goes',
        () {
      var readings = 0;
      for (final message in Rules.messages()) {
        if (!Rules.inCode(message)) continue;
        for (var gone = 1; gone <= Rules.lamps; gone++) {
          readings++;
          expect(Rules.holds(message, gone), isTrue,
              reason: '${Rules.tellMessage(message)} lamp $gone');
        }
      }
      expect(readings, 240);
    });

    test('and the counting finds that message and no other', () {
      final code = [
        for (final m in Rules.messages())
          if (Rules.inCode(m)) m,
      ];
      for (final message in code) {
        for (var gone = 1; gone <= Rules.lamps; gone++) {
          final seen = Rules.lost(message, gone).join();
          final could = [
            for (final other in code)
              if ([
                for (var i = 1; i <= Rules.lamps; i++)
                  Rules.lost(other, i).join(),
              ].contains(seen))
                other,
          ];
          expect(could.length, 1, reason: 'from $seen');
          expect(could.first.join(), message.join());
        }
      }
    });

    test('no two messages in the code look the same with a lamp out', () {
      final left = <String, String>{};
      for (final message in Rules.messages()) {
        if (!Rules.inCode(message)) continue;
        for (var gone = 1; gone <= Rules.lamps; gone++) {
          final key = Rules.lost(message, gone).join();
          final held = left[key];
          expect(held == null || held == message.join(), isTrue,
              reason: 'two messages leave $key');
          left[key] = message.join();
        }
      }
    });

    test('the reader reads seven lamps and puts one back', () {
      expect(Rules.read([0, 0, 0, 0, 0, 0, 0]), [0, 0, 0, 0, 0, 0, 0, 0]);
      expect(Rules.read([1, 1, 1, 1, 1, 1, 1]), [1, 1, 1, 1, 1, 1, 1, 1]);
    });
  });

  group('the asks', () {
    test('are landed by as many messages as the sweep counted', () {
      for (final level in Levels.all) {
        var n = 0;
        for (final message in Rules.messages()) {
          if (level.meets(message)) n++;
        }
        expect(n, level.ways, reason: level.name);
      }
    });

    test('the fewest lamps each one takes', () {
      expect([for (final level in Levels.all) level.fewest], [2, 3, 3, 5, null]);
      for (final level in Levels.all.where((l) => l.winnable)) {
        var cheapest = 99;
        for (final message in Rules.messages()) {
          if (!level.meets(message)) continue;
          final taps = Rules.taps(Rules.opening, message);
          if (taps < cheapest) cheapest = taps;
        }
        expect(level.fewest, cheapest, reason: level.name);
      }
    });

    test('none of them is landed before a lamp is changed', () {
      for (final level in Levels.all) {
        expect(level.meets(Rules.opening), isFalse, reason: level.name);
      }
    });

    test('the four alight messages are all in the code', () {
      var n = 0;
      for (final message in Rules.messages()) {
        if (!Levels.at(1).meets(message)) continue;
        n++;
        expect(Rules.inCode(message), isTrue);
        expect(Rules.lit(message), 4);
      }
      expect(n, 8);
    });
  });

  group('a go', () {
    test('opens on the last three lamps lit', () {
      final play = Play.of(Levels.at(0));
      expect(play.message, [0, 0, 0, 0, 0, 1, 1, 1]);
      expect(play.weight, 21);
      expect(play.over9, 3);
      expect(play.inCode, isFalse);
      expect(play.moves, 0);
      expect(play.isDone, isFalse);
    });

    test('a tap lights a lamp or puts it out', () {
      var play = Play.of(Levels.at(3)).tap(1);
      expect(play.message[0], 1);
      expect(play.moves, 1);
      play = play.tap(1);
      expect(play.message[0], 0);
      expect(play.moves, 2);
    });

    test('a tap off the end of the valley does nothing', () {
      final play = Play.of(Levels.at(3));
      expect(identical(play.tap(0), play), isTrue);
      expect(identical(play.tap(9), play), isTrue);
    });

    test('back undoes the last lamp', () {
      final play = Play.of(Levels.at(3)).tap(1).tap(2);
      expect(play.message, [1, 1, 0, 0, 0, 1, 1, 1]);
      expect(play.back.message, [1, 0, 0, 0, 0, 1, 1, 1]);
      expect(play.back.moves, 1);
      final opening = Play.of(Levels.at(3));
      expect(identical(opening.back, opening), isTrue);
    });

    test('a message in the code mends every lamp', () {
      final play = Play.standing(Levels.at(0), const [1, 1, 1, 1, 1, 1, 1, 1]);
      expect(play.inCode, isTrue);
      expect(play.mended, 8);
      for (var gone = 1; gone <= Rules.lamps; gone++) {
        expect(play.readBack(gone), play.message);
      }
    });

    test('the pointer lands every ask, in the fewest lamps', () {
      for (final level in Levels.all.where((l) => l.winnable)) {
        var play = Play.of(level);
        while (!play.isDone) {
          final was = play.nearest!.$2;
          play = play.tap(play.next!);
          expect(play.nearest!.$2, was - 1, reason: level.name);
        }
        expect(play.moves, level.fewest, reason: level.name);
        expect(play.next, isNull, reason: level.name);
      }
    });

    test('the pointer says which lamp and which way', () {
      final play = Play.of(Levels.at(0));
      expect(play.pointed(1), 'Light lamp 1.');
      expect(play.pointed(6), 'Put lamp 6 out.');
    });

    test('the hopeless ask admits it after four messages', () {
      var play = Play.of(Levels.all.last);
      expect(play.gaveUp, isFalse);
      for (final lamp in [1, 2, 3, 4]) {
        play = play.tap(lamp);
      }
      expect(play.seen.length, 4);
      expect(play.gaveUp, isTrue);
      expect(identical(play.tap(5), play), isTrue);
    });

    test('a winnable ask never gives up', () {
      var play = Play.of(Levels.at(3));
      for (final lamp in [1, 2, 3, 4]) {
        play = play.tap(lamp);
      }
      expect(play.gaveUp, isFalse);
      expect(play.seen, isEmpty);
    });

    test('the why names the two who published the code', () {
      final words = whyWords(Play.of(Levels.all.last));
      expect(words, contains('Varshamov and Tenengolts'));
      expect(words, contains('Levenshtein'));
      expect(words, contains('Fool the Reader'));
    });
  });
}
