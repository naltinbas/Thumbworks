import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: the two dials, the taps taken to set them, and the
/// go before, so a tap can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.stickers,
    required this.packets,
    required this.moves,
    required this.before,
  });

  /// Every ask opens on a set of six and ten packets: no ask is landed by
  /// that, and the checker says so.
  Play.of(this.level)
      : stickers = 6,
        packets = 10,
        moves = 0,
        before = null;

  /// A play stood at a setting, for the mark and the tests.
  Play.standing(this.level, this.stickers, this.packets)
      : moves = 0,
        before = null;

  final Level level;
  final int stickers, packets;

  /// The taps taken.
  final int moves;

  final Play? before;

  /// The line past which the hopeless ask admits it, if sixty packets
  /// are never reached.
  static const gaveUpAt = 60;

  Frac get average => Rules.averageByStages(stickers);
  Frac get chance => Rules.fullAfter(stickers, packets);

  /// Turns dial [which] (0 stickers, 1 packets) by [by], one or ten
  /// steps for the packets; a dial at its end stops there, and a turn
  /// that moves nothing is not a tap.
  Play set(int which, int by) {
    if (isOver || by == 0) return this;
    var s = stickers, p = packets;
    if (which == 0) {
      s = (stickers + by.sign).clamp(1, Rules.mostStickers);
    } else {
      p = (packets + by).clamp(1, Rules.mostPackets);
    }
    if (s == stickers && p == packets) return this;
    return Play._(level: level, stickers: s, packets: p, moves: moves + 1, before: this);
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(stickers, packets);

  /// A hopeless ask, admitted: sixty packets set with two stickers or
  /// more, and the album not certain still; or [gaveUpAt] taps.
  bool get gaveUp => !level.winnable && (packets == Rules.mostPackets && stickers >= 2 || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// What the pointer says: (dial, by), stickers first by ones, then
  /// packets by tens while ten or more off, else by ones; null when
  /// nothing points anywhere.
  (int, int)? get next {
    final aim = level.aim;
    if (aim == null || isOver) return null;
    if (stickers != aim.$1) return (0, (aim.$1 - stickers).sign);
    final gap = aim.$2 - packets;
    if (gap == 0) return null;
    return (1, gap.abs() >= 10 ? gap.sign * 10 : gap.sign);
  }

  static String pointed((int, int) aim) => aim.$1 == 0 ? '${aim.$2 > 0 ? 'One more' : 'One fewer'} sticker in the set.' : '${aim.$2 > 0 ? 'Up' : 'Down'} ${aim.$2.abs()} packet${aim.$2.abs() == 1 ? '' : 's'}.';
}

/// Why the harmonic number: the words behind the Why button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'A set of n stickers, one to a packet at random and each as likely as '
      'the rest. The first packet is always new; once k are held, a new one '
      'comes with chance (n - k)/n, so it takes n/(n - k) packets on average, '
      'and the whole set takes n/n + n/(n - 1) + ... + n/1, which is n times '
      'the n-th harmonic number: 14.7 for six, 29.28 for ten, and it grows '
      'like n times the log of n. The last sticker alone takes n packets on '
      'average, the slowest by far. And no count of packets makes a set of '
      'two or more certain, since the same sticker could come every time.\n\n'
      'The game works the average two ways in exact fractions, by the stages '
      'and by summing the chance of still being short over every count of '
      'packets, which counting closes to an alternating sum of binomials, and '
      'the two agree for every set to twelve; and the chance of a full album '
      'after m packets is worked by counting the ways and by walking the '
      'packets one at a time, and those agree on every one of the '
      '${Rules.settings} settings.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The tile\'s counts are the sweep\'s: every set of one to twelve and '
      'every count of packets to sixty, tried in full.';
}
