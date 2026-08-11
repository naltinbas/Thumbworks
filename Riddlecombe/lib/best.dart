import 'package:shared_preferences/shared_preferences.dart';

/// The fewest askings each mesh has been riddled with.
///
/// Keyed on the name rather than the place in the list, so putting a new
/// one in the middle does not hand somebody else's record to a mesh
/// nobody has woven. The short weave writes nothing.
class Best {
  Best(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'riddled.';

  static String _key(String mesh) => '$_prefix$mesh';

  int? askingsFor(String mesh) => _prefs.getInt(_key(mesh));

  bool has(String mesh) => askingsFor(mesh) != null;

  int get done =>
      _prefs.getKeys().where((key) => key.startsWith(_prefix)).length;

  /// Writes a clean riddle down, and says whether it beat what was
  /// there.
  Future<bool> record(String mesh, int askings) async {
    final before = askingsFor(mesh);
    if (before != null && before <= askings) return false;
    await _prefs.setInt(_key(mesh), askings);
    return true;
  }
}
