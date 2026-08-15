import 'package:flutter/material.dart';

import '../best.dart';
import '../string/play.dart';
import '../string/share.dart';
import 'stringview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One share, cut gap by gap.
class StringScreen extends StatefulWidget {
  const StringScreen({super.key, required this.share});

  final Share share;

  @override
  State<StringScreen> createState() => StringScreenState();
}

class StringScreenState extends State<StringScreen> {
  late Play play;

  /// What the show-me points at, or null.
  (String, int)? pointing;

  int? fewest;
  bool isRecord = false;
  bool _counted = false;

  @override
  void initState() {
    super.initState();
    play = Play.of(widget.share);
    Best.ready().then((_) {
      if (mounted) {
        setState(() => fewest = Best.fewest(widget.share.name));
      }
    });
  }

  void _tap(int? gap) {
    if (gap == null || play.isOver) return;
    setState(() {
      play = play.tap(gap);
      pointing = null;
    });
    if (play.isDone && !_counted) {
      _counted = true;
      Best.landed(widget.share.name, play.moves).then((record) {
        if (mounted) {
          setState(() {
            isRecord = record;
            fewest = Best.fewest(widget.share.name);
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
      play = Play.of(widget.share);
      pointing = null;
      _counted = false;
      isRecord = false;
    });
  }

  /// What the sham says of itself, as it stands.
  String verdict() {
    final aim = pointing;
    if (aim != null) {
      return aim.$1 == 'mend'
          ? 'Mend the ringed cut: it is off the share.'
          : 'Cut the string at the ringed gap.';
    }
    if (play.isDone) {
      return 'Shared: each child holds half of every kind.';
    }
    final (first, second) = play.shares;
    final unfair = [
      for (final kind in play.rules.kinds)
        if ((first[kind] ?? 0) != (second[kind] ?? 0)) Share.kindNames[kind]!,
    ];
    if (unfair.isEmpty && play.cuts.length > play.share.cuts) {
      return 'Fair, but ${play.cuts.length} cuts is more than allowed.';
    }
    if (unfair.isEmpty) return 'Fair as it stands.';
    return 'Cuts ${play.cuts.length} of ${play.share.cuts}; '
        '${unfair.join(' and ')} not yet halved.';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.night,
        appBar: AppBar(
          backgroundColor: Palette.night,
          foregroundColor: Palette.ink,
          title: Text(widget.share.name),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Tap a gap to cut the string, tap a cut to mend it; '
                  'the pieces go to the children in turn: '
                  '${widget.share.task}.',
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
                      painter: StringView(
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
                      'cuts ${play.cuts.length} of ${widget.share.cuts}',
                      style: const TextStyle(
                          color: Palette.ink, fontSize: 13),
                    ),
                  ),
                  for (final kind in play.rules.kinds)
                    Chip(
                      backgroundColor: Palette.board,
                      side: BorderSide(
                          color: (play.shares.$1[kind] ?? 0) ==
                                  (play.shares.$2[kind] ?? 0)
                              ? Palette.agree
                              : Palette.line),
                      label: Text(
                        '${Share.kindNames[kind]} '
                        '${play.shares.$1[kind] ?? 0} · '
                        '${play.shares.$2[kind] ?? 0}',
                        style: TextStyle(
                            color: (play.shares.$1[kind] ?? 0) ==
                                    (play.shares.$2[kind] ?? 0)
                                ? Palette.agree
                                : Palette.inkDim,
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
