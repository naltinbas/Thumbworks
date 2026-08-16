import 'dart:io';

import 'package:sharewick/trio/levels.dart';
import 'package:sharewick/trio/play.dart';
import 'package:sharewick/trio/rules.dart';

/// Looks at every family of the twenty trios two ways, counts what
/// Erdos, Ko and Rado promise, and refuses the bake on any disagreement.
///
/// Run with: dart run tool/check_trios.dart
void main() {
  var failed = false;
  void check(bool ok, String what) {
    if (!ok) {
      failed = true;
      stderr.writeln('DISAGREEMENT: $what');
    }
  }

  String commas(int n) => n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
  int choose(int n, int k) {
    var out = 1;
    for (var i = 1; i <= k; i++) {
      out = out * (n - k + i) ~/ i;
    }
    return out;
  }

  check(Rules.friends == 6 && Rules.count == 20 && Rules.families == 1048576, 'the friends and trios');
  check(Rules.missingPairs.length == 10, 'missing pairs ${Rules.missingPairs.length}');
  for (final (t, u) in Rules.missingPairs) {
    check(!Rules.share(t, u) && (t | u) == Rules.all, 'a missing pair that meets: ${Rules.nameOf(t)} ${Rules.nameOf(u)}');
  }
  for (final t in Rules.trios) {
    for (final u in Rules.trios) {
      check(Rules.share(t, u) == (u != Rules.otherThree(t)), '${Rules.nameOf(t)} and ${Rules.nameOf(u)}');
    }
  }

  final bySize = List<int>.filled(21, 0), sharingBySize = List<int>.filled(21, 0);
  var sharing = 0, stars = 0, noStar = 0, even = 0, fifteens = 0, fewerApart = 0, nineLowHands = 0;
  final tensByHand = <int, int>{};
  for (var family = 0; family < Rules.families; family++) {
    final n = Rules.size(family);
    bySize[n]++;
    final apart = Rules.apart(family);
    check(apart.isEmpty == Rules.oneOfEachPair(family), 'the two voices differ on ${Rules.tell(family)}');
    if (apart.isEmpty) {
      sharing++;
      sharingBySize[n]++;
      if (n == 10) {
        final h = Rules.hands(family);
        if (Rules.star(family) != null) {
          stars++;
        } else {
          noStar++;
        }
        if (h.every((x) => x == 5)) even++;
        final mx = h.reduce((a, b) => a > b ? a : b);
        tensByHand[mx] = (tensByHand[mx] ?? 0) + 1;
      }
      if (n == 9 && Rules.hands(family).every((x) => x <= 4)) nineLowHands++;
    }
    if (n == 15) {
      if (apart.length == 5) fifteens++;
      if (apart.length < 5) fewerApart++;
    }
  }
  check(sharing == 59049, 'sharing $sharing');
  for (var m = 0; m <= 20; m++) {
    check(bySize[m] == choose(20, m), 'families of $m: ${bySize[m]}');
    check(sharingBySize[m] == (m <= 10 ? choose(10, m) * (1 << m) : 0), 'sharing families of $m: ${sharingBySize[m]}');
  }
  check(stars == 6 && noStar == 1018 && even == 12, 'tens: stars $stars, without $noStar, even $even');
  check(tensByHand[10] == 6 && tensByHand[9] == 60 && tensByHand[8] == 270 && tensByHand[7] == 440 && tensByHand[6] == 236 && tensByHand[5] == 12, 'tens by fullest hand $tensByHand');
  check(nineLowHands == 0, 'nines with no hand over four: $nineLowHands');
  check(fifteens == 8064 && fewerApart == 0, 'fifteens with five apart $fifteens, with fewer $fewerApart');
  check(Rules.apart(Rules.families - 1).length == 10, 'the twenty');
  final evenOne = Rules.familyOf('ABC, ABD, ACE, ADF, AEF, BCF, BDE, BEF, CDE, CDF');
  check(Rules.sharing(evenOne) && Rules.hands(evenOne).every((h) => h == 5), 'the even hand named');
  final starA = Rules.familyOf('ABC, ABD, ABE, ABF, ACD, ACE, ACF, ADE, ADF, AEF');
  check(Rules.star(starA) == 0 && Rules.hands(starA).join(',') == '10,4,4,4,4,4', 'the star of A');

  // The asks.
  for (final level in Levels.all) {
    var ways = 0;
    for (var family = 0; family < Rules.families; family++) {
      if (level.meets(family)) ways++;
    }
    check(ways == level.ways, '${level.name}: ${level.ways} said, $ways swept');
    final aim = level.aim;
    check((aim == null) == !level.winnable, '${level.name}: aim $aim');
    if (aim != null) check(level.meets(aim), '${level.name}: the aim misses');
    final open = Play.of(level);
    check(!open.isOver, '${level.name}: opens over');
    if (aim != null) {
      var play = open;
      var steps = 0;
      while (!play.isDone && steps < 40) {
        final (trio, _) = play.next!;
        play = play.tap(trio);
        steps++;
      }
      check(play.isDone && play.moves == Rules.size(aim), '${level.name}: the pointer never lands, or takes ${play.moves} taps');
    }
  }
  check(Rules.tell(Levels.at(1).aim!) == 'ABC, ABD, ABE, ABF, ACD, ACE, ACF, ADE, ADF, AEF', 'the star\'s aim');
  check(Rules.tell(Levels.at(2).aim!) == 'ABC, ABD, ACE, ADF, AEF, BCF, BDE, BEF, CDE, CDF', 'the even hand\'s aim');
  var dead = Play.of(Levels.at(4));
  for (final t in Rules.trios.take(11)) {
    dead = dead.tap(t);
  }
  dead = dead.tap(Rules.trios[10]).tap(Rules.trios[11]).tap(Rules.trios[11]).tap(Rules.trios[12]);
  check(dead.seen.length == 3 && dead.gaveUp, 'the eleven does not admit it after three families');

  if (failed) {
    stderr.writeln('The bake is refused.');
    exit(1);
  }

  stdout.writeln('every family of the twenty trios of six friends taken, ${commas(Rules.families)}, every pair of trios in each looked at for a shared friend, and each family asked again only whether it takes both trios of any of the ten missing pairs, a trio and its other three, the two agreeing on all ${commas(Rules.families)}: ${commas(sharing)} families share throughout, three to the ten, and by size they run 1, 20, 180, 960, 3,360, 8,064, 13,440, 15,360, 11,520, 5,120 and ${commas(sharingBySize[10])}, ten choose the size times two to it, with none of eleven or more; of the ${commas(sharingBySize[10])} sharing tens $stars are stars, all holding one friend, ${commas(noStar)} hold no friend throughout, ${tensByHand[9]} hold one in nine, and $even deal every friend five; no sharing nine keeps every friend to four; fifteen trios have five pairs apart at the fewest, ${commas(fifteens)} families of the ${commas(bySize[15])} exactly five, and the twenty have ten\n');
  final width = Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final tail = level.winnable
        ? '${commas(level.ways)} of the ${commas(Rules.families)} families land${level.ways == 1 ? 's' : ''} it'
        : 'none of the ${commas(Rules.families)}, and the ten missing pairs said so first';
    stdout.writeln(' ${i + 1} ${level.name.padRight(width)} ${level.task}: $tail');
  }
}
