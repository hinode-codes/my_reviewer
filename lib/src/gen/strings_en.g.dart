///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	final TranslationMetadata<AppLocale, Translations> _meta;
	@override TranslationMetadata<AppLocale, Translations> get $meta => _meta;

	/// Access flat map
	dynamic operator[](String key) => _meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final Translations$common$en common = Translations$common$en._(_root);
	late final Translations$docs$en docs = Translations$docs$en._(_root);
	late final Translations$flashcards$en flashcards = Translations$flashcards$en._(_root);
	late final Translations$settings$en settings = Translations$settings$en._(_root);
}

// Path: common
class Translations$common$en {
	Translations$common$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'My Reviewer'
	String get title => 'My Reviewer';

	late final Translations$common$bottomNavbar$en bottomNavbar = Translations$common$bottomNavbar$en._(_root);
	late final Translations$common$buttons$en buttons = Translations$common$buttons$en._(_root);
	late final Translations$common$status$en status = Translations$common$status$en._(_root);
	late final Translations$common$selection$en selection = Translations$common$selection$en._(_root);
}

// Path: docs
class Translations$docs$en {
	Translations$docs$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$docs$main$en main = Translations$docs$main$en._(_root);
	late final Translations$docs$detail$en detail = Translations$docs$detail$en._(_root);
	late final Translations$docs$scan$en scan = Translations$docs$scan$en._(_root);
}

// Path: flashcards
class Translations$flashcards$en {
	Translations$flashcards$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$flashcards$main$en main = Translations$flashcards$main$en._(_root);
}

// Path: settings
class Translations$settings$en {
	Translations$settings$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Settings'
	String get title => 'Settings';
}

// Path: common.bottomNavbar
class Translations$common$bottomNavbar$en {
	Translations$common$bottomNavbar$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Documents'
	String get docs => 'Documents';

	/// en: 'Learn'
	String get learn => 'Learn';

	/// en: 'Settings'
	String get settings => 'Settings';
}

// Path: common.buttons
class Translations$common$buttons$en {
	Translations$common$buttons$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Confirm'
	String get confirm => 'Confirm';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Try again'
	String get retry => 'Try again';

	/// en: 'Close'
	String get close => 'Close';

	/// en: 'Proceed'
	String get proceed => 'Proceed';

	/// en: 'Done'
	String get done => 'Done';
}

// Path: common.status
class Translations$common$status$en {
	Translations$common$status$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Successful operation'
	String get success => 'Successful operation';

	/// en: 'Something went wrong'
	String get failed => 'Something went wrong';

	/// en: 'Preparing... please wait'
	String get preparing => 'Preparing... please wait';

	/// en: 'Finishing up...'
	String get finishing => 'Finishing up...';

	/// en: 'Processing... {count} / {total}'
	String processing({required Object count, required Object total}) => 'Processing... ${count} / ${total}';

	/// en: 'Loading...'
	String get loading => 'Loading...';
}

// Path: common.selection
class Translations$common$selection$en {
	Translations$common$selection$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$common$selection$tile$en tile = Translations$common$selection$tile$en._(_root);
	late final Translations$common$selection$delete$en delete = Translations$common$selection$delete$en._(_root);
	late final Translations$common$selection$close$en close = Translations$common$selection$close$en._(_root);

	/// en: '{count} / {total} selected'
	String label({required Object count, required Object total}) => '${count} / ${total} selected';

	late final Translations$common$selection$selectAllButton$en selectAllButton = Translations$common$selection$selectAllButton$en._(_root);
}

// Path: docs.main
class Translations$docs$main$en {
	Translations$docs$main$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Documents'
	String get title => 'Documents';

	/// en: 'Scan a document'
	String get fab => 'Scan a document';

	/// en: 'No documents found. Tap the button below to scan a document.'
	String get noDocs => 'No documents found. Tap the button below to scan a document.';

	/// en: 'Snapshot error: {error}'
	String snapshotError({required Object error}) => 'Snapshot error: ${error}';

	/// en: '(zero) {No documents} (one) {1 document} (other) {{n} documents}'
	String documentCount({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		zero: 'No documents',
		one: '1 document',
		other: '${n} documents',
	);
}

// Path: docs.detail
class Translations$docs$detail$en {
	Translations$docs$detail$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$docs$detail$edit$en edit = Translations$docs$detail$edit$en._(_root);

	/// en: 'No documents found in this group.'
	String get noDocs => 'No documents found in this group.';
}

// Path: docs.scan
class Translations$docs$scan$en {
	Translations$docs$scan$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Scan Document'
	String get title => 'Scan Document';

	/// en: 'No documents captured.'
	String get noDocsCaptured => 'No documents captured.';

	/// en: 'Scan new documents'
	String get noDocsRetry => 'Scan new documents';

	late final Translations$docs$scan$preview$en preview = Translations$docs$scan$preview$en._(_root);
	late final Translations$docs$scan$save$en save = Translations$docs$scan$save$en._(_root);
	late final Translations$docs$scan$discard$en discard = Translations$docs$scan$discard$en._(_root);
}

// Path: flashcards.main
class Translations$flashcards$main$en {
	Translations$flashcards$main$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Flashcards'
	String get title => 'Flashcards';
}

// Path: common.selection.tile
class Translations$common$selection$tile$en {
	Translations$common$selection$tile$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Select this tile'
	String get select => 'Select this tile';

	/// en: 'Deselect this tile'
	String get deselect => 'Deselect this tile';

	/// en: 'You have entered selection mode. This tile has been selected. Please select or deselect other tiles.'
	String get startSelecting => 'You have entered selection mode. This tile has been selected. Please select or deselect other tiles.';
}

// Path: common.selection.delete
class Translations$common$selection$delete$en {
	Translations$common$selection$delete$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$common$selection$delete$inactive$en inactive = Translations$common$selection$delete$inactive$en._(_root);
	late final Translations$common$selection$delete$active$en active = Translations$common$selection$delete$active$en._(_root);
	late final Translations$common$selection$delete$confirmationDialog$en confirmationDialog = Translations$common$selection$delete$confirmationDialog$en._(_root);
}

// Path: common.selection.close
class Translations$common$selection$close$en {
	Translations$common$selection$close$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Cancel selection'
	String get tooltip => 'Cancel selection';
}

// Path: common.selection.selectAllButton
class Translations$common$selection$selectAllButton$en {
	Translations$common$selection$selectAllButton$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$common$selection$selectAllButton$deselectAll$en deselectAll = Translations$common$selection$selectAllButton$deselectAll$en._(_root);
	late final Translations$common$selection$selectAllButton$selectAll$en selectAll = Translations$common$selection$selectAllButton$selectAll$en._(_root);
}

// Path: docs.detail.edit
class Translations$docs$detail$edit$en {
	Translations$docs$detail$edit$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Edit this document group'
	String get tooltip => 'Edit this document group';

	/// en: 'Edit Group'
	String get label => 'Edit Group';
}

// Path: docs.scan.preview
class Translations$docs$scan$preview$en {
	Translations$docs$scan$preview$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Scanned Documents'
	String get emptyTitle => 'Scanned Documents';

	/// en: '{current} / {total}'
	String title({required Object current, required Object total}) => '${current} / ${total}';

	/// en: 'Delete'
	String get delete => 'Delete';

	/// en: 'Scan More'
	String get scanMore => 'Scan More';

	/// en: 'Save'
	String get save => 'Save';

	/// en: 'Scan More'
	String get addLabel => 'Scan More';

	/// en: 'Scan more documents.'
	String get addTooltip => 'Scan more documents.';

	late final Translations$docs$scan$preview$bottomBar$en bottomBar = Translations$docs$scan$preview$bottomBar$en._(_root);

	/// en: 'Document Name'
	String get docNameLabel => 'Document Name';

	/// en: 'Enter Document Name'
	String get docNamePlaceholder => 'Enter Document Name';

	/// en: 'Document name cannot be empty.'
	String get docNameError => 'Document name cannot be empty.';

	late final Translations$docs$scan$preview$bottomSheet$en bottomSheet = Translations$docs$scan$preview$bottomSheet$en._(_root);
}

// Path: docs.scan.save
class Translations$docs$scan$save$en {
	Translations$docs$scan$save$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Failed to save document(s).'
	String get failed => 'Failed to save document(s).';

	/// en: 'Document(s) saved successfully.'
	String get done => 'Document(s) saved successfully.';

	/// en: 'Preparing to save document(s)...'
	String get preparing => 'Preparing to save document(s)...';

	/// en: 'Saving document(s)... {current} / {total}'
	String savingFiles({required Object current, required Object total}) => 'Saving document(s)... ${current} / ${total}';

	/// en: 'Finishing up...'
	String get finishing => 'Finishing up...';

	/// en: 'Proceed to Exit'
	String get backAction => 'Proceed to Exit';

	/// en: 'Okay'
	String get closeAction => 'Okay';

	/// en: 'Try to Save Again'
	String get retryAction => 'Try to Save Again';
}

// Path: docs.scan.discard
class Translations$docs$scan$discard$en {
	Translations$docs$scan$discard$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Exiting Document Scanner'
	String get title => 'Exiting Document Scanner';

	/// en: 'Unsaved documents are about to be discarded. Are you sure you want to continue? You can save them before exiting.'
	String get message => 'Unsaved documents are about to be discarded. Are you sure you want to continue? You can save them before exiting.';

	/// en: 'Exit & Discard'
	String get confirm => 'Exit & Discard';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Save & Exit'
	String get save => 'Save & Exit';
}

// Path: common.selection.delete.inactive
class Translations$common$selection$delete$inactive$en {
	Translations$common$selection$delete$inactive$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Select items to delete.'
	String get tooltip => 'Select items to delete.';
}

// Path: common.selection.delete.active
class Translations$common$selection$delete$active$en {
	Translations$common$selection$delete$active$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Delete selected items.'
	String get tooltip => 'Delete selected items.';
}

// Path: common.selection.delete.confirmationDialog
class Translations$common$selection$delete$confirmationDialog$en {
	Translations$common$selection$delete$confirmationDialog$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: '(one) {Deleting {n} document} (other) {Deleting {n} documents}'
	String title({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: 'Deleting ${n} document',
		other: 'Deleting ${n} documents',
	);

	/// en: 'Are you sure you want to continue?'
	String get message => 'Are you sure you want to continue?';
}

// Path: common.selection.selectAllButton.deselectAll
class Translations$common$selection$selectAllButton$deselectAll$en {
	Translations$common$selection$selectAllButton$deselectAll$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Deselect all items.'
	String get tooltip => 'Deselect all items.';
}

// Path: common.selection.selectAllButton.selectAll
class Translations$common$selection$selectAllButton$selectAll$en {
	Translations$common$selection$selectAllButton$selectAll$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Select all items.'
	String get tooltip => 'Select all items.';
}

// Path: docs.scan.preview.bottomBar
class Translations$docs$scan$preview$bottomBar$en {
	Translations$docs$scan$preview$bottomBar$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Scan more documents.'
	String get addTooltip => 'Scan more documents.';

	/// en: 'Delete current document.'
	String get deleteTooltip => 'Delete current document.';

	/// en: 'Show all documents.'
	String get groupTooltip => 'Show all documents.';

	/// en: 'Show Group ({count})'
	String groupButton({required Object count}) => 'Show Group (${count})';
}

// Path: docs.scan.preview.bottomSheet
class Translations$docs$scan$preview$bottomSheet$en {
	Translations$docs$scan$preview$bottomSheet$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Group Details'
	String get title => 'Group Details';

	/// en: 'Group Name'
	String get groupNameLabel => 'Group Name';

	/// en: 'Enter Group Name'
	String get groupNamePlaceholder => 'Enter Group Name';

	/// en: 'Group name cannot be empty.'
	String get groupNameError => 'Group name cannot be empty.';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'common.title' => 'My Reviewer',
			'common.bottomNavbar.docs' => 'Documents',
			'common.bottomNavbar.learn' => 'Learn',
			'common.bottomNavbar.settings' => 'Settings',
			'common.buttons.confirm' => 'Confirm',
			'common.buttons.cancel' => 'Cancel',
			'common.buttons.retry' => 'Try again',
			'common.buttons.close' => 'Close',
			'common.buttons.proceed' => 'Proceed',
			'common.buttons.done' => 'Done',
			'common.status.success' => 'Successful operation',
			'common.status.failed' => 'Something went wrong',
			'common.status.preparing' => 'Preparing... please wait',
			'common.status.finishing' => 'Finishing up...',
			'common.status.processing' => ({required Object count, required Object total}) => 'Processing... ${count} / ${total}',
			'common.status.loading' => 'Loading...',
			'common.selection.tile.select' => 'Select this tile',
			'common.selection.tile.deselect' => 'Deselect this tile',
			'common.selection.tile.startSelecting' => 'You have entered selection mode. This tile has been selected. Please select or deselect other tiles.',
			'common.selection.delete.inactive.tooltip' => 'Select items to delete.',
			'common.selection.delete.active.tooltip' => 'Delete selected items.',
			'common.selection.delete.confirmationDialog.title' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, one: 'Deleting ${n} document', other: 'Deleting ${n} documents', ), 
			'common.selection.delete.confirmationDialog.message' => 'Are you sure you want to continue?',
			'common.selection.close.tooltip' => 'Cancel selection',
			'common.selection.label' => ({required Object count, required Object total}) => '${count} / ${total} selected',
			'common.selection.selectAllButton.deselectAll.tooltip' => 'Deselect all items.',
			'common.selection.selectAllButton.selectAll.tooltip' => 'Select all items.',
			'docs.main.title' => 'Documents',
			'docs.main.fab' => 'Scan a document',
			'docs.main.noDocs' => 'No documents found. Tap the button below to scan a document.',
			'docs.main.snapshotError' => ({required Object error}) => 'Snapshot error: ${error}',
			'docs.main.documentCount' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, zero: 'No documents', one: '1 document', other: '${n} documents', ), 
			'docs.detail.edit.tooltip' => 'Edit this document group',
			'docs.detail.edit.label' => 'Edit Group',
			'docs.detail.noDocs' => 'No documents found in this group.',
			'docs.scan.title' => 'Scan Document',
			'docs.scan.noDocsCaptured' => 'No documents captured.',
			'docs.scan.noDocsRetry' => 'Scan new documents',
			'docs.scan.preview.emptyTitle' => 'Scanned Documents',
			'docs.scan.preview.title' => ({required Object current, required Object total}) => '${current} / ${total}',
			'docs.scan.preview.delete' => 'Delete',
			'docs.scan.preview.scanMore' => 'Scan More',
			'docs.scan.preview.save' => 'Save',
			'docs.scan.preview.addLabel' => 'Scan More',
			'docs.scan.preview.addTooltip' => 'Scan more documents.',
			'docs.scan.preview.bottomBar.addTooltip' => 'Scan more documents.',
			'docs.scan.preview.bottomBar.deleteTooltip' => 'Delete current document.',
			'docs.scan.preview.bottomBar.groupTooltip' => 'Show all documents.',
			'docs.scan.preview.bottomBar.groupButton' => ({required Object count}) => 'Show Group (${count})',
			'docs.scan.preview.docNameLabel' => 'Document Name',
			'docs.scan.preview.docNamePlaceholder' => 'Enter Document Name',
			'docs.scan.preview.docNameError' => 'Document name cannot be empty.',
			'docs.scan.preview.bottomSheet.title' => 'Group Details',
			'docs.scan.preview.bottomSheet.groupNameLabel' => 'Group Name',
			'docs.scan.preview.bottomSheet.groupNamePlaceholder' => 'Enter Group Name',
			'docs.scan.preview.bottomSheet.groupNameError' => 'Group name cannot be empty.',
			'docs.scan.save.failed' => 'Failed to save document(s).',
			'docs.scan.save.done' => 'Document(s) saved successfully.',
			'docs.scan.save.preparing' => 'Preparing to save document(s)...',
			'docs.scan.save.savingFiles' => ({required Object current, required Object total}) => 'Saving document(s)... ${current} / ${total}',
			'docs.scan.save.finishing' => 'Finishing up...',
			'docs.scan.save.backAction' => 'Proceed to Exit',
			'docs.scan.save.closeAction' => 'Okay',
			'docs.scan.save.retryAction' => 'Try to Save Again',
			'docs.scan.discard.title' => 'Exiting Document Scanner',
			'docs.scan.discard.message' => 'Unsaved documents are about to be discarded. Are you sure you want to continue? You can save them before exiting.',
			'docs.scan.discard.confirm' => 'Exit & Discard',
			'docs.scan.discard.cancel' => 'Cancel',
			'docs.scan.discard.save' => 'Save & Exit',
			'flashcards.main.title' => 'Flashcards',
			'settings.title' => 'Settings',
			_ => null,
		};
	}
}
