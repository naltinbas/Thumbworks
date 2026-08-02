import 'dart:math' as math;

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/rendering.dart';

import '../sim/world.dart';
import 'camera.dart';
import 'game_loop.dart';
import 'palette.dart';
import 'playfield.dart';
import 'starfield.dart';
import 'trail.dart';

/// Draws a run: the wells, the walls, the craft, what is holding it and where
/// it has just been.
///
/// Everything is placed in metres and handed to the camera, so the same
/// drawing code covers a small phone and a large one without a special case,
/// and nothing here has an opinion about how long a frame is.
class WorldPainter extends CustomPainter {
  WorldPainter({
    required this.world,
    required this.focusY,
    required this.trail,
    required this.flashes,
  }) : trailRevision = trail.revision;

  final World world;

  /// The height the camera is looking at, in metres.
  final double focusY;

  final Trail trail;

  /// What the trail looked like when this painter was made. The trail itself
  /// is the same object from one frame to the next and it is written to in
  /// place, so comparing it against the last painter's would always say
  /// nothing had changed.
  final int trailRevision;

  final List<Flash> flashes;

  /// Height between altitude marks, in metres. About one screen's worth on a
  /// phone, so there is usually one in view and never a ladder of them.
  static const _rungMetres = 25.0;

  static const _starfield = Starfield();

  @override
  void paint(Canvas canvas, Size size) {
    final camera = Camera.forSize(size, focusY);

    _paintSky(canvas, size);
    _starfield.paint(canvas, camera);
    _paintRungs(canvas, camera);
    _paintWalls(canvas, camera);

    for (final well in world.wells) {
      if (well.at.y < camera.bottomY - 3 || well.at.y > camera.topY + 3) {
        continue;
      }
      _paintWell(canvas, camera, well);
    }

    if (world.isHeld) _paintTether(canvas, camera);
    _paintTrail(canvas, camera);
    if (!world.isOver || world.ending == Ending.adrift) {
      _paintCraft(canvas, camera);
    }
    for (final flash in flashes) {
      _paintFlash(canvas, camera, flash);
    }
  }

  void _paintSky(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Palette.skyTop, Palette.skyBottom],
        ).createShader(rect),
    );
  }

  /// Horizontal marks every so many metres, with the height on them.
  ///
  /// The score is a count of wells and says nothing about how far up the
  /// craft is, and how far up it is turns out to be the thing players want to
  /// beat. These are also the only fixed thing on screen while the craft is
  /// flying, which is what makes the climb feel like a climb.
  void _paintRungs(Canvas canvas, Camera camera) {
    final line = Paint()
      ..strokeWidth = 1
      ..color = Palette.rung;
    final left = camera.toScreen(const Vec(-Playfield.edgeX, 0)).dx;
    final right = camera.toScreen(const Vec(Playfield.edgeX, 0)).dx;
    var height = (camera.bottomY / _rungMetres).ceil() * _rungMetres;
    for (; height < camera.topY; height += _rungMetres) {
      if (height <= 0) continue;
      final y = camera.toScreen(Vec(0, height)).dy;
      // Wall to wall rather than edge to edge, so the marks belong to the
      // playfield instead of to the screen.
      canvas.drawLine(Offset(left, y), Offset(right, y), line);

      final label = TextPainter(
        text: TextSpan(
          text: '${height.round()} m',
          style: const TextStyle(
            color: Palette.rungInk,
            // Named because a painter has no context to inherit one from, and
            // a headless render draws every glyph as a box without it.
            fontFamily: 'Roboto',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      label.paint(canvas, Offset(left + 8, y - label.height - 4));
    }
  }

  /// The sides of the playfield. A run ends past these, so they are drawn as
  /// something to stay away from rather than as a border.
  void _paintWalls(Canvas canvas, Camera camera) {
    final height = camera.size.height;
    for (final side in const [-1.0, 1.0]) {
      final x = camera.toScreen(Vec(side * Playfield.edgeX, 0)).dx;
      final inward = camera.px(1.1) * -side;
      final band = Rect.fromLTRB(
        math.min(x, x + inward),
        0,
        math.max(x, x + inward),
        height,
      );
      canvas.drawRect(
        band,
        Paint()
          ..shader = LinearGradient(
            begin: side < 0 ? Alignment.centerLeft : Alignment.centerRight,
            end: side < 0 ? Alignment.centerRight : Alignment.centerLeft,
            colors: [
              Palette.wall.withValues(alpha: 0.10),
              Palette.wall.withValues(alpha: 0),
            ],
          ).createShader(band),
      );
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, height),
        Paint()
          ..strokeWidth = 1.5
          ..color = Palette.wall.withValues(alpha: 0.35),
      );
    }
  }

  void _paintWell(Canvas canvas, Camera camera, Well well) {
    final centre = camera.toScreen(well.at);
    final radius = camera.px(well.radius);
    final used = well.collected;
    final held = world.isHeld && identical(world.wells[world.heldBy!], well);
    final tint = used ? Palette.wellUsed : Palette.well;

    // How near is near enough, drawn rather than left to be guessed at. A
    // player who can see the band learns the range in one run instead of ten.
    _dashedCircle(
      canvas,
      centre,
      camera.px(well.radius + Playfield.catchBand),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = tint.withValues(alpha: used ? 0.09 : 0.20),
      dashes: 32,
    );

    if (!used) {
      final glow = radius * 2.8;
      canvas.drawCircle(
        centre,
        glow,
        Paint()
          ..blendMode = BlendMode.plus
          ..shader = RadialGradient(
            colors: [
              tint.withValues(alpha: 0.26),
              tint.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: centre, radius: glow)),
      );
    }

    // Ticks round the rim, turning while the well is still worth something.
    // A used well keeps its ticks and stops turning, which reads as spent
    // without needing a second colour to explain it.
    final spin = used ? 0.0 : world.seconds * 0.9;
    final tick = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = used ? 1.2 : 2.0
      ..color = tint.withValues(alpha: used ? 0.35 : 0.75);
    for (var i = 0; i < 8; i++) {
      final angle = spin + i * math.pi / 4;
      final unit = Offset(math.cos(angle), math.sin(angle));
      canvas.drawLine(
        centre + unit * (radius * 1.18),
        centre + unit * (radius * 1.42),
        tick,
      );
    }

    canvas.drawCircle(
      centre,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = used ? 1.4 : 2.6
        ..color = (held ? Palette.wellHeld : tint)
            .withValues(alpha: used && !held ? 0.5 : 0.95),
    );

    // The solid middle. Hitting this ends the run, so it gets the one warning
    // colour on screen.
    final core = radius * Playfield.coreShare;
    canvas.drawCircle(centre, core, Paint()..color = Palette.wellCore);
    canvas.drawCircle(
      centre,
      core,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Palette.wellDanger.withValues(alpha: used ? 0.28 : 0.6),
    );
  }

  /// The line holding the craft, the circle it is being swung round, and a
  /// few dashes along the way it would leave.
  ///
  /// The dashes are the whole game in one cue: the release is a decision
  /// about direction, and a player who cannot see which way they are pointing
  /// is guessing rather than aiming. They stop short and they do not curve,
  /// because gravity has the rest of the say and that part is the skill.
  void _paintTether(Canvas canvas, Camera camera) {
    final well = world.wells[world.heldBy!];
    final anchor = camera.toScreen(well.at);
    final craft = camera.toScreen(world.craft);

    _dashedCircle(
      canvas,
      anchor,
      camera.px(Playfield.tether),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Palette.wellHeld.withValues(alpha: 0.16),
      dashes: 44,
    );

    canvas.drawLine(
      anchor,
      craft,
      Paint()
        ..strokeWidth = camera.px(0.055)
        ..strokeCap = StrokeCap.round
        ..shader = LinearGradient(
          colors: [
            Palette.wellHeld.withValues(alpha: 0.25),
            Palette.craft.withValues(alpha: 0.85),
          ],
        ).createShader(Rect.fromPoints(anchor, craft)),
    );

    final way = world.velocity.normalised;
    final dash = Paint()
      ..strokeCap = StrokeCap.round
      ..blendMode = BlendMode.plus;
    for (var i = 0; i < 4; i++) {
      final from = world.craft + way * (0.62 + i * 0.52);
      final to = from + way * 0.3;
      dash
        ..strokeWidth = camera.px(0.09 - i * 0.014)
        ..color = Palette.craft.withValues(alpha: 0.42 - i * 0.09);
      canvas.drawLine(camera.toScreen(from), camera.toScreen(to), dash);
    }
  }

  /// Where each pass of the trail starts along the path, how wide it is in
  /// metres, and how strongly it burns.
  static const _trailPasses = [
    (0.0, 0.045, 0.14),
    (0.45, 0.075, 0.22),
    (0.78, 0.11, 0.34),
  ];

  void _paintTrail(Canvas canvas, Camera camera) {
    final points = trail.points;
    if (points.length < 2) return;

    // Three strokes over the same path, each shorter and wider than the last,
    // rather than a stroke per step with its own width. Ninety little
    // segments with round caps bead where they overlap and the streak comes
    // out looking like a chain; three passes taper smoothly and cost three
    // draw calls instead of ninety.
    for (final (from, width, alpha) in _trailPasses) {
      final start = (points.length * from).floor();
      if (points.length - start < 2) continue;
      final path = Path();
      final head = camera.toScreen(points[start]);
      path.moveTo(head.dx, head.dy);
      for (var i = start + 1; i < points.length; i++) {
        final at = camera.toScreen(points[i]);
        path.lineTo(at.dx, at.dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..blendMode = BlendMode.plus
          ..strokeWidth = camera.px(width)
          ..color = Color.lerp(Palette.craft, Palette.craftHot, from)!
              .withValues(alpha: alpha),
      );
    }
  }

  void _paintCraft(Canvas canvas, Camera camera) {
    final way = world.velocity.length == 0
        ? const Vec(1, 0)
        : world.velocity.normalised;
    final side = way.perpendicular;
    final at = world.craft;
    final centre = camera.toScreen(at);

    final glow = camera.px(1.0);
    canvas.drawCircle(
      centre,
      glow,
      Paint()
        ..blendMode = BlendMode.plus
        ..shader = RadialGradient(
          colors: [
            Palette.craft.withValues(alpha: 0.34),
            Palette.craft.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: centre, radius: glow)),
    );

    // A dart, pointed the way it is going. Direction is the one thing the
    // player has to read off the craft, so the shape says it and nothing else.
    final hull = [
      at + way * 0.42,
      at - way * 0.2 + side * 0.22,
      at - way * 0.06,
      at - way * 0.2 - side * 0.22,
    ].map(camera.toScreen).toList();
    final body = Path()..moveTo(hull.first.dx, hull.first.dy);
    for (final point in hull.skip(1)) {
      body.lineTo(point.dx, point.dy);
    }
    body.close();

    canvas.drawPath(body, Paint()..color = Palette.craft);
    canvas.drawPath(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..strokeJoin = StrokeJoin.round
        ..color = Palette.craftHot,
    );
    canvas.drawCircle(
      camera.toScreen(at + way * 0.06),
      camera.px(0.07),
      Paint()..color = Palette.craftHot,
    );
  }

  void _paintFlash(Canvas canvas, Camera camera, Flash flash) {
    final t = flash.progress;
    if (t >= 1) return;
    final fade = (1 - t) * (1 - t);
    final centre = camera.toScreen(flash.at);

    final (Color colour, double from, double to, int spokes) = switch (
      flash.kind
    ) {
      // Letting go is the one thing the player did, so it gets the biggest
      // ring and the colour of the craft rather than of the world.
      // Starting outside the craft rather than on it, so the burst reads as
      // something leaving instead of as a scribble over the thing that left.
      FlashKind.released => (Palette.craft, 0.6, 2.4, 6),
      FlashKind.caught => (Palette.well, 0.5, 1.7, 0),
      FlashKind.crashed => (Palette.wellDanger, 0.4, 3.0, 10),
    };

    // Out fast and then slowing, which is what an expanding shockwave does.
    final eased = 1 - (1 - t) * (1 - t) * (1 - t);
    final radius = camera.px(from + (to - from) * eased);
    canvas.drawCircle(
      centre,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1, camera.px(0.1) * fade)
        ..blendMode = BlendMode.plus
        ..color = colour.withValues(alpha: 0.8 * fade),
    );

    if (spokes == 0) return;
    final spoke = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.max(1, camera.px(0.06) * fade)
      ..blendMode = BlendMode.plus
      ..color = colour.withValues(alpha: 0.6 * fade);
    for (var i = 0; i < spokes; i++) {
      final angle = i * 2 * math.pi / spokes;
      final unit = Offset(math.cos(angle), math.sin(angle));
      canvas.drawLine(
        centre + unit * (radius * 0.72),
        centre + unit * (radius * 1.15),
        spoke,
      );
    }
  }

  void _dashedCircle(
    Canvas canvas,
    Offset centre,
    double radius,
    Paint paint, {
    required int dashes,
  }) {
    if (radius <= 0) return;
    final rect = Rect.fromCircle(center: centre, radius: radius);
    final step = 2 * math.pi / dashes;
    for (var i = 0; i < dashes; i++) {
      canvas.drawArc(rect, i * step, step * 0.5, false, paint);
    }
  }

  @override
  bool shouldRepaint(WorldPainter old) =>
      // The world is rebuilt by every step it takes, so a world that is the
      // same object is a world nothing has happened to.
      !identical(old.world, world) ||
      old.focusY != focusY ||
      old.trailRevision != trailRevision ||
      !listEquals(old.flashes, flashes);
}
