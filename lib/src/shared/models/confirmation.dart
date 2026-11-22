import 'package:material_ui/material_ui.dart';

/// Returned instead of a bool so a dismissed dialog (null) is distinct from an
/// explicit cancel, and so the optional third button has its own value.
enum ConfirmChoice { confirm, cancel, tertiary }

/// How weighty an action is, which decides its colour.
///
/// An enum rather than an `isDestructive` flag so the call site reads on its
/// own and a new tone needs no new parameter.
enum ConfirmTone {
  normal,
  destructive;

  Color accentColor(ColorScheme colorScheme) => switch (this) {
    ConfirmTone.normal => colorScheme.primary,
    ConfirmTone.destructive => colorScheme.error,
  };
}
