import 'dart:io';

import 'package:rickmere/rick/frac.dart';
import 'package:rickmere/rick/levels.dart';
import 'package:rickmere/rick/play.dart';
import 'package:rickmere/rick/root3.dart';
import 'package:rickmere/rick/rules.dart';

/// Measures every field the green holds, raises its ricks both ways,
/// and refuses the bake on any disagreement.
///
/// Run with: dart run tool/check_ricks.dart
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

  // The arithmetic the whole thing rests on.
  final root = Root3(Frac.zero, Frac.one);
  check(root * root == Root3.of(3), 'the root of three squared');
  check(Root3.of(1) + Root3.of(2) == Root3.of(3), 'adding whole numbers');
  check(Root3(Frac.of(1), Frac.of(1)) * Root3(Frac.of(1), Frac.of(-1)) ==
      Root3.of(-2), 'one and a root times one less a root');
  check(Root3.of(2) != Root3(Frac.of(2), Frac.of(1)),
      'a root of three is not nothing');

  final all = Rules.fields();
  check(all.length == 2148, 'fields on the green: ${all.length}');

  var byLength = 0, byTurning = 0, areaSum = 0, measured = 0;
  var widestSeen = Rules.markerSides(all.first).first;
  final sidesSeen = <String, int>{};
  for (final posts in all) {
    check(Rules.isField(posts), 'a field that is not one: $posts');
    for (final out in [true, false]) {
      measured++;
      final sides = Rules.markerSides(posts, out: out);
      // The first voice: the three gaps between the markers.
      if (sides[0] == sides[1] && sides[1] == sides[2]) byLength++;
      // The second voice, which measures nothing.
      if (Rules.evenByTurning(posts, out: out)) byTurning++;
      check(Rules.evenByLength(posts, out: out) ==
          Rules.evenByTurning(posts, out: out),
          'the two voices differ on ${Rules.tellPosts(posts)}');
    }
    // Outward and inward, the two marker triangles' areas add to the
    // field's own, and the roots of three cancel.
    final outer = Rules.twiceAreaOf(Rules.markers(posts));
    final inner = Rules.twiceAreaOf(Rules.markers(posts, out: false));
    final both = outer + inner;
    if (both == Root3.of(Rules.twiceArea(posts))) areaSum++;
    check(both == Root3.of(Rules.twiceArea(posts)),
        'the areas of ${Rules.tellPosts(posts)} add to $both, not '
        '${Rules.twiceArea(posts)}');
    check(both.b == Frac.zero, 'the roots did not cancel on $posts');
    final side = Rules.markerSides(posts).first;
    sidesSeen['$side'] = (sidesSeen['$side'] ?? 0) + 1;
    if (side.toDouble > widestSeen.toDouble) widestSeen = side;
  }
  check(measured == 4296, 'measurings: $measured');
  check(byLength == measured, 'even by length on $byLength of $measured');
  check(byTurning == measured, 'even by turning on $byTurning of $measured');
  check(areaSum == all.length, 'the areas added on $areaSum of ${all.length}');
  check(widestSeen == Rules.widest, 'the widest ring: $widestSeen');

  // The asks.
  for (final level in Levels.all) {
    var n = 0, cheapest = 9;
    for (final posts in all) {
      if (!level.meets(posts)) continue;
      n++;
      final moves = Rules.moves(Rules.opening, posts);
      if (moves < cheapest) cheapest = moves;
    }
    check(n == level.ways, '${level.name}: $n against ${level.ways}');
    if (level.winnable) {
      check(level.fewest == cheapest,
          '${level.name}: ${level.fewest} against $cheapest');
    } else {
      check(level.fewest == null && n == 0, '${level.name} was landed');
    }
    check(!level.meets(Rules.opening), '${level.name} is landed at the opening');
  }

  // The pointer lands every ask it can, in the fewest posts moved.
  for (final level in Levels.all.where((l) => l.winnable)) {
    var play = Play.of(level);
    var steps = 0;
    while (!play.isDone && steps < 12) {
      final aim = play.next;
      check(aim != null, '${level.name} lost its pointer');
      if (aim == null) break;
      play = play.tap(play.posts[aim.$1]).tap(aim.$2);
      steps++;
    }
    check(play.isDone, '${level.name} never landed');
    check(play.moves == level.fewest,
        '${level.name} in ${play.moves} against ${level.fewest}');
  }

  // The hopeless ask, worn down by four fields.
  var stuck = Play.of(Levels.all.last);
  for (final peg in [(4, 4), (0, 0), (4, 0), (3, 3)]) {
    final was = stuck;
    stuck = stuck.tap(stuck.posts[0]).tap(peg);
    check(!identical(stuck, was), 'a move that did nothing at ${was.posts}');
  }
  check(stuck.gaveUp, 'the hopeless ask did not admit it');

  if (failed) {
    stderr.writeln('the green is not sound; no bake');
    exit(1);
  }

  final shapes = sidesSeen.length;
  final ledger = StringBuffer()
    ..write('every field the ${Rules.pegs} by ${Rules.pegs} green holds '
        'taken, all ${commas(all.length)} of them, with the ricks raised '
        'outward and then inward, ${commas(measured)} raisings, and each '
        'raising measured by both voices, ${commas(measured * 2)} measurings '
        'in all: the three markers are the same distance apart every time')
    ..write('; the first voice takes the three gaps between the markers and '
        'compares them, and the second turns one marker sixty degrees about '
        'another and asks whether it lands on the third, which measures '
        'nothing: they agree on all ${commas(measured)} raisings')
    ..write('; all of it is done in numbers of the form a and b roots of '
        'three, with a and b exact fractions, since raising an even triangle '
        'turns a side by sixty degrees and the sine of sixty is half the root '
        'of three: nothing here is a decimal, and equal means equal')
    ..write('; the markers stand ${commas(shapes)} different distances apart '
        'over the ${commas(all.length)} fields, the widest of them a gap '
        'whose square is ${Rules.widest}, which the four fields filling a '
        'corner of the green reach')
    ..write('; and raising the ricks inward instead gives another even '
        'triangle, whose area added to the outward one comes to the field\'s '
        'own area on all ${commas(all.length)} fields, the roots of three '
        'cancelling to leave a whole number every time');
  stdout.writeln(ledger);
  stdout.writeln();
  final width =
      Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final tail = level.winnable
        ? '${commas(level.ways)} of the ${commas(all.length)} fields '
            '${level.ways == 1 ? 'lands' : 'land'} it, the nearest '
            '${level.fewest} ${level.fewest == 1 ? 'post' : 'posts'} away'
        : 'none of the ${commas(all.length)}, raised either way, and the '
            'roots of three say why';
    stdout.writeln(' ${i + 1} ${level.name.padRight(width)} ${level.task}: $tail');
  }
}
