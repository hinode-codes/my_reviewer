import 'package:flutter/foundation.dart';

typedef WifiOnlyPreferenceReader = Future<bool> Function();
typedef WifiOnlyPreferenceWriter = Future<void> Function(bool value);

class SettingsController extends ChangeNotifier {
  SettingsController({this._readWifiOnly, this._writeWifiOnly});

  final WifiOnlyPreferenceReader? _readWifiOnly;
  final WifiOnlyPreferenceWriter? _writeWifiOnly;

  bool _wifiOnly = true;
  bool _disposed = false;

  bool get wifiOnly => _wifiOnly;

  Future<void> initialize() async {
    final saved = await _readWifiOnly?.call();
    if (saved != null) {
      _wifiOnly = saved;
    }

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

    await _writeWifiOnly?.call(value);
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
