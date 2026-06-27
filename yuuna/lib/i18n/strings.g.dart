/// Generated file. Do not edit.
///
/// Locales: 2
/// Strings: 796 (398 per locale)
///
/// Built on 2026-06-26 at 22:52 UTC

// coverage:ignore-file
// ignore_for_file: type=lint

import 'package:flutter/widgets.dart';
import 'package:slang/builder/model/node.dart';
import 'package:slang_flutter/slang_flutter.dart';
export 'package:slang_flutter/slang_flutter.dart';

const AppLocale _baseLocale = AppLocale.en;

/// Supported locales, see extension methods below.
///
/// Usage:
/// - LocaleSettings.setLocale(AppLocale.en) // set locale
/// - Locale locale = AppLocale.en.flutterLocale // get flutter locale from enum
/// - if (LocaleSettings.currentLocale == AppLocale.en) // locale check
enum AppLocale with BaseAppLocale<AppLocale, _StringsEn> {
	en(languageCode: 'en', build: _StringsEn.build),
	ptBr(languageCode: 'pt', countryCode: 'BR', build: _StringsPtBr.build);

	const AppLocale({required this.languageCode, this.scriptCode, this.countryCode, required this.build}); // ignore: unused_element

	@override final String languageCode;
	@override final String? scriptCode;
	@override final String? countryCode;
	@override final TranslationBuilder<AppLocale, _StringsEn> build;

	/// Gets current instance managed by [LocaleSettings].
	_StringsEn get translations => LocaleSettings.instance.translationMap[this]!;
}

/// Method A: Simple
///
/// No rebuild after locale change.
/// Translation happens during initialization of the widget (call of t).
/// Configurable via 'translate_var'.
///
/// Usage:
/// String a = t.someKey.anotherKey;
/// String b = t['someKey.anotherKey']; // Only for edge cases!
_StringsEn get t => LocaleSettings.instance.currentTranslations;

/// Method B: Advanced
///
/// All widgets using this method will trigger a rebuild when locale changes.
/// Use this if you have e.g. a settings page where the user can select the locale during runtime.
///
/// Step 1:
/// wrap your App with
/// TranslationProvider(
/// 	child: MyApp()
/// );
///
/// Step 2:
/// final t = Translations.of(context); // Get t variable.
/// String a = t.someKey.anotherKey; // Use t variable.
/// String b = t['someKey.anotherKey']; // Only for edge cases!
class Translations {
	Translations._(); // no constructor

	static _StringsEn of(BuildContext context) => InheritedLocaleData.of<AppLocale, _StringsEn>(context).translations;
}

/// The provider for method B
class TranslationProvider extends BaseTranslationProvider<AppLocale, _StringsEn> {
	TranslationProvider({required super.child}) : super(settings: LocaleSettings.instance);

	static InheritedLocaleData<AppLocale, _StringsEn> of(BuildContext context) => InheritedLocaleData.of<AppLocale, _StringsEn>(context);
}

/// Method B shorthand via [BuildContext] extension method.
/// Configurable via 'translate_var'.
///
/// Usage (e.g. in a widget's build method):
/// context.t.someKey.anotherKey
extension BuildContextTranslationsExtension on BuildContext {
	_StringsEn get t => TranslationProvider.of(this).translations;
}

/// Manages all translation instances and the current locale
class LocaleSettings extends BaseFlutterLocaleSettings<AppLocale, _StringsEn> {
	LocaleSettings._() : super(utils: AppLocaleUtils.instance);

	static final instance = LocaleSettings._();

	// static aliases (checkout base methods for documentation)
	static AppLocale get currentLocale => instance.currentLocale;
	static Stream<AppLocale> getLocaleStream() => instance.getLocaleStream();
	static AppLocale setLocale(AppLocale locale, {bool? listenToDeviceLocale = false}) => instance.setLocale(locale, listenToDeviceLocale: listenToDeviceLocale);
	static AppLocale setLocaleRaw(String rawLocale, {bool? listenToDeviceLocale = false}) => instance.setLocaleRaw(rawLocale, listenToDeviceLocale: listenToDeviceLocale);
	static AppLocale useDeviceLocale() => instance.useDeviceLocale();
	@Deprecated('Use [AppLocaleUtils.supportedLocales]') static List<Locale> get supportedLocales => instance.supportedLocales;
	@Deprecated('Use [AppLocaleUtils.supportedLocalesRaw]') static List<String> get supportedLocalesRaw => instance.supportedLocalesRaw;
	static void setPluralResolver({String? language, AppLocale? locale, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver}) => instance.setPluralResolver(
		language: language,
		locale: locale,
		cardinalResolver: cardinalResolver,
		ordinalResolver: ordinalResolver,
	);
}

/// Provides utility functions without any side effects.
class AppLocaleUtils extends BaseAppLocaleUtils<AppLocale, _StringsEn> {
	AppLocaleUtils._() : super(baseLocale: _baseLocale, locales: AppLocale.values);

	static final instance = AppLocaleUtils._();

	// static aliases (checkout base methods for documentation)
	static AppLocale parse(String rawLocale) => instance.parse(rawLocale);
	static AppLocale parseLocaleParts({required String languageCode, String? scriptCode, String? countryCode}) => instance.parseLocaleParts(languageCode: languageCode, scriptCode: scriptCode, countryCode: countryCode);
	static AppLocale findDeviceLocale() => instance.findDeviceLocale();
	static List<Locale> get supportedLocales => instance.supportedLocales;
	static List<String> get supportedLocalesRaw => instance.supportedLocalesRaw;
}

// translations

// Path: <root>
class _StringsEn implements BaseTranslations<AppLocale, _StringsEn> {

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	_StringsEn.build({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, _StringsEn> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final _StringsEn _root = this; // ignore: unused_field

	// Translations
	String get dictionary_media_type => 'Dictionary';
	String get player_media_type => 'Player';
	String get reader_media_type => 'Reader';
	String get viewer_media_type => 'Viewer';
	String get jellyfin_media_type => 'Jellyfin';
	String get back => 'Back';
	String get search => 'Search';
	String get search_ellipsis => 'Search...';
	String get show_more => 'Show More';
	String get show_menu => 'Show Menu';
	String get stash => 'Stash';
	String get pick_image => 'Pick Image';
	String get undo => 'Undo';
	String get copy => 'Copy';
	String get clear => 'Clear';
	String get creator => 'Creator';
	String get share => 'Share';
	String get resume_last_media => 'Resume Last Media';
	String get change_source => 'Change Source';
	String get launch_source => 'Launch Source';
	String get card_creator => 'Card Creator';
	String get target_language => 'Target language';
	String get show_options => 'Show Options';
	String get switch_profiles => 'Switch Profiles';
	String get dictionaries => 'Dictionaries';
	String get enhancements => 'Enhancements';
	String get app_locale => 'App locale';
	String get app_locale_warning => 'Community addons and enhancements are managed by their respective developers, and these may appear in their original language.';
	String get dialog_play => 'PLAY';
	String get dialog_read => 'READ';
	String get dialog_view => 'VIEW';
	String get dialog_edit => 'EDIT';
	String get dialog_export => 'EXPORT';
	String get dialog_import => 'IMPORT';
	String get dialog_close => 'CLOSE';
	String get dialog_clear => 'CLEAR';
	String get dialog_create => 'CREATE';
	String get dialog_delete => 'DELETE';
	String get dialog_cancel => 'CANCEL';
	String get dialog_select => 'SELECT';
	String get dialog_stash => 'STASH';
	String get dialog_search => 'SEARCH';
	String get dialog_exit => 'EXIT';
	String get dialog_share => 'SHARE';
	String get dialog_pop => 'POP';
	String get dialog_save => 'SAVE';
	String get dialog_set => 'SET';
	String get dialog_browse => 'BROWSE';
	String get dialog_channel => 'CHANNEL';
	String get dialog_directory => 'DIRECTORY';
	String get dialog_crop => 'CROP';
	String get dialog_connect => 'CONNECT';
	String get dialog_append => 'APPEND';
	String get dialog_record => 'RECORD';
	String get dialog_manage => 'MANAGE';
	String get dialog_stop => 'STOP';
	String get dialog_done => 'DONE';
	String get reset => 'Reset';
	String get dialog_launch_ankidroid => 'LAUNCH ANKIDROID';
	String get media_item_delete_confirmation => 'This will clear this item from history. Are you sure you want to do this?';
	String get dictionaries_delete_confirmation => 'Deleting a dictionary will also clear all dictionary results from history. Are you sure you want to do this?';
	String get mappings_delete_confirmation => 'This profile will be deleted. Are you sure you want to do this?';
	String get catalog_delete_confirmation => 'This catalog will be deleted. Are you sure you want to do this?';
	String get dictionaries_deleting_data => 'Deleting dictionary data...';
	String get dictionaries_menu_empty => 'Import a dictionary for use';
	String get options_theme_light => 'Use light theme';
	String get options_theme_dark => 'Use dark theme';
	String get options_incognito_on => 'Turn on incognito mode';
	String get options_incognito_off => 'Turn off incognito mode';
	String get options_dictionaries => 'Manage dictionaries';
	String get options_profiles => 'Export profiles';
	String get options_enhancements => 'User enhancements';
	String get options_language => 'Language settings';
	String get options_github => 'View repository on GitHub';
	String get options_attribution => 'Licenses and attribution';
	String get options_copy => 'Copy';
	String get options_collapse => 'Collapse';
	String get options_expand => 'Expand';
	String get options_delete => 'Delete';
	String get options_show => 'Show';
	String get options_hide => 'Hide';
	String get options_edit => 'Edit';
	String get info_empty_home_tab => 'History is empty';
	String get delete_in_progress => 'Delete in progress';
	String get import_format => 'Import format';
	String get import_in_progress => 'Import in progress';
	String get import_start => 'Preparing for import...';
	String get import_clean => 'Cleaning working space...';
	String import_extract_count({required Object n}) => 'Extracted ${n} files...';
	String get import_extract => 'Extracting files...';
	String import_name({required Object name}) => 'Importing 『${name}』...';
	String get import_entries => 'Processing entries...';
	String import_found_entry({required Object count}) => 'Found ${count} entries...';
	String import_found_tag({required Object count}) => 'Found ${count} tags...';
	String import_found_frequency({required Object count}) => 'Found ${count} frequency entries...';
	String import_found_pitch({required Object count}) => 'Found ${count} pitch accent entries...';
	String import_write_entry({required Object count, required Object total}) => 'Writing entries:\n${count} / ${total}';
	String import_write_tag({required Object count, required Object total}) => 'Writing tags:\n${count} / ${total}';
	String import_write_frequency({required Object count, required Object total}) => 'Writing frequency entries:\n${count} / ${total}';
	String import_write_pitch({required Object count, required Object total}) => 'Writing pitch accent entries:\n${count} / ${total}';
	String get import_failed => 'Dictionary import failed.';
	String get import_complete => 'Dictionary import complete.';
	String import_duplicate({required Object name}) => 'A dictionary with the name『${name}』is already imported.';
	String get dialog_title_dictionary_clear => 'Clear all dictionaries?';
	String get dialog_content_dictionary_clear => 'Wiping the dictionary database will also clear all search results in history.';
	String dialog_title_dictionary_delete({required Object name}) => 'Delete 『${name}』?';
	String get dialog_content_dictionary_delete => 'Deleting a single dictionary may take longer than clearing the entire dictionary database. This will also clear all search results in history.';
	String get delete_dictionary_data => 'Clearing all dictionary data...';
	String dictionary_tag({required Object name}) => 'Imported from ${name}';
	String get legalese => 'A full-featured immersion language learning suite for mobile.\n\nOriginally built for the Japanese language learning community by Arianne Orpilla. Logo by suzy and Aaron Marbella.\n\njidoujisho is free and open source software. See the project repository for a comprehensive list of other licenses and attribution notices. Enjoying the application? Help out by providing feedback, making a donation, reporting issues or contributing improvements on GitHub.';
	String get same_name_dictionary_found => 'Dictionary with same name found.';
	String import_file_extension_invalid({required Object extensions}) => 'This format expects files with the following extensions: ${extensions}';
	String get field_label_empty => 'Empty';
	String get model_to_map => 'Card type to use for new profile';
	String get mapping_name => 'Profile name';
	String get mapping_name_hint => 'Name to assign to profile';
	String get error_profile_name => 'Invalid profile name';
	String get error_profile_name_content => 'A profile with this name already exists or is not valid and cannot be saved.';
	String get error_standard_profile_name => 'Invalid profile name';
	String get error_standard_profile_name_content => 'Cannot rename the standard profile.';
	String get error_ankidroid_api => 'AnkiDroid error';
	String get error_ankidroid_api_content => 'There was an issue communicating with AnkiDroid.\n\nEnsure that the AnkiDroid background service is active and all relevant app permissions are granted in order to continue.';
	String get info_standard_model => 'Standard card type added';
	String get info_standard_model_content => '『jidoujisho Kinomoto』 has been added to AnkiDroid as a new card type.\n\nSetups making use of a different card type or field order may be used by adding a new export profile.';
	String get error_model_missing => 'Missing card type';
	String get error_model_missing_content => 'The corresponding card type of the currently selected profile is missing.\n\nThe profile will be deleted, and the standard profile has now been selected in its place.';
	String get error_model_changed => 'Card type changed';
	String get error_model_changed_content => 'The number of fields of the card type corresponding to the selected profile has changed.\n\nThe fields of the currently selected profile have been reset and will require reconfiguration.';
	String get creator_exporting_as => 'Creating card with profile';
	String get creator_exporting_as_fields_editing => 'Editing fields for profile';
	String get creator_exporting_as_enhancements_editing => 'Editing enhancements for profile';
	String get creator_export_card => 'Create Card';
	String get info_enhancements => 'Enhancements enable the automation of field editing prior to card creation. Pick a slot on the right of a field to allow use of an enhancement. Up to five right slots may be utilised for each field. The enhancement in the left slot of a field will be automatically applied in instant card creation or upon launch of the Card Creator.';
	String get info_actions => 'Quick actions allow for instant card creation and other automations to be used on dictionary search results. Actions can be assigned via the slots below. Up to six slots may be utilised.';
	String get no_more_available_enhancements => 'No more available enhancements for this field';
	String get no_more_available_quick_actions => 'No more available quick actions';
	String get assign_auto_enhancement => 'Assign Auto Enhancement';
	String get assign_manual_enhancement => 'Assign Manual Enhancement';
	String get remove_enhancement => 'Remove Enhancement';
	String copy_of_mapping({required Object name}) => 'Copy of ${name}';
	String get enter_search_term => 'Enter a search term...';
	String searching_for({required Object searchTerm}) => 'Searching for 『${searchTerm}』...';
	String get no_search_results => 'No search results found.';
	String get edit_actions => 'Edit Dictionary Quick Actions';
	String get remove_action => 'Remove Action';
	String get assign_action => 'Assign Action';
	String dictionary_import_tag({required Object name}) => 'Imported from ${name}';
	String stash_added_single({required Object term}) => '『${term}』has been added to the Stash.';
	String get stash_added_multiple => 'Multiple items have been added to the Stash.';
	String stash_clear_single({required Object term}) => '『${term}』has been removed from the Stash.';
	String get stash_clear_title => 'Clear Stash';
	String get stash_clear_description => 'All contents will be cleared. Are you sure?';
	String get stash_placeholder => 'No items in the Stash';
	String get stash_nothing_to_pop => 'No items to be popped from the Stash.';
	String get no_sentences_found => 'No sentences found';
	String get failed_online_service => 'Failed to communicate with online service';
	String get search_label_before => 'Show all ';
	String get search_label_middle => 'out of ';
	String get search_label_after => 'search results found for';
	String get clear_dictionary_title => 'Clear Dictionary Result History';
	String get clear_dictionary_description => 'This will clear all dictionary results from history. Are you sure?';
	String get clear_search_title => 'Clear Search History';
	String get clear_search_description => 'This will clear all search terms for this history. Are you sure?';
	String get clear_creator_title => 'Clear Creator';
	String get clear_creator_description => 'This will clear all fields. Are you sure?';
	String get copied_to_clipboard => 'Copied to clipboard.';
	String get no_text => 'No text.';
	String get info_fields => 'Fields are pre-filled based on the term selected on instant export or prior to opening the Card Creator. In order to include a field for card export, it must be enabled below as well as mapped in the current selected export profile. Enabled fields may also be collapsed below in order to reduce clutter during editing. Use the Clear button on the top-right of the Card Creator in order to wipe these hidden fields quickly when manually editing a card.';
	String get edit_fields => 'Edit and Reorder Fields';
	String get remove_field => 'Remove Field';
	String get add_field => 'Assign Field';
	String get add_field_hint => 'Assign a field to this row';
	String get no_more_available_fields => 'No more available fields';
	String get hidden_fields => 'Additional fields';
	String field_fallback_used({required Object field, required Object secondField}) => 'The ${field} field used ${secondField} as its fallback search term.';
	String get no_text_to_search => 'No text to search.';
	String get image_search_label_before => 'Selecting image ';
	String get image_search_label_middle => 'out of ';
	String get image_search_label_after => 'found for';
	String get image_search_label_none_middle => 'no image ';
	String get image_search_label_none_before => 'Selecting ';
	String get preparing_instant_export => 'Preparing card for export...';
	String get processing_in_progress => 'Preparing images';
	String get searching_in_progress => 'Searching for ';
	String get audio_unavailable => 'No audio could be found.';
	String get no_audio_enhancements => 'No audio enhancements are assigned.';
	String card_exported({required Object deck}) => 'Card exported to 『${deck}』.';
	String get info_incognito_on => 'Incognito mode on. Dictionary, media and search history will not be tracked.';
	String get info_incognito_off => 'Incognito mode off. Dictionary, media and search history will be tracked.';
	String get exit_media_title => 'Exit Media';
	String get exit_media_description => 'This will return you to the main menu. Are you sure?';
	String get unimplemented_source => 'Unimplemented source';
	String get clear_browser_title => 'Clear Browser Data';
	String get clear_browser_description => 'This will clear all browsing data used in media sources that use web content. Are you sure?';
	String get ttu_no_books_added => 'No books added to ッツ Ebook Reader';
	String get local_media_directory_empty => 'Directory has no folders or video';
	String get pick_video_file => 'Pick Video File';
	String get navigate_up_one_directory_level => 'Navigate Up One Directory Level';
	String get play => 'Play';
	String get pause => 'Pause';
	String get record => 'Record';
	String get stop => 'Stop';
	String get replay => 'Replay';
	String get audio_subtitles => 'Audio/Subtitles';
	String get player_option_shadowing => 'Shadowing Mode';
	String get player_option_change_mode => 'Change Playback Mode';
	String get player_option_listening_comprehension => 'Listening Comprehension Mode';
	String get player_option_drag_to_select => 'Use Drag to Select Subtitle Selection';
	String get player_option_tap_to_select => 'Use Tap to Select Subtitle Selection';
	String get player_option_dictionary_menu => 'Select Active Dictionary Source';
	String get player_option_cast_video => 'Cast to Display Device';
	String get player_option_share_subtitle => 'Share Current Subtitle';
	String get player_option_export => 'Create Card from Context';
	String get player_option_audio => 'Audio';
	String get player_option_subtitle => 'Subtitle';
	String get player_option_subtitle_external => 'External';
	String get player_option_subtitle_none => 'None';
	String get player_option_select_subtitle => 'Select Subtitle Track';
	String get player_option_select_audio => 'Select Audio Track';
	String get player_option_text_filter => 'Use Regular Expression Filter';
	String get player_option_blur_preferences => 'Blur Widget Preferences';
	String get player_option_blur_use => 'Use Blur Widget';
	String get player_option_blur_radius => 'Blur radius';
	String get player_option_blur_options => 'Set Blur Widget Color and Bluriness';
	String get player_option_blur_reset => 'Reset Blur Widget Size and Position';
	String get player_align_subtitle_transcript => 'Align Subtitle with Transcript';
	String get player_option_subtitle_appearance => 'Subtitle Timing and Appearance';
	String get player_option_load_subtitles => 'Load External Subtitles';
	String get player_option_subtitle_delay => 'Subtitle delay';
	String get player_option_audio_allowance => 'Audio allowance';
	String get player_option_font_name => 'Subtitle font name';
	String get player_option_font_size => 'Subtitle font size';
	String get player_option_regex_filter => 'Regular expression filter';
	String get player_option_subtitle_background_opacity => 'Subtitle background opacity';
	String get player_option_subtitle_background_blur_radius => 'Subtitle background blur radius';
	String get player_option_outline_width => 'Subtitle outline width';
	String get player_option_subtitle_always_above_bottom_bar => 'Always show subtitle above bottom bar area';
	String get player_subtitles_transcript_empty => 'Transcript is empty.';
	String get player_prepare_export => 'Preparing card...';
	String get player_change_player_orientation => 'Change Player Orientation';
	String get no_current_media => 'Play or refresh media for lyrics';
	String get lyrics_permission_required => 'Required permission not granted';
	String get no_lyrics_found => 'No lyrics found';
	String get trending => 'Trending';
	String get caption_filter => 'Filter Closed Captions';
	String get captions_query => 'Querying for captions';
	String get captions_target => 'Target language';
	String get captions_app => 'App language';
	String get captions_other => 'Other language';
	String get captions_closed => 'Closed captioning';
	String get captions_auto => 'Automatic captioning';
	String get captions_unavailable => 'No captioning';
	String get captions_error => 'Error while querying captions';
	String get change_quality => 'Change Quality';
	String get closed_captions_query => 'Querying for captions';
	String get closed_captions_target => 'Target language captions';
	String get closed_captions_app => 'App language captions';
	String get closed_captions_other => 'Other language captions';
	String get closed_captions_unavailable => 'No captions';
	String get closed_captions_error => 'Error while querying captions';
	String get stream_url => 'Stream URL';
	String get default_option => 'Default';
	String get paste => 'Paste';
	String get select_all => 'Select all';
	String get lyrics_title => 'Title';
	String get lyrics_artist => 'Artist';
	String get set_media => 'Set Media';
	String get no_recordings_found => 'No recordings found';
	String get wrap_image_audio => 'Include image/audio HTML tags on export';
	String get server_address => 'Server Address';
	String get no_active_connection => 'No active connection';
	String get failed_server_connection => 'Failed to connect to server';
	String get no_text_received => 'No text received';
	String get text_segmentation => 'Text Segmentation';
	String get connect_disconnect => 'Connect/Disconnect';
	String get clear_text_title => 'Clear Text';
	String get clear_text_description => 'This will clear all received text. Are you sure?';
	String get close_connection_title => 'Close Connection';
	String get close_connection_description => 'This will end the WebSocket connection and clear all received text. Are you sure?';
	String get use_slow_import => 'Slow import (use if failing)';
	String get settings => 'Settings';
	String get manager => 'Manager';
	String get volume_button_page_turning => 'Volume button page turning';
	String get invert_volume_buttons => 'Invert volume buttons';
	String get volume_button_turning_speed => 'Continuous scrolling speed';
	String get extend_page_beyond_navbar => 'Extend page beyond navigation bar';
	String get tweaks => 'Tweaks';
	String get increase => 'Increase';
	String get decrease => 'Decrease';
	String get unit_milliseconds => 'ms';
	String get unit_pixels => 'px';
	String get dictionary_settings => 'Dictionary Settings';
	String get auto_search => 'Auto search';
	String get auto_search_debounce_delay => 'Auto search debounce delay';
	String get dictionary_font_size => 'Dictionary font size';
	String get close_on_export => 'Close on Export';
	String get close_on_export_on => 'The Card Creator will now automatically close upon card export.';
	String get close_on_export_off => 'The Card Creator will no longer close upon card export.';
	String get export_profile_empty => 'Your export profile has no set fields and requires configuration.';
	String get error_export_media_ankidroid => 'There was an error in exporting media to AnkiDroid.';
	String get error_add_note => 'There was an error in adding a note to AnkiDroid.';
	String get first_time_setup => 'First-Time Setup';
	String get first_time_setup_description => 'Welcome to jidoujisho! Set your target language and a default profile will be tailored for you. You can change this later at anytime.';
	String get maximum_entries => 'Maximum dictionary entry query limit';
	String get maximum_terms => 'Maximum dictionary headwords in result';
	String get use_br_tags => 'Use line break tag instead of newline on export';
	String get prepend_dictionary_names => 'Prepend dictionary name in meaning';
	String get highlight_on_tap => 'Highlight text on tap';
	String get no_audio_file => 'No audio file to save.';
	String get storage_permissions => 'Please grant the following permissions for exporting to AnkiDroid.';
	String get stream => 'Stream';
	String get network_subtitles_warning => 'Embedded subtitles are unsupported for network streams.';
	String get accessibility => 'Permission is required to capture text from accessibility events.';
	String get comments => 'Comments';
	String get replies => 'Replies';
	String get no_comments_queried => 'No comments queried';
	String get no_text_in_clipboard => 'No text to display';
	String file_downloaded({required Object name}) => 'File downloaded: ${name}';
	String get cfhange_sort_order => 'Change Sort Order';
	String get login => 'Login';
	String get send => 'Send';
	String get no_messages => 'Start a chat';
	String get enter_message => 'Enter message...';
	String get clear_message_title => 'Clear Messages';
	String get clear_message_description => 'This will clear all messages and start a new chat. Are you sure?';
	String get error_chatgpt_response => 'Request failed or rate-limited. Try again shortly or check your usage limits.';
	String get pick_file => 'Pick File';
	String get open_url => 'Open URL';
	String get catalogs => 'Catalogs';
	String get name => 'Name';
	String get url => 'URL';
	String get duplicate_catalog => 'A catalog with this URL already exists.';
	String get no_catalogs_listed => 'No catalogs listed';
	String get go_back => 'Go Back';
	String get invalid_mokuro_file => 'File is not a Mokuro generated HTML file.';
	String get create_catalog => 'Create Catalog';
	String get adapt_ttu_theme => 'Adapt dictionary popup to theme';
	String get sentence_picker => 'Sentence Picker';
	String field_locked({required Object field}) => '${field} locked and will not clear on export while Creator is active.';
	String field_unlocked({required Object field}) => '${field} unlocked and will clear on export.';
	String get field_lock => 'Lock Field';
	String get field_unlock => 'Unlock Field';
	String get use_dark_theme => 'Use dark theme';
	String get stretch_to_fill_screen => 'Stretch to Fill Screen';
	String get processing_embedded_subtitles => 'Embedded subtitles are processing. Try again later.';
	String get transcript_playback_mode => 'Transcript Playback Mode';
	String get toggle_transcript_background => 'Toggle Transcript Background';
	String get seek => 'Seek';
	String get saved_tags => 'Tags saved.';
	String structured_content_first({required Object i}) => '${i} definitions are unsupported and were omitted.';
	String get structured_content_second => 'Consider a non-structured content version of this dictionary.';
	String get missing_api_key => 'API key not provided';
	String get chatgpt_error => 'There was an error in getting a response from ChatGPT.';
	String get api_key => 'API Key';
	String subtitle_delay_set({required Object ms}) => 'Subtitle delay set to ${ms} ms.';
	String get cancel => 'Cancel';
	String get server_port_in_use => 'Local server port already in use';
	String get google_fonts => 'Google Fonts';
	String get video_show => 'Show video';
	String get video_hide => 'Hide video';
	String get subtitle_timing_show => 'Show subtitle timings';
	String get subtitle_timing_hide => 'Hide subtitle timings';
	String get find_next => 'Find Next';
	String get find_previous => 'Find Previous';
	String get shadowing_mode => 'Shadowing Mode';
	String get display_settings => 'Display Settings';
	String get cloze => 'Cloze';
	String get info_standard_update => 'New standard profile card type';
	String get info_standard_update_content => 'The standard profile now uses the『jidoujisho Kinomoto』 card type.\n\nYour legacy standard profile remains available for backwards compatibility.';
	late final _StringsRetryingInEn retrying_in = _StringsRetryingInEn._(_root);
	late final _StringsViewRepliesEn view_replies = _StringsViewRepliesEn._(_root);
	String get manage_duplicate_checks => 'Manage Duplicate Checks';
	String get playback_normal => 'Normal Playback Mode';
	String get playback_condensed => 'Condensed Playback Mode';
	String get playback_auto_pause => 'Subtitle Pause Playback Mode';
	String get player_hardware_acceleration => 'Hardware acceleration';
	String get player_use_opensles => 'OpenSL ES audio';
	String get go_forward => 'Go Forward';
	String get browse => 'Browse';
	String get bookmark => 'Bookmark';
	String get add_bookmark => 'Add Bookmark';
	String get add_to_reading_list => 'Add To Reading List';
	String get reading_list_empty => 'Reading list is empty';
	String get reading_list_add_toast => 'Added to reading list.';
	String get reading_list_remove_toast => 'Removed from the reading list.';
	String get ad_block_hosts => 'Ad-block hosts';
	String get error_parsing_hosts_file => 'Error parsing hosts file.';
	String get double_tap_seek_duration => 'Double tap seek duration';
	String get player_background_play => 'Background play';
	String get loaded_from_cache => 'Loaded from web archive cache.';
	String get player_show_subtitle_in_notification => 'Show subtitles in media notification';
	String get subtitles_processing => 'Subtitles are processing...';
	String get video_unavailable => 'Video Unavailable';
	String get video_unavailable_content => 'Cannot fetch streams. There may be restrictions in place that prevent watching this video.';
	String get video_file_error => 'Cannot Load File';
	String get video_file_error_content => 'Unable to load the video file. Please ensure this file exists and is located in a directory accessible by the application.';
}

// Path: retrying_in
class _StringsRetryingInEn {
	_StringsRetryingInEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String seconds({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: 'Retrying in ${n} second...',
		other: 'Retrying in ${n} seconds...',
	);
}

// Path: view_replies
class _StringsViewRepliesEn {
	_StringsViewRepliesEn._(this._root);

	final _StringsEn _root; // ignore: unused_field

	// Translations
	String reply({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		one: 'SHOW ${n} REPLY',
		other: 'SHOW ${n} REPLIES',
	);
}

// Path: <root>
class _StringsPtBr implements _StringsEn {

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	_StringsPtBr.build({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = TranslationMetadata(
		    locale: AppLocale.ptBr,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <pt-BR>.
	@override final TranslationMetadata<AppLocale, _StringsEn> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key);

	@override late final _StringsPtBr _root = this; // ignore: unused_field

	// Translations
	@override String get dictionary_media_type => 'Dicionário';
	@override String get player_media_type => 'Player';
	@override String get reader_media_type => 'Leitor';
	@override String get viewer_media_type => 'Visualizador';
	@override String get jellyfin_media_type => 'Jellyfin';
	@override String get back => 'Voltar';
	@override String get search => 'Buscar';
	@override String get search_ellipsis => 'Buscar...';
	@override String get show_more => 'Mostrar Mais';
	@override String get show_menu => 'Mostrar Menu';
	@override String get stash => 'Reservar';
	@override String get pick_image => 'Escolher Imagem';
	@override String get undo => 'Desfazer';
	@override String get copy => 'Copiar';
	@override String get clear => 'Limpar';
	@override String get creator => 'Criador';
	@override String get share => 'Compartilhar';
	@override String get resume_last_media => 'Retomar Última Mídia';
	@override String get change_source => 'Mudar Fonte';
	@override String get launch_source => 'Iniciar Fonte';
	@override String get card_creator => 'Criador de Cards';
	@override String get target_language => 'Idioma alvo';
	@override String get show_options => 'Mostrar Opções';
	@override String get switch_profiles => 'Trocar Perfis';
	@override String get dictionaries => 'Dicionários';
	@override String get enhancements => 'Melhorias';
	@override String get app_locale => 'Idioma do app';
	@override String get app_locale_warning => 'Complementos e melhorias da comunidade são gerenciados por seus respectivos desenvolvedores e podem aparecer no idioma original.';
	@override String get dialog_play => 'REPRODUZIR';
	@override String get dialog_read => 'LER';
	@override String get dialog_view => 'VER';
	@override String get dialog_edit => 'EDITAR';
	@override String get dialog_export => 'EXPORTAR';
	@override String get dialog_import => 'IMPORTAR';
	@override String get dialog_close => 'FECHAR';
	@override String get dialog_clear => 'LIMPAR';
	@override String get dialog_create => 'CRIAR';
	@override String get dialog_delete => 'EXCLUIR';
	@override String get dialog_cancel => 'CANCELAR';
	@override String get dialog_select => 'SELECIONAR';
	@override String get dialog_stash => 'RESERVAR';
	@override String get dialog_search => 'BUSCAR';
	@override String get dialog_exit => 'SAIR';
	@override String get dialog_share => 'COMPARTILHAR';
	@override String get dialog_pop => 'REMOVER';
	@override String get dialog_save => 'SALVAR';
	@override String get dialog_set => 'DEFINIR';
	@override String get dialog_browse => 'NAVEGAR';
	@override String get dialog_channel => 'CANAL';
	@override String get dialog_directory => 'DIRETÓRIO';
	@override String get dialog_crop => 'CORTAR';
	@override String get dialog_connect => 'CONECTAR';
	@override String get dialog_append => 'ANEXAR';
	@override String get dialog_record => 'GRAVAR';
	@override String get dialog_manage => 'GERENCIAR';
	@override String get dialog_stop => 'PARAR';
	@override String get dialog_done => 'CONCLUÍDO';
	@override String get reset => 'Redefinir';
	@override String get dialog_launch_ankidroid => 'ABRIR ANKIDROID';
	@override String get media_item_delete_confirmation => 'Isso removerá este item do histórico. Tem certeza que deseja fazer isso?';
	@override String get dictionaries_delete_confirmation => 'Excluir um dicionário também limpará todos os resultados do histórico. Tem certeza que deseja fazer isso?';
	@override String get mappings_delete_confirmation => 'Este perfil será excluído. Tem certeza que deseja fazer isso?';
	@override String get catalog_delete_confirmation => 'Este catálogo será excluído. Tem certeza que deseja fazer isso?';
	@override String get dictionaries_deleting_data => 'Excluindo dados do dicionário...';
	@override String get dictionaries_menu_empty => 'Importe um dicionário para usar';
	@override String get options_theme_light => 'Usar tema claro';
	@override String get options_theme_dark => 'Usar tema escuro';
	@override String get options_incognito_on => 'Ativar modo anônimo';
	@override String get options_incognito_off => 'Desativar modo anônimo';
	@override String get options_dictionaries => 'Gerenciar dicionários';
	@override String get options_profiles => 'Exportar perfis';
	@override String get options_enhancements => 'Melhorias do usuário';
	@override String get options_language => 'Configurações de idioma';
	@override String get options_github => 'Ver repositório no GitHub';
	@override String get options_attribution => 'Licenças e atribuições';
	@override String get options_copy => 'Copiar';
	@override String get options_collapse => 'Recolher';
	@override String get options_expand => 'Expandir';
	@override String get options_delete => 'Excluir';
	@override String get options_show => 'Mostrar';
	@override String get options_hide => 'Ocultar';
	@override String get options_edit => 'Editar';
	@override String get info_empty_home_tab => 'Histórico vazio';
	@override String get delete_in_progress => 'Exclusão em andamento';
	@override String get import_format => 'Formato de importação';
	@override String get import_in_progress => 'Importação em andamento';
	@override String get import_start => 'Preparando para importar...';
	@override String get import_clean => 'Limpando espaço de trabalho...';
	@override String import_extract_count({required Object n}) => '${n} arquivos extraídos...';
	@override String get import_extract => 'Extraindo arquivos...';
	@override String import_name({required Object name}) => 'Importando 『${name}』...';
	@override String get import_entries => 'Processando entradas...';
	@override String import_found_entry({required Object count}) => '${count} entradas encontradas...';
	@override String import_found_tag({required Object count}) => '${count} tags encontradas...';
	@override String import_found_frequency({required Object count}) => '${count} entradas de frequência encontradas...';
	@override String import_found_pitch({required Object count}) => '${count} entradas de pitch accent encontradas...';
	@override String import_write_entry({required Object count, required Object total}) => 'Escrevendo entradas:\n${count} / ${total}';
	@override String import_write_tag({required Object count, required Object total}) => 'Escrevendo tags:\n${count} / ${total}';
	@override String import_write_frequency({required Object count, required Object total}) => 'Escrevendo entradas de frequência:\n${count} / ${total}';
	@override String import_write_pitch({required Object count, required Object total}) => 'Escrevendo entradas de pitch accent:\n${count} / ${total}';
	@override String get import_failed => 'Falha na importação do dicionário.';
	@override String get import_complete => 'Importação do dicionário concluída.';
	@override String import_duplicate({required Object name}) => 'Um dicionário com o nome『${name}』já está importado.';
	@override String get dialog_title_dictionary_clear => 'Limpar todos os dicionários?';
	@override String get dialog_content_dictionary_clear => 'Limpar o banco de dados de dicionários também excluirá todos os resultados de busca do histórico.';
	@override String dialog_title_dictionary_delete({required Object name}) => 'Excluir 『${name}』?';
	@override String get dialog_content_dictionary_delete => 'Excluir um único dicionário pode levar mais tempo do que limpar todo o banco de dados. Isso também excluirá todos os resultados de busca do histórico.';
	@override String get delete_dictionary_data => 'Limpando todos os dados do dicionário...';
	@override String dictionary_tag({required Object name}) => 'Importado de ${name}';
	@override String get legalese => 'Uma suíte completa de aprendizado de idiomas por imersão para dispositivos móveis.\n\nOriginalmente criado para a comunidade de aprendizado de japonês por Arianne Orpilla. Logo por suzy e Aaron Marbella.\n\njidoujisho é um software livre e de código aberto. Consulte o repositório do projeto para uma lista completa de outras licenças e avisos de atribuição. Gostando do aplicativo? Ajude dando feedback, fazendo uma doação, reportando problemas ou contribuindo com melhorias no GitHub.';
	@override String get same_name_dictionary_found => 'Dicionário com o mesmo nome encontrado.';
	@override String import_file_extension_invalid({required Object extensions}) => 'Este formato espera arquivos com as seguintes extensões: ${extensions}';
	@override String get field_label_empty => 'Vazio';
	@override String get model_to_map => 'Tipo de card a usar para novo perfil';
	@override String get mapping_name => 'Nome do perfil';
	@override String get mapping_name_hint => 'Nome a atribuir ao perfil';
	@override String get error_profile_name => 'Nome de perfil inválido';
	@override String get error_profile_name_content => 'Um perfil com este nome já existe ou não é válido e não pode ser salvo.';
	@override String get error_standard_profile_name => 'Nome de perfil inválido';
	@override String get error_standard_profile_name_content => 'Não é possível renomear o perfil padrão.';
	@override String get error_ankidroid_api => 'Erro do AnkiDroid';
	@override String get error_ankidroid_api_content => 'Houve um problema de comunicação com o AnkiDroid.\n\nCertifique-se de que o serviço em segundo plano do AnkiDroid esteja ativo e que todas as permissões relevantes do aplicativo tenham sido concedidas para continuar.';
	@override String get info_standard_model => 'Tipo de card padrão adicionado';
	@override String get info_standard_model_content => '『jidoujisho Kinomoto』 foi adicionado ao AnkiDroid como um novo tipo de card.\n\nConfigurações que usam um tipo de card ou ordem de campos diferente podem ser usadas adicionando um novo perfil de exportação.';
	@override String get error_model_missing => 'Tipo de card ausente';
	@override String get error_model_missing_content => 'O tipo de card correspondente ao perfil atualmente selecionado está ausente.\n\nO perfil será excluído e o perfil padrão foi selecionado em seu lugar.';
	@override String get error_model_changed => 'Tipo de card alterado';
	@override String get error_model_changed_content => 'O número de campos do tipo de card correspondente ao perfil selecionado foi alterado.\n\nOs campos do perfil atualmente selecionado foram redefinidos e precisarão de reconfiguração.';
	@override String get creator_exporting_as => 'Criando card com perfil';
	@override String get creator_exporting_as_fields_editing => 'Editando campos do perfil';
	@override String get creator_exporting_as_enhancements_editing => 'Editando melhorias do perfil';
	@override String get creator_export_card => 'Criar Card';
	@override String get info_enhancements => 'Melhorias permitem a automação da edição de campos antes da criação do card. Escolha um slot à direita de um campo para permitir o uso de uma melhoria. Até cinco slots direitos podem ser utilizados para cada campo. A melhoria no slot esquerdo de um campo será aplicada automaticamente na criação instantânea de cards ou ao abrir o Criador de Cards.';
	@override String get info_actions => 'Ações rápidas permitem a criação instantânea de cards e outras automações a serem usadas nos resultados de busca do dicionário. As ações podem ser atribuídas através dos slots abaixo. Até seis slots podem ser utilizados.';
	@override String get no_more_available_enhancements => 'Não há mais melhorias disponíveis para este campo';
	@override String get no_more_available_quick_actions => 'Não há mais ações rápidas disponíveis';
	@override String get assign_auto_enhancement => 'Atribuir Melhoria Automática';
	@override String get assign_manual_enhancement => 'Atribuir Melhoria Manual';
	@override String get remove_enhancement => 'Remover Melhoria';
	@override String copy_of_mapping({required Object name}) => 'Cópia de ${name}';
	@override String get enter_search_term => 'Digite um termo de busca...';
	@override String searching_for({required Object searchTerm}) => 'Buscando por 『${searchTerm}』...';
	@override String get no_search_results => 'Nenhum resultado encontrado.';
	@override String get edit_actions => 'Editar Ações Rápidas do Dicionário';
	@override String get remove_action => 'Remover Ação';
	@override String get assign_action => 'Atribuir Ação';
	@override String dictionary_import_tag({required Object name}) => 'Importado de ${name}';
	@override String stash_added_single({required Object term}) => '『${term}』foi adicionado à Reserva.';
	@override String get stash_added_multiple => 'Vários itens foram adicionados à Reserva.';
	@override String stash_clear_single({required Object term}) => '『${term}』foi removido da Reserva.';
	@override String get stash_clear_title => 'Limpar Reserva';
	@override String get stash_clear_description => 'Todo o conteúdo será limpo. Tem certeza?';
	@override String get stash_placeholder => 'Nenhum item na Reserva';
	@override String get stash_nothing_to_pop => 'Nenhum item para remover da Reserva.';
	@override String get no_sentences_found => 'Nenhuma frase encontrada';
	@override String get failed_online_service => 'Falha ao comunicar com o serviço online';
	@override String get search_label_before => 'Mostrar todos ';
	@override String get search_label_middle => 'de ';
	@override String get search_label_after => 'resultados encontrados para';
	@override String get clear_dictionary_title => 'Limpar Histórico de Resultados do Dicionário';
	@override String get clear_dictionary_description => 'Isso limpará todos os resultados do dicionário do histórico. Tem certeza?';
	@override String get clear_search_title => 'Limpar Histórico de Busca';
	@override String get clear_search_description => 'Isso limpará todos os termos de busca deste histórico. Tem certeza?';
	@override String get clear_creator_title => 'Limpar Criador';
	@override String get clear_creator_description => 'Isso limpará todos os campos. Tem certeza?';
	@override String get copied_to_clipboard => 'Copiado para a área de transferência.';
	@override String get no_text => 'Sem texto.';
	@override String get info_fields => 'Os campos são pré-preenchidos com base no termo selecionado na exportação instantânea ou antes de abrir o Criador de Cards. Para incluir um campo na exportação do card, ele deve estar habilitado abaixo e mapeado no perfil de exportação atualmente selecionado. Os campos habilitados também podem ser recolhidos abaixo para reduzir a desordem durante a edição. Use o botão Limpar no canto superior direito do Criador de Cards para limpar rapidamente esses campos ocultos ao editar manualmente um card.';
	@override String get edit_fields => 'Editar e Reordenar Campos';
	@override String get remove_field => 'Remover Campo';
	@override String get add_field => 'Atribuir Campo';
	@override String get add_field_hint => 'Atribuir um campo a esta linha';
	@override String get no_more_available_fields => 'Não há mais campos disponíveis';
	@override String get hidden_fields => 'Campos adicionais';
	@override String field_fallback_used({required Object field, required Object secondField}) => 'O campo ${field} usou ${secondField} como termo de busca alternativo.';
	@override String get no_text_to_search => 'Nenhum texto para buscar.';
	@override String get image_search_label_before => 'Selecionando imagem ';
	@override String get image_search_label_middle => 'de ';
	@override String get image_search_label_after => 'encontradas para';
	@override String get image_search_label_none_middle => 'nenhuma imagem ';
	@override String get image_search_label_none_before => 'Selecionando ';
	@override String get preparing_instant_export => 'Preparando card para exportação...';
	@override String get processing_in_progress => 'Preparando imagens';
	@override String get searching_in_progress => 'Buscando por ';
	@override String get audio_unavailable => 'Nenhum áudio encontrado.';
	@override String get no_audio_enhancements => 'Nenhuma melhoria de áudio atribuída.';
	@override String card_exported({required Object deck}) => 'Card exportado para 『${deck}』.';
	@override String get info_incognito_on => 'Modo anônimo ativado. O histórico de dicionário, mídia e busca não será rastreado.';
	@override String get info_incognito_off => 'Modo anônimo desativado. O histórico de dicionário, mídia e busca será rastreado.';
	@override String get exit_media_title => 'Sair da Mídia';
	@override String get exit_media_description => 'Isso retornará você ao menu principal. Tem certeza?';
	@override String get unimplemented_source => 'Fonte não implementada';
	@override String get clear_browser_title => 'Limpar Dados do Navegador';
	@override String get clear_browser_description => 'Isso limpará todos os dados de navegação usados em fontes de mídia que usam conteúdo web. Tem certeza?';
	@override String get ttu_no_books_added => 'Nenhum livro adicionado ao ッツ Ebook Reader';
	@override String get local_media_directory_empty => 'O diretório não tem pastas ou vídeos';
	@override String get pick_video_file => 'Escolher Arquivo de Vídeo';
	@override String get navigate_up_one_directory_level => 'Subir Um Nível de Diretório';
	@override String get play => 'Reproduzir';
	@override String get pause => 'Pausar';
	@override String get record => 'Gravar';
	@override String get stop => 'Parar';
	@override String get replay => 'Repetir';
	@override String get audio_subtitles => 'Áudio/Legendas';
	@override String get player_option_shadowing => 'Modo Shadowing';
	@override String get player_option_change_mode => 'Mudar Modo de Reprodução';
	@override String get player_option_listening_comprehension => 'Modo de Compreensão Auditiva';
	@override String get player_option_drag_to_select => 'Usar Arrastar para Selecionar Legenda';
	@override String get player_option_tap_to_select => 'Usar Toque para Selecionar Legenda';
	@override String get player_option_dictionary_menu => 'Selecionar Fonte de Dicionário Ativo';
	@override String get player_option_cast_video => 'Transmitir para Dispositivo';
	@override String get player_option_share_subtitle => 'Compartilhar Legenda Atual';
	@override String get player_option_export => 'Criar Card do Contexto';
	@override String get player_option_audio => 'Áudio';
	@override String get player_option_subtitle => 'Legenda';
	@override String get player_option_subtitle_external => 'Externa';
	@override String get player_option_subtitle_none => 'Nenhuma';
	@override String get player_option_select_subtitle => 'Selecionar Faixa de Legenda';
	@override String get player_option_select_audio => 'Selecionar Faixa de Áudio';
	@override String get player_option_text_filter => 'Usar Filtro de Expressão Regular';
	@override String get player_option_blur_preferences => 'Preferências do Widget de Desfoque';
	@override String get player_option_blur_use => 'Usar Widget de Desfoque';
	@override String get player_option_blur_radius => 'Raio do desfoque';
	@override String get player_option_blur_options => 'Definir Cor e Intensidade do Widget de Desfoque';
	@override String get player_option_blur_reset => 'Redefinir Tamanho e Posição do Widget de Desfoque';
	@override String get player_align_subtitle_transcript => 'Alinhar Legenda com Transcrição';
	@override String get player_option_subtitle_appearance => 'Tempo e Aparência da Legenda';
	@override String get player_option_load_subtitles => 'Carregar Legendas Externas';
	@override String get player_option_subtitle_delay => 'Atraso da legenda';
	@override String get player_option_audio_allowance => 'Margem de áudio';
	@override String get player_option_font_name => 'Nome da fonte da legenda';
	@override String get player_option_font_size => 'Tamanho da fonte da legenda';
	@override String get player_option_regex_filter => 'Filtro de expressão regular';
	@override String get player_option_subtitle_background_opacity => 'Opacidade do fundo da legenda';
	@override String get player_option_subtitle_background_blur_radius => 'Raio de desfoque do fundo da legenda';
	@override String get player_option_outline_width => 'Largura do contorno da legenda';
	@override String get player_option_subtitle_always_above_bottom_bar => 'Sempre mostrar legenda acima da barra inferior';
	@override String get player_subtitles_transcript_empty => 'A transcrição está vazia.';
	@override String get player_prepare_export => 'Preparando card...';
	@override String get player_change_player_orientation => 'Mudar Orientação do Player';
	@override String get no_current_media => 'Reproduza ou atualize a mídia para letras';
	@override String get lyrics_permission_required => 'Permissão necessária não concedida';
	@override String get no_lyrics_found => 'Nenhuma letra encontrada';
	@override String get trending => 'Em alta';
	@override String get caption_filter => 'Filtrar Legendas Ocultas';
	@override String get captions_query => 'Consultando legendas';
	@override String get captions_target => 'Idioma alvo';
	@override String get captions_app => 'Idioma do app';
	@override String get captions_other => 'Outro idioma';
	@override String get captions_closed => 'Legenda oculta';
	@override String get captions_auto => 'Legenda automática';
	@override String get captions_unavailable => 'Sem legendas';
	@override String get captions_error => 'Erro ao consultar legendas';
	@override String get change_quality => 'Mudar Qualidade';
	@override String get closed_captions_query => 'Consultando legendas';
	@override String get closed_captions_target => 'Legendas no idioma alvo';
	@override String get closed_captions_app => 'Legendas no idioma do app';
	@override String get closed_captions_other => 'Legendas em outro idioma';
	@override String get closed_captions_unavailable => 'Sem legendas';
	@override String get closed_captions_error => 'Erro ao consultar legendas';
	@override String get stream_url => 'URL do Stream';
	@override String get default_option => 'Padrão';
	@override String get paste => 'Colar';
	@override String get select_all => 'Selecionar tudo';
	@override String get lyrics_title => 'Título';
	@override String get lyrics_artist => 'Artista';
	@override String get set_media => 'Definir Mídia';
	@override String get no_recordings_found => 'Nenhuma gravação encontrada';
	@override String get wrap_image_audio => 'Incluir tags HTML de imagem/áudio na exportação';
	@override String get server_address => 'Endereço do Servidor';
	@override String get no_active_connection => 'Nenhuma conexão ativa';
	@override String get failed_server_connection => 'Falha ao conectar ao servidor';
	@override String get no_text_received => 'Nenhum texto recebido';
	@override String get text_segmentation => 'Segmentação de Texto';
	@override String get connect_disconnect => 'Conectar/Desconectar';
	@override String get clear_text_title => 'Limpar Texto';
	@override String get clear_text_description => 'Isso limpará todo o texto recebido. Tem certeza?';
	@override String get close_connection_title => 'Fechar Conexão';
	@override String get close_connection_description => 'Isso encerrará a conexão WebSocket e limpará todo o texto recebido. Tem certeza?';
	@override String get use_slow_import => 'Importação lenta (use se estiver falhando)';
	@override String get settings => 'Configurações';
	@override String get manager => 'Gerenciador';
	@override String get volume_button_page_turning => 'Virar página com botão de volume';
	@override String get invert_volume_buttons => 'Inverter botões de volume';
	@override String get volume_button_turning_speed => 'Velocidade de rolagem contínua';
	@override String get extend_page_beyond_navbar => 'Estender página além da barra de navegação';
	@override String get tweaks => 'Ajustes';
	@override String get increase => 'Aumentar';
	@override String get decrease => 'Diminuir';
	@override String get unit_milliseconds => 'ms';
	@override String get unit_pixels => 'px';
	@override String get dictionary_settings => 'Configurações do Dicionário';
	@override String get auto_search => 'Busca automática';
	@override String get auto_search_debounce_delay => 'Atraso da busca automática';
	@override String get dictionary_font_size => 'Tamanho da fonte do dicionário';
	@override String get close_on_export => 'Fechar ao Exportar';
	@override String get close_on_export_on => 'O Criador de Cards agora fechará automaticamente ao exportar o card.';
	@override String get close_on_export_off => 'O Criador de Cards não fechará mais ao exportar o card.';
	@override String get export_profile_empty => 'Seu perfil de exportação não tem campos definidos e requer configuração.';
	@override String get error_export_media_ankidroid => 'Houve um erro ao exportar mídia para o AnkiDroid.';
	@override String get error_add_note => 'Houve um erro ao adicionar uma nota ao AnkiDroid.';
	@override String get first_time_setup => 'Configuração Inicial';
	@override String get first_time_setup_description => 'Bem-vindo ao jidoujisho! Defina seu idioma alvo e um perfil padrão será criado para você. Você pode mudar isso depois a qualquer momento.';
	@override String get maximum_entries => 'Limite máximo de consulta de entradas do dicionário';
	@override String get maximum_terms => 'Máximo de palavras-chave do dicionário nos resultados';
	@override String get use_br_tags => 'Usar tag de quebra de linha em vez de nova linha na exportação';
	@override String get prepend_dictionary_names => 'Adicionar nome do dicionário no significado';
	@override String get highlight_on_tap => 'Destacar texto ao tocar';
	@override String get no_audio_file => 'Nenhum arquivo de áudio para salvar.';
	@override String get storage_permissions => 'Por favor, conceda as seguintes permissões para exportar para o AnkiDroid.';
	@override String get stream => 'Stream';
	@override String get network_subtitles_warning => 'Legendas incorporadas não são suportadas para streams de rede.';
	@override String get accessibility => 'É necessária permissão para capturar texto de eventos de acessibilidade.';
	@override String get comments => 'Comentários';
	@override String get replies => 'Respostas';
	@override String get no_comments_queried => 'Nenhum comentário consultado';
	@override String get no_text_in_clipboard => 'Nenhum texto para exibir';
	@override String file_downloaded({required Object name}) => 'Arquivo baixado: ${name}';
	@override String get cfhange_sort_order => 'Mudar Ordem de Classificação';
	@override String get login => 'Entrar';
	@override String get send => 'Enviar';
	@override String get no_messages => 'Iniciar um chat';
	@override String get enter_message => 'Digite a mensagem...';
	@override String get clear_message_title => 'Limpar Mensagens';
	@override String get clear_message_description => 'Isso limpará todas as mensagens e iniciará um novo chat. Tem certeza?';
	@override String get error_chatgpt_response => 'Solicitação falhou ou foi limitada. Tente novamente em breve ou verifique seus limites de uso.';
	@override String get pick_file => 'Escolher Arquivo';
	@override String get open_url => 'Abrir URL';
	@override String get catalogs => 'Catálogos';
	@override String get name => 'Nome';
	@override String get url => 'URL';
	@override String get duplicate_catalog => 'Já existe um catálogo com esta URL.';
	@override String get no_catalogs_listed => 'Nenhum catálogo listado';
	@override String get go_back => 'Voltar';
	@override String get invalid_mokuro_file => 'O arquivo não é um HTML gerado pelo Mokuro.';
	@override String get create_catalog => 'Criar Catálogo';
	@override String get adapt_ttu_theme => 'Adaptar popup do dicionário ao tema';
	@override String get sentence_picker => 'Seletor de Frases';
	@override String field_locked({required Object field}) => '${field} bloqueado e não será limpo na exportação enquanto o Criador estiver ativo.';
	@override String field_unlocked({required Object field}) => '${field} desbloqueado e será limpo na exportação.';
	@override String get field_lock => 'Bloquear Campo';
	@override String get field_unlock => 'Desbloquear Campo';
	@override String get use_dark_theme => 'Usar tema escuro';
	@override String get stretch_to_fill_screen => 'Esticar para Preencher a Tela';
	@override String get processing_embedded_subtitles => 'Legendas incorporadas estão processando. Tente novamente mais tarde.';
	@override String get transcript_playback_mode => 'Modo de Reprodução da Transcrição';
	@override String get toggle_transcript_background => 'Alternar Fundo da Transcrição';
	@override String get seek => 'Avançar';
	@override String get saved_tags => 'Tags salvas.';
	@override String structured_content_first({required Object i}) => '${i} definições não são suportadas e foram omitidas.';
	@override String get structured_content_second => 'Considere uma versão sem conteúdo estruturado deste dicionário.';
	@override String get missing_api_key => 'Chave de API não fornecida';
	@override String get chatgpt_error => 'Houve um erro ao obter resposta do ChatGPT.';
	@override String get api_key => 'Chave API';
	@override String subtitle_delay_set({required Object ms}) => 'Atraso da legenda definido para ${ms} ms.';
	@override String get cancel => 'Cancelar';
	@override String get server_port_in_use => 'Porta do servidor local já está em uso';
	@override String get google_fonts => 'Fontes do Google';
	@override String get video_show => 'Mostrar vídeo';
	@override String get video_hide => 'Ocultar vídeo';
	@override String get subtitle_timing_show => 'Mostrar tempos da legenda';
	@override String get subtitle_timing_hide => 'Ocultar tempos da legenda';
	@override String get find_next => 'Encontrar Próximo';
	@override String get find_previous => 'Encontrar Anterior';
	@override String get shadowing_mode => 'Modo Shadowing';
	@override String get display_settings => 'Configurações de Exibição';
	@override String get cloze => 'Cloze';
	@override String get info_standard_update => 'Novo tipo de card do perfil padrão';
	@override String get info_standard_update_content => 'O perfil padrão agora usa o tipo de card『jidoujisho Kinomoto』.\n\nSeu perfil padrão legado permanece disponível para compatibilidade retroativa.';
	@override late final _StringsRetryingInPtBr retrying_in = _StringsRetryingInPtBr._(_root);
	@override late final _StringsViewRepliesPtBr view_replies = _StringsViewRepliesPtBr._(_root);
	@override String get manage_duplicate_checks => 'Gerenciar Verificações de Duplicatas';
	@override String get playback_normal => 'Modo de Reprodução Normal';
	@override String get playback_condensed => 'Modo de Reprodução Condensado';
	@override String get playback_auto_pause => 'Modo de Reprodução com Pausa na Legenda';
	@override String get player_hardware_acceleration => 'Aceleração de hardware';
	@override String get player_use_opensles => 'Áudio OpenSL ES';
	@override String get go_forward => 'Avançar';
	@override String get browse => 'Navegar';
	@override String get bookmark => 'Marcador';
	@override String get add_bookmark => 'Adicionar Marcador';
	@override String get add_to_reading_list => 'Adicionar à Lista de Leitura';
	@override String get reading_list_empty => 'Lista de leitura vazia';
	@override String get reading_list_add_toast => 'Adicionado à lista de leitura.';
	@override String get reading_list_remove_toast => 'Removido da lista de leitura.';
	@override String get ad_block_hosts => 'Hosts de bloqueio de anúncios';
	@override String get error_parsing_hosts_file => 'Erro ao analisar arquivo de hosts.';
	@override String get double_tap_seek_duration => 'Duração do avanço com toque duplo';
	@override String get player_background_play => 'Reprodução em segundo plano';
	@override String get loaded_from_cache => 'Carregado do cache do arquivo web.';
	@override String get player_show_subtitle_in_notification => 'Mostrar legendas na notificação de mídia';
	@override String get subtitles_processing => 'Legendas estão processando...';
	@override String get video_unavailable => 'Vídeo Indisponível';
	@override String get video_unavailable_content => 'Não foi possível obter streams. Pode haver restrições que impeçam assistir este vídeo.';
	@override String get video_file_error => 'Não Foi Possível Carregar o Arquivo';
	@override String get video_file_error_content => 'Não foi possível carregar o arquivo de vídeo. Certifique-se de que este arquivo existe e está localizado em um diretório acessível pelo aplicativo.';
}

// Path: retrying_in
class _StringsRetryingInPtBr implements _StringsRetryingInEn {
	_StringsRetryingInPtBr._(this._root);

	@override final _StringsPtBr _root; // ignore: unused_field

	// Translations
	@override String seconds({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
		one: 'Tentando novamente em ${n} segundo...',
		other: 'Tentando novamente em ${n} segundos...',
	);
}

// Path: view_replies
class _StringsViewRepliesPtBr implements _StringsViewRepliesEn {
	_StringsViewRepliesPtBr._(this._root);

	@override final _StringsPtBr _root; // ignore: unused_field

	// Translations
	@override String reply({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
		one: 'MOSTRAR ${n} RESPOSTA',
		other: 'MOSTRAR ${n} RESPOSTAS',
	);
}

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.

extension on _StringsEn {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'dictionary_media_type': return 'Dictionary';
			case 'player_media_type': return 'Player';
			case 'reader_media_type': return 'Reader';
			case 'viewer_media_type': return 'Viewer';
			case 'jellyfin_media_type': return 'Jellyfin';
			case 'back': return 'Back';
			case 'search': return 'Search';
			case 'search_ellipsis': return 'Search...';
			case 'show_more': return 'Show More';
			case 'show_menu': return 'Show Menu';
			case 'stash': return 'Stash';
			case 'pick_image': return 'Pick Image';
			case 'undo': return 'Undo';
			case 'copy': return 'Copy';
			case 'clear': return 'Clear';
			case 'creator': return 'Creator';
			case 'share': return 'Share';
			case 'resume_last_media': return 'Resume Last Media';
			case 'change_source': return 'Change Source';
			case 'launch_source': return 'Launch Source';
			case 'card_creator': return 'Card Creator';
			case 'target_language': return 'Target language';
			case 'show_options': return 'Show Options';
			case 'switch_profiles': return 'Switch Profiles';
			case 'dictionaries': return 'Dictionaries';
			case 'enhancements': return 'Enhancements';
			case 'app_locale': return 'App locale';
			case 'app_locale_warning': return 'Community addons and enhancements are managed by their respective developers, and these may appear in their original language.';
			case 'dialog_play': return 'PLAY';
			case 'dialog_read': return 'READ';
			case 'dialog_view': return 'VIEW';
			case 'dialog_edit': return 'EDIT';
			case 'dialog_export': return 'EXPORT';
			case 'dialog_import': return 'IMPORT';
			case 'dialog_close': return 'CLOSE';
			case 'dialog_clear': return 'CLEAR';
			case 'dialog_create': return 'CREATE';
			case 'dialog_delete': return 'DELETE';
			case 'dialog_cancel': return 'CANCEL';
			case 'dialog_select': return 'SELECT';
			case 'dialog_stash': return 'STASH';
			case 'dialog_search': return 'SEARCH';
			case 'dialog_exit': return 'EXIT';
			case 'dialog_share': return 'SHARE';
			case 'dialog_pop': return 'POP';
			case 'dialog_save': return 'SAVE';
			case 'dialog_set': return 'SET';
			case 'dialog_browse': return 'BROWSE';
			case 'dialog_channel': return 'CHANNEL';
			case 'dialog_directory': return 'DIRECTORY';
			case 'dialog_crop': return 'CROP';
			case 'dialog_connect': return 'CONNECT';
			case 'dialog_append': return 'APPEND';
			case 'dialog_record': return 'RECORD';
			case 'dialog_manage': return 'MANAGE';
			case 'dialog_stop': return 'STOP';
			case 'dialog_done': return 'DONE';
			case 'reset': return 'Reset';
			case 'dialog_launch_ankidroid': return 'LAUNCH ANKIDROID';
			case 'media_item_delete_confirmation': return 'This will clear this item from history. Are you sure you want to do this?';
			case 'dictionaries_delete_confirmation': return 'Deleting a dictionary will also clear all dictionary results from history. Are you sure you want to do this?';
			case 'mappings_delete_confirmation': return 'This profile will be deleted. Are you sure you want to do this?';
			case 'catalog_delete_confirmation': return 'This catalog will be deleted. Are you sure you want to do this?';
			case 'dictionaries_deleting_data': return 'Deleting dictionary data...';
			case 'dictionaries_menu_empty': return 'Import a dictionary for use';
			case 'options_theme_light': return 'Use light theme';
			case 'options_theme_dark': return 'Use dark theme';
			case 'options_incognito_on': return 'Turn on incognito mode';
			case 'options_incognito_off': return 'Turn off incognito mode';
			case 'options_dictionaries': return 'Manage dictionaries';
			case 'options_profiles': return 'Export profiles';
			case 'options_enhancements': return 'User enhancements';
			case 'options_language': return 'Language settings';
			case 'options_github': return 'View repository on GitHub';
			case 'options_attribution': return 'Licenses and attribution';
			case 'options_copy': return 'Copy';
			case 'options_collapse': return 'Collapse';
			case 'options_expand': return 'Expand';
			case 'options_delete': return 'Delete';
			case 'options_show': return 'Show';
			case 'options_hide': return 'Hide';
			case 'options_edit': return 'Edit';
			case 'info_empty_home_tab': return 'History is empty';
			case 'delete_in_progress': return 'Delete in progress';
			case 'import_format': return 'Import format';
			case 'import_in_progress': return 'Import in progress';
			case 'import_start': return 'Preparing for import...';
			case 'import_clean': return 'Cleaning working space...';
			case 'import_extract_count': return ({required Object n}) => 'Extracted ${n} files...';
			case 'import_extract': return 'Extracting files...';
			case 'import_name': return ({required Object name}) => 'Importing 『${name}』...';
			case 'import_entries': return 'Processing entries...';
			case 'import_found_entry': return ({required Object count}) => 'Found ${count} entries...';
			case 'import_found_tag': return ({required Object count}) => 'Found ${count} tags...';
			case 'import_found_frequency': return ({required Object count}) => 'Found ${count} frequency entries...';
			case 'import_found_pitch': return ({required Object count}) => 'Found ${count} pitch accent entries...';
			case 'import_write_entry': return ({required Object count, required Object total}) => 'Writing entries:\n${count} / ${total}';
			case 'import_write_tag': return ({required Object count, required Object total}) => 'Writing tags:\n${count} / ${total}';
			case 'import_write_frequency': return ({required Object count, required Object total}) => 'Writing frequency entries:\n${count} / ${total}';
			case 'import_write_pitch': return ({required Object count, required Object total}) => 'Writing pitch accent entries:\n${count} / ${total}';
			case 'import_failed': return 'Dictionary import failed.';
			case 'import_complete': return 'Dictionary import complete.';
			case 'import_duplicate': return ({required Object name}) => 'A dictionary with the name『${name}』is already imported.';
			case 'dialog_title_dictionary_clear': return 'Clear all dictionaries?';
			case 'dialog_content_dictionary_clear': return 'Wiping the dictionary database will also clear all search results in history.';
			case 'dialog_title_dictionary_delete': return ({required Object name}) => 'Delete 『${name}』?';
			case 'dialog_content_dictionary_delete': return 'Deleting a single dictionary may take longer than clearing the entire dictionary database. This will also clear all search results in history.';
			case 'delete_dictionary_data': return 'Clearing all dictionary data...';
			case 'dictionary_tag': return ({required Object name}) => 'Imported from ${name}';
			case 'legalese': return 'A full-featured immersion language learning suite for mobile.\n\nOriginally built for the Japanese language learning community by Arianne Orpilla. Logo by suzy and Aaron Marbella.\n\njidoujisho is free and open source software. See the project repository for a comprehensive list of other licenses and attribution notices. Enjoying the application? Help out by providing feedback, making a donation, reporting issues or contributing improvements on GitHub.';
			case 'same_name_dictionary_found': return 'Dictionary with same name found.';
			case 'import_file_extension_invalid': return ({required Object extensions}) => 'This format expects files with the following extensions: ${extensions}';
			case 'field_label_empty': return 'Empty';
			case 'model_to_map': return 'Card type to use for new profile';
			case 'mapping_name': return 'Profile name';
			case 'mapping_name_hint': return 'Name to assign to profile';
			case 'error_profile_name': return 'Invalid profile name';
			case 'error_profile_name_content': return 'A profile with this name already exists or is not valid and cannot be saved.';
			case 'error_standard_profile_name': return 'Invalid profile name';
			case 'error_standard_profile_name_content': return 'Cannot rename the standard profile.';
			case 'error_ankidroid_api': return 'AnkiDroid error';
			case 'error_ankidroid_api_content': return 'There was an issue communicating with AnkiDroid.\n\nEnsure that the AnkiDroid background service is active and all relevant app permissions are granted in order to continue.';
			case 'info_standard_model': return 'Standard card type added';
			case 'info_standard_model_content': return '『jidoujisho Kinomoto』 has been added to AnkiDroid as a new card type.\n\nSetups making use of a different card type or field order may be used by adding a new export profile.';
			case 'error_model_missing': return 'Missing card type';
			case 'error_model_missing_content': return 'The corresponding card type of the currently selected profile is missing.\n\nThe profile will be deleted, and the standard profile has now been selected in its place.';
			case 'error_model_changed': return 'Card type changed';
			case 'error_model_changed_content': return 'The number of fields of the card type corresponding to the selected profile has changed.\n\nThe fields of the currently selected profile have been reset and will require reconfiguration.';
			case 'creator_exporting_as': return 'Creating card with profile';
			case 'creator_exporting_as_fields_editing': return 'Editing fields for profile';
			case 'creator_exporting_as_enhancements_editing': return 'Editing enhancements for profile';
			case 'creator_export_card': return 'Create Card';
			case 'info_enhancements': return 'Enhancements enable the automation of field editing prior to card creation. Pick a slot on the right of a field to allow use of an enhancement. Up to five right slots may be utilised for each field. The enhancement in the left slot of a field will be automatically applied in instant card creation or upon launch of the Card Creator.';
			case 'info_actions': return 'Quick actions allow for instant card creation and other automations to be used on dictionary search results. Actions can be assigned via the slots below. Up to six slots may be utilised.';
			case 'no_more_available_enhancements': return 'No more available enhancements for this field';
			case 'no_more_available_quick_actions': return 'No more available quick actions';
			case 'assign_auto_enhancement': return 'Assign Auto Enhancement';
			case 'assign_manual_enhancement': return 'Assign Manual Enhancement';
			case 'remove_enhancement': return 'Remove Enhancement';
			case 'copy_of_mapping': return ({required Object name}) => 'Copy of ${name}';
			case 'enter_search_term': return 'Enter a search term...';
			case 'searching_for': return ({required Object searchTerm}) => 'Searching for 『${searchTerm}』...';
			case 'no_search_results': return 'No search results found.';
			case 'edit_actions': return 'Edit Dictionary Quick Actions';
			case 'remove_action': return 'Remove Action';
			case 'assign_action': return 'Assign Action';
			case 'dictionary_import_tag': return ({required Object name}) => 'Imported from ${name}';
			case 'stash_added_single': return ({required Object term}) => '『${term}』has been added to the Stash.';
			case 'stash_added_multiple': return 'Multiple items have been added to the Stash.';
			case 'stash_clear_single': return ({required Object term}) => '『${term}』has been removed from the Stash.';
			case 'stash_clear_title': return 'Clear Stash';
			case 'stash_clear_description': return 'All contents will be cleared. Are you sure?';
			case 'stash_placeholder': return 'No items in the Stash';
			case 'stash_nothing_to_pop': return 'No items to be popped from the Stash.';
			case 'no_sentences_found': return 'No sentences found';
			case 'failed_online_service': return 'Failed to communicate with online service';
			case 'search_label_before': return 'Show all ';
			case 'search_label_middle': return 'out of ';
			case 'search_label_after': return 'search results found for';
			case 'clear_dictionary_title': return 'Clear Dictionary Result History';
			case 'clear_dictionary_description': return 'This will clear all dictionary results from history. Are you sure?';
			case 'clear_search_title': return 'Clear Search History';
			case 'clear_search_description': return 'This will clear all search terms for this history. Are you sure?';
			case 'clear_creator_title': return 'Clear Creator';
			case 'clear_creator_description': return 'This will clear all fields. Are you sure?';
			case 'copied_to_clipboard': return 'Copied to clipboard.';
			case 'no_text': return 'No text.';
			case 'info_fields': return 'Fields are pre-filled based on the term selected on instant export or prior to opening the Card Creator. In order to include a field for card export, it must be enabled below as well as mapped in the current selected export profile. Enabled fields may also be collapsed below in order to reduce clutter during editing. Use the Clear button on the top-right of the Card Creator in order to wipe these hidden fields quickly when manually editing a card.';
			case 'edit_fields': return 'Edit and Reorder Fields';
			case 'remove_field': return 'Remove Field';
			case 'add_field': return 'Assign Field';
			case 'add_field_hint': return 'Assign a field to this row';
			case 'no_more_available_fields': return 'No more available fields';
			case 'hidden_fields': return 'Additional fields';
			case 'field_fallback_used': return ({required Object field, required Object secondField}) => 'The ${field} field used ${secondField} as its fallback search term.';
			case 'no_text_to_search': return 'No text to search.';
			case 'image_search_label_before': return 'Selecting image ';
			case 'image_search_label_middle': return 'out of ';
			case 'image_search_label_after': return 'found for';
			case 'image_search_label_none_middle': return 'no image ';
			case 'image_search_label_none_before': return 'Selecting ';
			case 'preparing_instant_export': return 'Preparing card for export...';
			case 'processing_in_progress': return 'Preparing images';
			case 'searching_in_progress': return 'Searching for ';
			case 'audio_unavailable': return 'No audio could be found.';
			case 'no_audio_enhancements': return 'No audio enhancements are assigned.';
			case 'card_exported': return ({required Object deck}) => 'Card exported to 『${deck}』.';
			case 'info_incognito_on': return 'Incognito mode on. Dictionary, media and search history will not be tracked.';
			case 'info_incognito_off': return 'Incognito mode off. Dictionary, media and search history will be tracked.';
			case 'exit_media_title': return 'Exit Media';
			case 'exit_media_description': return 'This will return you to the main menu. Are you sure?';
			case 'unimplemented_source': return 'Unimplemented source';
			case 'clear_browser_title': return 'Clear Browser Data';
			case 'clear_browser_description': return 'This will clear all browsing data used in media sources that use web content. Are you sure?';
			case 'ttu_no_books_added': return 'No books added to ッツ Ebook Reader';
			case 'local_media_directory_empty': return 'Directory has no folders or video';
			case 'pick_video_file': return 'Pick Video File';
			case 'navigate_up_one_directory_level': return 'Navigate Up One Directory Level';
			case 'play': return 'Play';
			case 'pause': return 'Pause';
			case 'record': return 'Record';
			case 'stop': return 'Stop';
			case 'replay': return 'Replay';
			case 'audio_subtitles': return 'Audio/Subtitles';
			case 'player_option_shadowing': return 'Shadowing Mode';
			case 'player_option_change_mode': return 'Change Playback Mode';
			case 'player_option_listening_comprehension': return 'Listening Comprehension Mode';
			case 'player_option_drag_to_select': return 'Use Drag to Select Subtitle Selection';
			case 'player_option_tap_to_select': return 'Use Tap to Select Subtitle Selection';
			case 'player_option_dictionary_menu': return 'Select Active Dictionary Source';
			case 'player_option_cast_video': return 'Cast to Display Device';
			case 'player_option_share_subtitle': return 'Share Current Subtitle';
			case 'player_option_export': return 'Create Card from Context';
			case 'player_option_audio': return 'Audio';
			case 'player_option_subtitle': return 'Subtitle';
			case 'player_option_subtitle_external': return 'External';
			case 'player_option_subtitle_none': return 'None';
			case 'player_option_select_subtitle': return 'Select Subtitle Track';
			case 'player_option_select_audio': return 'Select Audio Track';
			case 'player_option_text_filter': return 'Use Regular Expression Filter';
			case 'player_option_blur_preferences': return 'Blur Widget Preferences';
			case 'player_option_blur_use': return 'Use Blur Widget';
			case 'player_option_blur_radius': return 'Blur radius';
			case 'player_option_blur_options': return 'Set Blur Widget Color and Bluriness';
			case 'player_option_blur_reset': return 'Reset Blur Widget Size and Position';
			case 'player_align_subtitle_transcript': return 'Align Subtitle with Transcript';
			case 'player_option_subtitle_appearance': return 'Subtitle Timing and Appearance';
			case 'player_option_load_subtitles': return 'Load External Subtitles';
			case 'player_option_subtitle_delay': return 'Subtitle delay';
			case 'player_option_audio_allowance': return 'Audio allowance';
			case 'player_option_font_name': return 'Subtitle font name';
			case 'player_option_font_size': return 'Subtitle font size';
			case 'player_option_regex_filter': return 'Regular expression filter';
			case 'player_option_subtitle_background_opacity': return 'Subtitle background opacity';
			case 'player_option_subtitle_background_blur_radius': return 'Subtitle background blur radius';
			case 'player_option_outline_width': return 'Subtitle outline width';
			case 'player_option_subtitle_always_above_bottom_bar': return 'Always show subtitle above bottom bar area';
			case 'player_subtitles_transcript_empty': return 'Transcript is empty.';
			case 'player_prepare_export': return 'Preparing card...';
			case 'player_change_player_orientation': return 'Change Player Orientation';
			case 'no_current_media': return 'Play or refresh media for lyrics';
			case 'lyrics_permission_required': return 'Required permission not granted';
			case 'no_lyrics_found': return 'No lyrics found';
			case 'trending': return 'Trending';
			case 'caption_filter': return 'Filter Closed Captions';
			case 'captions_query': return 'Querying for captions';
			case 'captions_target': return 'Target language';
			case 'captions_app': return 'App language';
			case 'captions_other': return 'Other language';
			case 'captions_closed': return 'Closed captioning';
			case 'captions_auto': return 'Automatic captioning';
			case 'captions_unavailable': return 'No captioning';
			case 'captions_error': return 'Error while querying captions';
			case 'change_quality': return 'Change Quality';
			case 'closed_captions_query': return 'Querying for captions';
			case 'closed_captions_target': return 'Target language captions';
			case 'closed_captions_app': return 'App language captions';
			case 'closed_captions_other': return 'Other language captions';
			case 'closed_captions_unavailable': return 'No captions';
			case 'closed_captions_error': return 'Error while querying captions';
			case 'stream_url': return 'Stream URL';
			case 'default_option': return 'Default';
			case 'paste': return 'Paste';
			case 'select_all': return 'Select all';
			case 'lyrics_title': return 'Title';
			case 'lyrics_artist': return 'Artist';
			case 'set_media': return 'Set Media';
			case 'no_recordings_found': return 'No recordings found';
			case 'wrap_image_audio': return 'Include image/audio HTML tags on export';
			case 'server_address': return 'Server Address';
			case 'no_active_connection': return 'No active connection';
			case 'failed_server_connection': return 'Failed to connect to server';
			case 'no_text_received': return 'No text received';
			case 'text_segmentation': return 'Text Segmentation';
			case 'connect_disconnect': return 'Connect/Disconnect';
			case 'clear_text_title': return 'Clear Text';
			case 'clear_text_description': return 'This will clear all received text. Are you sure?';
			case 'close_connection_title': return 'Close Connection';
			case 'close_connection_description': return 'This will end the WebSocket connection and clear all received text. Are you sure?';
			case 'use_slow_import': return 'Slow import (use if failing)';
			case 'settings': return 'Settings';
			case 'manager': return 'Manager';
			case 'volume_button_page_turning': return 'Volume button page turning';
			case 'invert_volume_buttons': return 'Invert volume buttons';
			case 'volume_button_turning_speed': return 'Continuous scrolling speed';
			case 'extend_page_beyond_navbar': return 'Extend page beyond navigation bar';
			case 'tweaks': return 'Tweaks';
			case 'increase': return 'Increase';
			case 'decrease': return 'Decrease';
			case 'unit_milliseconds': return 'ms';
			case 'unit_pixels': return 'px';
			case 'dictionary_settings': return 'Dictionary Settings';
			case 'auto_search': return 'Auto search';
			case 'auto_search_debounce_delay': return 'Auto search debounce delay';
			case 'dictionary_font_size': return 'Dictionary font size';
			case 'close_on_export': return 'Close on Export';
			case 'close_on_export_on': return 'The Card Creator will now automatically close upon card export.';
			case 'close_on_export_off': return 'The Card Creator will no longer close upon card export.';
			case 'export_profile_empty': return 'Your export profile has no set fields and requires configuration.';
			case 'error_export_media_ankidroid': return 'There was an error in exporting media to AnkiDroid.';
			case 'error_add_note': return 'There was an error in adding a note to AnkiDroid.';
			case 'first_time_setup': return 'First-Time Setup';
			case 'first_time_setup_description': return 'Welcome to jidoujisho! Set your target language and a default profile will be tailored for you. You can change this later at anytime.';
			case 'maximum_entries': return 'Maximum dictionary entry query limit';
			case 'maximum_terms': return 'Maximum dictionary headwords in result';
			case 'use_br_tags': return 'Use line break tag instead of newline on export';
			case 'prepend_dictionary_names': return 'Prepend dictionary name in meaning';
			case 'highlight_on_tap': return 'Highlight text on tap';
			case 'no_audio_file': return 'No audio file to save.';
			case 'storage_permissions': return 'Please grant the following permissions for exporting to AnkiDroid.';
			case 'stream': return 'Stream';
			case 'network_subtitles_warning': return 'Embedded subtitles are unsupported for network streams.';
			case 'accessibility': return 'Permission is required to capture text from accessibility events.';
			case 'comments': return 'Comments';
			case 'replies': return 'Replies';
			case 'no_comments_queried': return 'No comments queried';
			case 'no_text_in_clipboard': return 'No text to display';
			case 'file_downloaded': return ({required Object name}) => 'File downloaded: ${name}';
			case 'cfhange_sort_order': return 'Change Sort Order';
			case 'login': return 'Login';
			case 'send': return 'Send';
			case 'no_messages': return 'Start a chat';
			case 'enter_message': return 'Enter message...';
			case 'clear_message_title': return 'Clear Messages';
			case 'clear_message_description': return 'This will clear all messages and start a new chat. Are you sure?';
			case 'error_chatgpt_response': return 'Request failed or rate-limited. Try again shortly or check your usage limits.';
			case 'pick_file': return 'Pick File';
			case 'open_url': return 'Open URL';
			case 'catalogs': return 'Catalogs';
			case 'name': return 'Name';
			case 'url': return 'URL';
			case 'duplicate_catalog': return 'A catalog with this URL already exists.';
			case 'no_catalogs_listed': return 'No catalogs listed';
			case 'go_back': return 'Go Back';
			case 'invalid_mokuro_file': return 'File is not a Mokuro generated HTML file.';
			case 'create_catalog': return 'Create Catalog';
			case 'adapt_ttu_theme': return 'Adapt dictionary popup to theme';
			case 'sentence_picker': return 'Sentence Picker';
			case 'field_locked': return ({required Object field}) => '${field} locked and will not clear on export while Creator is active.';
			case 'field_unlocked': return ({required Object field}) => '${field} unlocked and will clear on export.';
			case 'field_lock': return 'Lock Field';
			case 'field_unlock': return 'Unlock Field';
			case 'use_dark_theme': return 'Use dark theme';
			case 'stretch_to_fill_screen': return 'Stretch to Fill Screen';
			case 'processing_embedded_subtitles': return 'Embedded subtitles are processing. Try again later.';
			case 'transcript_playback_mode': return 'Transcript Playback Mode';
			case 'toggle_transcript_background': return 'Toggle Transcript Background';
			case 'seek': return 'Seek';
			case 'saved_tags': return 'Tags saved.';
			case 'structured_content_first': return ({required Object i}) => '${i} definitions are unsupported and were omitted.';
			case 'structured_content_second': return 'Consider a non-structured content version of this dictionary.';
			case 'missing_api_key': return 'API key not provided';
			case 'chatgpt_error': return 'There was an error in getting a response from ChatGPT.';
			case 'api_key': return 'API Key';
			case 'subtitle_delay_set': return ({required Object ms}) => 'Subtitle delay set to ${ms} ms.';
			case 'cancel': return 'Cancel';
			case 'server_port_in_use': return 'Local server port already in use';
			case 'google_fonts': return 'Google Fonts';
			case 'video_show': return 'Show video';
			case 'video_hide': return 'Hide video';
			case 'subtitle_timing_show': return 'Show subtitle timings';
			case 'subtitle_timing_hide': return 'Hide subtitle timings';
			case 'find_next': return 'Find Next';
			case 'find_previous': return 'Find Previous';
			case 'shadowing_mode': return 'Shadowing Mode';
			case 'display_settings': return 'Display Settings';
			case 'cloze': return 'Cloze';
			case 'info_standard_update': return 'New standard profile card type';
			case 'info_standard_update_content': return 'The standard profile now uses the『jidoujisho Kinomoto』 card type.\n\nYour legacy standard profile remains available for backwards compatibility.';
			case 'retrying_in.seconds': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
				one: 'Retrying in ${n} second...',
				other: 'Retrying in ${n} seconds...',
			);
			case 'view_replies.reply': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
				one: 'SHOW ${n} REPLY',
				other: 'SHOW ${n} REPLIES',
			);
			case 'manage_duplicate_checks': return 'Manage Duplicate Checks';
			case 'playback_normal': return 'Normal Playback Mode';
			case 'playback_condensed': return 'Condensed Playback Mode';
			case 'playback_auto_pause': return 'Subtitle Pause Playback Mode';
			case 'player_hardware_acceleration': return 'Hardware acceleration';
			case 'player_use_opensles': return 'OpenSL ES audio';
			case 'go_forward': return 'Go Forward';
			case 'browse': return 'Browse';
			case 'bookmark': return 'Bookmark';
			case 'add_bookmark': return 'Add Bookmark';
			case 'add_to_reading_list': return 'Add To Reading List';
			case 'reading_list_empty': return 'Reading list is empty';
			case 'reading_list_add_toast': return 'Added to reading list.';
			case 'reading_list_remove_toast': return 'Removed from the reading list.';
			case 'ad_block_hosts': return 'Ad-block hosts';
			case 'error_parsing_hosts_file': return 'Error parsing hosts file.';
			case 'double_tap_seek_duration': return 'Double tap seek duration';
			case 'player_background_play': return 'Background play';
			case 'loaded_from_cache': return 'Loaded from web archive cache.';
			case 'player_show_subtitle_in_notification': return 'Show subtitles in media notification';
			case 'subtitles_processing': return 'Subtitles are processing...';
			case 'video_unavailable': return 'Video Unavailable';
			case 'video_unavailable_content': return 'Cannot fetch streams. There may be restrictions in place that prevent watching this video.';
			case 'video_file_error': return 'Cannot Load File';
			case 'video_file_error_content': return 'Unable to load the video file. Please ensure this file exists and is located in a directory accessible by the application.';
			default: return null;
		}
	}
}

extension on _StringsPtBr {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'dictionary_media_type': return 'Dicionário';
			case 'player_media_type': return 'Player';
			case 'reader_media_type': return 'Leitor';
			case 'viewer_media_type': return 'Visualizador';
			case 'jellyfin_media_type': return 'Jellyfin';
			case 'back': return 'Voltar';
			case 'search': return 'Buscar';
			case 'search_ellipsis': return 'Buscar...';
			case 'show_more': return 'Mostrar Mais';
			case 'show_menu': return 'Mostrar Menu';
			case 'stash': return 'Reservar';
			case 'pick_image': return 'Escolher Imagem';
			case 'undo': return 'Desfazer';
			case 'copy': return 'Copiar';
			case 'clear': return 'Limpar';
			case 'creator': return 'Criador';
			case 'share': return 'Compartilhar';
			case 'resume_last_media': return 'Retomar Última Mídia';
			case 'change_source': return 'Mudar Fonte';
			case 'launch_source': return 'Iniciar Fonte';
			case 'card_creator': return 'Criador de Cards';
			case 'target_language': return 'Idioma alvo';
			case 'show_options': return 'Mostrar Opções';
			case 'switch_profiles': return 'Trocar Perfis';
			case 'dictionaries': return 'Dicionários';
			case 'enhancements': return 'Melhorias';
			case 'app_locale': return 'Idioma do app';
			case 'app_locale_warning': return 'Complementos e melhorias da comunidade são gerenciados por seus respectivos desenvolvedores e podem aparecer no idioma original.';
			case 'dialog_play': return 'REPRODUZIR';
			case 'dialog_read': return 'LER';
			case 'dialog_view': return 'VER';
			case 'dialog_edit': return 'EDITAR';
			case 'dialog_export': return 'EXPORTAR';
			case 'dialog_import': return 'IMPORTAR';
			case 'dialog_close': return 'FECHAR';
			case 'dialog_clear': return 'LIMPAR';
			case 'dialog_create': return 'CRIAR';
			case 'dialog_delete': return 'EXCLUIR';
			case 'dialog_cancel': return 'CANCELAR';
			case 'dialog_select': return 'SELECIONAR';
			case 'dialog_stash': return 'RESERVAR';
			case 'dialog_search': return 'BUSCAR';
			case 'dialog_exit': return 'SAIR';
			case 'dialog_share': return 'COMPARTILHAR';
			case 'dialog_pop': return 'REMOVER';
			case 'dialog_save': return 'SALVAR';
			case 'dialog_set': return 'DEFINIR';
			case 'dialog_browse': return 'NAVEGAR';
			case 'dialog_channel': return 'CANAL';
			case 'dialog_directory': return 'DIRETÓRIO';
			case 'dialog_crop': return 'CORTAR';
			case 'dialog_connect': return 'CONECTAR';
			case 'dialog_append': return 'ANEXAR';
			case 'dialog_record': return 'GRAVAR';
			case 'dialog_manage': return 'GERENCIAR';
			case 'dialog_stop': return 'PARAR';
			case 'dialog_done': return 'CONCLUÍDO';
			case 'reset': return 'Redefinir';
			case 'dialog_launch_ankidroid': return 'ABRIR ANKIDROID';
			case 'media_item_delete_confirmation': return 'Isso removerá este item do histórico. Tem certeza que deseja fazer isso?';
			case 'dictionaries_delete_confirmation': return 'Excluir um dicionário também limpará todos os resultados do histórico. Tem certeza que deseja fazer isso?';
			case 'mappings_delete_confirmation': return 'Este perfil será excluído. Tem certeza que deseja fazer isso?';
			case 'catalog_delete_confirmation': return 'Este catálogo será excluído. Tem certeza que deseja fazer isso?';
			case 'dictionaries_deleting_data': return 'Excluindo dados do dicionário...';
			case 'dictionaries_menu_empty': return 'Importe um dicionário para usar';
			case 'options_theme_light': return 'Usar tema claro';
			case 'options_theme_dark': return 'Usar tema escuro';
			case 'options_incognito_on': return 'Ativar modo anônimo';
			case 'options_incognito_off': return 'Desativar modo anônimo';
			case 'options_dictionaries': return 'Gerenciar dicionários';
			case 'options_profiles': return 'Exportar perfis';
			case 'options_enhancements': return 'Melhorias do usuário';
			case 'options_language': return 'Configurações de idioma';
			case 'options_github': return 'Ver repositório no GitHub';
			case 'options_attribution': return 'Licenças e atribuições';
			case 'options_copy': return 'Copiar';
			case 'options_collapse': return 'Recolher';
			case 'options_expand': return 'Expandir';
			case 'options_delete': return 'Excluir';
			case 'options_show': return 'Mostrar';
			case 'options_hide': return 'Ocultar';
			case 'options_edit': return 'Editar';
			case 'info_empty_home_tab': return 'Histórico vazio';
			case 'delete_in_progress': return 'Exclusão em andamento';
			case 'import_format': return 'Formato de importação';
			case 'import_in_progress': return 'Importação em andamento';
			case 'import_start': return 'Preparando para importar...';
			case 'import_clean': return 'Limpando espaço de trabalho...';
			case 'import_extract_count': return ({required Object n}) => '${n} arquivos extraídos...';
			case 'import_extract': return 'Extraindo arquivos...';
			case 'import_name': return ({required Object name}) => 'Importando 『${name}』...';
			case 'import_entries': return 'Processando entradas...';
			case 'import_found_entry': return ({required Object count}) => '${count} entradas encontradas...';
			case 'import_found_tag': return ({required Object count}) => '${count} tags encontradas...';
			case 'import_found_frequency': return ({required Object count}) => '${count} entradas de frequência encontradas...';
			case 'import_found_pitch': return ({required Object count}) => '${count} entradas de pitch accent encontradas...';
			case 'import_write_entry': return ({required Object count, required Object total}) => 'Escrevendo entradas:\n${count} / ${total}';
			case 'import_write_tag': return ({required Object count, required Object total}) => 'Escrevendo tags:\n${count} / ${total}';
			case 'import_write_frequency': return ({required Object count, required Object total}) => 'Escrevendo entradas de frequência:\n${count} / ${total}';
			case 'import_write_pitch': return ({required Object count, required Object total}) => 'Escrevendo entradas de pitch accent:\n${count} / ${total}';
			case 'import_failed': return 'Falha na importação do dicionário.';
			case 'import_complete': return 'Importação do dicionário concluída.';
			case 'import_duplicate': return ({required Object name}) => 'Um dicionário com o nome『${name}』já está importado.';
			case 'dialog_title_dictionary_clear': return 'Limpar todos os dicionários?';
			case 'dialog_content_dictionary_clear': return 'Limpar o banco de dados de dicionários também excluirá todos os resultados de busca do histórico.';
			case 'dialog_title_dictionary_delete': return ({required Object name}) => 'Excluir 『${name}』?';
			case 'dialog_content_dictionary_delete': return 'Excluir um único dicionário pode levar mais tempo do que limpar todo o banco de dados. Isso também excluirá todos os resultados de busca do histórico.';
			case 'delete_dictionary_data': return 'Limpando todos os dados do dicionário...';
			case 'dictionary_tag': return ({required Object name}) => 'Importado de ${name}';
			case 'legalese': return 'Uma suíte completa de aprendizado de idiomas por imersão para dispositivos móveis.\n\nOriginalmente criado para a comunidade de aprendizado de japonês por Arianne Orpilla. Logo por suzy e Aaron Marbella.\n\njidoujisho é um software livre e de código aberto. Consulte o repositório do projeto para uma lista completa de outras licenças e avisos de atribuição. Gostando do aplicativo? Ajude dando feedback, fazendo uma doação, reportando problemas ou contribuindo com melhorias no GitHub.';
			case 'same_name_dictionary_found': return 'Dicionário com o mesmo nome encontrado.';
			case 'import_file_extension_invalid': return ({required Object extensions}) => 'Este formato espera arquivos com as seguintes extensões: ${extensions}';
			case 'field_label_empty': return 'Vazio';
			case 'model_to_map': return 'Tipo de card a usar para novo perfil';
			case 'mapping_name': return 'Nome do perfil';
			case 'mapping_name_hint': return 'Nome a atribuir ao perfil';
			case 'error_profile_name': return 'Nome de perfil inválido';
			case 'error_profile_name_content': return 'Um perfil com este nome já existe ou não é válido e não pode ser salvo.';
			case 'error_standard_profile_name': return 'Nome de perfil inválido';
			case 'error_standard_profile_name_content': return 'Não é possível renomear o perfil padrão.';
			case 'error_ankidroid_api': return 'Erro do AnkiDroid';
			case 'error_ankidroid_api_content': return 'Houve um problema de comunicação com o AnkiDroid.\n\nCertifique-se de que o serviço em segundo plano do AnkiDroid esteja ativo e que todas as permissões relevantes do aplicativo tenham sido concedidas para continuar.';
			case 'info_standard_model': return 'Tipo de card padrão adicionado';
			case 'info_standard_model_content': return '『jidoujisho Kinomoto』 foi adicionado ao AnkiDroid como um novo tipo de card.\n\nConfigurações que usam um tipo de card ou ordem de campos diferente podem ser usadas adicionando um novo perfil de exportação.';
			case 'error_model_missing': return 'Tipo de card ausente';
			case 'error_model_missing_content': return 'O tipo de card correspondente ao perfil atualmente selecionado está ausente.\n\nO perfil será excluído e o perfil padrão foi selecionado em seu lugar.';
			case 'error_model_changed': return 'Tipo de card alterado';
			case 'error_model_changed_content': return 'O número de campos do tipo de card correspondente ao perfil selecionado foi alterado.\n\nOs campos do perfil atualmente selecionado foram redefinidos e precisarão de reconfiguração.';
			case 'creator_exporting_as': return 'Criando card com perfil';
			case 'creator_exporting_as_fields_editing': return 'Editando campos do perfil';
			case 'creator_exporting_as_enhancements_editing': return 'Editando melhorias do perfil';
			case 'creator_export_card': return 'Criar Card';
			case 'info_enhancements': return 'Melhorias permitem a automação da edição de campos antes da criação do card. Escolha um slot à direita de um campo para permitir o uso de uma melhoria. Até cinco slots direitos podem ser utilizados para cada campo. A melhoria no slot esquerdo de um campo será aplicada automaticamente na criação instantânea de cards ou ao abrir o Criador de Cards.';
			case 'info_actions': return 'Ações rápidas permitem a criação instantânea de cards e outras automações a serem usadas nos resultados de busca do dicionário. As ações podem ser atribuídas através dos slots abaixo. Até seis slots podem ser utilizados.';
			case 'no_more_available_enhancements': return 'Não há mais melhorias disponíveis para este campo';
			case 'no_more_available_quick_actions': return 'Não há mais ações rápidas disponíveis';
			case 'assign_auto_enhancement': return 'Atribuir Melhoria Automática';
			case 'assign_manual_enhancement': return 'Atribuir Melhoria Manual';
			case 'remove_enhancement': return 'Remover Melhoria';
			case 'copy_of_mapping': return ({required Object name}) => 'Cópia de ${name}';
			case 'enter_search_term': return 'Digite um termo de busca...';
			case 'searching_for': return ({required Object searchTerm}) => 'Buscando por 『${searchTerm}』...';
			case 'no_search_results': return 'Nenhum resultado encontrado.';
			case 'edit_actions': return 'Editar Ações Rápidas do Dicionário';
			case 'remove_action': return 'Remover Ação';
			case 'assign_action': return 'Atribuir Ação';
			case 'dictionary_import_tag': return ({required Object name}) => 'Importado de ${name}';
			case 'stash_added_single': return ({required Object term}) => '『${term}』foi adicionado à Reserva.';
			case 'stash_added_multiple': return 'Vários itens foram adicionados à Reserva.';
			case 'stash_clear_single': return ({required Object term}) => '『${term}』foi removido da Reserva.';
			case 'stash_clear_title': return 'Limpar Reserva';
			case 'stash_clear_description': return 'Todo o conteúdo será limpo. Tem certeza?';
			case 'stash_placeholder': return 'Nenhum item na Reserva';
			case 'stash_nothing_to_pop': return 'Nenhum item para remover da Reserva.';
			case 'no_sentences_found': return 'Nenhuma frase encontrada';
			case 'failed_online_service': return 'Falha ao comunicar com o serviço online';
			case 'search_label_before': return 'Mostrar todos ';
			case 'search_label_middle': return 'de ';
			case 'search_label_after': return 'resultados encontrados para';
			case 'clear_dictionary_title': return 'Limpar Histórico de Resultados do Dicionário';
			case 'clear_dictionary_description': return 'Isso limpará todos os resultados do dicionário do histórico. Tem certeza?';
			case 'clear_search_title': return 'Limpar Histórico de Busca';
			case 'clear_search_description': return 'Isso limpará todos os termos de busca deste histórico. Tem certeza?';
			case 'clear_creator_title': return 'Limpar Criador';
			case 'clear_creator_description': return 'Isso limpará todos os campos. Tem certeza?';
			case 'copied_to_clipboard': return 'Copiado para a área de transferência.';
			case 'no_text': return 'Sem texto.';
			case 'info_fields': return 'Os campos são pré-preenchidos com base no termo selecionado na exportação instantânea ou antes de abrir o Criador de Cards. Para incluir um campo na exportação do card, ele deve estar habilitado abaixo e mapeado no perfil de exportação atualmente selecionado. Os campos habilitados também podem ser recolhidos abaixo para reduzir a desordem durante a edição. Use o botão Limpar no canto superior direito do Criador de Cards para limpar rapidamente esses campos ocultos ao editar manualmente um card.';
			case 'edit_fields': return 'Editar e Reordenar Campos';
			case 'remove_field': return 'Remover Campo';
			case 'add_field': return 'Atribuir Campo';
			case 'add_field_hint': return 'Atribuir um campo a esta linha';
			case 'no_more_available_fields': return 'Não há mais campos disponíveis';
			case 'hidden_fields': return 'Campos adicionais';
			case 'field_fallback_used': return ({required Object field, required Object secondField}) => 'O campo ${field} usou ${secondField} como termo de busca alternativo.';
			case 'no_text_to_search': return 'Nenhum texto para buscar.';
			case 'image_search_label_before': return 'Selecionando imagem ';
			case 'image_search_label_middle': return 'de ';
			case 'image_search_label_after': return 'encontradas para';
			case 'image_search_label_none_middle': return 'nenhuma imagem ';
			case 'image_search_label_none_before': return 'Selecionando ';
			case 'preparing_instant_export': return 'Preparando card para exportação...';
			case 'processing_in_progress': return 'Preparando imagens';
			case 'searching_in_progress': return 'Buscando por ';
			case 'audio_unavailable': return 'Nenhum áudio encontrado.';
			case 'no_audio_enhancements': return 'Nenhuma melhoria de áudio atribuída.';
			case 'card_exported': return ({required Object deck}) => 'Card exportado para 『${deck}』.';
			case 'info_incognito_on': return 'Modo anônimo ativado. O histórico de dicionário, mídia e busca não será rastreado.';
			case 'info_incognito_off': return 'Modo anônimo desativado. O histórico de dicionário, mídia e busca será rastreado.';
			case 'exit_media_title': return 'Sair da Mídia';
			case 'exit_media_description': return 'Isso retornará você ao menu principal. Tem certeza?';
			case 'unimplemented_source': return 'Fonte não implementada';
			case 'clear_browser_title': return 'Limpar Dados do Navegador';
			case 'clear_browser_description': return 'Isso limpará todos os dados de navegação usados em fontes de mídia que usam conteúdo web. Tem certeza?';
			case 'ttu_no_books_added': return 'Nenhum livro adicionado ao ッツ Ebook Reader';
			case 'local_media_directory_empty': return 'O diretório não tem pastas ou vídeos';
			case 'pick_video_file': return 'Escolher Arquivo de Vídeo';
			case 'navigate_up_one_directory_level': return 'Subir Um Nível de Diretório';
			case 'play': return 'Reproduzir';
			case 'pause': return 'Pausar';
			case 'record': return 'Gravar';
			case 'stop': return 'Parar';
			case 'replay': return 'Repetir';
			case 'audio_subtitles': return 'Áudio/Legendas';
			case 'player_option_shadowing': return 'Modo Shadowing';
			case 'player_option_change_mode': return 'Mudar Modo de Reprodução';
			case 'player_option_listening_comprehension': return 'Modo de Compreensão Auditiva';
			case 'player_option_drag_to_select': return 'Usar Arrastar para Selecionar Legenda';
			case 'player_option_tap_to_select': return 'Usar Toque para Selecionar Legenda';
			case 'player_option_dictionary_menu': return 'Selecionar Fonte de Dicionário Ativo';
			case 'player_option_cast_video': return 'Transmitir para Dispositivo';
			case 'player_option_share_subtitle': return 'Compartilhar Legenda Atual';
			case 'player_option_export': return 'Criar Card do Contexto';
			case 'player_option_audio': return 'Áudio';
			case 'player_option_subtitle': return 'Legenda';
			case 'player_option_subtitle_external': return 'Externa';
			case 'player_option_subtitle_none': return 'Nenhuma';
			case 'player_option_select_subtitle': return 'Selecionar Faixa de Legenda';
			case 'player_option_select_audio': return 'Selecionar Faixa de Áudio';
			case 'player_option_text_filter': return 'Usar Filtro de Expressão Regular';
			case 'player_option_blur_preferences': return 'Preferências do Widget de Desfoque';
			case 'player_option_blur_use': return 'Usar Widget de Desfoque';
			case 'player_option_blur_radius': return 'Raio do desfoque';
			case 'player_option_blur_options': return 'Definir Cor e Intensidade do Widget de Desfoque';
			case 'player_option_blur_reset': return 'Redefinir Tamanho e Posição do Widget de Desfoque';
			case 'player_align_subtitle_transcript': return 'Alinhar Legenda com Transcrição';
			case 'player_option_subtitle_appearance': return 'Tempo e Aparência da Legenda';
			case 'player_option_load_subtitles': return 'Carregar Legendas Externas';
			case 'player_option_subtitle_delay': return 'Atraso da legenda';
			case 'player_option_audio_allowance': return 'Margem de áudio';
			case 'player_option_font_name': return 'Nome da fonte da legenda';
			case 'player_option_font_size': return 'Tamanho da fonte da legenda';
			case 'player_option_regex_filter': return 'Filtro de expressão regular';
			case 'player_option_subtitle_background_opacity': return 'Opacidade do fundo da legenda';
			case 'player_option_subtitle_background_blur_radius': return 'Raio de desfoque do fundo da legenda';
			case 'player_option_outline_width': return 'Largura do contorno da legenda';
			case 'player_option_subtitle_always_above_bottom_bar': return 'Sempre mostrar legenda acima da barra inferior';
			case 'player_subtitles_transcript_empty': return 'A transcrição está vazia.';
			case 'player_prepare_export': return 'Preparando card...';
			case 'player_change_player_orientation': return 'Mudar Orientação do Player';
			case 'no_current_media': return 'Reproduza ou atualize a mídia para letras';
			case 'lyrics_permission_required': return 'Permissão necessária não concedida';
			case 'no_lyrics_found': return 'Nenhuma letra encontrada';
			case 'trending': return 'Em alta';
			case 'caption_filter': return 'Filtrar Legendas Ocultas';
			case 'captions_query': return 'Consultando legendas';
			case 'captions_target': return 'Idioma alvo';
			case 'captions_app': return 'Idioma do app';
			case 'captions_other': return 'Outro idioma';
			case 'captions_closed': return 'Legenda oculta';
			case 'captions_auto': return 'Legenda automática';
			case 'captions_unavailable': return 'Sem legendas';
			case 'captions_error': return 'Erro ao consultar legendas';
			case 'change_quality': return 'Mudar Qualidade';
			case 'closed_captions_query': return 'Consultando legendas';
			case 'closed_captions_target': return 'Legendas no idioma alvo';
			case 'closed_captions_app': return 'Legendas no idioma do app';
			case 'closed_captions_other': return 'Legendas em outro idioma';
			case 'closed_captions_unavailable': return 'Sem legendas';
			case 'closed_captions_error': return 'Erro ao consultar legendas';
			case 'stream_url': return 'URL do Stream';
			case 'default_option': return 'Padrão';
			case 'paste': return 'Colar';
			case 'select_all': return 'Selecionar tudo';
			case 'lyrics_title': return 'Título';
			case 'lyrics_artist': return 'Artista';
			case 'set_media': return 'Definir Mídia';
			case 'no_recordings_found': return 'Nenhuma gravação encontrada';
			case 'wrap_image_audio': return 'Incluir tags HTML de imagem/áudio na exportação';
			case 'server_address': return 'Endereço do Servidor';
			case 'no_active_connection': return 'Nenhuma conexão ativa';
			case 'failed_server_connection': return 'Falha ao conectar ao servidor';
			case 'no_text_received': return 'Nenhum texto recebido';
			case 'text_segmentation': return 'Segmentação de Texto';
			case 'connect_disconnect': return 'Conectar/Desconectar';
			case 'clear_text_title': return 'Limpar Texto';
			case 'clear_text_description': return 'Isso limpará todo o texto recebido. Tem certeza?';
			case 'close_connection_title': return 'Fechar Conexão';
			case 'close_connection_description': return 'Isso encerrará a conexão WebSocket e limpará todo o texto recebido. Tem certeza?';
			case 'use_slow_import': return 'Importação lenta (use se estiver falhando)';
			case 'settings': return 'Configurações';
			case 'manager': return 'Gerenciador';
			case 'volume_button_page_turning': return 'Virar página com botão de volume';
			case 'invert_volume_buttons': return 'Inverter botões de volume';
			case 'volume_button_turning_speed': return 'Velocidade de rolagem contínua';
			case 'extend_page_beyond_navbar': return 'Estender página além da barra de navegação';
			case 'tweaks': return 'Ajustes';
			case 'increase': return 'Aumentar';
			case 'decrease': return 'Diminuir';
			case 'unit_milliseconds': return 'ms';
			case 'unit_pixels': return 'px';
			case 'dictionary_settings': return 'Configurações do Dicionário';
			case 'auto_search': return 'Busca automática';
			case 'auto_search_debounce_delay': return 'Atraso da busca automática';
			case 'dictionary_font_size': return 'Tamanho da fonte do dicionário';
			case 'close_on_export': return 'Fechar ao Exportar';
			case 'close_on_export_on': return 'O Criador de Cards agora fechará automaticamente ao exportar o card.';
			case 'close_on_export_off': return 'O Criador de Cards não fechará mais ao exportar o card.';
			case 'export_profile_empty': return 'Seu perfil de exportação não tem campos definidos e requer configuração.';
			case 'error_export_media_ankidroid': return 'Houve um erro ao exportar mídia para o AnkiDroid.';
			case 'error_add_note': return 'Houve um erro ao adicionar uma nota ao AnkiDroid.';
			case 'first_time_setup': return 'Configuração Inicial';
			case 'first_time_setup_description': return 'Bem-vindo ao jidoujisho! Defina seu idioma alvo e um perfil padrão será criado para você. Você pode mudar isso depois a qualquer momento.';
			case 'maximum_entries': return 'Limite máximo de consulta de entradas do dicionário';
			case 'maximum_terms': return 'Máximo de palavras-chave do dicionário nos resultados';
			case 'use_br_tags': return 'Usar tag de quebra de linha em vez de nova linha na exportação';
			case 'prepend_dictionary_names': return 'Adicionar nome do dicionário no significado';
			case 'highlight_on_tap': return 'Destacar texto ao tocar';
			case 'no_audio_file': return 'Nenhum arquivo de áudio para salvar.';
			case 'storage_permissions': return 'Por favor, conceda as seguintes permissões para exportar para o AnkiDroid.';
			case 'stream': return 'Stream';
			case 'network_subtitles_warning': return 'Legendas incorporadas não são suportadas para streams de rede.';
			case 'accessibility': return 'É necessária permissão para capturar texto de eventos de acessibilidade.';
			case 'comments': return 'Comentários';
			case 'replies': return 'Respostas';
			case 'no_comments_queried': return 'Nenhum comentário consultado';
			case 'no_text_in_clipboard': return 'Nenhum texto para exibir';
			case 'file_downloaded': return ({required Object name}) => 'Arquivo baixado: ${name}';
			case 'cfhange_sort_order': return 'Mudar Ordem de Classificação';
			case 'login': return 'Entrar';
			case 'send': return 'Enviar';
			case 'no_messages': return 'Iniciar um chat';
			case 'enter_message': return 'Digite a mensagem...';
			case 'clear_message_title': return 'Limpar Mensagens';
			case 'clear_message_description': return 'Isso limpará todas as mensagens e iniciará um novo chat. Tem certeza?';
			case 'error_chatgpt_response': return 'Solicitação falhou ou foi limitada. Tente novamente em breve ou verifique seus limites de uso.';
			case 'pick_file': return 'Escolher Arquivo';
			case 'open_url': return 'Abrir URL';
			case 'catalogs': return 'Catálogos';
			case 'name': return 'Nome';
			case 'url': return 'URL';
			case 'duplicate_catalog': return 'Já existe um catálogo com esta URL.';
			case 'no_catalogs_listed': return 'Nenhum catálogo listado';
			case 'go_back': return 'Voltar';
			case 'invalid_mokuro_file': return 'O arquivo não é um HTML gerado pelo Mokuro.';
			case 'create_catalog': return 'Criar Catálogo';
			case 'adapt_ttu_theme': return 'Adaptar popup do dicionário ao tema';
			case 'sentence_picker': return 'Seletor de Frases';
			case 'field_locked': return ({required Object field}) => '${field} bloqueado e não será limpo na exportação enquanto o Criador estiver ativo.';
			case 'field_unlocked': return ({required Object field}) => '${field} desbloqueado e será limpo na exportação.';
			case 'field_lock': return 'Bloquear Campo';
			case 'field_unlock': return 'Desbloquear Campo';
			case 'use_dark_theme': return 'Usar tema escuro';
			case 'stretch_to_fill_screen': return 'Esticar para Preencher a Tela';
			case 'processing_embedded_subtitles': return 'Legendas incorporadas estão processando. Tente novamente mais tarde.';
			case 'transcript_playback_mode': return 'Modo de Reprodução da Transcrição';
			case 'toggle_transcript_background': return 'Alternar Fundo da Transcrição';
			case 'seek': return 'Avançar';
			case 'saved_tags': return 'Tags salvas.';
			case 'structured_content_first': return ({required Object i}) => '${i} definições não são suportadas e foram omitidas.';
			case 'structured_content_second': return 'Considere uma versão sem conteúdo estruturado deste dicionário.';
			case 'missing_api_key': return 'Chave de API não fornecida';
			case 'chatgpt_error': return 'Houve um erro ao obter resposta do ChatGPT.';
			case 'api_key': return 'Chave API';
			case 'subtitle_delay_set': return ({required Object ms}) => 'Atraso da legenda definido para ${ms} ms.';
			case 'cancel': return 'Cancelar';
			case 'server_port_in_use': return 'Porta do servidor local já está em uso';
			case 'google_fonts': return 'Fontes do Google';
			case 'video_show': return 'Mostrar vídeo';
			case 'video_hide': return 'Ocultar vídeo';
			case 'subtitle_timing_show': return 'Mostrar tempos da legenda';
			case 'subtitle_timing_hide': return 'Ocultar tempos da legenda';
			case 'find_next': return 'Encontrar Próximo';
			case 'find_previous': return 'Encontrar Anterior';
			case 'shadowing_mode': return 'Modo Shadowing';
			case 'display_settings': return 'Configurações de Exibição';
			case 'cloze': return 'Cloze';
			case 'info_standard_update': return 'Novo tipo de card do perfil padrão';
			case 'info_standard_update_content': return 'O perfil padrão agora usa o tipo de card『jidoujisho Kinomoto』.\n\nSeu perfil padrão legado permanece disponível para compatibilidade retroativa.';
			case 'retrying_in.seconds': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
				one: 'Tentando novamente em ${n} segundo...',
				other: 'Tentando novamente em ${n} segundos...',
			);
			case 'view_replies.reply': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('pt'))(n,
				one: 'MOSTRAR ${n} RESPOSTA',
				other: 'MOSTRAR ${n} RESPOSTAS',
			);
			case 'manage_duplicate_checks': return 'Gerenciar Verificações de Duplicatas';
			case 'playback_normal': return 'Modo de Reprodução Normal';
			case 'playback_condensed': return 'Modo de Reprodução Condensado';
			case 'playback_auto_pause': return 'Modo de Reprodução com Pausa na Legenda';
			case 'player_hardware_acceleration': return 'Aceleração de hardware';
			case 'player_use_opensles': return 'Áudio OpenSL ES';
			case 'go_forward': return 'Avançar';
			case 'browse': return 'Navegar';
			case 'bookmark': return 'Marcador';
			case 'add_bookmark': return 'Adicionar Marcador';
			case 'add_to_reading_list': return 'Adicionar à Lista de Leitura';
			case 'reading_list_empty': return 'Lista de leitura vazia';
			case 'reading_list_add_toast': return 'Adicionado à lista de leitura.';
			case 'reading_list_remove_toast': return 'Removido da lista de leitura.';
			case 'ad_block_hosts': return 'Hosts de bloqueio de anúncios';
			case 'error_parsing_hosts_file': return 'Erro ao analisar arquivo de hosts.';
			case 'double_tap_seek_duration': return 'Duração do avanço com toque duplo';
			case 'player_background_play': return 'Reprodução em segundo plano';
			case 'loaded_from_cache': return 'Carregado do cache do arquivo web.';
			case 'player_show_subtitle_in_notification': return 'Mostrar legendas na notificação de mídia';
			case 'subtitles_processing': return 'Legendas estão processando...';
			case 'video_unavailable': return 'Vídeo Indisponível';
			case 'video_unavailable_content': return 'Não foi possível obter streams. Pode haver restrições que impeçam assistir este vídeo.';
			case 'video_file_error': return 'Não Foi Possível Carregar o Arquivo';
			case 'video_file_error_content': return 'Não foi possível carregar o arquivo de vídeo. Certifique-se de que este arquivo existe e está localizado em um diretório acessível pelo aplicativo.';
			default: return null;
		}
	}
}
