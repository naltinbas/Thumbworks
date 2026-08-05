import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../raise/frames.dart';
import '../raise/play.dart';
import 'frameview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One frame: get it standing in the fewest days.
class RaiseScreen extends StatefulWidget {
  const RaiseScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, the first time a frame is standing, with the days it took.
  /// Answers whether that beat what was written down before.
  final Future<bool> Function(int days)? onDone;

  @override
  State<RaiseScreen> createState() => RaiseScreenState();
}

class RaiseScreenState extends State<RaiseScreen> {
  static const frameKey = ValueKey('frame');

  late Play _play;

  var _showRun = false;
  var _pointing = -1;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Play get play => _play;
  bool get showRun => _showRun;
  int get pointing => _pointing;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(RaiseScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _play = Play.of(
      Frames.at(widget.number),
      Frames.raiserFor(widget.number),
      Frames.raisingFor(widget.number),
    );
    _showRun = false;
    _pointing = -1;
    _hints = 0;
    _saying = null;
    _told = false;
    _best = false;
  }

  void _touched(int timber) {
    if (timber < 0 || _play.isDone) return;

    if (_play.isUp(timber)) {
      setState(() {
        _showRun = false;
        _pointing = -1;
        _saying = '${_name(timber)} is up already.';
      });
      return;
    }

    if (!_play.isToday(timber) && !_play.isReady(timber)) {
      final waiting = _play.frame.waitingOn(timber, _play.standing);
      setState(() {
        _showRun = false;
        _pointing = waiting.first;
        _saying = '${_name(timber)} rests on ${_list(waiting)}.';
      });
      return;
    }

    final next = _play.put(timber);
    if (identical(next, _play)) {
      setState(() {
        _showRun = false;
        _pointing = -1;
        _saying = 'There are only ${_play.frame.crews} crews, and they are all '
            'on something.';
      });
      return;
    }

    HapticFeedback.selectionClick();
    setState(() {
      _play = next;
      _showRun = false;
      _pointing = -1;
      _saying = null;
    });
  }

  void _raise() {
    if (!_play.canRaise) {
      setState(() => _saying = 'Put the crews on something first.');
      return;
    }
    HapticFeedback.mediumImpact();
    final next = _play.raise();
    setState(() {
      _play = next;
      _showRun = false;
      _pointing = -1;
      _saying = _note(next);
    });
    if (next.isDone) _finished();
  }

  /// What the site has to say at the end of a day.
  ///
  /// One thing, and only when it is true: that the frame can no longer be up
  /// in as few days as it might have been. The game can say that because it
  /// works the whole thing out again from what is standing, which is the same
  /// working out it did at the start and costs nothing the second time.
  String? _note(Play play) {
    if (play.isDone) return null;
    final could = play.couldFinishIn;
    if (could <= play.answer.days) return null;
    return 'The best this can be up in now is $could days, which is '
        '${could - play.answer.days} more than the ${play.answer.days} it '
        'takes.';
  }

  void _again() {
    setState(() {
      _play = _play.again;
      _showRun = false;
      _pointing = -1;
      _saying = null;
      _told = false;
      _best = false;
    });
  }

  void _clear() {
    if (_play.today.isEmpty) return;
    setState(() {
      _play = _play.clearToday;
      _saying = null;
    });
  }

  /// Asked. Puts the crews on the timbers that still finish in as few days as
  /// the frame can now be finished in.
  void _showMe() {
    final next = _play.next;
    setState(() {
      _hints++;
      _showRun = false;
      _pointing = -1;
      if (next.isEmpty) {
        _saying = 'There is nothing left to raise.';
        return;
      }
      var laid = _play.clearToday;
      for (final timber in next) {
        laid = laid.put(timber);
      }
      _play = laid;
      _saying = '${_list(next)} today. '
          '${_play.daysLeft - 1} more days after this one.';
    });
  }

  /// Asked why it takes what it takes. Whichever floor is the tight one: the
  /// longest run of timbers each resting on the last, which no number of crews
  /// can spread over fewer days, or the plain work, which no amount of
  /// planning can get under.
  void _why() {
    setState(() {
      _hints++;
      _pointing = -1;
      final answer = _play.answer;
      final frame = _play.frame;

      if (answer.chainIsTight) {
        _showRun = true;
        final run = answer.chain.map(_name).toList();
        _saying = '${_list(answer.chain)} each rest on the one before, so no '
            'two of them can go up on the same day. That is ${run.length} days '
            'before anybody counts the crews.';
        return;
      }

      _showRun = false;
      _saying = 'There are ${frame.count} timbers and ${frame.crews} crews, '
          'and a crew raises one timber a day. That is ${answer.byWork} days '
          'of work whatever order anybody does it in.';
    });
  }

  String _name(int timber) => _play.frame.timbers[timber].name;

  String _list(List<int> timbers) {
    final names = timbers.map(_name).toList();
    if (names.length == 1) return names.first;
    return '${names.sublist(0, names.length - 1).join(', ')} and ${names.last}';
  }

  void _finished() {
    HapticFeedback.mediumImpact();
    if (_told) return;
    _told = true;
    widget.onDone?.call(_play.day).then((best) {
      if (mounted && best) setState(() => _best = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) widget.onLeave();
      },
      child: Scaffold(
        backgroundColor: Palette.night,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Ledger(play: _play, onLeave: widget.onLeave),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _Site(
                    play: _play,
                    showRun: _showRun,
                    pointing: _pointing,
                    onTouch: _touched,
                  ),
                ),
              ),
              if (_play.isDone)
                ResultCard(
                  play: _play,
                  best: _best,
                  onAgain: _again,
                  onNext: widget.onNext,
                  onLeave: widget.onLeave,
                )
              else
                _Tools(
                  saying: _saying,
                  play: _play,
                  onRaise: _raise,
                  onClear: _clear,
                  onAgain: _again,
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

/// The line above the site: which frame, and how it is going.
class _Ledger extends StatelessWidget {
  const _Ledger({required this.play, required this.onLeave});

  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final over = play.couldFinishIn > play.answer.days;

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the frames',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  play.frame.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Palette.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  play.isDone
                      ? 'the whole frame is standing'
                      : 'day ${play.day + 1}, '
                          '${play.today.length} of ${play.frame.crews} crews '
                          'set on',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: play.isDone ? Palette.good : Palette.inkDim,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${play.day} / ${play.answer.days}',
            style: TextStyle(
              color: over ? Palette.bad : Palette.ink,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

/// The site itself.
class _Site extends StatelessWidget {
  const _Site({
    required this.play,
    required this.showRun,
    required this.pointing,
    required this.onTouch,
  });

  final Play play;
  final bool showRun;
  final int pointing;
  final ValueChanged<int> onTouch;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final size = Size(room.maxWidth, room.maxHeight);
          final metrics = Metrics(play, size);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (touch) => onTouch(metrics.timberAt(touch.localPosition)),
            child: CustomPaint(
              key: RaiseScreenState.frameKey,
              size: size,
              painter: FrameView(
                play: play,
                showRun: showRun,
                pointing: pointing,
                labels: const TextStyle(fontFamily: 'Roboto', fontSize: 12),
              ),
            ),
          );
        },
      );
}

/// Under the site: what the game has to say, and what else can be done.
class _Tools extends StatelessWidget {
  const _Tools({
    required this.saying,
    required this.play,
    required this.onRaise,
    required this.onClear,
    required this.onAgain,
    required this.onShowMe,
    required this.onWhy,
  });

  final String? saying;
  final Play play;
  final VoidCallback onRaise;
  final VoidCallback onClear;
  final VoidCallback onAgain;
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
                color: Palette.verge,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Palette.line, width: 1.1),
              ),
              child: Text(
                saying ??
                    'Tap the timbers to put the crews on them, up to '
                        '${play.frame.crews} a day, then raise the day. '
                        'Nothing goes up before what it rests on.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: saying == null ? Palette.inkDim : Palette.ink,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Never dead: a tap on it with nobody set on is worth a word about
            // why rather than nothing at all.
            _Button(
              label: 'Raise the day',
              quiet: !play.canRaise,
              onTap: onRaise,
              big: true,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _Button(label: 'Stand down', onTap: onClear),
                ),
                const SizedBox(width: 7),
                Expanded(child: _Button(label: 'Again', onTap: onAgain)),
                const SizedBox(width: 7),
                Expanded(child: _Button(label: 'Show me', onTap: onShowMe)),
                const SizedBox(width: 7),
                Expanded(child: _Button(label: 'Why', onTap: onWhy)),
              ],
            ),
          ],
        ),
      );
}

class _Button extends StatelessWidget {
  const _Button({
    required this.label,
    required this.onTap,
    this.big = false,
    this.quiet = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool big;

  /// Drawn as though it were dead, but still worth tapping.
  final bool quiet;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        child: GestureDetector(
          onTap: onTap,
          child: ExcludeSemantics(
            child: Container(
              height: big ? 48 : 44,
              decoration: BoxDecoration(
                color: big && !quiet ? Palette.chosen : Palette.verge,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: quiet ? Palette.line : Palette.edge,
                  width: 1.1,
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    color: quiet
                        ? Palette.inkDim
                        : big
                            ? Palette.night
                            : Palette.ink,
                    fontSize: big ? 16 : 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
