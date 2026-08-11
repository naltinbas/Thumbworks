import 'stow.dart';
import 'berth.dart';

/// One round on the quay: the player's looks, then the crew's.
class Play {
  const Play._(
    this.berth,
    this.stow,
    this.opened,
    this.settled,
  );

  Play.of(Berth berth, Stow stow)
      : this._(berth, stow, const [], false);

  final Berth berth;

  /// How the bosun stowed the chits this round. Dealt outside the game,
  /// so a test can hand in exactly the stowing it means to see.
  final Stow stow;

  /// The lockers the player has opened, in order. The player is the
  /// first sailor.
  final List<int> opened;

  /// Whether the round is settled, found or failed.
  final bool settled;

  bool get isOver => settled;

  /// Whether the player found their own chit.
  bool get found => opened.isNotEmpty && stow.chits[opened.last] == 0;

  /// Whether the whole crew came through: the player found theirs, and
  /// every other sailor's loop fits their looks. Meaningless before
  /// settled.
  bool get through {
    if (!found) return false;
    for (var sailor = 1; sailor < berth.lockers; sailor++) {
      if (stow.loopThrough(sailor).length > berth.looks) return false;
    }
    return true;
  }

  /// The sailor whose loop sank the crew, or -1. The player counts too.
  int get sunkBy {
    if (settled && !found) return 0;
    for (var sailor = 1; sailor < berth.lockers; sailor++) {
      if (stow.loopThrough(sailor).length > berth.looks) return sailor;
    }
    return -1;
  }

  bool isOpen(int locker) => opened.contains(locker);

  /// Opens a locker. Settles the round when the chit is the player's own
  /// or the looks run out.
  Play open(int locker) {
    if (settled || locker < 0 || locker >= berth.lockers ||
        isOpen(locker)) {
      return this;
    }
    final grown = [...opened, locker];
    final foundNow = stow.chits[locker] == 0;
    final spent = grown.length >= berth.looks;
    return Play._(berth, stow, grown, foundNow || spent);
  }

  /// The locker the chits say to open next: your own first, then the
  /// locker of whoever's chit you just found. Null when settled.
  int? get next {
    if (settled) return null;
    if (opened.isEmpty) return 0;
    final chit = stow.chits[opened.last];
    return isOpen(chit) ? null : chit;
  }
}
