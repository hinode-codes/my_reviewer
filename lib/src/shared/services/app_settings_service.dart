import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized singleton service managing user preferences and credentials.
///
/// Non-sensitive preferences are persisted via [SharedPreferencesAsync], while
/// sensitive credentials (such as API/model tokens) are stored in
/// [FlutterSecureStorage].
class AppSettingsService {
  AppSettingsService({
    SharedPreferencesAsync? prefs,
    FlutterSecureStorage? secureStorage,
    String? defaultHuggingFaceToken,
  }) : _prefs = prefs ?? SharedPreferencesAsync(),
       _secureStorage = secureStorage ?? const FlutterSecureStorage(),
       _defaultHuggingFaceToken = (defaultHuggingFaceToken ?? _envHfToken)
           .trim();

  static const String _envHfToken = String.fromEnvironment('HF_TOKEN');

  final SharedPreferencesAsync _prefs;
  final FlutterSecureStorage _secureStorage;
  final String _defaultHuggingFaceToken;

  // SharedPreferences keys
  static const _selectedOcrModelIdKey = 'selected_ocr_model_id';
  static const _wifiOnlyDownloadsKey = 'wifi_only_downloads';
  static const _jobNotificationsEnabledKey = 'job_notifications_enabled';

  // FlutterSecureStorage keys
  static const _huggingFaceTokenKey = 'hugging_face_token';

  /// Seeds default credentials from `--dart-define=HF_TOKEN=...` into secure
  /// storage if no token has been saved yet.
  Future<void> initialize() async {
    if (_defaultHuggingFaceToken.isEmpty) return;

    final existing = await _secureStorage.read(key: _huggingFaceTokenKey);
    if (existing == null || existing.trim().isEmpty) {
      await _secureStorage.write(
        key: _huggingFaceTokenKey,
        value: _defaultHuggingFaceToken,
      );
    }
  }

  // --- Selected OCR Model ---
  Future<String?> getSelectedOcrModelId() =>
      _prefs.getString(_selectedOcrModelIdKey);

  Future<void> setSelectedOcrModelId(String modelId) =>
      _prefs.setString(_selectedOcrModelIdKey, modelId);

  // --- Download Preferences ---
  Future<bool> isWifiOnlyDownloads() async =>
      await _prefs.getBool(_wifiOnlyDownloadsKey) ?? true;

  Future<void> setWifiOnlyDownloads(bool value) =>
      _prefs.setBool(_wifiOnlyDownloadsKey, value);

  // --- Notifications ---
  Future<bool> isJobNotificationEnabled() async =>
      await _prefs.getBool(_jobNotificationsEnabledKey) ?? true;

  Future<void> setJobNotificationEnabled(bool value) =>
      _prefs.setBool(_jobNotificationsEnabledKey, value);

  // --- Credentials (Encrypted) ---
  Future<String?> getHuggingFaceToken() async {
    final stored = await _secureStorage.read(key: _huggingFaceTokenKey);
    if (stored != null && stored.trim().isNotEmpty) {
      return stored;
    }
    return _defaultHuggingFaceToken.isNotEmpty
        ? _defaultHuggingFaceToken
        : null;
  }

  Future<void> setHuggingFaceToken(String? token) {
    final trimmed = token?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return _secureStorage.delete(key: _huggingFaceTokenKey);
    }
    return _secureStorage.write(key: _huggingFaceTokenKey, value: trimmed);
  }
}
