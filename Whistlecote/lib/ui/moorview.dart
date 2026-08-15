import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../whistle/play.dart';
import '../whistle/rules.dart';
import 'palette.dart';

/// Where the whistles stand on the board, so the screen and the tests
/// can find every one: the tree of notes hangs from the shepherd at the
/// top, low to the left and high to the right, and the shares bar and
/// the calls sit under it.
class Metrics {
  Metrics(this.play, Size room, {this.bare = false}) {
    final treeTop = room.height * (bare ? 0.06 : 0.04);
    final treeHeight = room.height * (bare ? 0.62 : 0.5);
    rowGap = treeHeight / (play.rules.depth + 0.4);
    rootAt = Offset(room.width / 2, treeTop + rowGap * 0.4);
    width = room.width;
    nodeRadius = bare ? math.min(room.width * 0.055, room.height * 0.09) : math.min(room.width * 0.042, 22);
    final barTop = treeTop + treeHeight + room.height * (bare ? 0.1 : 0.09);
    bar = Rect.fromLTWH(room.width * 0.08, barTop, room.width * 0.84, room.height * (bare ? 0.09 : 0.045));
    callsTop = bar.bottom + room.height * 0.035;
    callGap = math.min(room.height * 0.045, 26);
  }

  final Play play;
  final bool bare;

  late final Offset rootAt;
  late final double rowGap;
  late final double width;
  late final double nodeRadius;
  late final Rect bar;
  late final double callsTop;
  late final double callGap;

  /// Node [k]'s place: its row by its notes, its column by its place
  /// among the whistles of that many notes.
  Offset at(int k) {
    if (k == 1) return rootAt;
    final d = Rules.notesOf(k);
    final across = 1 << d;
    final i = k - across;
    return Offset(width * (i + 0.5) / across, rootAt.dy + d * rowGap);
  }

  /// The whistle under a touch, or null.
  int? under(Offset touch) {
    for (final k in play.rules.nodes) {
      if ((touch - at(k)).distance <= nodeRadius * 1.5) return k;
    }
    return null;
  }
}

/// The moor: the tree of whistles hanging from the shepherd, marked
/// nodes filled in their call's colour and every whistle they begin
/// dimmed, rust where a marked whistle starts another; under it the bar
/// of shares, and the calls with their notes.
class MoorView extends CustomPainter {
  MoorView({required this.play, this.pointing, required this.labels, this.bare = false});

  final Play play;

  /// What the show-me points at, or null.
  final (String, int)? pointing;
  final TextStyle labels;

  /// Whether to leave the words off, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Palette.moor);
    canvas.drawRect(Rect.fromLTWH(0, m.bar.top - size.height * 0.02, size.width, size.height), Paint()..color = Palette.heather);
    canvas.drawRect(Rect.fromLTWH(0, size.height * 0.93, size.width, size.height * 0.07), Paint()..color = Palette.grass);
    final rules = play.rules;
    final clashes = play.clashes;
    final hair = bare ? m.nodeRadius * 0.1 : 1.5;
    // The branches, root down; a branch under a clash goes rust.
    for (final k in rules.nodes) {
      final parent = k >> 1;
      final rust = clashes.any((c) => Rules.begins(c.$1, k) && (c.$2 == k || Rules.begins(k, c.$2)));
      canvas.drawLine(m.at(parent), m.at(k), Paint()
        ..color = rust ? Palette.clash : play.shadowed(k) ? Palette.stoneDim : Palette.branch
        ..strokeWidth = rust ? hair * 2 : hair);
    }
    // The shepherd at the root, a small whistle.
    canvas.drawCircle(m.rootAt, m.nodeRadius * 0.7, Paint()..color = Palette.stone);
    canvas.drawRect(Rect.fromCenter(center: m.rootAt + Offset(m.nodeRadius * 0.9, 0), width: m.nodeRadius * 1.2, height: m.nodeRadius * 0.4), Paint()..color = Palette.stone);
    if (!bare) {
      _write(canvas, 'low', m.at(2) + Offset(0, -m.rowGap * 0.5) + Offset(-m.nodeRadius * 1.6, 0), labels.copyWith(color: Palette.inkDim, fontSize: 11));
      _write(canvas, 'high', m.at(3) + Offset(0, -m.rowGap * 0.5) + Offset(m.nodeRadius * 1.6, 0), labels.copyWith(color: Palette.inkDim, fontSize: 11));
    }
    // The whistles.
    for (final k in rules.nodes) {
      final at = m.at(k);
      final call = play.callOf(k);
      final marked = play.isMarked(k);
      final clashing = clashes.any((c) => c.$1 == k || c.$2 == k);
      final colour = marked
          ? (call == null ? Palette.stone : Palette.calls[call % Palette.calls.length])
          : play.shadowed(k)
              ? Palette.stoneDim
              : Palette.moor;
      canvas.drawCircle(at, m.nodeRadius, Paint()..color = colour);
      canvas.drawCircle(at, m.nodeRadius, Paint()
        ..color = clashing ? Palette.clash : marked ? Palette.ink.withValues(alpha: 0.6) : play.shadowed(k) ? Palette.stoneDim : Palette.stone
        ..style = PaintingStyle.stroke
        ..strokeWidth = clashing ? hair * 2 : hair);
      // The notes of the whistle, drawn as a little stave in the disc:
      // a high note up, a low note down.
      final notes = Rules.notes(k);
      final step = m.nodeRadius * 1.1 / notes.length;
      for (var i = 0; i < notes.length; i++) {
        final x = at.dx - m.nodeRadius * 0.55 + step * (i + 0.5);
        final y = at.dy + (notes[i] ? -m.nodeRadius * 0.3 : m.nodeRadius * 0.3);
        canvas.drawLine(Offset(x - step * 0.3, y), Offset(x + step * 0.3, y), Paint()
          ..color = marked ? Palette.night : play.shadowed(k) ? Palette.stone.withValues(alpha: 0.5) : Palette.ink
          ..strokeWidth = hair * 1.7);
      }
      if (!bare && call != null) {
        _write(canvas, '${call + 1}', at + Offset(0, m.nodeRadius * 1.6), labels.copyWith(color: Palette.calls[call % Palette.calls.length], fontSize: 11, fontWeight: FontWeight.w800));
      }
    }
    // The pointer.
    final aim = pointing;
    if (aim != null) {
      canvas.drawCircle(m.at(aim.$2), m.nodeRadius * 1.5, Paint()
        ..color = aim.$1 == 'mark' ? Palette.shown : Palette.clash
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3);
    }
    // The bar of shares: the whole, and each mark's share laid along it
    // in its call's colour, over the end in rust.
    canvas.drawRRect(RRect.fromRectAndRadius(m.bar, const Radius.circular(4)), Paint()..color = Palette.whole);
    var x = m.bar.left;
    final unit = m.bar.width / rules.whole;
    for (final k in play.marks) {
      final w = unit * (1 << (rules.depth - Rules.notesOf(k)));
      final call = play.callOf(k);
      final over = x + w > m.bar.right + 0.5;
      canvas.drawRect(Rect.fromLTWH(x, m.bar.top, w, m.bar.height).deflate(1), Paint()
        ..color = over ? Palette.clash : call == null ? Palette.stone : Palette.calls[call % Palette.calls.length]);
      x += w;
    }
    for (var i = 1; i < rules.whole; i++) {
      canvas.drawLine(Offset(m.bar.left + unit * i, m.bar.top), Offset(m.bar.left + unit * i, m.bar.bottom), Paint()
        ..color = Palette.moor.withValues(alpha: 0.7)
        ..strokeWidth = hair * 0.7);
    }
    if (!bare) {
      // The calls, each with its notes so far.
      for (var c = 0; c < play.level.calls.length; c++) {
        final (name, l) = play.level.calls[c];
        final node = play.nodeOf(c);
        final y = m.callsTop + c * m.callGap;
        final colour = Palette.calls[c % Palette.calls.length];
        canvas.drawCircle(Offset(m.bar.left + 6, y), 5, Paint()..color = node == null ? Palette.stoneDim : colour);
        final words = node == null
            ? '${c + 1} $name, ${_notes(l)}: not yet'
            : '${c + 1} $name, ${_notes(l)}: ${Rules.said(node)}';
        _writeLeft(canvas, words, Offset(m.bar.left + 18, y), labels.copyWith(color: node == null ? Palette.inkDim : Palette.ink, fontSize: 12));
      }
    }
  }

  static String _notes(int l) => l == 1 ? 'one note' : l == 2 ? 'two notes' : 'three notes';

  void _write(Canvas canvas, String words, Offset at, TextStyle style) {
    final painter = TextPainter(text: TextSpan(text: words, style: style), textDirection: TextDirection.ltr)..layout();
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  void _writeLeft(Canvas canvas, String words, Offset at, TextStyle style) {
    final painter = TextPainter(text: TextSpan(text: words, style: style), textDirection: TextDirection.ltr)..layout();
    painter.paint(canvas, at - Offset(0, painter.height / 2));
  }

  @override
  bool shouldRepaint(MoorView old) => old.play != play || old.pointing != pointing;
}

/// The why, spoken for a set of calls as it stands.
String whyWords(Play play) {
  final level = play.level;
  final note = level.note == null ? '' : ' ${level.note}';
  final rules = play.rules;
  if (!level.winnable) {
    return 'Every whistle takes a share of all the tunes that could follow it, '
        'the tunes that begin with it: one note takes half of them, two notes a '
        'quarter, three notes an eighth, and no two calls may share a tune, or '
        'the dog would go at the first. The calls asked take ${rules.share(level.lengths)} '
        'shares of ${rules.whole}, more than the whole, so no marking lands, and '
        'every one of the ${level.markings} markings was swept to be sure. Kraft\'s '
        'inequality says as much for any calls: on every set of up to six calls of '
        'up to four notes, 209 sets, the sweep and the shares agree.$note';
  }
  return 'The sweep marks the whistles every way with the notes asked, '
      '${level.markings} markings, and keeps those where no whistle is the start '
      'of another; the shepherd\'s way marks with no sweep, the shortest calls '
      'first and each on the leftmost whistle no marked one begins, and lands '
      'whenever the shares come to no more than the whole, which is Kraft\'s '
      'inequality; and the count landing is the product of the free choices at '
      'each length. ${level.ways} of the ${level.markings} land it, the shares '
      'coming to ${rules.share(level.lengths)} of ${rules.whole}.$note';
}
