/// Shared by the stacked thumbnails and the detail grid: a Hero only flies
/// when both ends build exactly the same tag.
String pageHeroTag(String groupId, String imagePath) => '${groupId}_$imagePath';
