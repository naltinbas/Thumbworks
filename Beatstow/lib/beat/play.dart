import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: what is laid on each beat, the throw in the hand,
/// the taps counted, and the go before, so a tap can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.laid,
    required this.held,
    required this.taps,
    required this.seen,
    required this.before,
  });

  Play.of(this.level)
      : laid = const [-1, -1, -1, -1, -1],
        held = null,
        taps = 0,
        seen = const {},
        before = null;

  /// A go laid out as it stands, no taps counted: what the mark draws.
  const Play.laying(this.level, this.laid)
      : held = null,
        taps = 0,
        seen = const {},
        before = null;

  final Level level;

  /// The throw on each beat, or -1 where the beat is still empty.
  final List<int> laid;

  /// The throw in the hand, waiting for a beat, or null.
  final int? held;

  final int taps;

  /// The layings tried on a hopeless ask.
  final Set<String> seen;

  final Play? before;

  /// The taps a hopeless ask runs to before the ring admits it.
  static const gaveUpAt = 20;

  /// The layings a hopeless ask lets the player try before the ring
  /// admits it.
  static const enough = 6;

  /// The throws still to be laid, sorted, counting the one in the hand
  /// as already off the rack.
  List<int> get rack {
    final left = [...level.rack]..sort();
    for (final t in laid) {
      if (t >= 0) left.remove(t);
    }
    if (held != null) left.remove(held);
    return left;
  }

  bool get full => !laid.contains(-1);

  /// The beats two or more balls come down on.
  List<int> get clashes => Rules.clashes(laid);

  /// Where each laid ball comes down.
  List<int> get landings => [
        for (var i = 0; i < Rules.beats; i++)
          laid[i] < 0 ? -1 : Rules.lands(i, laid[i]),
      ];

  /// How many balls come down on each beat.
  List<int> get arrivals {
    final out = List.filled(Rules.beats, 0);
    for (var i = 0; i < Rules.beats; i++) {
      if (laid[i] >= 0) out[Rules.lands(i, laid[i])]++;
    }
    return out;
  }

  /// The throws laid so far, added up.
  int get laidTotal {
    var n = 0;
    for (final t in laid) {
      if (t > 0) n += t;
    }
    return n;
  }

  /// The balls in the air after each beat, watched rather than worked
  /// out. Only meant for a full ring.
  List<int> get aloft => Rules.aloft([for (final t in laid) t < 0 ? 0 : t]);

  String get mark => laid.join(',');

  /// Whether a throw of [height] may go on [beat]: the beat has to be
  /// free and the ball must come down where no ball comes down yet.
  bool canLay(int beat, int height) {
    if (laid[beat] >= 0) return false;
    final at = Rules.lands(beat, height);
    for (var i = 0; i < Rules.beats; i++) {
      if (laid[i] >= 0 && Rules.lands(i, laid[i]) == at) return false;
    }
    return true;
  }

  /// Picks a throw up off the rack, or puts the one in hand back.
  Play take(int height) {
    if (isOver) return this;
    if (held == height) {
      return Play._(
        level: level,
        laid: laid,
        held: null,
        taps: taps + 1,
        seen: seen,
        before: before,
      );
    }
    if (!rack.contains(height)) return this;
    return Play._(
      level: level,
      laid: laid,
      held: height,
      taps: taps + 1,
      seen: seen,
      before: before,
    );
  }

  /// Lays the throw in the hand on a beat, or lifts the one already
  /// there back onto the rack.
  Play tap(int beat) {
    if (isOver || beat < 0 || beat >= Rules.beats) return this;
    if (laid[beat] >= 0) {
      final to = [...laid]..[beat] = -1;
      return Play._(
        level: level,
        laid: to,
        held: held,
        taps: taps + 1,
        seen: seen,
        before: this,
      );
    }
    final hand = held;
    if (hand == null) return this;
    if (!canLay(beat, hand)) return this;
    final to = [...laid]..[beat] = hand;
    return Play._(
      level: level,
      laid: to,
      held: null,
      taps: taps + 1,
      seen: !level.winnable ? {...seen, to.join(',')} : seen,
      before: this,
    );
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(laid);

  /// A hopeless ask, admitted: [enough] layings tried, or [gaveUpAt]
  /// taps.
  bool get gaveUp =>
      !level.winnable && (seen.length >= enough || taps >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// Every laying that juggles, worked out once per ask.
  static final Map<String, List<List<int>>> _winners = {};

  static List<List<int>> winners(Level level) =>
      _winners.putIfAbsent(level.name, () => Rules.ways(level.rack));

  /// A laying that juggles and keeps everything already down, or null.
  List<int>? get carryOn {
    for (final win in winners(level)) {
      var holds = true;
      for (var i = 0; i < Rules.beats; i++) {
        if (laid[i] >= 0 && laid[i] != win[i]) {
          holds = false;
          break;
        }
      }
      if (!holds) continue;
      if (held != null) {
        var wanted = false;
        for (var i = 0; i < Rules.beats; i++) {
          if (laid[i] < 0 && win[i] == held) wanted = true;
        }
        if (!wanted) continue;
      }
      return win;
    }
    return null;
  }

  /// What the pointer says: a throw to pick up, or a beat to lay it on.
  /// The first of the pair is the height when nothing is in the hand and
  /// null otherwise; the second is the beat.
  (int?, int)? get next {
    if (isOver) return null;
    final win = carryOn;
    if (win == null) return null;
    for (var i = 0; i < Rules.beats; i++) {
      if (laid[i] >= 0) continue;
      if (held != null) {
        if (win[i] == held) return (null, i);
        continue;
      }
      return (win[i], i);
    }
    return null;
  }

  /// The pointer's words.
  String pointed((int?, int) aim) => aim.$1 == null
      ? 'Lay it on beat ${aim.$2}.'
      : 'Take the ${aim.$1} off the rack, for beat ${aim.$2}.';
}

/// Why a rack juggles or does not: the words behind the Why button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'Five beats round a ring, and a rack of throws to lay on them. A '
      'throw of height h laid on beat i sends its ball up to come down at '
      'beat i plus h, counted round, so a throw of five comes down on the '
      'beat it left and a throw of nothing is a rest. Two balls coming down '
      'on one beat is a drop.\n\n'
      'So a laying juggles exactly when the five landing beats are all '
      'different, which is to say the landings are the beats themselves in '
      'some order. That is a thing to look at rather than to work out, and '
      'the tapping is the looking: every throw laid drops its ball into a '
      'pan, and a pan that already holds one will not take another, so the '
      'ring refuses the throw and names the beat.\n\n'
      'The second half is the one worth having. When a rack juggles, the '
      'balls in the air come to the plain average of the throws. Not about '
      'the average: the average, every time, and it has to be a whole '
      'number. That is why the rack itself decides the matter before a '
      'single throw is laid. Add the throws up. If the total does not go '
      'round the beats evenly, no arrangement of them juggles at all, and if '
      'it does, some arrangement always will.\n\n'
      'The ring counts everything at least twice. One voice reads the '
      'landing beats and asks whether they are all different. The other '
      'watches the pattern run and counts the balls still in the air after '
      'each beat, which knows nothing of averages: on a rack that juggles '
      'that count holds steady and equals the average, and on one that does '
      'not it wobbles. A third voice lays nothing out at all and counts the '
      'patterns by a closed form, the balls plus one raised to the beats, '
      'less the balls raised to the beats.\n\n'
      'Every rack of five single-figure throws was walked before the bake, '
      'and every laying of every one of them, 100,000 layings over 2,002 '
      'racks, with all three voices agreeing on every one.\n\n'
      'This is ask $number, ${level.name}. ${level.note}';
}
