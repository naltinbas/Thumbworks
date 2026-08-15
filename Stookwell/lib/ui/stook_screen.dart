import 'package:flutter/material.dart';

import '../best.dart';
import '../stook/level.dart';
import '../stook/play.dart';
import 'stookview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One harvest, stooked sheaf by sheaf.
class StookScreen extends StatefulWidget {
  const StookScreen({super.key, required this.level});

  final Level level;

  @override
  State<StookScreen> createState() => StookScreenState();
}

class StookScreenState extends State<StookScreen> {
  late Play play;

  /// What the show-me points at, or null.
  (String, int)? pointing;

  int? fewest;
  bool isRecord = false;
  bool _counted = false;

  @override
  void initState() {
    super.initState();
    play = Play.of(widget.level);
    Best.ready().then((_) {
      if (mounted) {
        setState(() => fewest = Best.fewest(widget.level.name));
      }
    });
  }

  void _tap(int? where) {
    if (where == null || play.isOver) return;
    setState(() {
      play = play.tap(where);
      pointing = null;
    });
    if (play.isDone && !_counted) {
      _counted = true;
      Best.landed(widget.level.name, play.moves).then((record) {
        if (mounted) {
          setState(() {
            isRecord = record;
            fewest = Best.fewest(widget.level.name);
          });
        }
      });
    }
  }

  void _back() {
    if (play.before == null) return;
    setState(() {
      play = play.back;
      pointing = null;
      _counted = false;
      isRecord = false;
    });
  }

  void _show() {
    setState(() => pointing = play.next);
  }

  void _why() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Palette.board,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Why',
              style: TextStyle(
                color: Palette.ink,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              whyWords(play),
              style: const TextStyle(
                  color: Palette.ink, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _again() {
    setState(() {
      play = Play.of(widget.level);
      pointing = null;
      _counted = false;
      isRecord = false;
    });
  }

  /// What the sham says of itself, as it stands.
  String verdict() {
    final aim = pointing;
    if (aim != null) {
      return aim.$1 == 'back'
          ? 'Take a sheaf back: this standing has strayed.'
          : aim.$1 == 'new'
              ? 'Begin a new stook from the pool.'
              : 'Stand one more sheaf in the ringed stook.';
    }
    if (play.isDone) {
      return 'Stood: ${play.parts.join(', ')}, ${play.level.kind == 'apart' ? 'all apart' : 'all odd'}.';
    }
    if (play.missed) return 'All stood, but ${_fault()}.';
    if (play.stooks.isEmpty) return 'Nothing stood yet; tap the pool to begin a stook.';
    return 'Stooks ${play.parts.join(', ')}; ${play.pool} sheaves to stand.';
  }

  int _alikePairs() {
    var pairs = 0;
    final sizes = play.stooks;
    for (var i = 0; i < sizes.length; i++) {
      for (var j = i + 1; j < sizes.length; j++) {
        if (sizes[i] == sizes[j]) pairs++;
      }
    }
    return pairs;
  }

  String _fault() {
    final sizes = play.stooks;
    if (play.level.stooks != null && sizes.length != play.level.stooks) {
      return 'there are ${sizes.length} stooks, not ${play.level.stooks}';
    }
    if (play.level.kind == 'apart') {
      final alike = sizes.firstWhere((s) => sizes.where((t) => t == s).length > 1);
      return 'two stooks hold $alike alike';
    }
    final even = sizes.firstWhere((s) => s.isEven);
    return 'a stook holds $even, which is even';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.night,
        appBar: AppBar(
          backgroundColor: Palette.night,
          foregroundColor: Palette.ink,
          title: Text(widget.level.name),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Tap the pool to begin a stook with one sheaf, tap a stook '
                  'to stand one more in it: ${widget.level.task}.',
                  style: const TextStyle(
                      color: Palette.inkDim, fontSize: 14),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, room) => GestureDetector(
                    onTapUp: (tap) => _tap(Metrics(
                      play,
                      Size(room.maxWidth, room.maxHeight),
                    ).under(tap.localPosition)),
                    child: CustomPaint(
                      key: const Key('board'),
                      painter: StookView(
                        play: play,
                        pointing: pointing,
                        labels: const TextStyle(fontFamily: 'Roboto'),
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                alignment: WrapAlignment.center,
                children: [
                  Chip(
                    backgroundColor: Palette.board,
                    side: BorderSide(
                        color: play.isDone ? Palette.good : Palette.line),
                    label: Text(
                      'stood ${play.stood} of ${widget.level.sheaves}',
                      style: const TextStyle(
                          color: Palette.ink, fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: BorderSide(
                        color: play.missed ? Palette.bad : Palette.line),
                    label: Text(
                      'stooks ${play.stooks.length}${widget.level.stooks == null ? '' : ' of ${widget.level.stooks}'}',
                      style: const TextStyle(
                          color: Palette.ear, fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: const BorderSide(color: Palette.line),
                    label: Text(
                      widget.level.kind == 'apart'
                          ? 'alike ${_alikePairs()}'
                          : 'even stooks ${play.stooks.where((s) => s.isEven).length}',
                      style: TextStyle(
                          color: (widget.level.kind == 'apart' ? _alikePairs() : play.stooks.where((s) => s.isEven).length) == 0
                              ? Palette.inkDim
                              : Palette.bad,
                          fontSize: 13),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: Text(
                  verdict(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: pointing != null
                        ? Palette.shown
                        : play.isDone
                            ? Palette.good
                            : Palette.ink,
                    fontSize: 14,
                  ),
                ),
              ),
              if (play.isOver)
                ResultCard(
                  play: play,
                  fewest: fewest,
                  isRecord: isRecord,
                  onAgain: _again,
                  onSham: () => Navigator.of(context).pop(),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: play.before == null ? null : _back,
                      child: const Text('Back'),
                    ),
                    TextButton(
                      onPressed: play.isOver ? null : _show,
                      child: const Text('Show me'),
                    ),
                    TextButton(
                      onPressed: _why,
                      child: const Text('Why'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
