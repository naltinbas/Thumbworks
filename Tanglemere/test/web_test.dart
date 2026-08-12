import 'package:flutter_test/flutter_test.dart';
import 'package:tanglemere/web/play.dart';
import 'package:tanglemere/web/rules.dart';
import 'package:tanglemere/web/webs.dart';

void main() {
  group('the web', () {
    test('holds its threads and triangles', () {
      final five = Rules(5);
      expect(five.threads, 10);
      expect(five.triangles, hasLength(10));
      final six = Rules(6);
      expect(six.threads, 15);
      expect(six.triangles, hasLength(20));
    });

    test('a closing thread names its triangle', () {
      final rules = Rules(5);
      // Threads 0 (0-1), 1 (0-2): thread between 1 and 2 closes.
      final held = (1 << 0) | (1 << 1);
      final thread =
          rules.edges.indexWhere((edge) => edge == (1, 2));
      expect(rules.closing(held, thread), isNotNull);
      expect(rules.closing(held, rules.edges.indexWhere(
          (edge) => edge == (3, 4))), isNull);
    });
  });

  group('the Ramsey pair', () {
    test('five posts keep twelve safe paintings, all rings', () {
      final rules = Rules(5);
      expect(rules.safePaintings(), 12);
    });

    test('six posts keep none, and the counting argument finds the '
        'triangle every time', () {
      final rules = Rules(6);
      expect(rules.safePaintings(), 0);
      for (var paint = 0; paint < (1 << 15); paint++) {
        final (x, y, z) = rules.pigeonTriangle(paint);
        final a = (paint >> x) & 1;
        final b = (paint >> y) & 1;
        final c = (paint >> z) & 1;
        expect(a == b && b == c, isTrue, reason: 'painting $paint');
      }
    });
  });

  group('the search', () {
    test('reads the famous standings', () {
      expect(Rules(5).value(0, 0), 0);
      expect(Rules(6).value(0, 0), -1);
    });

    test('every shipped standing is what the search says', () {
      for (var number = 0; number < Webs.count; number++) {
        final web = Webs.at(number);
        final rules = Rules(web.dots);
        final standing = web.playerFirst
            ? rules.value(0, 0)
            : -rules.value(0, 0);
        expect(standing, web.standing, reason: web.name);
      }
    });
  });

  group('a web in play', () {
    test('starts bare, the house opening where it weaves first', () {
      final first = Play.of(Webs.at(0));
      expect(first.woven, 0);
      final second = Play.of(Webs.at(2)).houseOpens();
      expect(second.woven, 1);
      expect(second.theirs, isNot(0));
    });

    test('a weave claims the thread and the house replies', () {
      var play = Play.of(Webs.at(0));
      play = play.weave(play.next!);
      expect(play.woven, 2);
      expect(play.mine, isNot(0));
      expect(play.theirs, isNot(0));
    });

    test('take back returns the loom as it stood', () {
      final start = Play.of(Webs.at(0));
      final woven = start.weave(start.next!);
      expect(woven.back.back.woven, 0);
    });

    test('closing your own triangle ends the weave lost', () {
      // Claim three threads of one triangle by hand against a house
      // that weaves elsewhere: find a line where that is possible by
      // just trying the triangle's threads in turn when free.
      var play = Play.of(Webs.at(0));
      final (x, y, z) = play.rules.triangles.first;
      for (final thread in [x, y, z]) {
        if (play.isOver) break;
        if (play.isFree(thread)) play = play.weave(thread);
      }
      // Either the player closed it, or the house stole a thread of
      // it; both are lawful weaves. When closed, the loss is the
      // player's and the triangle is named.
      if (play.lostBy == true) {
        expect(play.closedTriangle, isNotNull);
        expect(play.isOver, isTrue);
      }
    });

    test('following the search draws both five-post webs', () {
      for (final number in const [0, 1]) {
        var play = Play.of(Webs.at(number)).houseOpens();
        var guard = 0;
        while (!play.isOver) {
          if (guard++ > 12) fail('the five posts never settled');
          play = play.weave(play.next!);
        }
        expect(play.isDrawn, isTrue,
            reason: Webs.at(number).name);
      }
    });

    test('following the search wins the six posts from the second '
        'seat', () {
      var play = Play.of(Webs.at(2)).houseOpens();
      var guard = 0;
      while (!play.isOver) {
        if (guard++ > 10) fail('the six posts never settled');
        play = play.weave(play.next!);
      }
      expect(play.playerWon, isTrue);
    });

    test('the first thread loses however well it is woven', () {
      var play = Play.of(Webs.at(3));
      expect(play.standing, -1);
      var guard = 0;
      while (!play.isOver) {
        if (guard++ > 10) fail('the first thread never settled');
        play = play.weave(play.next!);
      }
      expect(play.lostBy, isTrue);
      expect(play.closedTriangle, isNotNull);
    });
  });
}
