import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../flow/most.dart';
import '../flow/play.dart';
import '../flow/works_list.dart';
import 'palette.dart';
import 'result_card.dart';
import 'waterworks.dart';

/// One works: get everything the pipes will carry to the mill.
class WorksScreen extends StatefulWidget {
  const WorksScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, the first time a works runs, with the turns it took.
  /// Answers whether that beat what was written down before.
  final Future<bool> Function(int turns)? onDone;

  @override
  State<WorksScreen> createState() => WorksScreenState();
}

class WorksScreenState extends State<WorksScreen> {
  static const worksKey = ValueKey('works');

  late Waterwork _waterwork;
  late Play _play;
  late Most _most;

  var _pointing = -1;
  var _showCut = false;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Waterwork get waterwork => _waterwork;
  Play get play => _play;
  Most get most => _most;
  int get pointing => _pointing;
  bool get showCut => _showCut;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(WorksScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _waterwork = Waterworks.at(widget.number);
    _play = Play.of(_waterwork.works, _waterwork.target);
    // The most that can get through, and the cut that says why not more.
    // Worked out once when the works opens; it is a few dozen steps.
    _most = _play.answer;
    _pointing = -1;
    _showCut = false;
    _hints = 0;
    _saying = null;
    _told = false;
    _best = false;
  }

  void _touched(int pipe) {
    if (_play.isDone || pipe < 0) return;
    HapticFeedback.selectionClick();
    final next = _play.turn(pipe);
    setState(() {
      _play = next;
      _pointing = -1;
      _showCut = false;
      _saying = _note(next);
    });
    if (next.isDone) _finished();
  }

  /// What the works has to say after a pipe is turned.
  ///
  /// One thing, and only when it is true: a pond where the water does not add
  /// up. That is the rule somebody can break without noticing, since the
  /// numbers on the pipes still look reasonable one at a time.
  String? _note(Play play) {
    if (play.isDone) return null;
    final spills = play.spills;
    if (spills.isEmpty) return null;

    final one = spills.first;
    final name = play.works.ponds[one.pond].name;
    return one.over > 0
        ? '${one.over} more arrives at the $name than leaves it.'
        : '${-one.over} more leaves the $name than arrives.';
  }

  void _again() {
    setState(() {
      _play = _play.again;
      _pointing = -1;
      _showCut = false;
      _saying = null;
      _told = false;
      _best = false;
    });
  }

  /// Asked. The first ask points at a pipe that should be carrying more. The
  /// second shows the cut, which is the answer to the question somebody is
  /// really asking by then: why can it not be more than this?
  void _showMe() {
    if (_play.isDone) return;
    setState(() {
      _hints++;

      for (var pipe = 0; pipe < _play.down.length; pipe++) {
        if (_play.downPipe(pipe) == _most.down[pipe]) continue;
        _pointing = pipe;
        _showCut = false;
        final want = _most.down[pipe];
        final has = _play.downPipe(pipe);
        _saying = want > has
            ? 'That pipe carries $want in the answer, and has $has.'
            : 'That pipe carries $want in the answer, and has $has. Turn it '
                'round to nothing and start it again.';
        return;
      }

      _pointing = -1;
      _showCut = true;
      _saying = 'Everything is where it should be.';
    });
  }

  /// Asked why there is no more. Shows the pipes that hold the whole works
  /// back, which is a proof rather than an excuse: cut those and nothing gets
  /// from the spring to the mill at all, and they hold exactly what the mill
  /// is being asked for.
  void _whyNotMore() {
    setState(() {
      _hints++;
      _showCut = true;
      _pointing = -1;
      final held = _most.holdsOfCut(_play.works);
      _saying = _most.cut.length == 1
          ? 'One pipe holds the whole works back. It takes $held, so $held is '
              'all there is.'
          : '${_most.cut.length} pipes hold the whole works back. Together '
              'they take $held, and cutting them leaves no way from the '
              'spring to the mill at all, so $held is all there is.';
    });
  }

  void _finished() {
    HapticFeedback.mediumImpact();
    if (_told) return;
    _told = true;
    widget.onDone?.call(_play.turns).then((best) {
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
              _Ledger(
                waterwork: _waterwork,
                play: _play,
                onLeave: widget.onLeave,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: _Works(
                    play: _play,
                    pointing: _pointing,
                    showCut: _showCut,
                    cut: _most.cut,
                    onTouch: _touched,
                  ),
                ),
              ),
              if (_play.isDone)
                ResultCard(
                  waterwork: _waterwork,
                  play: _play,
                  best: _best,
                  onAgain: _again,
                  onNext: widget.onNext,
                  onLeave: widget.onLeave,
                )
              else
                _Tools(
                  saying: _saying,
                  onAgain: _again,
                  onShowMe: _showMe,
                  onWhyNotMore: _whyNotMore,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The line above the works: which one, and how it is going.
class _Ledger extends StatelessWidget {
  const _Ledger({
    required this.waterwork,
    required this.play,
    required this.onLeave,
  });

  final Waterwork waterwork;
  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final spills = play.spills.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the works',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  waterwork.name,
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
                      ? 'the mill has all there is'
                      : spills > 0
                          ? '$spills ${spills == 1 ? 'pond does' : 'ponds do'} '
                              'not add up'
                          : '${play.arriving} of ${waterwork.target} at the '
                              'mill',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: play.isDone
                        ? Palette.good
                        : spills > 0
                            ? Palette.bad
                            : Palette.inkDim,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${play.arriving} / ${waterwork.target}',
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

/// The works itself.
class _Works extends StatelessWidget {
  const _Works({
    required this.play,
    required this.pointing,
    required this.showCut,
    required this.cut,
    required this.onTouch,
  });

  final Play play;
  final int pointing;
  final bool showCut;
  final List<int> cut;
  final ValueChanged<int> onTouch;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final size = Size(room.maxWidth, room.maxHeight);
          final metrics = Metrics(play.works, size);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (touch) => onTouch(metrics.pipeAt(touch.localPosition)),
            child: CustomPaint(
              key: WorksScreenState.worksKey,
              size: size,
              painter: Leat(
                play: play,
                pointing: pointing,
                showCut: showCut,
                cut: cut,
                labels: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      );
}

/// Under the works: what the game has to say, and what else can be done.
class _Tools extends StatelessWidget {
  const _Tools({
    required this.saying,
    required this.onAgain,
    required this.onShowMe,
    required this.onWhyNotMore,
  });

  final String? saying;
  final VoidCallback onAgain;
  final VoidCallback onShowMe;
  final VoidCallback onWhyNotMore;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 2, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Palette.stone,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Palette.cut, width: 1.1),
              ),
              child: Text(
                saying ??
                    'Tap a pipe to send one more down it. What arrives at a '
                        'pond has to leave it.',
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
                Expanded(child: _Button(label: 'Show me', onTap: onShowMe)),
                const SizedBox(width: 8),
                Expanded(
                  child: _Button(label: 'Why no more', onTap: onWhyNotMore),
                ),
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
                color: Palette.stone,
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
