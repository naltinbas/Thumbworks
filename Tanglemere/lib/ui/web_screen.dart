import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../web/play.dart';
import '../web/webs.dart';
import 'palette.dart';
import 'result_card.dart';
import 'webview.dart';

/// One web: weave and never close your own triangle.
class WebScreen extends StatefulWidget {
  const WebScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, when the player does as well as the web allows,
  /// with the askings used. Answers whether that beat what was
  /// written down before.
  final Future<bool> Function(int askings)? onDone;

  @override
  State<WebScreen> createState() => WebScreenState();
}

class WebScreenState extends State<WebScreen> {
  static const loomKey = ValueKey('loom');

  late Play _play;

  var _pointing = -1;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Play get play => _play;
  int get pointing => _pointing;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(WebScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _play = Play.of(Webs.at(widget.number)).houseOpens();
    _pointing = -1;
    _hints = 0;
    _saying = switch (Webs.at(widget.number).standing) {
      -1 => 'The search of every weave gives this web to the house '
          'before your first thread. Play it out; ask why for the '
          'words.',
      _ => null,
    };
    _told = false;
    _best = false;
  }

  void _touched(int thread) {
    if (thread < 0 || _play.isOver) return;
    if (!_play.isFree(thread)) {
      HapticFeedback.selectionClick();
      setState(() {
        _saying = 'That thread is woven already.';
      });
      return;
    }

    HapticFeedback.selectionClick();
    final could = _play.standing;
    final closes = _play.rules.closing(_play.mine, thread) != null;
    final next = _play.weave(thread);
    setState(() {
      _play = next;
      _pointing = -1;
      _saying = _note(next, could, closes);
    });
    if (next.isOver) _finished();
  }

  String? _note(Play play, int could, bool closed) {
    if (play.isOver) return null;
    final now = play.standing;
    if (now < could) {
      return 'That thread let the weave slip: the search now reads '
          'it ${now == 0 ? 'a draw at best' : 'lost'}. Back takes it '
          'off the loom.';
    }
    return null;
  }

  void _again() {
    setState(_set);
  }

  /// Take back the round: the house's reply and your thread.
  void _takeBack() {
    if (_play.before == null) return;
    setState(() {
      var back = _play.back;
      // Never take back past the house's opening thread.
      if (back.before != null &&
          !(back.woven <= 1 && !_play.web.playerFirst)) {
        back = back.back;
      }
      _play = back;
      _pointing = -1;
      _saying = null;
    });
  }

  /// Asked. The search's thread.
  void _showMe() {
    final thread = _play.next;
    setState(() {
      _hints++;
      if (_play.isOver) {
        _pointing = -1;
        _saying = 'The weave is settled.';
        return;
      }
      if (thread == null || thread < 0) {
        _pointing = -1;
        _saying = 'No thread is left.';
        return;
      }
      _pointing = thread;
      _saying = _play.standing >= 0
          ? 'Weave that thread: the search has read every weave '
              'below it, and it keeps your standing.'
          : 'Weave that thread: it holds out longest, though the '
              'search reads the web lost from every thread here.';
    });
  }

  /// Asked why. The Ramsey pair, and the search.
  void _why() {
    setState(() {
      _hints++;
      _pointing = -1;
      _saying = whyWords(_play);
    });
  }

  void _finished() {
    HapticFeedback.mediumImpact();
    if (_told) return;
    _told = true;
    // Doing as well as the web allows earns the record: a win where
    // the win stands, a draw where the draw does.
    final asked = _play.web.standing;
    final got = _play.playerWon ? 1 : (_play.isDrawn ? 0 : -1);
    if (got >= asked && asked >= 0) {
      widget.onDone?.call(_hints).then((best) {
        if (mounted && best) setState(() => _best = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) widget.onLeave();
      },
      child: Scaffold(
        backgroundColor: Palette.dark,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Ledger(play: _play, onLeave: widget.onLeave),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _Loom(
                    play: _play,
                    pointing: _pointing,
                    onTouch: _touched,
                  ),
                ),
              ),
              if (_play.isOver)
                ResultCard(
                  play: _play,
                  best: _best,
                  hints: _hints,
                  onAgain: _again,
                  onNext: widget.onNext,
                  onLeave: widget.onLeave,
                )
              else
                _Tools(
                  saying: _saying,
                  onAgain: _again,
                  onBack: _takeBack,
                  onShowMe: _showMe,
                  onWhy: _why,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The line above the loom: which web, and how it is going.
class _Ledger extends StatelessWidget {
  const _Ledger({required this.play, required this.onLeave});

  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final standing = play.standing;

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the webs',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  play.web.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Palette.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  play.isOver
                      ? play.playerWon
                          ? 'the house closed its triangle'
                          : play.isDrawn
                              ? 'the web holds, nobody caught'
                              : 'your triangle closed'
                      : switch (standing) {
                          1 => 'the search reads the win yours',
                          0 => 'the search reads the weave even',
                          _ => 'the search reads the web the '
                              'house\'s',
                        },
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: play.isOver
                        ? (play.playerWon || play.isDrawn
                            ? Palette.good
                            : Palette.bad)
                        : standing >= 0
                            ? Palette.inkDim
                            : Palette.bad,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${play.woven} woven',
            style: const TextStyle(
              color: Palette.ink,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

/// The loom itself.
class _Loom extends StatelessWidget {
  const _Loom({
    required this.play,
    required this.pointing,
    required this.onTouch,
  });

  final Play play;
  final int pointing;
  final ValueChanged<int> onTouch;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final size = Size(room.maxWidth, room.maxHeight);
          final metrics = Metrics(play, size);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (touch) =>
                onTouch(metrics.threadAt(touch.localPosition)),
            child: CustomPaint(
              key: WebScreenState.loomKey,
              size: size,
              painter: WebView(
                play: play,
                pointing: pointing,
                labels: const TextStyle(fontFamily: 'Roboto'),
              ),
            ),
          );
        },
      );
}

/// Under the loom: what the game has to say, and what else can be
/// done.
class _Tools extends StatelessWidget {
  const _Tools({
    required this.saying,
    required this.onAgain,
    required this.onBack,
    required this.onShowMe,
    required this.onWhy,
  });

  final String? saying;
  final VoidCallback onAgain;
  final VoidCallback onBack;
  final VoidCallback onShowMe;
  final VoidCallback onWhy;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Palette.panel,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Palette.line, width: 1.1),
              ),
              child: Text(
                saying ??
                    'Tap a free thread to weave it yours; the house '
                        'weaves back at once. Whoever closes a '
                        'triangle of their own colour loses.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: saying == null ? Palette.inkDim : Palette.ink,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _Button(label: 'Again', onTap: onAgain)),
                const SizedBox(width: 8),
                Expanded(child: _Button(label: 'Back', onTap: onBack)),
                const SizedBox(width: 8),
                Expanded(child: _Button(label: 'Show me', onTap: onShowMe)),
                const SizedBox(width: 8),
                Expanded(child: _Button(label: 'Why', onTap: onWhy)),
              ],
            ),
          ],
        ),
      );
}

class _Button extends StatelessWidget {
  const _Button({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        child: GestureDetector(
          onTap: onTap,
          child: ExcludeSemantics(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: Palette.panel,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Palette.edge, width: 1.1),
              ),
              child: Center(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Palette.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
