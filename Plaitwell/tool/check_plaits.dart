import 'dart:io';

import 'package:plaitwell/plait/levels.dart';
import 'package:plaitwell/plait/play.dart';
import 'package:plaitwell/plait/rules.dart';

/// Sweeps every painting of every plait the game ships, works the three
/// moves on each plait in every place they will go and counts again, and
/// refuses the bake on any disagreement.
///
/// Run with: dart run tool/check_plaits.dart
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

  int count(int strands, List<int> word, {bool allThree = false}) =>
      Rules.paintings(Rules.crossings(strands, word), Rules.arcs(strands, word),
          allThree: allThree);

  // The asks, each swept painting by painting.
  var swept = 0;
  for (final level in Levels.all) {
    final arcs = level.arcs;
    final crossings = level.crossings;
    check(crossings.length == level.word.length,
        '${level.name}: ${crossings.length} crossings for ${level.word.length}');
    check(Rules.ropes(level.strands, level.word) == 1,
        '${level.name} closes into more than one rope');
    swept += level.allPaintings;
    check(count(level.strands, level.word) == level.legal,
        '${level.name}: legal paintings against ${level.legal}');
    check(count(level.strands, level.word, allThree: true) == level.ways,
        '${level.name}: paintings in all three against ${level.ways}');
    // The one-colour paintings keep the rule on every plait there is.
    for (var c = 0; c < Rules.colours; c++) {
      check(Rules.legal(crossings, List.filled(arcs, c)),
          '${level.name} refuses the plain colour $c');
    }
    check(!level.meets(List.filled(arcs, 0)),
        '${level.name} is landed by the opening');
    final proper = Rules.proper(crossings, arcs);
    check(proper.length == level.ways, '${level.name}: proper list is wrong');
    if (level.winnable) {
      final fewest = proper
          .map((p) => Rules.between(List.filled(arcs, 0), p))
          .reduce((a, b) => a < b ? a : b);
      check(fewest == level.fewest,
          '${level.name}: nearest $fewest against ${level.fewest}');
    } else {
      check(level.fewest == null && proper.isEmpty,
          '${level.name} was landed');
    }
  }

  // The count is always three to some power, and never less than three,
  // because the one-colour paintings are always there and the paintings add
  // together. Swept over every plait of three ropes up to five crossings.
  var plaits = 0, powers = 0;
  final wide = <List<int>>[];
  void grow(List<int> so) {
    if (so.isNotEmpty) wide.add([...so]);
    if (so.length == 6) return;
    for (final turn in const [1, -1, 2, -2]) {
      grow([...so, turn]);
    }
  }

  grow(const []);
  for (final word in wide) {
    plaits++;
    final n = count(3, word);
    var p = 1;
    while (p < n) {
      p *= 3;
    }
    if (p == n && n >= 3) powers++;
  }
  check(plaits == 5460, 'plaits of three ropes up to six crossings: $plaits');
  check(powers == plaits, 'plaits whose count is not a power of three: '
      '${plaits - powers}');

  // The three moves. A kink put in or taken out, a pair slid over and back,
  // and a rope slid across a crossing. None of them may shift the count.
  //
  // Written on the plait's word these are: adding a strand with one crossing
  // on the end, putting a turn and its opposite in anywhere, and the
  // exchange that slides one rope across another. Turning the word round is
  // free as well, since the plait is joined in a ring.
  List<(String, int, List<int>)> movesOn(int strands, List<int> word) {
    final out = <(String, int, List<int>)>[];
    for (var k = 1; k < word.length; k++) {
      out.add(('turned round', strands, [...word.skip(k), ...word.take(k)]));
    }
    for (var k = 0; k <= word.length; k++) {
      for (var g = 1; g < strands; g++) {
        out.add(('pair put in', strands,
            [...word.take(k), g, -g, ...word.skip(k)]));
        out.add(('pair put in', strands,
            [...word.take(k), -g, g, ...word.skip(k)]));
      }
    }
    for (var k = 0; k + 3 <= word.length; k++) {
      final a = word[k], b = word[k + 1], c = word[k + 2];
      if (a == c && (b - a).abs() == 1 && a * b > 0) {
        out.add(('rope slid across', strands,
            [...word.take(k), b, a, b, ...word.skip(k + 3)]));
      }
    }
    for (var k = 0; k + 2 <= word.length; k++) {
      if ((word[k].abs() - word[k + 1].abs()).abs() >= 2) {
        final v = [...word];
        final held = v[k];
        v[k] = v[k + 1];
        v[k + 1] = held;
        out.add(('far crossings swapped', strands, v));
      }
    }
    for (final sign in const [1, -1]) {
      out.add(('strand added', strands + 1, [...word, sign * strands]));
    }
    return out;
  }

  var movedHere = 0, movedElse = 0, movedWrong = 0;
  for (final level in Levels.all) {
    final was = count(level.strands, level.word);
    for (final (_, strands, word) in movesOn(level.strands, level.word)) {
      movedHere++;
      if (count(strands, word) != was) movedWrong++;
    }
  }
  // And on plaits the game does not ship, so the agreement is not five lucky
  // pictures.
  final others = wide.where((w) => w.length <= 4).toList();
  for (final word in others) {
    final was = count(3, word);
    for (final (_, strands, word2) in movesOn(3, word)) {
      movedElse++;
      if (count(strands, word2) != was) movedWrong++;
    }
  }
  check(movedWrong == 0, 'moves that shifted the count: $movedWrong');

  // The short plait and the long plait are the same knot, and here is the
  // walk from one to the other in three moves.
  const walk = <(String, int, List<int>)>[
    ('the short plait', 2, [1, 1, 1]),
    ('a strand added', 3, [1, 1, 1, 2]),
    ('turned round', 3, [1, 1, 2, 1]),
    ('a rope slid across', 3, [1, 2, 1, 2]),
  ];
  for (var k = 1; k < walk.length; k++) {
    final (what, strands, word) = walk[k];
    final (_, wasStrands, wasWord) = walk[k - 1];
    final ok = movesOn(wasStrands, wasWord)
        .any((m) => m.$2 == strands && m.$3.join(',') == word.join(','));
    check(ok, 'the walk step "$what" is not one of the moves');
    check(count(strands, word) == count(wasStrands, wasWord),
        'the walk step "$what" shifted the count');
  }
  check(walk.last.$3.join(',') == Levels.at(1).word.join(',') &&
      walk.first.$3.join(',') == Levels.at(0).word.join(','),
      'the walk does not join the two plaits the game ships');

  // The figure eight, argued rather than merely counted. If every crossing
  // showed three colours the plait would contradict itself, and any painting
  // with a crossing showing one colour comes out one colour throughout.
  final dead = Levels.all.last;
  final deadCrossings = dead.crossings;
  var allDifferent = 0, oneColourSomewhere = 0, notPlain = 0;
  final paint = List.filled(dead.arcs, 0);
  void walkPaint(int at) {
    if (at == dead.arcs) {
      var different = 0, same = 0;
      for (final c in deadCrossings) {
        final three = {paint[c.$1], paint[c.$2], paint[c.$3]};
        if (three.length == 3) different++;
        if (three.length == 1) same++;
      }
      if (different == deadCrossings.length) allDifferent++;
      if (Rules.legal(deadCrossings, paint) && same > 0) {
        oneColourSomewhere++;
        if (paint.toSet().length != 1) notPlain++;
      }
      return;
    }
    for (var c = 0; c < Rules.colours; c++) {
      paint[at] = c;
      walkPaint(at + 1);
    }
    paint[at] = 0;
  }

  walkPaint(0);
  check(allDifferent == 0,
      'paintings of the figure eight with every crossing in three colours: '
      '$allDifferent');
  check(oneColourSomewhere == 3,
      'legal paintings with a crossing in one colour: $oneColourSomewhere');
  check(notPlain == 0,
      'legal paintings that stopped short of one colour throughout: $notPlain');

  // Two trefoils tied in a row: the counts multiply, less the three plain
  // paintings counted twice.
  final one = count(3, const [1, 1, 1, 2]);
  final granny = count(3, const [1, 1, 1, 2, 2, 2]);
  check(one * one ~/ 3 == granny,
      'the granny came to $granny, not ${one * one ~/ 3}');

  // The pointer lands every ask it can, in the taps it promises.
  for (final level in Levels.all.where((l) => l.winnable)) {
    var play = Play.of(level);
    var steps = 0;
    while (!play.isDone && steps < 30) {
      final arc = play.next;
      check(arc != null, '${level.name} lost its pointer');
      if (arc == null) break;
      play = play.tap(arc);
      steps++;
    }
    check(play.isDone, '${level.name} was never painted');
    check(play.taps == level.fewest,
        '${level.name} in ${play.taps} taps against ${level.fewest}');
  }

  // The hopeless ask, worn down by eight paintings.
  check(Play.of(dead).next == null, 'the hopeless ask kept a pointer');
  var stuck = Play.of(dead);
  for (final arc in const [0, 1, 2, 3, 0, 1, 2, 3]) {
    final was = stuck;
    stuck = stuck.tap(arc);
    check(stuck.mark != was.mark, 'a tap that changed nothing at $arc');
  }
  check(stuck.gaveUp, 'the hopeless ask did not admit it');
  check(!Play.of(dead).gaveUp, 'it admitted it at once');

  if (failed) {
    stderr.writeln('the plait is not sound; no bake');
    exit(1);
  }

  final ledger = StringBuffer()
    ..write('every painting of every plait the game ships tried, '
        '${commas(swept)} of them, three colours over '
        '${Levels.all.map((l) => l.arcs).reduce((a, b) => a + b)} arcs: the '
        'paintings that keep the rule come to '
        '${Levels.all.map((l) => l.legal).join(', ')} and the ones using all '
        'three colours to ${Levels.all.map((l) => l.ways).join(', ')}')
    ..write('; painting a whole rope one colour keeps the rule on every '
        'plait, which is why the ask is always for all three')
    ..write('; the three moves that change a picture without untying it were '
        'worked in every place they would go, ${commas(movedHere)} of them on '
        'the five plaits the game ships and ${commas(movedElse)} more on '
        '${commas(others.length)} plaits it does not, and not one shifted the '
        'count')
    ..write('; the short plait becomes the long plait in three moves, a '
        'strand added, the word turned round, a rope slid across, and the '
        'count stays 9 the whole way')
    ..write('; the count came to a power of three on every one of the '
        '${commas(plaits)} plaits of three ropes up to six crossings, and '
        'never below three')
    ..write('; the figure eight has no painting at all with every crossing '
        'in three colours, and each of its 3 legal paintings is one colour '
        'from end to end, while the trefoil has 6 in all three colours, so '
        'the two are not the same knot');
  stdout.writeln(ledger);
  stdout.writeln();
  final width =
      Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final tail = level.winnable
        ? '${level.ways} of the ${commas(level.allPaintings)} paintings do '
            'it, the nearest ${level.fewest} taps away'
        : 'none of the ${commas(level.allPaintings)}, and the crossings say '
            'so before you start';
    stdout
        .writeln(' ${i + 1} ${level.name.padRight(width)} ${level.task}: $tail');
  }
}
