import 'package:flutter/material.dart';

import '../acre/field.dart';
import '../acre/play.dart';
import '../best.dart';
import 'acreview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One field, fenced post by post.
class AcreScreen extends StatefulWidget {
  const AcreScreen({super.key, required this.field});

  final Field field;

  @override
  State<AcreScreen> createState() => AcreScreenState();
}

class AcreScreenState extends State<AcreScreen> {
  late Play play;

  /// The post the show-me points at, or null.
  ((int, int), bool)? pointing;

  int? fewest;
  bool isRecord = false;
  bool _counted = false;

  @override
  void initState() {
    super.initState();
    play = Play.of(widget.field);
    Best.ready().then((_) {
      if (mounted) {
        setState(() => fewest = Best.fewest(widget.field.name));
      }
    });
  }

  void _tap((int, int)? post) {
    if (post == null || play.isOver) return;
    setState(() {
      play = play.tapAt(post);
      pointing = null;
    });
    if (play.isDone && !_counted) {
      _counted = true;
      Best.landed(widget.field.name, play.moves).then((record) {
        if (mounted) {
          setState(() {
            isRecord = record;
            fewest = Best.fewest(widget.field.name);
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
      play = Play.of(widget.field);
      pointing = null;
      _counted = false;
      isRecord = false;
    });
  }

  /// What the field says of itself, as it stands.
  String verdict() {
    final aim = pointing;
    if (aim != null) {
      return aim.$2
          ? 'Close the fence at the ringed first post.'
          : 'Walk the fence to the ringed post.';
    }
    if (play.isDone) {
      return 'Fenced: rails say ${play.twoA}, Pick says '
          '${play.twoAByPick}, and the field is landed.';
    }
    if (play.closed) {
      final field = widget.field;
      if (field.twoA != null && play.twoA != field.twoA) {
        return 'Closed, but the paddock holds '
            '${Field.acresWords(play.twoA)} where '
            '${Field.acresWords(field.twoA)} was asked.';
      }
      if (field.inside != null && play.inside != field.inside) {
        return 'Closed, but ${play.inside} '
            'post${play.inside == 1 ? ' stands' : 's stand'} within '
            'where ${field.inside} ${field.inside == 1 ? 'is' : 'are'} '
            'asked.';
      }
      return 'Closed, but a post sits mid-rail where the rim '
          'must stay bare.';
    }
    if (play.walk.length == widget.field.posts) {
      return 'All ${widget.field.posts} posts walked; tap the '
          'first again to close.';
    }
    return 'Posts ${play.walk.length} of ${widget.field.posts} '
        'walked.';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.night,
        appBar: AppBar(
          backgroundColor: Palette.night,
          foregroundColor: Palette.ink,
          title: Text(widget.field.name),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Tap post after post to string the fence, and '
                  'the first post again to close it: '
                  '${widget.field.task}.',
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
                    ).postUnder(tap.localPosition)),
                    child: CustomPaint(
                      painter: AcreView(
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
                children: [
                  Chip(
                    backgroundColor: Palette.board,
                    side: const BorderSide(color: Palette.line),
                    label: Text(
                      'posts ${play.walk.length} of '
                      '${widget.field.posts}',
                      style: const TextStyle(
                          color: Palette.ink, fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: BorderSide(
                        color: play.closed
                            ? Palette.held
                            : Palette.line),
                    label: Text(
                      play.closed
                          ? 'rails ${play.twoA} · Pick '
                              '${play.twoAByPick}'
                          : 'rim so far: ${play.rimSoFar}',
                      style: const TextStyle(
                          color: Palette.inkDim, fontSize: 13),
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
                  onField: () => Navigator.of(context).pop(),
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
