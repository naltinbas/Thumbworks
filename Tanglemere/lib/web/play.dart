import 'rules.dart';
import 'web.dart';

/// A web being woven. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.web, this.rules, this.mine, this.theirs, this.woven,
      this.lostBy, this.before);

  Play.of(Web web)
      : this._(web, _rulesFor(web), 0, 0, 0, null, null);

  final Web web;
  final Rules rules;

  /// The player's threads and the house's, as bits.
  final int mine;
  final int theirs;

  /// Threads woven in all.
  final int woven;

  /// Who closed a triangle, or null while the weave stands: true =
  /// the player closed one and lost.
  final bool? lostBy;

  final Play? before;

  static final _kept = <int, Rules>{};

  static Rules _rulesFor(Web web) =>
      _kept[web.dots] ??= Rules(web.dots);

  bool get isOver => lostBy != null || woven == rules.threads;

  bool get isDrawn => lostBy == null && woven == rules.threads;

  /// Whether the player won: the house closed a triangle.
  bool get playerWon => lostBy == false;

  bool isMine(int thread) => mine & (1 << thread) != 0;
  bool isTheirs(int thread) => theirs & (1 << thread) != 0;
  bool isFree(int thread) =>
      (mine | theirs) & (1 << thread) == 0;

  /// The player weaves a thread; the house replies at once with its
  /// best. Closing a triangle ends the weave there.
  Play weave(int thread) {
    if (isOver || thread < 0 || thread >= rules.threads) return this;
    if (!isFree(thread)) return this;
    final closed = rules.closing(mine, thread);
    final afterMine = mine | (1 << thread);
    if (closed != null) {
      return Play._(web, rules, afterMine, theirs, woven + 1, true, this);
    }
    if (woven + 1 == rules.threads) {
      return Play._(
          web, rules, afterMine, theirs, woven + 1, null, this);
    }
    // The house's reply.
    final reply = rules.bestThread(theirs, afterMine);
    final houseClosed = rules.closing(theirs, reply);
    return Play._(
      web,
      rules,
      afterMine,
      theirs | (1 << reply),
      woven + 2,
      houseClosed != null ? false : null,
      this,
    );
  }

  /// The house weaves first, where the web says so.
  Play houseOpens() {
    if (woven != 0 || web.playerFirst) return this;
    final thread = rules.bestThread(theirs, mine);
    return Play._(
        web, rules, mine, theirs | (1 << thread), 1, null, this);
  }

  Play get back => before ?? this;

  /// The player's standing from here with best weaving: 1, 0 or -1.
  int get standing {
    if (isOver) return playerWon ? 1 : (isDrawn ? 0 : -1);
    return rules.value(mine, theirs);
  }

  /// The thread the search weaves next for the player, or null.
  int? get next => isOver ? null : rules.bestThread(mine, theirs);

  /// The triangle that ended the weave, or null.
  (int, int, int)? get closedTriangle {
    if (lostBy == null) return null;
    final held = lostBy! ? mine : theirs;
    for (final (x, y, z) in rules.triangles) {
      if (held & (1 << x) != 0 &&
          held & (1 << y) != 0 &&
          held & (1 << z) != 0) {
        return (x, y, z);
      }
    }
    return null;
  }
}
