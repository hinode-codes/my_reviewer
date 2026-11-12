/// Returned by deletions so the caller knows whether the screen it is on
/// still has anything to show.
enum DeletionOutcome { itemsDeleted, parentDeleted }

/// What happens to a group once its last document is deleted.
enum EmptyGroupPolicy {
  deleteGroup,

  /// For the edit flow, which may still hold unsaved pages for the group.
  keepGroup,
}
