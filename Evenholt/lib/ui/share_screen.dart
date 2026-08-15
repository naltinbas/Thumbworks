import 'package:flutter/material.dart';

import '../best.dart';
import '../share/play.dart';
import '../share/share.dart';
import 'trayview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One share, dealt token by token.
class ShareScreen extends StatefulWidget {
  const ShareScreen({super.key, required this.share});

  final Share share;

  @override
  State<ShareScreen> createState() => ShareScreenState();
}

class ShareScreenState extends State<ShareScreen> {
  late Play play;

  /// The token the show-me points at, or null.
  int? pointing;

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

  void _tap(int? token) {
    if (token == null || play.isOver) return;
    setState(() {
      play = play.tap(token);
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
      return 'Carry token $aim across to the other tray.';
    }
    if (play.isDone) {
      return 'Shared: every power agrees.';
    }
    final agreeing = play.agreeing;
    final agreed = agreeing.where((yes) => yes).length;
    if (play.leftTray.length != play.rightTray.length) {
      return 'Trays hold ${play.leftTray.length} and '
          '${play.rightTray.length}; ${play.share.half} each wanted.';
    }
    if (agreed == 0) {
      return 'Half and half, no power agreeing yet.';
    }
    final names = [
      for (var degree = 1; degree <= play.share.degrees; degree++)
        if (agreeing[degree - 1]) Share.powerNames[degree - 1],
    ];
    return '${names.join(' and ')} agree; '
        '${play.share.degrees - agreed} to go.';
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
                  'Tap a token to carry it to the other tray: '
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
                      painter: TrayView(
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
                        color: play.leftTray.length == play.rightTray.length
                            ? Palette.line
                            : Palette.part),
                    label: Text(
                      'trays ${play.leftTray.length} · '
                      '${play.rightTray.length}',
                      style: const TextStyle(
                          color: Palette.ink, fontSize: 13),
                    ),
                  ),
                  for (var degree = 1;
                      degree <= widget.share.degrees;
                      degree++)
                    Chip(
                      backgroundColor: Palette.board,
                      side: BorderSide(
                          color: play.agreeing[degree - 1]
                              ? Palette.agree
                              : Palette.line),
                      label: Text(
                        '${Share.powerNames[degree - 1]} '
                        '${play.sums(degree).$1} · '
                        '${play.sums(degree).$2}',
                        style: TextStyle(
                            color: play.agreeing[degree - 1]
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
