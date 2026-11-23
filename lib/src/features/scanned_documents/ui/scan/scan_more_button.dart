import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/shared/i18n/gen/strings.g.dart';

enum ScanMoreButtonVariant { icon, filled }

class ScanMoreButton extends StatelessWidget {
  const ScanMoreButton({
    super.key,
    required this.onPressed,
    this.variant = ScanMoreButtonVariant.icon,
  });

  final VoidCallback onPressed;
  final ScanMoreButtonVariant variant;

  void _handlePressed() {
    FocusManager.instance.primaryFocus?.unfocus();
    onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final strings = t.docs.scan.preview;
    const icon = Icon(Icons.add_a_photo_outlined);

    return switch (variant) {
      ScanMoreButtonVariant.icon => IconButton(
        tooltip: strings.tooltips.add,
        icon: icon,
        color: Theme.of(context).colorScheme.primary,
        onPressed: _handlePressed,
      ),
      ScanMoreButtonVariant.filled => FilledButton.icon(
        onPressed: _handlePressed,
        icon: icon,
        label: Text(strings.actions.add),
      ),
    };
  }
}
