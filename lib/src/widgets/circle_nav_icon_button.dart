import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/constants/ui_constants.dart';

/// A round icon button that floats over content.
///
/// Like the framework's buttons, a null [onPressed] disables it; the button
/// then fades instead of disappearing so the layout does not jump.
class CircleNavIconButton extends StatelessWidget {
  const CircleNavIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: AppDurations.fast,
      opacity: onPressed == null
          ? AppOpacity.disabledControl
          : AppOpacity.opaque,
      child: Material(
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: IconButton(
          iconSize: AppSizes.icon,
          icon: Icon(icon),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
