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
	late final Translations$learn$en learn = Translations$learn$en._(_root);
	late final Translations$settings$en settings = Translations$settings$en._(_root);
}

// Path: common
class Translations$common$en {
	Translations$common$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'My Reviewer'
	String get title => 'My Reviewer';

	late final Translations$common$navigation$en navigation = Translations$common$navigation$en._(_root);
	late final Translations$common$actions$en actions = Translations$common$actions$en._(_root);
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
	late final Translations$docs$transcription$en transcription = Translations$docs$transcription$en._(_root);
}

// Path: learn
class Translations$learn$en {
	Translations$learn$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$learn$main$en main = Translations$learn$main$en._(_root);
}

// Path: settings
class Translations$settings$en {
	Translations$settings$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$settings$main$en main = Translations$settings$main$en._(_root);
}

// Path: common.navigation
class Translations$common$navigation$en {
	Translations$common$navigation$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Documents'
	String get docs => 'Documents';

	/// en: 'Learn'
	String get learn => 'Learn';

	/// en: 'Settings'
	String get settings => 'Settings';
}

// Path: common.actions
class Translations$common$actions$en {
	Translations$common$actions$en._(this._root);

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

	/// en: 'Hide'
	String get hide => 'Hide';

	/// en: 'Keep'
	String get keep => 'Keep';

	/// en: 'Delete'
	String get delete => 'Delete';
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

	/// en: 'Processing... {count: int} / {total: int}'
	String processing({required int count, required int total}) => 'Processing... ${count} / ${total}';

	/// en: 'Loading...'
	String get loading => 'Loading...';
}

// Path: common.selection
class Translations$common$selection$en {
	Translations$common$selection$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$common$selection$tooltips$en tooltips = Translations$common$selection$tooltips$en._(_root);
	late final Translations$common$selection$semantics$en semantics = Translations$common$selection$semantics$en._(_root);
	late final Translations$common$selection$status$en status = Translations$common$selection$status$en._(_root);
	late final Translations$common$selection$dialogs$en dialogs = Translations$common$selection$dialogs$en._(_root);
}

// Path: docs.main
class Translations$docs$main$en {
	Translations$docs$main$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Documents'
	String get title => _root.common.navigation.docs;

	late final Translations$docs$main$actions$en actions = Translations$docs$main$actions$en._(_root);
	late final Translations$docs$main$status$en status = Translations$docs$main$status$en._(_root);
	late final Translations$docs$main$empty$en empty = Translations$docs$main$empty$en._(_root);
	late final Translations$docs$main$errors$en errors = Translations$docs$main$errors$en._(_root);
}

// Path: docs.detail
class Translations$docs$detail$en {
	Translations$docs$detail$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$docs$detail$actions$en actions = Translations$docs$detail$actions$en._(_root);
	late final Translations$docs$detail$tooltips$en tooltips = Translations$docs$detail$tooltips$en._(_root);
	late final Translations$docs$detail$empty$en empty = Translations$docs$detail$empty$en._(_root);
}

// Path: docs.scan
class Translations$docs$scan$en {
	Translations$docs$scan$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Scan Document'
	String get title => 'Scan Document';

	late final Translations$docs$scan$empty$en empty = Translations$docs$scan$empty$en._(_root);
	late final Translations$docs$scan$dialogs$en dialogs = Translations$docs$scan$dialogs$en._(_root);
	late final Translations$docs$scan$preview$en preview = Translations$docs$scan$preview$en._(_root);
	late final Translations$docs$scan$save$en save = Translations$docs$scan$save$en._(_root);
}

// Path: docs.transcription
class Translations$docs$transcription$en {
	Translations$docs$transcription$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$docs$transcription$actions$en actions = Translations$docs$transcription$actions$en._(_root);
	late final Translations$docs$transcription$status$en status = Translations$docs$transcription$status$en._(_root);
	late final Translations$docs$transcription$empty$en empty = Translations$docs$transcription$empty$en._(_root);

	/// en: '{words: int} words · ~{seconds: int}s read'
	String stats({required int words, required int seconds}) => '${words} words · ~${seconds}s read';
}

// Path: learn.main
class Translations$learn$main$en {
	Translations$learn$main$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Learn'
	String get title => _root.common.navigation.learn;
}

// Path: settings.main
class Translations$settings$main$en {
	Translations$settings$main$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Settings'
	String get title => _root.common.navigation.settings;

	late final Translations$settings$main$model$en model = Translations$settings$main$model$en._(_root);
	late final Translations$settings$main$downloads$en downloads = Translations$settings$main$downloads$en._(_root);
	late final Translations$settings$main$notifications$en notifications = Translations$settings$main$notifications$en._(_root);
}

// Path: common.selection.tooltips
class Translations$common$selection$tooltips$en {
	Translations$common$selection$tooltips$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Cancel selection'
	String get close => 'Cancel selection';

	/// en: 'Select items to delete.'
	String get deleteInactive => 'Select items to delete.';

	/// en: 'Delete selected items.'
	String get deleteActive => 'Delete selected items.';

	/// en: 'Select all items.'
	String get selectAll => 'Select all items.';

	/// en: 'Deselect all items.'
	String get deselectAll => 'Deselect all items.';
}

// Path: common.selection.semantics
class Translations$common$selection$semantics$en {
	Translations$common$selection$semantics$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Select this tile'
	String get select => 'Select this tile';

	/// en: 'Deselect this tile'
	String get deselect => 'Deselect this tile';

	/// en: 'You have entered selection mode. This tile has been selected. Please select or deselect other tiles.'
	String get startSelecting => 'You have entered selection mode. This tile has been selected. Please select or deselect other tiles.';
}

// Path: common.selection.status
class Translations$common$selection$status$en {
	Translations$common$selection$status$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: '{count: int} / {total: int} selected'
	String selected({required int count, required int total}) => '${count} / ${total} selected';
}

// Path: common.selection.dialogs
class Translations$common$selection$dialogs$en {
	Translations$common$selection$dialogs$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$common$selection$dialogs$delete$en delete = Translations$common$selection$dialogs$delete$en._(_root);
}

// Path: docs.main.actions
class Translations$docs$main$actions$en {
	Translations$docs$main$actions$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Scan a document'
	String get scan => 'Scan a document';
}

// Path: docs.main.status
class Translations$docs$main$status$en {
	Translations$docs$main$status$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: '(zero) {No documents} (one) {{n} document} (other) {{n} documents}'
	String documentCount({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		zero: 'No documents',
		one: '${n} document',
		other: '${n} documents',
	);
}

// Path: docs.main.empty
class Translations$docs$main$empty$en {
	Translations$docs$main$empty$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'No documents found. Tap the button below to scan a document.'
	String get message => 'No documents found. Tap the button below to scan a document.';
}

// Path: docs.main.errors
class Translations$docs$main$errors$en {
	Translations$docs$main$errors$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Snapshot error: {error}'
	String snapshot({required Object error}) => 'Snapshot error: ${error}';
}

// Path: docs.detail.actions
class Translations$docs$detail$actions$en {
	Translations$docs$detail$actions$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Edit Group'
	String get edit => 'Edit Group';
}

// Path: docs.detail.tooltips
class Translations$docs$detail$tooltips$en {
	Translations$docs$detail$tooltips$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Edit this document group'
	String get edit => 'Edit this document group';
}

// Path: docs.detail.empty
class Translations$docs$detail$empty$en {
	Translations$docs$detail$empty$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'No documents found in this group.'
	String get message => 'No documents found in this group.';
}

// Path: docs.scan.empty
class Translations$docs$scan$empty$en {
	Translations$docs$scan$empty$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'No documents captured.'
	String get message => 'No documents captured.';

	/// en: 'Scan new documents'
	String get action => 'Scan new documents';
}

// Path: docs.scan.dialogs
class Translations$docs$scan$dialogs$en {
	Translations$docs$scan$dialogs$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$docs$scan$dialogs$discard$en discard = Translations$docs$scan$dialogs$discard$en._(_root);
}

// Path: docs.scan.preview
class Translations$docs$scan$preview$en {
	Translations$docs$scan$preview$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: '{current: int} / {total: int}'
	String title({required int current, required int total}) => '${current} / ${total}';

	late final Translations$docs$scan$preview$actions$en actions = Translations$docs$scan$preview$actions$en._(_root);
	late final Translations$docs$scan$preview$fields$en fields = Translations$docs$scan$preview$fields$en._(_root);
	late final Translations$docs$scan$preview$empty$en empty = Translations$docs$scan$preview$empty$en._(_root);
	late final Translations$docs$scan$preview$bottomBar$en bottomBar = Translations$docs$scan$preview$bottomBar$en._(_root);
	late final Translations$docs$scan$preview$bottomSheet$en bottomSheet = Translations$docs$scan$preview$bottomSheet$en._(_root);
}

// Path: docs.scan.save
class Translations$docs$scan$save$en {
	Translations$docs$scan$save$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$docs$scan$save$actions$en actions = Translations$docs$scan$save$actions$en._(_root);
	late final Translations$docs$scan$save$status$en status = Translations$docs$scan$save$status$en._(_root);
}

// Path: docs.transcription.actions
class Translations$docs$transcription$actions$en {
	Translations$docs$transcription$actions$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'View transcription'
	String get view => 'View transcription';

	/// en: 'View scanned image'
	String get viewImage => 'View scanned image';

	/// en: 'Re-transcribe page'
	String get retranscribe => 'Re-transcribe page';

	/// en: 'Transcribe Page'
	String get start => 'Transcribe Page';
}

// Path: docs.transcription.status
class Translations$docs$transcription$status$en {
	Translations$docs$transcription$status$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Waiting in transcription queue...'
	String get queued => 'Waiting in transcription queue...';

	/// en: 'Transcribing page...'
	String get streaming => 'Transcribing page...';
}

// Path: docs.transcription.empty
class Translations$docs$transcription$empty$en {
	Translations$docs$transcription$empty$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'No Transcription Yet'
	String get title => 'No Transcription Yet';

	/// en: 'Transcribe this scanned page offline into editable Markdown.'
	String get message => 'Transcribe this scanned page offline into editable Markdown.';
}

// Path: settings.main.model
class Translations$settings$main$model$en {
	Translations$settings$main$model$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Transcription Model'
	String get title => 'Transcription Model';

	/// en: 'Choose the model used to transcribe your scanned pages on this device.'
	String get description => 'Choose the model used to transcribe your scanned pages on this device.';

	late final Translations$settings$main$model$actions$en actions = Translations$settings$main$model$actions$en._(_root);
	late final Translations$settings$main$model$status$en status = Translations$settings$main$model$status$en._(_root);
	late final Translations$settings$main$model$alerts$en alerts = Translations$settings$main$model$alerts$en._(_root);
	late final Translations$settings$main$model$errors$en errors = Translations$settings$main$model$errors$en._(_root);
	late final Translations$settings$main$model$size$en size = Translations$settings$main$model$size$en._(_root);
	late final Translations$settings$main$model$dialogs$en dialogs = Translations$settings$main$model$dialogs$en._(_root);
}

// Path: settings.main.downloads
class Translations$settings$main$downloads$en {
	Translations$settings$main$downloads$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$settings$main$downloads$fields$en fields = Translations$settings$main$downloads$fields$en._(_root);
}

// Path: settings.main.notifications
class Translations$settings$main$notifications$en {
	Translations$settings$main$notifications$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$settings$main$notifications$download$en download = Translations$settings$main$notifications$download$en._(_root);
}

// Path: common.selection.dialogs.delete
class Translations$common$selection$dialogs$delete$en {
	Translations$common$selection$dialogs$delete$en._(this._root);

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

// Path: docs.scan.dialogs.discard
class Translations$docs$scan$dialogs$discard$en {
	Translations$docs$scan$dialogs$discard$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Exiting Document Scanner'
	String get title => 'Exiting Document Scanner';

	/// en: 'Unsaved documents are about to be discarded. Are you sure you want to continue? You can save them before exiting.'
	String get message => 'Unsaved documents are about to be discarded. Are you sure you want to continue? You can save them before exiting.';

	late final Translations$docs$scan$dialogs$discard$actions$en actions = Translations$docs$scan$dialogs$discard$actions$en._(_root);
}

// Path: docs.scan.preview.actions
class Translations$docs$scan$preview$actions$en {
	Translations$docs$scan$preview$actions$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Scan More'
	String get add => 'Scan More';

	/// en: 'Save'
	String get save => 'Save';
}

// Path: docs.scan.preview.fields
class Translations$docs$scan$preview$fields$en {
	Translations$docs$scan$preview$fields$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$docs$scan$preview$fields$docName$en docName = Translations$docs$scan$preview$fields$docName$en._(_root);
}

// Path: docs.scan.preview.empty
class Translations$docs$scan$preview$empty$en {
	Translations$docs$scan$preview$empty$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Scanned Documents'
	String get title => 'Scanned Documents';
}

// Path: docs.scan.preview.bottomBar
class Translations$docs$scan$preview$bottomBar$en {
	Translations$docs$scan$preview$bottomBar$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$docs$scan$preview$bottomBar$actions$en actions = Translations$docs$scan$preview$bottomBar$actions$en._(_root);
	late final Translations$docs$scan$preview$bottomBar$tooltips$en tooltips = Translations$docs$scan$preview$bottomBar$tooltips$en._(_root);
}

// Path: docs.scan.preview.bottomSheet
class Translations$docs$scan$preview$bottomSheet$en {
	Translations$docs$scan$preview$bottomSheet$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Group Details'
	String get title => 'Group Details';

	late final Translations$docs$scan$preview$bottomSheet$fields$en fields = Translations$docs$scan$preview$bottomSheet$fields$en._(_root);
}

// Path: docs.scan.save.actions
class Translations$docs$scan$save$actions$en {
	Translations$docs$scan$save$actions$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Proceed to Exit'
	String get back => 'Proceed to Exit';

	/// en: 'Okay'
	String get close => 'Okay';

	/// en: 'Try to Save Again'
	String get retry => 'Try to Save Again';
}

// Path: docs.scan.save.status
class Translations$docs$scan$save$status$en {
	Translations$docs$scan$save$status$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: '(one) {Preparing to save document...} (other) {Preparing to save documents...}'
	String preparing({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: 'Preparing to save document...',
		other: 'Preparing to save documents...',
	);

	/// en: '(one) {Saving document... {current: int} / {total: int}} (other) {Saving documents... {current: int} / {total: int}}'
	String saving({required int total, required int current}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(total,
		one: 'Saving document... ${current} / ${total}',
		other: 'Saving documents... ${current} / ${total}',
	);

	/// en: '(one) {Document saved successfully.} (other) {Documents saved successfully.}'
	String done({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: 'Document saved successfully.',
		other: 'Documents saved successfully.',
	);

	/// en: '(one) {Failed to save document.} (other) {Failed to save documents.}'
	String failed({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: 'Failed to save document.',
		other: 'Failed to save documents.',
	);
}

// Path: settings.main.model.actions
class Translations$settings$main$model$actions$en {
	Translations$settings$main$model$actions$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Download'
	String get download => 'Download';

	/// en: 'Resume'
	String get resume => 'Resume';

	/// en: 'Try again'
	String get retry => 'Try again';

	/// en: 'Cancel'
	String get cancel => 'Cancel';
}

// Path: settings.main.model.status
class Translations$settings$main$model$status$en {
	Translations$settings$main$model$status$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Ready to use'
	String get ready => 'Ready to use';

	/// en: 'Waiting for Wi-Fi...'
	String get waitingForWifi => 'Waiting for Wi-Fi...';

	/// en: 'Downloading... {progress: int}%'
	String downloading({required int progress}) => 'Downloading... ${progress}%';

	/// en: 'Verifying files integrity...'
	String get verifying => 'Verifying files integrity...';
}

// Path: settings.main.model.alerts
class Translations$settings$main$model$alerts$en {
	Translations$settings$main$model$alerts$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$settings$main$model$alerts$missing$en missing = Translations$settings$main$model$alerts$missing$en._(_root);
	late final Translations$settings$main$model$alerts$partial$en partial = Translations$settings$main$model$alerts$partial$en._(_root);
}

// Path: settings.main.model.errors
class Translations$settings$main$model$errors$en {
	Translations$settings$main$model$errors$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Not enough storage space. You need at least {size: String} free to download this model.'
	String notEnoughStorage({required String size}) => 'Not enough storage space. You need at least ${size} free to download this model.';

	/// en: 'No internet connection. Connect and try again.'
	String get noConnection => 'No internet connection. Connect and try again.';

	/// en: 'Couldn't reach the download server. Please try again later.'
	String get serverUnreachable => 'Couldn\'t reach the download server. Please try again later.';

	/// en: 'The downloaded files are damaged. Downloading them again.'
	String get corrupted => 'The downloaded files are damaged. Downloading them again.';

	/// en: 'The download failed. Check your connection and try again.'
	String get downloadFailed => 'The download failed. Check your connection and try again.';

	/// en: 'Couldn't resume the download. Starting over from the beginning.'
	String get resumeFailed => 'Couldn\'t resume the download. Starting over from the beginning.';
}

// Path: settings.main.model.size
class Translations$settings$main$model$size$en {
	Translations$settings$main$model$size$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Download size: {size: String}'
	String label({required String size}) => 'Download size: ${size}';

	/// en: 'Download size unavailable'
	String get unavailable => 'Download size unavailable';

	late final Translations$settings$main$model$size$actions$en actions = Translations$settings$main$model$size$actions$en._(_root);
}

// Path: settings.main.model.dialogs
class Translations$settings$main$model$dialogs$en {
	Translations$settings$main$model$dialogs$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$settings$main$model$dialogs$required$en required = Translations$settings$main$model$dialogs$required$en._(_root);
	late final Translations$settings$main$model$dialogs$size$en size = Translations$settings$main$model$dialogs$size$en._(_root);
}

// Path: settings.main.downloads.fields
class Translations$settings$main$downloads$fields$en {
	Translations$settings$main$downloads$fields$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$settings$main$downloads$fields$wifiOnly$en wifiOnly = Translations$settings$main$downloads$fields$wifiOnly$en._(_root);
}

// Path: settings.main.notifications.download
class Translations$settings$main$notifications$download$en {
	Translations$settings$main$notifications$download$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Downloading transcription model'
	String get title => 'Downloading transcription model';

	late final Translations$settings$main$notifications$download$status$en status = Translations$settings$main$notifications$download$status$en._(_root);
}

// Path: docs.scan.dialogs.discard.actions
class Translations$docs$scan$dialogs$discard$actions$en {
	Translations$docs$scan$dialogs$discard$actions$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Exit & Discard'
	String get confirm => 'Exit & Discard';

	/// en: 'Save & Exit'
	String get save => 'Save & Exit';
}

// Path: docs.scan.preview.fields.docName
class Translations$docs$scan$preview$fields$docName$en {
	Translations$docs$scan$preview$fields$docName$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Document Name'
	String get label => 'Document Name';

	/// en: 'Enter Document Name'
	String get placeholder => 'Enter Document Name';

	late final Translations$docs$scan$preview$fields$docName$errors$en errors = Translations$docs$scan$preview$fields$docName$errors$en._(_root);
}

// Path: docs.scan.preview.bottomBar.actions
class Translations$docs$scan$preview$bottomBar$actions$en {
	Translations$docs$scan$preview$bottomBar$actions$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Show Group ({count: int})'
	String showGroup({required int count}) => 'Show Group (${count})';
}

// Path: docs.scan.preview.bottomBar.tooltips
class Translations$docs$scan$preview$bottomBar$tooltips$en {
	Translations$docs$scan$preview$bottomBar$tooltips$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Scan more documents.'
	String get add => 'Scan more documents.';

	/// en: 'Delete current document.'
	String get delete => 'Delete current document.';

	/// en: 'Show all documents.'
	String get group => 'Show all documents.';
}

// Path: docs.scan.preview.bottomSheet.fields
class Translations$docs$scan$preview$bottomSheet$fields$en {
	Translations$docs$scan$preview$bottomSheet$fields$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$docs$scan$preview$bottomSheet$fields$groupName$en groupName = Translations$docs$scan$preview$bottomSheet$fields$groupName$en._(_root);
}

// Path: settings.main.model.alerts.missing
class Translations$settings$main$model$alerts$missing$en {
	Translations$settings$main$model$alerts$missing$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Model not downloaded'
	String get title => 'Model not downloaded';

	/// en: 'Download this model to transcribe your pages. It's a one-time download.'
	String get message => 'Download this model to transcribe your pages. It\'s a one-time download.';
}

// Path: settings.main.model.alerts.partial
class Translations$settings$main$model$alerts$partial$en {
	Translations$settings$main$model$alerts$partial$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Download incomplete'
	String get title => 'Download incomplete';

	/// en: 'A previous download didn't finish. Resume to continue where it left off.'
	String get message => 'A previous download didn\'t finish. Resume to continue where it left off.';
}

// Path: settings.main.model.size.actions
class Translations$settings$main$model$size$actions$en {
	Translations$settings$main$model$size$actions$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'More info'
	String get moreInfo => 'More info';
}

// Path: settings.main.model.dialogs.required
class Translations$settings$main$model$dialogs$required$en {
	Translations$settings$main$model$dialogs$required$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Download needed'
	String get title => 'Download needed';

	/// en: 'This model needs a one-time download before you can transcribe pages. You can leave the app while it downloads. Progress will show in a notification.'
	String get message => 'This model needs a one-time download before you can transcribe pages. You can leave the app while it downloads. Progress will show in a notification.';
}

// Path: settings.main.model.dialogs.size
class Translations$settings$main$model$dialogs$size$en {
	Translations$settings$main$model$dialogs$size$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Download size'
	String get title => 'Download size';

	/// en: 'Total size: {size: String}'
	String total({required String size}) => 'Total size: ${size}';

	/// en: '(one) {{n} file} (other) {{n} files}'
	String fileCount({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: '${n} file',
		other: '${n} files',
	);
}

// Path: settings.main.downloads.fields.wifiOnly
class Translations$settings$main$downloads$fields$wifiOnly$en {
	Translations$settings$main$downloads$fields$wifiOnly$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Use Wi-Fi for large downloads'
	String get label => 'Use Wi-Fi for large downloads';

	/// en: 'Large downloads wait for Wi-Fi instead of using mobile data.'
	String get description => 'Large downloads wait for Wi-Fi instead of using mobile data.';
}

// Path: settings.main.notifications.download.status
class Translations$settings$main$notifications$download$status$en {
	Translations$settings$main$notifications$download$status$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Downloading... {progress: int}%'
	String downloading({required int progress}) => _root.settings.main.model.status.downloading(progress: progress);

	/// en: 'Waiting for Wi-Fi...'
	String get waitingForWifi => _root.settings.main.model.status.waitingForWifi;

	/// en: 'Verifying files integrity...'
	String get verifying => _root.settings.main.model.status.verifying;

	/// en: 'Model ready to use'
	String get done => 'Model ready to use';

	/// en: 'Download failed'
	String get failed => 'Download failed';
}

// Path: docs.scan.preview.fields.docName.errors
class Translations$docs$scan$preview$fields$docName$errors$en {
	Translations$docs$scan$preview$fields$docName$errors$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Document name cannot be empty.'
	String get empty => 'Document name cannot be empty.';
}

// Path: docs.scan.preview.bottomSheet.fields.groupName
class Translations$docs$scan$preview$bottomSheet$fields$groupName$en {
	Translations$docs$scan$preview$bottomSheet$fields$groupName$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Group Name'
	String get label => 'Group Name';

	/// en: 'Enter Group Name'
	String get placeholder => 'Enter Group Name';

	late final Translations$docs$scan$preview$bottomSheet$fields$groupName$errors$en errors = Translations$docs$scan$preview$bottomSheet$fields$groupName$errors$en._(_root);
}

// Path: docs.scan.preview.bottomSheet.fields.groupName.errors
class Translations$docs$scan$preview$bottomSheet$fields$groupName$errors$en {
	Translations$docs$scan$preview$bottomSheet$fields$groupName$errors$en._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Group name cannot be empty.'
	String get empty => 'Group name cannot be empty.';
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
			'common.navigation.docs' => 'Documents',
			'common.navigation.learn' => 'Learn',
			'common.navigation.settings' => 'Settings',
			'common.actions.confirm' => 'Confirm',
			'common.actions.cancel' => 'Cancel',
			'common.actions.retry' => 'Try again',
			'common.actions.close' => 'Close',
			'common.actions.proceed' => 'Proceed',
			'common.actions.done' => 'Done',
			'common.actions.hide' => 'Hide',
			'common.actions.keep' => 'Keep',
			'common.actions.delete' => 'Delete',
			'common.status.success' => 'Successful operation',
			'common.status.failed' => 'Something went wrong',
			'common.status.preparing' => 'Preparing... please wait',
			'common.status.finishing' => 'Finishing up...',
			'common.status.processing' => ({required int count, required int total}) => 'Processing... ${count} / ${total}',
			'common.status.loading' => 'Loading...',
			'common.selection.tooltips.close' => 'Cancel selection',
			'common.selection.tooltips.deleteInactive' => 'Select items to delete.',
			'common.selection.tooltips.deleteActive' => 'Delete selected items.',
			'common.selection.tooltips.selectAll' => 'Select all items.',
			'common.selection.tooltips.deselectAll' => 'Deselect all items.',
			'common.selection.semantics.select' => 'Select this tile',
			'common.selection.semantics.deselect' => 'Deselect this tile',
			'common.selection.semantics.startSelecting' => 'You have entered selection mode. This tile has been selected. Please select or deselect other tiles.',
			'common.selection.status.selected' => ({required int count, required int total}) => '${count} / ${total} selected',
			'common.selection.dialogs.delete.title' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, one: 'Deleting ${n} document', other: 'Deleting ${n} documents', ), 
			'common.selection.dialogs.delete.message' => 'Are you sure you want to continue?',
			'docs.main.title' => _root.common.navigation.docs,
			'docs.main.actions.scan' => 'Scan a document',
			'docs.main.status.documentCount' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, zero: 'No documents', one: '${n} document', other: '${n} documents', ), 
			'docs.main.empty.message' => 'No documents found. Tap the button below to scan a document.',
			'docs.main.errors.snapshot' => ({required Object error}) => 'Snapshot error: ${error}',
			'docs.detail.actions.edit' => 'Edit Group',
			'docs.detail.tooltips.edit' => 'Edit this document group',
			'docs.detail.empty.message' => 'No documents found in this group.',
			'docs.scan.title' => 'Scan Document',
			'docs.scan.empty.message' => 'No documents captured.',
			'docs.scan.empty.action' => 'Scan new documents',
			'docs.scan.dialogs.discard.title' => 'Exiting Document Scanner',
			'docs.scan.dialogs.discard.message' => 'Unsaved documents are about to be discarded. Are you sure you want to continue? You can save them before exiting.',
			'docs.scan.dialogs.discard.actions.confirm' => 'Exit & Discard',
			'docs.scan.dialogs.discard.actions.save' => 'Save & Exit',
			'docs.scan.preview.title' => ({required int current, required int total}) => '${current} / ${total}',
			'docs.scan.preview.actions.add' => 'Scan More',
			'docs.scan.preview.actions.save' => 'Save',
			'docs.scan.preview.fields.docName.label' => 'Document Name',
			'docs.scan.preview.fields.docName.placeholder' => 'Enter Document Name',
			'docs.scan.preview.fields.docName.errors.empty' => 'Document name cannot be empty.',
			'docs.scan.preview.empty.title' => 'Scanned Documents',
			'docs.scan.preview.bottomBar.actions.showGroup' => ({required int count}) => 'Show Group (${count})',
			'docs.scan.preview.bottomBar.tooltips.add' => 'Scan more documents.',
			'docs.scan.preview.bottomBar.tooltips.delete' => 'Delete current document.',
			'docs.scan.preview.bottomBar.tooltips.group' => 'Show all documents.',
			'docs.scan.preview.bottomSheet.title' => 'Group Details',
			'docs.scan.preview.bottomSheet.fields.groupName.label' => 'Group Name',
			'docs.scan.preview.bottomSheet.fields.groupName.placeholder' => 'Enter Group Name',
			'docs.scan.preview.bottomSheet.fields.groupName.errors.empty' => 'Group name cannot be empty.',
			'docs.scan.save.actions.back' => 'Proceed to Exit',
			'docs.scan.save.actions.close' => 'Okay',
			'docs.scan.save.actions.retry' => 'Try to Save Again',
			'docs.scan.save.status.preparing' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, one: 'Preparing to save document...', other: 'Preparing to save documents...', ), 
			'docs.scan.save.status.saving' => ({required int total, required int current}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(total, one: 'Saving document... ${current} / ${total}', other: 'Saving documents... ${current} / ${total}', ), 
			'docs.scan.save.status.done' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, one: 'Document saved successfully.', other: 'Documents saved successfully.', ), 
			'docs.scan.save.status.failed' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, one: 'Failed to save document.', other: 'Failed to save documents.', ), 
			'docs.transcription.actions.view' => 'View transcription',
			'docs.transcription.actions.viewImage' => 'View scanned image',
			'docs.transcription.actions.retranscribe' => 'Re-transcribe page',
			'docs.transcription.actions.start' => 'Transcribe Page',
			'docs.transcription.status.queued' => 'Waiting in transcription queue...',
			'docs.transcription.status.streaming' => 'Transcribing page...',
			'docs.transcription.empty.title' => 'No Transcription Yet',
			'docs.transcription.empty.message' => 'Transcribe this scanned page offline into editable Markdown.',
			'docs.transcription.stats' => ({required int words, required int seconds}) => '${words} words · ~${seconds}s read',
			'learn.main.title' => _root.common.navigation.learn,
			'settings.main.title' => _root.common.navigation.settings,
			'settings.main.model.title' => 'Transcription Model',
			'settings.main.model.description' => 'Choose the model used to transcribe your scanned pages on this device.',
			'settings.main.model.actions.download' => 'Download',
			'settings.main.model.actions.resume' => 'Resume',
			'settings.main.model.actions.retry' => 'Try again',
			'settings.main.model.actions.cancel' => 'Cancel',
			'settings.main.model.status.ready' => 'Ready to use',
			'settings.main.model.status.waitingForWifi' => 'Waiting for Wi-Fi...',
			'settings.main.model.status.downloading' => ({required int progress}) => 'Downloading... ${progress}%',
			'settings.main.model.status.verifying' => 'Verifying files integrity...',
			'settings.main.model.alerts.missing.title' => 'Model not downloaded',
			'settings.main.model.alerts.missing.message' => 'Download this model to transcribe your pages. It\'s a one-time download.',
			'settings.main.model.alerts.partial.title' => 'Download incomplete',
			'settings.main.model.alerts.partial.message' => 'A previous download didn\'t finish. Resume to continue where it left off.',
			'settings.main.model.errors.notEnoughStorage' => ({required String size}) => 'Not enough storage space. You need at least ${size} free to download this model.',
			'settings.main.model.errors.noConnection' => 'No internet connection. Connect and try again.',
			'settings.main.model.errors.serverUnreachable' => 'Couldn\'t reach the download server. Please try again later.',
			'settings.main.model.errors.corrupted' => 'The downloaded files are damaged. Downloading them again.',
			'settings.main.model.errors.downloadFailed' => 'The download failed. Check your connection and try again.',
			'settings.main.model.errors.resumeFailed' => 'Couldn\'t resume the download. Starting over from the beginning.',
			'settings.main.model.size.label' => ({required String size}) => 'Download size: ${size}',
			'settings.main.model.size.unavailable' => 'Download size unavailable',
			'settings.main.model.size.actions.moreInfo' => 'More info',
			'settings.main.model.dialogs.required.title' => 'Download needed',
			'settings.main.model.dialogs.required.message' => 'This model needs a one-time download before you can transcribe pages. You can leave the app while it downloads. Progress will show in a notification.',
			'settings.main.model.dialogs.size.title' => 'Download size',
			'settings.main.model.dialogs.size.total' => ({required String size}) => 'Total size: ${size}',
			'settings.main.model.dialogs.size.fileCount' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n, one: '${n} file', other: '${n} files', ), 
			'settings.main.downloads.fields.wifiOnly.label' => 'Use Wi-Fi for large downloads',
			'settings.main.downloads.fields.wifiOnly.description' => 'Large downloads wait for Wi-Fi instead of using mobile data.',
			'settings.main.notifications.download.title' => 'Downloading transcription model',
			'settings.main.notifications.download.status.downloading' => ({required int progress}) => _root.settings.main.model.status.downloading(progress: progress),
			'settings.main.notifications.download.status.waitingForWifi' => _root.settings.main.model.status.waitingForWifi,
			'settings.main.notifications.download.status.verifying' => _root.settings.main.model.status.verifying,
			'settings.main.notifications.download.status.done' => 'Model ready to use',
			'settings.main.notifications.download.status.failed' => 'Download failed',
			_ => null,
		};
	}
}
