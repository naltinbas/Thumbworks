import 'dart:io';

import 'package:riddlecombe/weave/meshes.dart';
import 'package:riddlecombe/weave/rules.dart';

/// Proves every shipped claim from the combs up, and refuses the bake
/// on any disagreement.
void main() {
  var bad = 0;

  void claim(bool holds, String what) {
    if (holds) return;
    bad++;
    stdout.writeln('WRONG: $what');
  }

  for (var number = 0; number < Meshes.count; number++) {
    final mesh = Meshes.at(number);
    final rules = Rules(mesh.strands);

    final can = rules.canStill(const [], mesh.combs);
    claim(can == mesh.winnable,
        '${mesh.name}: search says ${can ? 'weavable' : 'not'}');
    if (mesh.winnable) {
      claim(!rules.canStill(const [], mesh.combs - 1),
          '${mesh.name}: one comb fewer riddles after all');
    }

    final verdict = mesh.winnable
        ? 'riddles in ${mesh.combs} combs and not in ${mesh.combs - 1}'
        : 'no weave of ${mesh.combs} combs riddles';
    stdout.writeln(' ${number + 1} ${mesh.name.padRight(17)} '
        '${mesh.strands} strands, ${mesh.grists} grists  $verdict');
  }

  // The short weave, proved the long way besides: every four-comb
  // weave of four strands, run through every grist, and through every
  // ordering too, the nought-one principle holding at each.
  final four = Rules(4);
  var swept = 0;
  var riddling = 0;
  var parted = 0;
  for (final weave in four.allWeaves(4)) {
    swept++;
    final byGrists = four.riddles(weave);
    if (byGrists) riddling++;
    if (byGrists != four.riddlesOrderings(weave)) parted++;
  }
  claim(swept == 1296, 'the short sweep saw $swept weaves');
  claim(riddling == 0, '$riddling short weaves riddle');
  claim(parted == 0, 'nought-one parted on $parted weaves');
  stdout.writeln('\nall 1296 four-comb weaves swept: none riddles, and '
      'the nought-one principle held on every one');

  // And the dozen five-comb weaves that do the four.
  var fine = 0;
  for (final weave in four.allWeaves(5)) {
    if (four.riddles(weave)) fine++;
  }
  claim(fine == 12, '$fine five-comb weaves riddle, not twelve');
  stdout.writeln('of the 7776 five-comb weaves, exactly 12 riddle');

  if (bad > 0) {
    stdout.writeln('\n$bad claims failed');
    exit(1);
  }
}
