import 'package:bondwell/bond/rules.dart';
import 'package:bondwell/bond/levels.dart';
import 'package:bondwell/bond/play.dart';

void main() {
  print('garment(4,2,4) = ${Rules.garmentParts(4, 2, 4)}  (twelfths)');
  print('garment(10,4,12) = ${Rules.garmentParts(10, 4, 12)}');
  print('garment(12,24,12) = ${Rules.garmentParts(12, 24, 12)}');
  // direction check on the Mishnah's own garment scaled: claims 2 and 1, estate 2
  print('garment(2,1,2) = ${Rules.garmentParts(2, 1, 2)}  want (18,6) i.e. 3/2 and 1/2');

  // proportional estates
  final prop = <int>[];
  for (var e = 0; e <= 72; e++) {
    final s = Rules.shares(e);
    // proportional to 12,24,36 means s[1]==2*s[0] and s[2]==3*s[0]
    if (s[1] == 2 * s[0] && s[2] == 3 * s[0]) prop.add(e);
  }
  print('proportional estates 0..72: $prop');
  print('shares(36)=${Rules.shares(36)} shares(72)=${Rules.shares(72)}');

  // estate 12: how many divisions put C ahead of A; how many level
  var cAhead = 0, level = 0, both = 0;
  final levellers = <List<int>>[];
  for (final d in Rules.divisions(12)) {
    if (d[2] > d[0]) cAhead++;
    if (Rules.allLevel(d)) { level++; levellers.add(d); }
    if (d[2] > d[0] && Rules.allLevel(d)) both++;
  }
  print('estate 12: 91? ${Rules.howManyDivisions(12)}; C ahead of A: $cAhead; level: $level $levellers; both: $both');

  // short bond share across estates
  final firsts = <int, List<int>>{};
  for (final e in [12, 18, 24, 36, 48, 54, 57]) firsts[e] = Rules.shares(e).map((p) => p).toList();
  print('shares by estate: $firsts');

  // division above 72
  for (final e in [72, 73, 75, 78, 84]) {
    final d = Rules.division(e);
    print('division($e) = $d  shares=${Rules.shares(e)} allLevel=${d == null ? 'n/a' : Rules.allLevel(d)}');
  }

  // tilt units
  print('tilt([5,3,4],0,1) = ${Rules.tilt([5, 3, 4], 0, 1)}');
  print('tilts of [9,6,6] middling: ${Play.standing(Levels.at(1), const [9, 6, 6]).tilts}');

  // pair concessions at estate 24 division 6,9,9
  int conceded(int mine, int pot) => pot - mine > 0 ? pot - mine : 0;
  print('estate 24 [6,9,9]: pair AB pot 15, A concedes ${conceded(12, 15)}, B concedes ${conceded(24, 15)}');
  print('estate 12 [4,4,4]: pair AB pot 8, A concedes ${conceded(12, 8)}, B concedes ${conceded(24, 8)}');

  // _equalAwards divisibility across estates: shares sum
  var bad = 0;
  for (var e = 0; e <= 72; e++) {
    final s = Rules.shares(e);
    if (s.reduce((a, b) => a + b) != Rules.parts * e) { bad++; print('sum off at $e: $s'); }
  }
  print('estates whose shares do not sum: $bad');

  // seen set: repeated same division
  var p = Play.of(Levels.all.last);
  p = p.step(2, 3).step(2, 3).step(2, 3).step(2, 3); // [0,0,12]
  print('after fill: moves=${p.moves} seen=${p.seen} gaveUp=${p.gaveUp}');
  for (var i = 0; i < 8; i++) {
    p = p.step(2, -1).step(2, 1);
    if (p.gaveUp) { print('gave up at moves=${p.moves} seen=${p.seen.length}'); break; }
  }
  print('after wobble: moves=${p.moves} seen=${p.seen.length} gaveUp=${p.gaveUp}');

  // three distinct
  var q = Play.of(Levels.all.last);
  for (final t in [[0,0,12],[0,3,9],[3,3,6]]) {
    // reset purses by taking out then putting in is messy; just use fresh path counts
  }
  print('fewest per level: ${[for (final l in Levels.all) l.fewest]}');
  print('aim fuller: ${Levels.at(3).aim}');
  // pointer from [5,0,0] on fuller
  var f = Play.standing(Levels.at(3), const [5, 0, 0]);
  print('pointer at [5,0,0] fuller: ${f.next}');
  print('taps counts: ${[for (final l in Levels.all) l.divisions]}');
}
