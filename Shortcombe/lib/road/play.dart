import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: the crowd dialled, the shortcut open or shut, the
/// taps taken, and the go before, so a tap can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.crowd,
    required this.open,
    required this.moves,
    required this.before,
  });

  Play.of(this.level)
      : crowd = opening,
        open = false,
        moves = 0,
        before = null;

  /// A go standing at a setting, no taps counted: what the mark draws.
  Play.standing(this.level, this.crowd, this.open)
      : moves = 0,
        before = null;

  final Level level;

  /// The crowd, in hundreds.
  final int crowd;

  /// Whether the shortcut is open.
  final bool open;

  /// The taps taken.
  final int moves;

  final Play? before;

  /// The crowd every ask opens on, the shortcut shut.
  static const opening = 20;

  /// The taps a hopeless ask runs to before the sham admits it, if the
  /// player never opens the shortcut on a big crowd.
  static const gaveUpAt = 12;

  /// How the crowd settles: (top, bottom, across).
  (int, int, int) get settled => Rules.settle(crowd, open);

  /// How it settles by the potential, the second voice.
  (int, int, int) get settledByPotential => Rules.settleByPotential(crowd, open);

  (int, int, int?) get minutes => Rules.minutes(crowd, open);

  int get journey => Rules.journey(crowd, open);

  int get journeyShut => Rules.journey(crowd, false);
  int get journeyOpen => Rules.journey(crowd, true);

  String get verdictOf => Rules.verdictOf(crowd);

  /// Turns dial [which] (0 the crowd, 1 the shortcut) by [by]: the crowd
  /// two hundred a tap, either way, stopping at the dial's ends; the
  /// shortcut over, open to shut or shut to open. A dial at its end
  /// stays, and that is not a tap.
  Play set(int which, int by) {
    if (isOver || by == 0) return this;
    var c = crowd, o = open;
    if (which == 0) {
      c = crowd + by.sign * Rules.step;
      if (c < Rules.least || c > Rules.most) return this;
    } else {
      o = !open;
    }
    return Play._(level: level, crowd: c, open: o, moves: moves + 1, before: this);
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(crowd, open);

  /// A hopeless ask, admitted: the shortcut is open on a crowd past
  /// thirty hundred and hurting, or [gaveUpAt] taps are gone.
  bool get gaveUp => !level.winnable && (open && crowd > 30 || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// What the pointer says: (dial, way), the crowd first, then the
  /// shortcut; null when there is nothing to point at.
  (int, int)? get next {
    final aim = level.aim;
    if (aim == null || isOver) return null;
    if (crowd != aim.$1) return (0, (aim.$1 - crowd).sign);
    if (open != aim.$2) return (1, 1);
    return null;
  }

  /// The pointer's words.
  static String pointed((int, int) aim, {required bool open}) =>
      aim.$1 == 0 ? 'Turn the crowd ${aim.$2 > 0 ? 'up' : 'down'}.' : (open ? 'Shut the shortcut.' : 'Open the shortcut.');
}

/// Why a new road can slow everyone: the words behind the Why button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'Two roads run from Start to End, one over the top junction and one '
      'under the bottom. Start to the top and bottom to End take a minute per '
      'hundred drivers on them; top to End and Start to bottom take 45 '
      'minutes whatever the crowd. Forty hundred drivers split twenty and '
      'twenty and take 65 minutes each. Then a shortcut opens from top to '
      'bottom, taking no time at all, and every driver, seeing that top, '
      'across and bottom costs the two variable roads and no fixed one, '
      'takes it, whatever the others do; all forty hundred are on both '
      'variable roads, and every one takes 40 + 40 = 80. Nobody can do '
      'better alone. Braess found it in 1968: a road added, everyone slower. '
      'The crowd settles where no driver gains by switching, which is also '
      'where the potential is least, each road\'s minutes summed over the '
      'crowd on it as it fills.\n\n'
      'The game dials the crowd from two hundred to sixty, two hundred a '
      'step, with the shortcut open or shut, ${Rules.settings} settings, and '
      'settles each twice: by cases, and by the least potential over every '
      'whole split of the crowd. The two agree on all ${Rules.settings}; the '
      'shortcut helps under thirty hundred, makes no odds at thirty, and '
      'hurts past it, by 22 minutes at the most.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The tile\'s counts are the sweep\'s: every crowd on the dial, the '
      'shortcut open and shut, settled both ways.';
}
