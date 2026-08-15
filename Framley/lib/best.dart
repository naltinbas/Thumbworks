import 'package:shared_preferences/shared_preferences.dart';

/// The fewest moves each wall has ever been hung in, kept
/// on the phone.
class Best {
  static SharedPreferences? _kept;

  static Future<void> ready() async {
    _kept ??= await SharedPreferences.getInstance();
  }

  static String _key(String name) => 'framley.fewest.$name';

  static int? fewest(String name) => _kept?.getInt(_key(name));

  /// Keeps [moves] if it beats the standing record. True when it did.
  static Future<bool> landed(String name, int moves) async {
    await ready();
    final standing = fewest(name);
    if (standing != null && standing <= moves) return false;
    await _kept!.setInt(_key(name), moves);
    return true;
  }
}
