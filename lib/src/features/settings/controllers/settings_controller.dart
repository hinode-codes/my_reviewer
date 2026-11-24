import 'package:flutter/foundation.dart';
import 'package:my_reviewer/src/shared/services/app_settings_service.dart';

/// Controller managing user-configurable application settings.
class SettingsController extends ChangeNotifier {
  SettingsController({required this._settingsService});

  final AppSettingsService _settingsService;

  bool _wifiOnly = true;
  bool _disposed = false;

  bool get wifiOnly => _wifiOnly;

  Future<void> initialize() async {
    _wifiOnly = await _settingsService.isWifiOnlyDownloads();

    if (!_disposed) {
      notifyListeners();
    }
  }

  Future<void> setWifiOnly(bool value) async {
    if (_wifiOnly == value) {
      return;
    }

    _wifiOnly = value;
    if (!_disposed) {
      notifyListeners();
    }

    await _settingsService.setWifiOnlyDownloads(value);
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
