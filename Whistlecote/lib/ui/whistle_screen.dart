import 'package:flutter/material.dart';

import '../best.dart';
import '../whistle/level.dart';
import '../whistle/play.dart';
import '../whistle/rules.dart';
import 'moorview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One set of calls, whistled note by note.
class WhistleScreen extends StatefulWidget {
  const WhistleScreen({super.key, required this.level});

  final Level level;

  @override
  State<WhistleScreen> createState() => WhistleScreenState();
}

class WhistleScreenState extends State<WhistleScreen> {
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

  void _tap(int? node) {
    if (node == null || play.isOver) return;
    setState(() {
      play = play.tap(node);
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
      final (_, k) = aim;
      if (aim.$1 == 'lift') return 'Lift the whistle ${Rules.said(k)}; the shepherd has no call for it.';
      final aimed = Play.aimFor(play.level)!;
      final call = play.level.calls[_callFor(aimed, k)].$1;
      return 'Give $call the whistle ${Rules.said(k)}.';
    }
    if (play.isDone) return 'Whistled: every call has its notes and none is the start of another.';
    final clashes = play.clashes;
    if (clashes.isNotEmpty) {
      final (a, b) = clashes.first;
      return '${_name(a)} is the start of ${_name(b)}: the dog would go at the first'
          '${clashes.length > 1 ? ', and ${clashes.length - 1} more pair${clashes.length > 2 ? 's' : ''} clash' : ''}.';
    }
    if (play.over > 0) {
      return '${play.over} whistle${play.over == 1 ? '' : 's'} more than the calls ask at that length; lift ${play.over == 1 ? 'it' : 'them'}.';
    }
    return 'Whistled ${play.whistled} of ${play.level.calls.length}; none the start of another so far.';
  }

  /// A marked whistle by its call's name, or by its notes.
  String _name(int k) {
    final call = play.callOf(k);
    return call == null ? 'the whistle ${Rules.said(k)}' : play.level.calls[call].$1;
  }

  /// Which call the shepherd gives node [k] in the marking [aimed]: the
  /// i-th of its length among the marks is the i-th call of that length.
  int _callFor(List<int> aimed, int k) {
    final l = Rules.notesOf(k);
    var seen = 0;
    for (final m in aimed) {
      if (m == k) break;
      if (Rules.notesOf(m) == l) seen++;
    }
    var i = 0;
    for (var c = 0; c < play.level.calls.length; c++) {
      if (play.level.calls[c].$2 != l) continue;
      if (i == seen) return c;
      i++;
    }
    return 0;
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
                  'Tap a whistle to give it to the next call of that many '
                  'notes, again to take it back; a whistle that is the start '
                  'of another goes rust: ${widget.level.task}.',
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
                      painter: MoorView(
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
                      'whistled ${play.whistled} of ${widget.level.calls.length}',
                      style: const TextStyle(
                          color: Palette.ink, fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: BorderSide(
                        color: play.clashes.isEmpty ? Palette.line : Palette.bad),
                    label: Text(
                      'clashes ${play.clashes.length}',
                      style: TextStyle(
                          color: play.clashes.isEmpty ? Palette.good : Palette.bad, fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: BorderSide(
                        color: play.share > play.rules.whole ? Palette.bad : Palette.line),
                    label: Text(
                      'shares ${play.share} of ${play.rules.whole}',
                      style: TextStyle(
                          color: play.share > play.rules.whole ? Palette.bad : Palette.inkDim, fontSize: 13),
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
