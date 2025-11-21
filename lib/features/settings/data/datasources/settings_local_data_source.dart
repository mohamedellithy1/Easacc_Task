import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/failures.dart';

abstract class SettingsLocalDataSource {
  Future<void> saveUrl(String url);
  Future<String?> getUrl();
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final SharedPreferences sharedPreferences;

  SettingsLocalDataSourceImpl({required this.sharedPreferences});

  static const String cachedUrlKey = 'CACHED_URL';

  @override
  Future<String?> getUrl() async {
    try {
      return sharedPreferences.getString(cachedUrlKey);
    } catch (e) {
      throw const CacheFailure('Error reading from cache');
    }
  }

  @override
  Future<void> saveUrl(String url) async {
    try {
      await sharedPreferences.setString(cachedUrlKey, url);
    } catch (e) {
      throw const CacheFailure('Error writing to cache');
    }
  }
}

