import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/models/docs/view_models.dart';
import 'package:my_reviewer/src/models/selection_state.dart';
import 'package:my_reviewer/src/repositories/scanned_document/interface.dart';

/// Whether the page showing is zoomed in. While it is, a horizontal drag
/// pans the page instead of turning it.
enum PageZoom { fitted, zoomed }

/// What the page viewer is opened with, as one get_it factory parameter
/// (get_it passes at most two).
typedef DocsPageViewerArgs = ({
  String groupId,
  String docId,
  List<ScannedDocumentModel>? initialDocuments,
});

/// The page viewer's state: the group's pages and which one is showing.
///
/// Opened from the grid, the pages come with the route, so the viewer is
/// ready on its first frame and the hero has something to land on. Opened
/// from a deep link, [initialize] fetches the group's pages first.
class DocsPageViewerController extends ChangeNotifier {
  DocsPageViewerController({
    required this._repository,
    required this._groupId,
    required this._docId,
    List<ScannedDocumentModel>? initialDocuments,
  }) {
    if (initialDocuments != null) {
      _show(initialDocuments);
    }
  }

  final IScannedDocumentRepository _repository;
  final String _groupId;
  final String _docId;

  ItemsStatus _status = ItemsStatus.loading;

  /// Failed when the pages could not be fetched, or do not contain the page
  /// asked for.
  ItemsStatus get status => _status;

  List<ScannedDocumentModel> _docs = const [];

  /// The group's pages, in order. Replaced only once, when they load.
  List<ScannedDocumentModel> get docs => _docs;

  int _currentIndex = 0;

  /// Which page is showing. Only meaningful while [status] is ready.
  int get currentIndex => _currentIndex;

  ScannedDocumentModel get currentDoc => _docs[_currentIndex];

  PageZoom _zoom = PageZoom.fitted;
  PageZoom get zoom => _zoom;

  bool _disposed = false;

  /// Fetches the group's pages, unless they came with the route.
  Future<void> initialize() async {
    switch (_status) {
      case ItemsStatus.ready || ItemsStatus.failed:
        return;
      case ItemsStatus.loading:
        break;
    }

    try {
      final docs = await _repository.getScannedDocumentsByGroupId(_groupId);

      // The user can leave while the fetch runs; a disposed notifier must
      // not notify.
      if (_disposed) {
        return;
      }

      _show(docs);
    } catch (err) {
      debugPrint('Failed to load pages of group $_groupId: $err');

      if (_disposed) {
        return;
      }

      _status = ItemsStatus.failed;
    }

    notifyListeners();
  }

  void showPage(int index) {
    if (index < 0 || index >= _docs.length || index == _currentIndex) {
      return;
    }

    _currentIndex = index;
    // Pages only turn while fitted, and a newly shown page starts fitted.
    _zoom = PageZoom.fitted;

    notifyListeners();
  }

  void setZoom(PageZoom zoom) {
    if (zoom == _zoom) {
      return;
    }

    _zoom = zoom;

    notifyListeners();
  }

  /// Sets the pages and starts at [_docId]. Does not notify: the
  /// constructor has no listeners yet, and [initialize] notifies once.
  void _show(List<ScannedDocumentModel> docs) {
    final index = docs.indexWhere((doc) => doc.id == _docId);

    if (index < 0) {
      _status = ItemsStatus.failed;

      return;
    }

    _docs = List.unmodifiable(docs);
    _currentIndex = index;
    _status = ItemsStatus.ready;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}