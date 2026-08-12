import 'dart:io';

import 'package:hurdlecote/fold/green.dart';
import 'package:hurdlecote/fold/greens.dart';
import 'package:hurdlecote/fold/rules.dart';

/// Sweeps every simple fence of the green, proves Pick against the
/// shoelace on each, and plays every task out. Refuses the bake on
/// any disagreement: this is what `make greens` runs, and the README
/// quotes its ledger verbatim.
void main() {
  final fences = Rules.everyFence(5, 4);

  // The two reckonings, on every fence there is.
  for (final fence in fences) {
    final shoelace = Rules.area2(fence);
    final picks = 2 * Rules.penned(fence) + Rules.walked(fence) - 2;
    if (shoelace != picks) {
      stderr.writeln('PICK BREAKS on $fence: '
          'shoelace $shoelace, crossings say $picks');
      exit(1);
    }
  }

  // The acreages march in halves: least a half, greatest sixteen.
  var least = 1 << 30;
  var greatest = 0;
  for (final fence in fences) {
    final twice = Rules.area2(fence);
    if (twice < least) least = twice;
    if (twice > greatest) greatest = twice;
  }
  if (least != 1 || greatest != 32) {
    stderr.writeln('ACREAGE RANGE WRONG: $least..$greatest');
    exit(1);
  }

  stdout.writeln(
      'every simple fence of four hurdles or fewer on the '
      'five-by-five green, ${fences.length} of them: what the '
      'shoelace reckons from coordinates and what Pick counts from '
      'crossings agree on every one, and twice the acreage is '
      'always a whole number, from 1 up to 32');
  stdout.writeln('');

  bool settles(Green green, List<(int, int)> fence) {
    final thirds = green.thirds;
    if (thirds != null) return 3 * Rules.area2(fence) == 2 * thirds;
    final twice = green.area2;
    if (twice != null && Rules.area2(fence) != twice) return false;
    final sheep = green.penned;
    if (sheep != null && Rules.penned(fence) != sheep) return false;
    return true;
  }

  for (var number = 0; number < Greens.count; number++) {
    final green = Greens.at(number);
    var fewest = -1;
    var ways = 0;
    for (final fence in fences) {
      if (!settles(green, fence)) continue;
      ways++;
      if (fewest == -1 || fence.length < fewest) {
        fewest = fence.length;
      }
    }

    if (green.winnable != (fewest != -1) ||
        (green.winnable && fewest != green.posts) ||
        (green.winnable && ways != green.ways)) {
      stderr.writeln('${green.name}: label says ${green.posts} '
          'fewest of ${green.ways} ways, sweep says $fewest of '
          '$ways');
      exit(1);
    }

    final name = green.name.padRight(18);
    stdout.writeln(green.winnable
        ? ' ${number + 1} $name ${green.task} — $ways fences do it, '
            '${green.posts} hurdles at fewest'
        : ' ${number + 1} $name ${green.task} — no fence of any '
            'size does: twice an acreage is whole, and two thirds '
            'is not');
  }
}
