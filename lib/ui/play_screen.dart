import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../music.dart';
import '../play/beat.dart';
import '../play/session.dart';
import '../tune/tune.dart';
import 'hud.dart';
import 'palette.dart';
import 'result_card.dart';
import 'stage_painter.dart';

/// One go at one tune.
class PlayScreen extends StatefulWidget {
  const PlayScreen({
    super.key,
    required this.tune,
    required this.onLeave,
    required this.onAgain,
    this.music,
    this.silent = false,
  });

  final Tune tune;
  final VoidCallback onLeave;
  final VoidCallback onAgain;

  /// The player. A test passes its own, or none at all.
  final Music? music;

  /// Runs the tune off a plain clock instead of the music.
  ///
  /// Only a test or a screenshot does this. It is the same game either way —
  /// everything that judges anything works off a number of seconds and does
  /// not care where the number came from.
  final bool silent;

  @override
  State<PlayScreen> createState() => PlayScreenState();
}

class PlayScreenState extends State<PlayScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late Session _session;
  final _beat = Beat();
  Music? _music;
  StreamSubscription<Duration>? _positions;

  Ticker? _ticker;
  Duration _wall = Duration.zero;

  /// Lanes a finger is on, and how long since.
  final _struck = <int, double>{};

  /// The last thing the game said about a tap, and when it said it.
  Judgement? _said;
  double _saidAt = 0;

  bool _away = false;

  Session get session => _session;
  double get at => _session.at;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _session = Session.of(widget.tune);
    _ticker = createTicker(_tick)..start();
    _start();
  }

  Future<void> _start() async {
    if (widget.silent) {
      // No sound, so the wall clock is the music. The first frame is time
      // zero.
      return;
    }
    final music = widget.music ?? Music();
    _music = music;
    _positions = music.positions.listen((position) {
      _beat.reported(position, _wall);
    });
    await music.play(widget.tune);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _positions?.cancel();
    _ticker?.dispose();
    if (widget.music == null) _music?.throwAway();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) return;
    if (_away || _session.isOver) return;
    setState(() => _away = true);
    _music?.pause();
  }

  void _comeBack() {
    if (!_away) return;
    setState(() => _away = false);
    _music?.carryOn();
  }

  void _tick(Duration elapsed) {
    _wall = elapsed;
    if (_session.isOver || _away) return;

    // Where the music is. Without sound, the wall clock stands in for it.
    final now = widget.silent
        ? elapsed.inMicroseconds / 1000000
        : _beat.at(elapsed);
    if (!widget.silent && !_beat.running) return;

    for (final lane in _struck.keys.toList()) {
      _struck[lane] = _struck[lane]! + 1 / 60;
      if (_struck[lane]! > 0.4) _struck.remove(lane);
    }

    final was = _session.hits.length;
    final session = _session.seenTo(now);
    if (session.hits.length != was &&
        session.hits.last.judgement == Judgement.missed) {
      _said = Judgement.missed;
      _saidAt = now;
    }

    setState(() => _session = session);
    if (session.isOver) _finish();
  }

  void _finish() {
    _music?.stop();
    HapticFeedback.mediumImpact();
  }

  void _tapped(int lane) {
    if (_session.isOver || _away) return;
    HapticFeedback.selectionClick();

    final before = _session.hits.length;
    final session = _session.tapped(lane, _session.at);
    setState(() {
      _session = session;
      _struck[lane] = 0;
      if (session.hits.length != before) {
        _said = session.hits.last.judgement;
        _saidAt = session.at;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final saying = _said != null && _session.at - _saidAt < 0.55 ? _said : null;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) widget.onLeave();
      },
      child: Scaffold(
        backgroundColor: Palette.night,
        body: Stack(
          fit: StackFit.expand,
          children: [
            LayoutBuilder(
              builder: (context, box) {
                final metrics = Metrics(Size(box.maxWidth, box.maxHeight));
                return Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: (event) =>
                      _tapped(metrics.laneAt(event.localPosition)),
                  child: CustomPaint(
                    size: Size(box.maxWidth, box.maxHeight),
                    painter: StagePainter(
                      session: _session,
                      metrics: metrics,
                      at: _session.at,
                      struck: Map<int, double>.from(_struck),
                    ),
                  ),
                );
              },
            ),
            // A wash under the top bar. Notes fall the whole height of the
            // screen and the score sits in the same place, so without this the
            // number is unreadable exactly when it is worth reading.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 150,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Palette.night,
                        Palette.night.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Ledger(
                  session: _session,
                  saying: saying,
                  onLeave: widget.onLeave,
                ),
              ),
            ),
            if (_away)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _comeBack,
                  child: ColoredBox(
                    color: Palette.veil.withValues(alpha: 0.94),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Held',
                            style: TextStyle(
                              color: Palette.ink,
                              fontSize: 30,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 6,
                            ),
                          ),
                          SizedBox(height: 18),
                          Text(
                            'Touch to carry on',
                            style: TextStyle(
                              color: Palette.perfect,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            if (_session.isOver)
              ResultCard(
                session: _session,
                onAgain: widget.onAgain,
                onLeave: widget.onLeave,
              ),
          ],
        ),
      ),
    );
  }
}
