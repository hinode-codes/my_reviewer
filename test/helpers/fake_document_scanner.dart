import 'dart:async';

import 'package:my_reviewer/src/services/document_scanner_service.dart';

/// Stands in for the ML Kit scanner. Queue what each scan should do with
/// [returns], [cancels], [throws] or [holds]; each call takes the next one.
class FakeDocumentScanner implements IDocumentScannerService {
  final List<Future<List<String>?> Function()> _queue = [];

  int _calls = 0;
  int get calls => _calls;

  void returns(List<String> paths) => _queue.add(() async => paths);

  void cancels() => _queue.add(() async => null);

  void throws(Object error) => _queue.add(() async => throw error);

  /// The scan stays open until the returned completer completes.
  Completer<List<String>?> holds() {
    final completer = Completer<List<String>?>();
    _queue.add(() => completer.future);
    return completer;
  }

  @override
  Future<List<String>?> scanDocument({int pageLimit = 10}) {
    _calls++;
    return _queue.removeAt(0)();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}