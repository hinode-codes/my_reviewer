/// Short UI sounds, each a bundled asset.
///
/// Kept to roughly the length of a route transition (about 300 ms), so a
/// sound ends with the hero flight it accompanies instead of trailing it.
enum UiSound {
  /// A stack of pages fanning out into its group.
  stackSpread('assets/sounds/stack_spread.wav'),

  /// Pages gathering back into their stack.
  stackGather('assets/sounds/stack_gather.wav'),

  /// A page lifting off the grid to full screen.
  pageOpen('assets/sounds/page_open.wav'),

  /// A page settling back into the grid.
  pageClose('assets/sounds/page_close.wav');

  const UiSound(this.asset);

  final String asset;
}