import 'package:shared_preferences/shared_preferences.dart';

/// The fewest weighings each box has been settled in.
///
/// Keyed on the name rather than the place in the list, so putting a new one
/// in the middle does not hand somebody else's record to a box nobody has
/// opened.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'assayed.';

  static String _key(String box) => '$_prefix$box';

  int? weighingsFor(String box) => _prefs.getInt(_key(box));

  bool has(String box) => weighingsFor(box) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a box down, and says whether it beat what was there.
  Future<bool> record(String box, int weighings) async {
    final before = weighingsFor(box);
    if (before != null && before <= weighings) return false;
    await _prefs.setInt(_key(box), weighings);
    return true;
  }
}
