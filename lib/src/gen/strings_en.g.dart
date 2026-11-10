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
}

// Path: docs
class Translations$docs$en {
	Translations$docs$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$docs$main$en main = Translations$docs$main$en._(_root);
	late final Translations$docs$selection$en selection = Translations$docs$selection$en._(_root);
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
	String get documents => 'Documents';

	/// en: 'Flashcards'
	String get flashcards => 'Flashcards';

	/// en: 'Settings'
	String get settings => 'Settings';
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

// Path: docs.selection
class Translations$docs$selection$en {
	Translations$docs$selection$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: '{count} / {total}'
	String selectedLabel({required Object count, required Object total}) => '${count} / ${total}';

	/// en: 'Cancel selection mode.'
	String get cancelTooltip => 'Cancel selection mode.';

	/// en: 'Deselect all documents.'
	String get deselectAllTooltip => 'Deselect all documents.';

	/// en: 'Select all documents.'
	String get selectAllTooltip => 'Select all documents.';

	/// en: 'Delete selected documents.'
	String get deleteTooltip => 'Delete selected documents.';

	/// en: 'Enter selection mode.'
	String get enterSelectionTooltip => 'Enter selection mode.';

	/// en: 'Delete {n} document(s)?'
	String deleteConfirmTitle({required Object n}) => 'Delete ${n} document(s)?';

	/// en: 'Are you sure you want to delete the selected document(s)?'
	String get deleteConfirmMessage => 'Are you sure you want to delete the selected document(s)?';

	/// en: 'Cancel'
	String get cancelButton => 'Cancel';

	/// en: 'Delete'
	String get deleteButton => 'Delete';

	late final Translations$docs$selection$delete$en delete = Translations$docs$selection$delete$en._(_root);
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

// Path: docs.selection.delete
class Translations$docs$selection$delete$en {
	Translations$docs$selection$delete$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Deleting document(s)... {current} / {total}'
	String deletingFiles({required Object current, required Object total}) => 'Deleting document(s)... ${current} / ${total}';

	/// en: 'Document(s) deleted successfully.'
	String get done => 'Document(s) deleted successfully.';

	/// en: 'Failed to delete document(s).'
	String get failed => 'Failed to delete document(s).';

	/// en: 'Okay'
	String get closeAction => 'Okay';

	/// en: 'Try to Delete Again'
	String get retryAction => 'Try to Delete Again';

	/// en: 'Preparing to delete document(s)...'
	String get preparing => 'Preparing to delete document(s)...';

	/// en: 'Finishing up...'
	String get finishing => 'Finishing up...';
}

// Path: docs.scan.preview
class Translations$docs$scan$preview$en {
	Translations$docs$scan$preview$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: '{current} / {total}'
	String title({required Object current, required Object total}) => '${current} / ${total}';

	/// en: 'Delete'
	String get delete => 'Delete';

	/// en: 'Scan More'
	String get scanMore => 'Scan More';

	/// en: 'Save'
	String get save => 'Save';

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
			'common.bottomNavbar.documents' => 'Documents',
			'common.bottomNavbar.flashcards' => 'Flashcards',
			'common.bottomNavbar.settings' => 'Settings',
			'docs.main.title' => 'Documents',
			'docs.main.fab' => 'Scan a document',
			'docs.main.noDocs' => 'No documents found. Tap the button below to scan a document.',
			'docs.main.snapshotError' => ({required Object error}) => 'Snapshot error: ${error}',
			'docs.main.documentCount' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, zero: 'No documents', one: '1 document', other: '${n} documents', ), 
			'docs.selection.selectedLabel' => ({required Object count, required Object total}) => '${count} / ${total}',
			'docs.selection.cancelTooltip' => 'Cancel selection mode.',
			'docs.selection.deselectAllTooltip' => 'Deselect all documents.',
			'docs.selection.selectAllTooltip' => 'Select all documents.',
			'docs.selection.deleteTooltip' => 'Delete selected documents.',
			'docs.selection.enterSelectionTooltip' => 'Enter selection mode.',
			'docs.selection.deleteConfirmTitle' => ({required Object n}) => 'Delete ${n} document(s)?',
			'docs.selection.deleteConfirmMessage' => 'Are you sure you want to delete the selected document(s)?',
			'docs.selection.cancelButton' => 'Cancel',
			'docs.selection.deleteButton' => 'Delete',
			'docs.selection.delete.deletingFiles' => ({required Object current, required Object total}) => 'Deleting document(s)... ${current} / ${total}',
			'docs.selection.delete.done' => 'Document(s) deleted successfully.',
			'docs.selection.delete.failed' => 'Failed to delete document(s).',
			'docs.selection.delete.closeAction' => 'Okay',
			'docs.selection.delete.retryAction' => 'Try to Delete Again',
			'docs.selection.delete.preparing' => 'Preparing to delete document(s)...',
			'docs.selection.delete.finishing' => 'Finishing up...',
			'docs.scan.title' => 'Scan Document',
			'docs.scan.noDocsCaptured' => 'No documents captured.',
			'docs.scan.noDocsRetry' => 'Scan new documents',
			'docs.scan.preview.title' => ({required Object current, required Object total}) => '${current} / ${total}',
			'docs.scan.preview.delete' => 'Delete',
			'docs.scan.preview.scanMore' => 'Scan More',
			'docs.scan.preview.save' => 'Save',
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
