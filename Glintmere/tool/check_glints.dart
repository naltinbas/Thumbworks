import 'dart:io';

import 'package:glintmere/glint/level.dart';
import 'package:glintmere/glint/levels.dart';
import 'package:glintmere/glint/play.dart';
import 'package:glintmere/glint/rules.dart';

/// Walks every setting of lamp, eye and bounce, asks both voices about
/// each, and refuses the bake on any disagreement.
///
/// Run with: dart run tool/check_glints.dart
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

  // The whole-number arithmetic the rest of it stands on.
  check(Rules.root(25) == 5, 'the root of 25');
  check(Rules.root(24) == null, '24 has no whole root');
  check(Rules.root(0) == 0, 'the root of nothing');
  check(Rules.within(25, 25, 10), '5 and 5 within 10');
  check(!Rules.within(25, 25, 9), '5 and 5 within 9');
  check(Rules.equals(25, 25, 100), '5 and 5 make the run of 10');
  check(!Rules.equals(20, 80, 100), 'a bent path is not the straight one');
  check(Rules.paces(25, 25) == 10, 'the paces of 5 and 5');
  check(Rules.paces(20, 80) == null, 'a path that is no whole number');

  // The sweep. Every lamp, every eye, every bounce.
  var settings = 0, shorter = 0, disagree = 0, matched = 0, exact = 0;
  for (var lampY = 1; lampY <= Rules.sky; lampY++) {
    for (var eyeY = 1; eyeY <= Rules.sky; eyeY++) {
      for (var lampX = 0; lampX < Rules.mirror; lampX++) {
        for (var eyeX = 0; eyeX < Rules.mirror; eyeX++) {
          final run = Rules.folded(lampX, lampY, eyeX, eyeY);
          for (final bounce in Rules.bounces) {
            settings++;
            final (one, two) = Rules.legs(lampX, lampY, eyeX, eyeY, bounce);
            // The first voice paces the path and holds it against the
            // straight run to the folded eye.
            final isExact = Rules.equals(one, two, run);
            // Nothing may beat that run. Beating it would mean the two
            // legs added come to less than it, which the pacing catches
            // by squaring.
            if (_under(one, two, run)) shorter++;
            // The second voice never measures anything: it crosses the
            // runs with the rises and asks whether the angles match.
            final byAngle =
                Rules.anglesMatch(lampX, lampY, eyeX, eyeY, bounce);
            if (byAngle) matched++;
            if (isExact) exact++;
            if (byAngle != isExact) disagree++;
            check(byAngle == isExact,
                'the voices differ at lamp($lampX,$lampY) eye($eyeX,$eyeY) '
                'bounce $bounce');
          }
        }
      }
    }
  }

  check(settings == 54925, 'settings swept: $settings');
  check(shorter == 0, 'paths beating their own straight run: $shorter');
  check(disagree == 0, 'the two voices differed $disagree times');
  check(matched == exact, 'matched $matched against exact $exact');
  check(matched == 1125, 'bounces where the angles match: $matched');

  // The board the asks stand on.
  check(Level.lampX == 2 && Level.lampY == 4, 'the lamp moved');
  check(Level.eyeX == 8 && Level.eyeY == 4, 'the eye moved');
  check(Level.folded == 100, 'the folded run squared: ${Level.folded}');
  check(Level.least == 10, 'the shortest path: ${Level.least}');
  final even = [
    for (final p in Rules.bounces)
      if (Rules.anglesMatch(Level.lampX, Level.lampY, Level.eyeX, Level.eyeY, p))
        p,
  ];
  check(even.length == 1 && even.first == 5,
      'the even-angled bounce: $even');
  final (oneLeg, twoLeg) = Rules.legs(
      Level.lampX, Level.lampY, Level.eyeX, Level.eyeY, 5);
  check(Rules.root(oneLeg) == 5 && Rules.root(twoLeg) == 5,
      'the legs at the even bounce: $oneLeg and $twoLeg');
  check(Rules.paces(oneLeg, twoLeg) == 10, 'the paces at the even bounce');

  // The asks.
  for (final level in Levels.all) {
    final ok = [for (final p in Rules.bounces) if (level.meets(p)) p];
    check(ok.length == level.ways,
        '${level.name}: ${ok.length} against ${level.ways}');
    check(!level.meets(Level.opening),
        '${level.name} is landed before the bounce moves');
    if (level.winnable) {
      final cheapest =
          ok.map((p) => (p - Level.opening).abs()).reduce((a, b) => a < b ? a : b);
      check(level.fewest == cheapest,
          '${level.name}: ${level.fewest} against $cheapest');
      check(level.paces >= Level.least,
          '${level.name} asks for less than the shortest path and is '
          'called winnable');
    } else {
      check(level.fewest == null && ok.isEmpty, '${level.name} was landed');
      check(level.paces < Level.least,
          '${level.name} is hopeless for some other reason than the run');
    }
  }
  // The asking tightens by one pace at a time and the count falls with
  // it, which is the whole of the ladder.
  for (var i = 1; i < Levels.count; i++) {
    check(Levels.at(i).paces == Levels.at(i - 1).paces - 1,
        'the asking does not tighten by one at ask ${i + 1}');
    check(Levels.at(i).ways < Levels.at(i - 1).ways,
        'the count did not fall at ask ${i + 1}');
  }

  // The pointer lands every ask it can, in the slides it promises.
  for (final level in Levels.all.where((l) => l.winnable)) {
    var play = Play.of(level);
    var steps = 0;
    while (!play.isDone && steps < 20) {
      final aim = play.next;
      check(aim != null, '${level.name} lost its pointer');
      if (aim == null) break;
      play = play.slide(aim);
      steps++;
    }
    check(play.isDone, '${level.name} was never landed');
    check(play.slides == level.fewest,
        '${level.name} in ${play.slides} against ${level.fewest}');
  }

  // The hopeless ask, worn down by seven bounces.
  final dead = Levels.all.last;
  check(Play.of(dead).next == null, 'the hopeless ask kept a pointer');
  var stuck = Play.of(dead);
  for (var k = 0; k < Play.enough; k++) {
    final was = stuck;
    stuck = stuck.slide(Rules.mirror - 1);
    check(stuck.bounce != was.bounce, 'a slide that went nowhere at $k');
  }
  check(stuck.gaveUp, 'the hopeless ask did not admit it');
  check(!Play.of(dead).gaveUp, 'it admitted it at once');

  if (failed) {
    stderr.writeln('the mirror is not sound; no bake');
    exit(1);
  }

  final ledger = StringBuffer()
    ..write('every setting of lamp, eye and bounce walked, '
        '${commas(settings)} of them, the lamp and the eye anywhere over a '
        'mirror of ${Rules.mirror} pegs at any height to ${Rules.sky}, and '
        'the bounce on any peg of it')
    ..write('; each was asked twice. The pacing takes the two squared legs, '
        'holds their roots added against the straight run to the eye folded '
        'across the mirror, and settles it by squaring twice, so the whole '
        'question is whole numbers. The folding never measures a length: it '
        'crosses each run with the other rise and asks whether the two '
        'angles match')
    ..write('; the two agreed on all ${commas(settings)} settings, naming the '
        'same ${commas(matched)} bounces')
    ..write('; and on not one of the ${commas(settings)} did a path come to '
        'less than its own straight run, which is Hero of Alexandria in his '
        'Catoptrics: the light takes the shortest way, and the shortest way '
        'is the one with matching angles')
    ..write('; the board the asks stand on puts the lamp at ${Level.lampX} '
        'across and ${Level.lampY} up and the eye at ${Level.eyeX} and '
        '${Level.eyeY}, so the folded eye lies 8 down and 6 across from the '
        'lamp and the straight run is ${Level.least} paces exactly, reached '
        'at the one bounce on peg ${even.first}, whose legs are 5 paces and '
        '5 paces')
    ..write('; the asking then tightens a pace at a time and the pegs that '
        'answer it fall away from both ends together, '
        '${Levels.all.map((l) => l.ways).join(', ')}');
  stdout.writeln(ledger);
  stdout.writeln();
  final width =
      Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final tail = level.winnable
        ? '${level.ways} of the ${Rules.mirror} pegs do it, the nearest '
            '${level.fewest} ${level.fewest == 1 ? 'slide' : 'slides'} away'
        : 'none of the ${Rules.mirror}, and the folding said so first';
    stdout.writeln(' ${i + 1} ${level.name.padRight(width)} ${level.task}: $tail');
  }
}

/// Whether the roots of [one] and [two] added come to strictly less than
/// the root of [whole]. Squaring twice keeps it in whole numbers.
bool _under(int one, int two, int whole) {
  final over = whole - one - two;
  if (over < 0) return false;
  return 4 * one * two < over * over;
}
