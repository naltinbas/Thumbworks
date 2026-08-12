/// What a fold can ask of a finished fencing's crown.
enum Asking {
  /// Any full fencing at all.
  any,

  /// Some post cornering four pens.
  fourCrown,

  /// No post cornering more than three.
  evenFold,

  /// Every crown a one or a three.
  zigzag,

  /// No post cornering exactly one pen: the hopeless asking.
  earless,
}

/// One fold of the leigh: its paddock and its asking.
class Fold {
  const Fold({
    required this.name,
    required this.posts,
    required this.asking,
    required this.ways,
    this.note,
  });

  final String name;

  /// Posts round the paddock.
  final int posts;

  final Asking asking;

  /// Full fencings of the sweep that land it; nought on the
  /// hopeless fold, and the label says so.
  final int ways;

  /// One thing worth knowing about this fold, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  /// Whether a crown lands this asking.
  bool lands(List<int> crown) => switch (asking) {
        Asking.any => true,
        Asking.fourCrown => crown.contains(4),
        Asking.evenFold => crown.every((pens) => pens <= 3),
        Asking.zigzag =>
          crown.every((pens) => pens == 1 || pens == 3),
        Asking.earless => !crown.contains(1),
      };

  /// The task, told in words for the ledger.
  String get task => switch (asking) {
        Asking.any => 'fold the $posts-post paddock into pens',
        Asking.fourCrown =>
          'fold the paddock so some post corners 4 pens',
        Asking.evenFold =>
          'fold the paddock with no post cornering more than 3',
        Asking.zigzag =>
          'fold the paddock so every crown is a 1 or a 3',
        Asking.earless =>
          'fold the paddock with no post cornering exactly 1 pen',
      };
}
