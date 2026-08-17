import 'dart:io';

import 'package:hedgemere/hedge/levels.dart';
import 'package:hedgemere/hedge/play.dart';
import 'package:hedgemere/hedge/rules.dart';

/// Peels every hedge the dials reach and every labelled hedge up to
/// eight posts, measures each one a second way, and refuses the bake on
/// any disagreement.
///
/// Run with: dart run tool/check_hedges.dart
void main() {
  var failed = false;
  void check(bool ok, String what) {
    if (!ok) {
      failed = true;
      stderr.writeln('DISAGREEMENT: $what');
    }
  }

  String commas(int n) => n.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');

  // The two voices, written out for any number of posts so the sweep of
  // labelled hedges can use them too.
  (List<int>, int) peelOf(int n, List<Set<int>> joined) {
    final left = joined.map((p) => p.toSet()).toList();
    final standing = <int>{for (var p = 1; p <= n; p++) p};
    var rounds = 0;
    while (standing.length > 2) {
      final leaves = [
        for (final p in standing)
          if (left[p].length <= 1) p,
      ];
      for (final p in leaves) {
        for (final q in left[p]) {
          left[q].remove(p);
        }
        left[p].clear();
        standing.remove(p);
      }
      rounds++;
    }
    return (standing.toList()..sort(), rounds);
  }

  (List<int>, List<int>) walkFrom(int n, List<Set<int>> joined, int from) {
    final away = List.filled(n + 1, -1);
    final came = List.filled(n + 1, 0);
    away[from] = 0;
    final queue = <int>[from];
    for (var head = 0; head < queue.length; head++) {
      final p = queue[head];
      for (final q in joined[p]) {
        if (away[q] < 0) {
          away[q] = away[p] + 1;
          came[q] = p;
          queue.add(q);
        }
      }
    }
    return (away, came);
  }

  (List<int>, int, int) measureOf(int n, List<Set<int>> joined) {
    final worst = List.filled(n + 1, 0);
    for (var p = 1; p <= n; p++) {
      final (away, _) = walkFrom(n, joined, p);
      var far = 0;
      for (var q = 1; q <= n; q++) {
        if (away[q] > far) far = away[q];
      }
      worst[p] = far;
    }
    var radius = worst[1], longest = 0;
    for (var p = 1; p <= n; p++) {
      if (worst[p] < radius) radius = worst[p];
      if (worst[p] > longest) longest = worst[p];
    }
    return (
      [for (var p = 1; p <= n; p++) if (worst[p] == radius) p],
      radius,
      longest
    );
  }

  /// The halfway posts of every longest walk, or null when two longest
  /// walks disagree about where halfway is.
  List<int>? halfwayOf(int n, List<Set<int>> joined, int longest) {
    List<int>? held;
    for (var u = 1; u <= n; u++) {
      final (away, came) = walkFrom(n, joined, u);
      for (var v = u + 1; v <= n; v++) {
        if (away[v] != longest) continue;
        final walk = <int>[v];
        while (walk.last != u) {
          walk.add(came[walk.last]);
        }
        final at = longest ~/ 2;
        final halfway = longest.isEven
            ? [walk[at]]
            : ([walk[at], walk[at + 1]]..sort());
        if (held == null) {
          held = halfway;
        } else if (held.join(',') != halfway.join(',')) {
          return null;
        }
      }
    }
    return held;
  }

  List<Set<int>> joinedOf(int n, List<(int, int)> paths) {
    final out = [for (var p = 0; p <= n; p++) <int>{}];
    for (final (a, b) in paths) {
      out[a].add(b);
      out[b].add(a);
    }
    return out;
  }

  /// Every labelled hedge on n posts, one for each Prufer word.
  List<(int, int)> fromPrufer(int n, List<int> word) {
    final owed = List.filled(n + 1, 1);
    for (final x in word) {
      owed[x]++;
    }
    final paths = <(int, int)>[];
    var pointer = 1;
    while (owed[pointer] != 1) {
      pointer++;
    }
    var leaf = pointer;
    for (final x in word) {
      paths.add((leaf, x));
      owed[x]--;
      if (owed[x] == 1 && x < pointer) {
        leaf = x;
      } else {
        pointer++;
        while (owed[pointer] != 1) {
          pointer++;
        }
        leaf = pointer;
      }
    }
    paths.add((leaf, n));
    return paths;
  }

  // The hedges the dials reach.
  var hangings = 0, oneMiddle = 0, twoMiddle = 0;
  final byRounds = <int, int>{};
  final byLongest = <int, int>{};
  final ways = <String, int>{for (final level in Levels.all) level.name: 0};
  final cheapest = <String, int>{};
  for (final hanging in Rules.hangings()) {
    hangings++;
    final joined = Rules.joined(hanging);
    final (middle, rounds, fell) = Rules.peel(hanging);
    final (middle2, radius, longest) = Rules.measure(hanging);
    check(middle.join(',') == middle2.join(','),
        'the hedge ${Rules.tellHanging(hanging)}: $middle peeled, $middle2 measured');
    check(middle.length == 1 || middle.length == 2,
        'the hedge ${Rules.tellHanging(hanging)} has ${middle.length} middle posts');
    check(rounds == longest ~/ 2 && radius == (longest + 1) ~/ 2,
        'the hedge ${Rules.tellHanging(hanging)}: $rounds rounds, longest $longest, radius $radius');
    check((middle.length == 1) == longest.isEven,
        'the hedge ${Rules.tellHanging(hanging)}: ${middle.length} middles on a longest walk of $longest');
    final halfway = halfwayOf(Rules.posts, joined, longest);
    check(halfway != null && halfway.join(',') == middle.join(','),
        'the hedge ${Rules.tellHanging(hanging)}: halfway $halfway against middle $middle');
    // Every post either falls in a round or is left standing, and the
    // round it falls in is how far it is from the middle going in.
    for (var p = 1; p <= Rules.posts; p++) {
      check((fell[p] == 0) == middle.contains(p),
          'the hedge ${Rules.tellHanging(hanging)}: post $p fell in ${fell[p]}');
      check(fell[p] <= rounds, 'post $p fell after the last round');
    }
    if (middle.length == 1) {
      oneMiddle++;
    } else {
      twoMiddle++;
    }
    byRounds[rounds] = (byRounds[rounds] ?? 0) + 1;
    byLongest[longest] = (byLongest[longest] ?? 0) + 1;
    for (final level in Levels.all) {
      if (!level.meets(hanging)) continue;
      ways[level.name] = ways[level.name]! + 1;
      final taps = Rules.taps(Rules.opening, hanging);
      final held = cheapest[level.name];
      if (held == null || taps < held) cheapest[level.name] = taps;
    }
  }
  check(hangings == Rules.howManyHangings && hangings == 720,
      'hangings swept: $hangings');
  check(oneMiddle == 412 && twoMiddle == 308,
      'one middle $oneMiddle, two $twoMiddle');
  check(byRounds[1] == 84 && byRounds[2] == 604 && byRounds[3] == 32,
      'the rounds: $byRounds');
  check(
      byLongest[2] == 2 &&
          byLongest[3] == 82 &&
          byLongest[4] == 378 &&
          byLongest[5] == 226 &&
          byLongest[6] == 32,
      'the longest walks: $byLongest');
  // The board opens on two middles and two rounds, which is not one of
  // the asks, so no ask is landed before a tap is taken.
  final (openMiddle, openRounds, _) = Rules.peel(Rules.opening);
  check(openMiddle.length == 2 && openRounds == 2, 'the opening: $openMiddle');

  // Every labelled hedge from two posts to eight, one for each Prufer
  // word, peeled and measured the same two ways.
  var trees = 0, oneAll = 0, twoAll = 0;
  final perPosts = <int, (int, int, int)>{};
  for (var n = 2; n <= 8; n++) {
    var here = 0, c1 = 0, c2 = 0;
    final word = List.filled(n - 2, 1);
    while (true) {
      final joined = joinedOf(n, fromPrufer(n, word));
      final (middle, rounds) = peelOf(n, joined);
      final (middle2, radius, longest) = measureOf(n, joined);
      check(middle.join(',') == middle2.join(','),
          'the hedge of $n on $word: $middle peeled, $middle2 measured');
      check(middle.length == 1 || middle.length == 2,
          'the hedge of $n on $word has ${middle.length} middle posts');
      check(rounds == longest ~/ 2 && radius == (longest + 1) ~/ 2,
          'the hedge of $n on $word: $rounds rounds against a longest walk of $longest');
      check((middle.length == 1) == longest.isEven,
          'the hedge of $n on $word: ${middle.length} middles, longest $longest');
      final halfway = halfwayOf(n, joined, longest);
      check(halfway != null && halfway.join(',') == middle.join(','),
          'the hedge of $n on $word: halfway $halfway against middle $middle');
      here++;
      if (middle.length == 1) {
        c1++;
      } else {
        c2++;
      }
      var i = n - 3;
      while (i >= 0) {
        word[i]++;
        if (word[i] <= n) break;
        word[i] = 1;
        i--;
      }
      if (i < 0) break;
    }
    perPosts[n] = (here, c1, c2);
    trees += here;
    oneAll += c1;
    twoAll += c2;
  }
  check(trees == 280392, 'labelled hedges swept: $trees');
  check(oneAll == 137103 && twoAll == 143289,
      'one middle $oneAll, two $twoAll');
  check(perPosts[3]!.$3 == 0 && perPosts[2]!.$2 == 0,
      'three posts and two posts');
  check(
      perPosts[8]!.$1 == 262144 &&
          perPosts[8]!.$2 == 127688 &&
          perPosts[8]!.$3 == 134456,
      'eight posts: ${perPosts[8]}');

  // The asks.
  for (final level in Levels.all) {
    check(ways[level.name] == level.ways,
        '${level.name}: ${ways[level.name]} against ${level.ways}');
    if (level.winnable) {
      check(level.meets(level.aim!), '${level.name}: the aim misses');
      check(Rules.taps(Rules.opening, level.aim!) == cheapest[level.name],
          '${level.name}: the aim takes ${Rules.taps(Rules.opening, level.aim!)}, '
          'cheapest ${cheapest[level.name]}');
    } else {
      check(level.aim == null && ways[level.name] == 0,
          '${level.name} was landed');
    }
  }

  // The pointer lands every ask it can, in the fewest taps.
  for (final level in Levels.all.where((l) => l.winnable)) {
    var play = Play.of(level);
    var steps = 0;
    while (!play.isDone && steps < 40) {
      final aim = play.next;
      check(aim != null, '${level.name} lost its pointer');
      if (aim == null) break;
      play = play.step(aim.$1, aim.$2);
      steps++;
    }
    check(play.isDone, '${level.name} never landed');
    check(play.moves == level.fewest,
        '${level.name} in ${play.moves} against ${level.fewest}');
  }

  if (failed) {
    stderr.writeln('the hedge is not sound; no bake');
    exit(1);
  }

  final ledger = StringBuffer()
    ..write('every hedge the dials reach taken, ${commas(hangings)} of them '
        'over ${Rules.posts} posts, and each one found twice, once by '
        'stripping every post with a single path left round after round and '
        'once by walking outward from every post and keeping the ones whose '
        'worst walk is shortest: the two name the same posts on every hedge')
    ..write('; $oneMiddle of the ${commas(hangings)} come down to one post '
        'and $twoMiddle to two, none to three, and on every one of them the '
        'rounds come to half the longest walk rounded down, one middle post '
        'turns up exactly when that walk is an even number of steps, and the '
        'middle is the halfway mark of every longest walk there is')
    ..write('; the longest walks run ')
    ..write([
      for (final steps in byLongest.keys.toList()..sort())
        '${commas(byLongest[steps]!)} at $steps steps'
    ].join(', '))
    ..write(', and the peeling takes ')
    ..write([
      for (final rounds in byRounds.keys.toList()..sort())
        '${commas(byRounds[rounds]!)} at ${Rules.tellRounds(rounds)}'
    ].join(', '))
    ..write('; then every labelled hedge from two posts up to eight, one for '
        'each Prufer word, ${commas(trees)} hedges in all, peeled and '
        'measured the same two ways: ${commas(oneAll)} come down to one post '
        'and ${commas(twoAll)} to two, not one of them to three, and the same '
        'four laws hold on every one, ')
    ..write([
      for (var n = 2; n <= 8; n++)
        '$n posts ${commas(perPosts[n]!.$1)} '
            '${perPosts[n]!.$1 == 1 ? 'hedge' : 'hedges'}, '
            '${commas(perPosts[n]!.$2)} to one and ${commas(perPosts[n]!.$3)} '
            'to two'
    ].join('; '))
    ..write('; three posts is the only size where every hedge comes down to '
        'one, and two posts the only size where every hedge comes down to '
        'two');
  stdout.writeln(ledger);
  stdout.writeln();
  final width =
      Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final tail = level.winnable
        ? '${commas(level.ways)} of the ${commas(hangings)} hangings land it, '
            'the cheapest in ${level.fewest} '
            '${level.fewest == 1 ? 'tap' : 'taps'}'
        : 'none of the ${commas(hangings)}, and the halfway mark says why';
    stdout.writeln(' ${i + 1} ${level.name.padRight(width)} ${level.task}: $tail');
  }
}
