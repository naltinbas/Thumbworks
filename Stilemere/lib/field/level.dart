import 'rules.dart';

/// One field on the sham: its shape, its stiles and ponds, and what
/// the walk of every route found.
class Level {
  const Level({
    required this.name,
    required this.field,
    required this.ways,
    required this.walks,
    this.note,
  });

  final String name;
  final Field field;

  /// Routes that land, by walking every one; nought for the hopeless.
  final int ways;

  /// Routes from the gate to the mill, all told.
  final int walks;

  /// One thing worth knowing about this field, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  static const _words = {3: 'three', 4: 'four', 5: 'five'};

  /// The task, told in words for the ledger.
  String get task {
    final f = field;
    final shape = 'the ${_words[f.width]}-by-${_words[f.height]} field';
    final stiles = f.stiles.isEmpty
        ? ''
        : ' over the stile${f.stiles.length == 1 ? '' : 's'} at ${f.stiles.map((s) => '(${s.$1}, ${s.$2})').join(' and ')}';
    final ponds = f.ponds.isEmpty
        ? ''
        : ' round the pond${f.ponds.length == 1 ? '' : 's'} at ${f.ponds.map((p) => '(${p.$1}, ${p.$2})').join(' and ')}';
    return 'walk $shape from the gate to the mill$stiles$ponds';
  }
}
