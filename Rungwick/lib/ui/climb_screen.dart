import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../ladder/climbs.dart';
import '../ladder/graph.dart';
import '../ladder/play.dart';
import 'palette.dart';
import 'result_card.dart';
import 'tile.dart';

/// One climb: change a letter at a time until you reach the other word.
class ClimbScreen extends StatefulWidget {
  const ClimbScreen({
    super.key,
    required this.number,
    required this.ladder,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;

  /// The word graph. Worked out once by whoever opened the app.
  final Ladder ladder;

  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, with the rungs it took, the first time a climb is finished.
  /// Answers whether that was the fewest yet.
  final Future<bool> Function(int rungs)? onDone;

  @override
  State<ClimbScreen> createState() => ClimbScreenState();
}

class ClimbScreenState extends State<ClimbScreen> {
  late Climb _climb;
  late Play _play;

  /// Which letter of the word in hand is being changed, or -1.
  var _changing = -1;

  String? _saying;
  var _best = false;
  var _told = false;

  Climb get climb => _climb;
  Play get play => _play;
  int get changing => _changing;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(ClimbScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _climb = Climbs.at(widget.number);
    _play = Play.of(_climb, widget.ladder);
    _changing = -1;
    _saying = null;
    _best = false;
    _told = false;
  }

  void _pickLetter(int at) {
    if (_play.isDone) return;
    setState(() {
      _changing = _changing == at ? -1 : at;
      _saying = null;
    });
  }

  /// Puts a letter in the slot being changed, which is the only move there is.
  ///
  /// Changing exactly one letter is the rule of the game, so it is the shape
  /// of the interaction rather than something the game has to check: pick the
  /// letter to change, pick what to change it to. All that is left to say is
  /// whether the result is a word.
  void _put(String letter) {
    if (_play.isDone || _changing < 0) return;
    final word = _play.here.replaceRange(_changing, _changing + 1, letter);
    if (word == _play.here) {
      setState(() => _changing = -1);
      return;
    }

    final next = _play.tried(word);
    if (next.refused != null) {
      HapticFeedback.mediumImpact();
      setState(() {
        _saying = switch (next.refused!) {
          Refusal.notAWord => '$word is not in the list.',
          Refusal.beenThere => 'You have been to $word already.',
          Refusal.notOneLetter => 'That changes more than one letter.',
        };
      });
      return;
    }

    HapticFeedback.selectionClick();
    setState(() {
      _play = next;
      _changing = -1;
      _saying = next.onShortest
          ? null
          : 'That rung is not on any shortest way to ${_climb.to}.';
    });
    if (_play.isDone) _finished();
  }

  void _takeBack() {
    if (_play.taken == 0) return;
    setState(() {
      _play = _play.back;
      _changing = -1;
      _saying = null;
    });
  }

  void _again() {
    setState(() {
      _play = Play.of(_climb, widget.ladder);
      _changing = -1;
      _saying = null;
    });
  }

  /// Asked. Names the next word on a shortest ladder from where the player is
  /// standing — which is the honest answer, because a hint read off the
  /// shortest ladder from the start is advice about a climb nobody is on.
  void _showMe() {
    if (_play.isDone) return;
    final next = _play.nextRung;
    setState(() {
      _saying = next == null
          ? 'Every way on from here doubles back. Take a rung off.'
          : 'From here it is ${_play.stepsLeft} more, and $next is one of '
                'them.';
    });
  }

  void _finished() {
    HapticFeedback.mediumImpact();
    if (_told) return;
    _told = true;
    widget.onDone?.call(_play.taken).then((best) {
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
            children: [
              _Ledger(climb: _climb, play: _play, onLeave: widget.onLeave),
              Expanded(
                child: _TheLadder(
                  play: _play,
                  changing: _changing,
                  wrong: _saying != null && _changing >= 0,
                  onTapLetter: _pickLetter,
                ),
              ),
              if (_play.isDone)
                ResultCard(
                  climb: _climb,
                  play: _play,
                  best: _best,
                  onAgain: _again,
                  onNext: widget.onNext,
                  onLeave: widget.onLeave,
                )
              else
                _Rack(
                  saying: _saying,
                  changing: _changing >= 0,
                  canTakeBack: _play.taken > 0,
                  onPut: _put,
                  onTakeBack: _takeBack,
                  onShowMe: _showMe,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The line above the ladder: which climb, and how it is going.
class _Ledger extends StatelessWidget {
  const _Ledger({
    required this.climb,
    required this.play,
    required this.onLeave,
  });

  final Climb climb;
  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final over = play.taken > climb.rungs;

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the climbs',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${climb.from} to ${climb.to}',
                  style: const TextStyle(
                    color: Palette.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  play.isDone
                      ? 'done'
                      : play.onShortest
                      ? '${play.stepsLeft} to go'
                      : '${play.stepsLeft} to go, '
                            '${play.wasted} more than it had to be',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: play.onShortest ? Palette.inkDim : Palette.bad,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${play.taken} / ${climb.rungs}',
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

/// The ladder itself: where it started, every rung since, and where it is
/// going.
class _TheLadder extends StatelessWidget {
  const _TheLadder({
    required this.play,
    required this.changing,
    required this.wrong,
    required this.onTapLetter,
  });

  final Play play;
  final int changing;
  final bool wrong;
  final ValueChanged<int> onTapLetter;

  /// Which letter changed between two words.
  static int _changedAt(String word, String before) {
    for (var at = 0; at < word.length; at++) {
      if (word[at] != before[at]) return at;
    }
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    final words = play.words;

    return LayoutBuilder(
      builder: (context, box) {
        final side = ((box.maxWidth - 60) / play.climb.letters).clamp(
          30.0,
          58.0,
        );

        // Centred rather than piled at the top: a ladder is five or six rows
        // and the screen is twenty, and the rungs read as a ladder rather
        // than as the top of a list.
        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                for (var i = 0; i < words.length; i++) ...[
                  Word(
                    word: words[i],
                    side: i == words.length - 1 ? side : side * 0.78,
                    changedAt: i == 0 ? -1 : _changedAt(words[i], words[i - 1]),
                    litAt: i == words.length - 1 ? changing : -1,
                    faded: i != words.length - 1,
                    wrong: i == words.length - 1 && wrong,
                    onTapLetter: i == words.length - 1 && !play.isDone
                        ? onTapLetter
                        : null,
                  ),
                  SizedBox(height: side * 0.16),
                ],
                if (!play.isDone) ...[
                  SizedBox(height: side * 0.10),
                  Icon(
                    Icons.more_vert_rounded,
                    color: Palette.rungEdge,
                    size: side * 0.5,
                  ),
                  SizedBox(height: side * 0.10),
                  Word(word: play.climb.to, side: side * 0.78, faded: true),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// The rack: the letters to choose from, and what else can be done.
class _Rack extends StatelessWidget {
  const _Rack({
    required this.saying,
    required this.changing,
    required this.canTakeBack,
    required this.onPut,
    required this.onTakeBack,
    required this.onShowMe,
  });

  /// What the game has to say, if anything.
  final String? saying;

  /// Whether a letter has been picked to change.
  final bool changing;

  final bool canTakeBack;
  final ValueChanged<String> onPut;
  final VoidCallback onTakeBack;
  final VoidCallback onShowMe;

  static const _letters = 'abcdefghijklmnopqrstuvwxyz';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Palette.board,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: Palette.rungEdge, width: 1.1),
            ),
            child: Text(
              saying ??
                  (changing
                      ? 'Now pick what to change it to.'
                      : 'Tap the letter you want to change.'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: saying == null ? Palette.inkDim : Palette.ink,
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Opacity(
            opacity: changing ? 1 : 0.35,
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 5,
              runSpacing: 5,
              children: [
                for (final letter in _letters.split(''))
                  Semantics(
                    button: true,
                    label: 'the letter $letter',
                    child: GestureDetector(
                      onTap: changing ? () => onPut(letter) : null,
                      child: ExcludeSemantics(
                        child: Container(
                          width: 30,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Palette.rung,
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(
                              color: Palette.rungEdge,
                              width: 1.1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            letter.toUpperCase(),
                            style: const TextStyle(
                              color: Palette.ink,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _Button(
                  label: 'Take back',
                  dead: !canTakeBack,
                  onTap: onTakeBack,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Button(label: 'Show me', dead: false, onTap: onShowMe),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Button extends StatelessWidget {
  const _Button({required this.label, required this.dead, required this.onTap});

  final String label;
  final bool dead;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    child: GestureDetector(
      onTap: dead ? null : onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: Palette.board,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: dead ? Palette.rungEdge : Palette.rope,
            width: 1.1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: dead ? Palette.inkDim : Palette.ink,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    ),
  );
}
