import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../share/play.dart';
import '../share/share.dart';
import 'palette.dart';

/// Where the trays and tokens lie on the board, so the screen
/// and the tests can find every token.
class Metrics {
  Metrics(this.play, Size room, {bool snug = false}) {
    final count = play.share.count;
    // Room for every token on one tray, as the deal opens; the
    // mark alone is drawn snug round the tokens as they stand.
    final most = snug
        ? math.max(play.leftTray.length, play.rightTray.length)
        : count;
    cols = most <= 4 ? 2 : 4;
    rows = math.max(1, (most + cols - 1) ~/ cols);
    final trayWidth = room.width * 0.44;
    final gutter = room.width * 0.04;
    // The lines of sums under the trays take a third of a pitch
    // each; trays and lines together sit in the middle of the
    // room.
    final lines = play.share.degrees;
    final trayHeight = room.height * 0.9 / (rows + 0.34 * lines + 0.2);
    final pitchX = trayWidth / cols;
    pitch = math.min(pitchX, trayHeight);
    token = pitch * 0.42;
    final usedWidth = pitch * cols;
    final usedHeight = pitch * rows;
    final wholeHeight = usedHeight + pitch * (0.34 * lines + 0.2);
    final top = math.max(pitch * 0.1, (room.height - wholeHeight) / 2);
    left = Rect.fromLTWH(
      room.width / 2 - gutter / 2 - usedWidth,
      top,
      usedWidth,
      usedHeight,
    );
    right = Rect.fromLTWH(
      room.width / 2 + gutter / 2,
      top,
      usedWidth,
      usedHeight,
    );
    labelsY = top + usedHeight + pitch * 0.36;
  }

  final Play play;

  late final int cols;
  late final int rows;

  /// The grid pitch inside a tray, and a token's radius.
  late final double pitch;
  late final double token;

  late final Rect left;
  late final Rect right;

  /// Where the trays' sums are written.
  late final double labelsY;

  /// The middle of a token, by its tray and its order there.
  Offset tokenAt(int number) {
    final onRight = play.right[number - 1];
    final tray = onRight ? play.rightTray : play.leftTray;
    final order = tray.indexOf(number);
    final rect = onRight ? right : left;
    return Offset(
      rect.left + (order % cols + 0.5) * pitch,
      rect.top + (order ~/ cols + 0.5) * pitch,
    );
  }

  /// The token under a touch, or null.
  int? under(Offset touch) {
    for (var number = 1; number <= play.share.count; number++) {
      if ((tokenAt(number) - touch).distance <= token * 1.25) {
        return number;
      }
    }
    return null;
  }
}

/// The trays themselves: tokens by number, and under each tray
/// its sums, squares and cubes as the share asks, green where
/// the two agree.
class TrayView extends CustomPainter {
  TrayView({
    required this.play,
    this.pointing,
    required this.labels,
    this.snug = false,
  });

  final Play play;
  final int? pointing;
  final TextStyle labels;

  /// Whether the trays close round the tokens as they stand.
  final bool snug;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size, snug: snug);
    final radius = Radius.circular(metrics.pitch * 0.25);
    for (final tray in [metrics.left, metrics.right]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(tray.inflate(metrics.pitch * 0.08), radius),
        Paint()..color = Palette.tray,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(tray.inflate(metrics.pitch * 0.08), radius),
        Paint()
          ..color = Palette.trayRim
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1, metrics.pitch * 0.03),
      );
    }

    for (var number = 1; number <= play.share.count; number++) {
      final at = metrics.tokenAt(number);
      final onRight = play.right[number - 1];
      canvas.drawCircle(
        at,
        metrics.token,
        Paint()..color = onRight ? Palette.tokenRight : Palette.token,
      );
      if (pointing == number) {
        canvas.drawCircle(
          at,
          metrics.token * 1.22,
          Paint()
            ..color = Palette.shown
            ..style = PaintingStyle.stroke
            ..strokeWidth = math.max(2, metrics.token * 0.14),
        );
      }
      _write(canvas, '$number', at,
          labels.copyWith(
            color: Palette.tokenInk,
            fontSize: metrics.token * 0.95,
            fontWeight: FontWeight.w700,
          ));
    }

    // The powers under the trays.
    final agreeing = play.agreeing;
    final lineHeight = metrics.pitch * 0.34;
    for (var degree = 1; degree <= play.share.degrees; degree++) {
      final (leftSum, rightSum) = play.sums(degree);
      final colour = agreeing[degree - 1] ? Palette.agree : Palette.part;
      final y = metrics.labelsY + (degree - 1) * lineHeight;
      final style = labels.copyWith(
        color: colour,
        fontSize: math.min(lineHeight * 0.66, 15),
        fontWeight: FontWeight.w600,
      );
      _write(canvas, '${Share.powerNames[degree - 1]} $leftSum',
          Offset(metrics.left.center.dx, y), style);
      _write(canvas, '${Share.powerNames[degree - 1]} $rightSum',
          Offset(metrics.right.center.dx, y), style);
    }
  }

  void _write(Canvas canvas, String words, Offset at, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: words, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
        canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(TrayView old) =>
      old.play != play || old.pointing != pointing || old.snug != snug;
}

/// The why, spoken for a share as it stands.
String whyWords(Play play) {
  final share = play.share;
  final note = share.note == null ? '' : ' ${share.note}';
  if (!share.winnable) {
    return 'Two and two out of four is three pairings, and you can '
        'read them all: only 1 with 4 against 2 with 3 agrees in '
        'sums, and its squares are 1 and 16 against 4 and 9. The '
        'sweep dealt the three and found no share.$note';
  }
  final second = share.count == 12
      ? 'twelve tokens have no doubling pattern behind them, and '
          'the sweep alone found their one share'
      : 'Prouhet\'s doubling pattern is dealt with no searching, '
          'token 1 left with every token whose number less one has '
          'an even count of ones written in twos, and his polynomial '
          'divides by one less x once for every doubling, which is '
          'why the powers agree';
  return 'The shares are counted by the sweep, every half-and-half '
      'deal with token 1 on the left, and held to a second voice: '
      '$second. ${share.ways} share${share.ways == 1 ? '' : 's'} '
      'land${share.ways == 1 ? 's' : ''} this deal.$note';
}
