import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/shared/constants/image_constants.dart';
import 'package:my_reviewer/src/shared/ui/image/thumbnail_image.dart';

/// Builds with the real width / height of the page image at [path].
///
/// Read from the page's thumbnail, which keeps the image's proportions and
/// is usually cached already, so the real value is known on the first
/// frame. Until it is, or if it cannot be read, the document default is
/// used.
class PageAspectBuilder extends StatefulWidget {
  const PageAspectBuilder({
    super.key,
    required this.path,
    required this.builder,
  });

  final String path;
  final Widget Function(BuildContext context, double aspectRatio) builder;

  @override
  State<PageAspectBuilder> createState() => _PageAspectBuilderState();
}

class _PageAspectBuilderState extends State<PageAspectBuilder> {
  ImageStream? _stream;
  late final ImageStreamListener _listener = ImageStreamListener(
    _onImage,
    // A broken image keeps the default shape; ThumbnailImage shows the
    // error itself.
    onError: (_, _) {},
  );

  double _aspectRatio = ImageConstants.defaultCardAspectRatio;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolve();
  }

  @override
  void didUpdateWidget(PageAspectBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.path != widget.path) {
      _aspectRatio = ImageConstants.defaultCardAspectRatio;
      _resolve();
    }
  }

  void _resolve() {
    final stream = ThumbnailImage.providerFor(widget.path)
        .resolve(createLocalImageConfiguration(context));

    if (stream.key == _stream?.key) {
      return;
    }

    _stream?.removeListener(_listener);
    _stream = stream..addListener(_listener);
  }

  void _onImage(ImageInfo info, bool synchronousCall) {
    final image = info.image;
    final aspectRatio = image.width / image.height;

    // Listeners own the ImageInfo they are given.
    info.dispose();

    if (aspectRatio == _aspectRatio) {
      return;
    }

    // A cached image reports while this state is still being set up, which
    // is before its build: assigning is enough there.
    if (synchronousCall) {
      _aspectRatio = aspectRatio;
    } else {
      setState(() => _aspectRatio = aspectRatio);
    }
  }

  @override
  void dispose() {
    _stream?.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _aspectRatio);
}
