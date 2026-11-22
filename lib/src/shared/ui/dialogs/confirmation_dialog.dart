import 'package:material_ui/material_ui.dart';
import 'package:my_reviewer/src/shared/models/confirmation.dart';

/// A confirm / cancel dialog, with an optional third action in the middle.
///
/// Knows nothing about any feature: the caller supplies the already-translated
/// copy and reads the choice back. Passing [tertiaryLabel] adds the third
/// button, which resolves to [ConfirmChoice.tertiary].
///
/// The actions are given cancel-first so a single row reads left to right as
/// cancel, (tertiary), confirm — cancel on the leading edge, confirm on the
/// trailing one. When they do not fit and stack into a column,
/// [VerticalDirection.up] reverses that order, so confirm sits on top and
/// cancel at the bottom.
class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    this.tone = ConfirmTone.normal,
    this.tertiaryLabel,
    this.tertiaryTone = ConfirmTone.normal,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final ConfirmTone tone;

  /// Label for the optional middle action. Null hides the third button.
  final String? tertiaryLabel;
  final ConfirmTone tertiaryTone;

  /// Shows the dialog and resolves to the choice, or null if dismissed by
  /// tapping outside or the system back gesture.
  static Future<ConfirmChoice?> show(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required String cancelLabel,
    ConfirmTone tone = ConfirmTone.normal,
    String? tertiaryLabel,
    ConfirmTone tertiaryTone = ConfirmTone.normal,
  }) {
    return showDialog<ConfirmChoice>(
      context: context,
      builder: (_) => ConfirmationDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        tone: tone,
        tertiaryLabel: tertiaryLabel,
        tertiaryTone: tertiaryTone,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tertiaryLabel = this.tertiaryLabel;

    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actionsOverflowDirection: VerticalDirection.up,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, ConfirmChoice.cancel),
          child: Text(cancelLabel),
        ),
        if (tertiaryLabel != null)
          TextButton(
            onPressed: () => Navigator.pop(context, ConfirmChoice.tertiary),
            style: TextButton.styleFrom(
              foregroundColor: tertiaryTone.accentColor(colorScheme),
            ),
            child: Text(tertiaryLabel),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context, ConfirmChoice.confirm),
          style: TextButton.styleFrom(
            foregroundColor: tone.accentColor(colorScheme),
          ),
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}
