enum SelectionMode {
  inactive,
  active;

  bool get isActive => this == SelectionMode.active;
}

/// Whether the select-all action should select or deselect. `partial`
/// includes nothing selected.
enum SelectionCoverage { partial, all }

/// How one item looks. `unavailable` means selection mode is off, which a
/// tile shows differently from "on but not selected".
enum ItemSelection { unavailable, unselected, selected }

/// Tells a tile whether a tap was consumed by selection or should open
/// the item.
enum SelectionTap { toggled, openItem }

enum ItemsStatus { loading, ready, failed }
