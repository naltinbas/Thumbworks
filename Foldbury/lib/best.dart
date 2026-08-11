import 'package:shared_preferences/shared_preferences.dart';

/// The fewest shepherds each fold has been watched with.
///
/// Keyed on the name rather than the place in the list, so putting a new one
/// in the middle does not hand somebody else's record to a fold nobody has
/// watched.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'watched.';

  static String _key(String fold) => '$_prefix$fold';

  int? shepherdsFor(String fold) => _prefs.getInt(_key(fold));

  bool has(String fold) => shepherdsFor(fold) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a night down, and says whether it beat what was there.
  Future<bool> record(String fold, int shepherds) async {
    final before = shepherdsFor(fold);
    if (before != null && before <= shepherds) return false;
    await _prefs.setInt(_key(fold), shepherds);
    return true;
  }
}
