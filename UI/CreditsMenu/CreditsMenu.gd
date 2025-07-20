extends Control


signal close_pressed()


const TITLE_ATTRIBUTE_NAME = "title"
const URL_ATTRIBUTE_NAME = "url"
const LINK_ATTRIBUTE_NAME = "link"
const TEXT_ATTRIBUTE_NAME = "text"
const ELEMENTS_ATTRIBUTE_NAME = "elements"
const FILES_ATTRIBUTE_NAME = "files"
const FROM_ATTRIBUTE_NAME = "from"
const FROM_URL_ATTRIBUTE_NAME = "from_url"
const AUTHOR_ATTRIBUTE_NAME = "author"
const AUTHOR_URL_ATTRIBUTE_NAME = "author_url"
const SOURCE_ATTRIBUTE_NAME = "source"

const BODY_PRE = "[font_size=18]\n"
const BODY_POST = "[/font_size]\n"

const LINK_PLAIN_TEMPLATE = "[url]{0}[/url]"
const LINK_TEMPLATE = "[url={0}]{1}[/url]"

const SUPER_SECTION_TEMPLATE = "[font_size=32][center]{0}[/center][/font_size]\n[hr]\n"
const SECTION_TEMPLATE = "[font_size=24][center]{0}[/center][/font_size]\n[hr]\n"
const SUB_SECTION_TEMPLATE = "[font_size=20][center]{0}[/center][/font_size]\n[hr]\n"

const ENTRY_LINK_EMPTY_TEMPLATE = "[ul bullet=-][url]{0}[/url][/ul]\n"
const ENTRY_LINK_TEMPLATE = "[ul bullet=-][url={0}]{1}[/url][/ul]\n"

const FROM_TEMPLATE = "From {0} by {1}:"
const FILE_TEMPLATE = "[ul bullet=-][code]res://{0}[/code][/ul]"


@onready var credits_label := %CreditsRichTextLabel


func _ready() -> void:
	_fill_credits()


func _build_header(template: String, entry: Dictionary) -> String:
	if entry.has(TITLE_ATTRIBUTE_NAME):
		var title = entry[TITLE_ATTRIBUTE_NAME] as String
		var url := ""
		if entry.has(URL_ATTRIBUTE_NAME):
			url = entry[URL_ATTRIBUTE_NAME] as String

		if not url.is_empty():
			title = LINK_TEMPLATE.format([url, title])

		return template.format([title])

	return ""


func _build_element(data: Dictionary) -> String:
	if data.has(LINK_ATTRIBUTE_NAME):
		return BODY_PRE + ENTRY_LINK_EMPTY_TEMPLATE.format([data[LINK_ATTRIBUTE_NAME]]) + BODY_POST
	elif data.has(TEXT_ATTRIBUTE_NAME):
		# Just return the plain text data.
		return BODY_PRE + data[TEXT_ATTRIBUTE_NAME] + BODY_POST
	elif data.has(SOURCE_ATTRIBUTE_NAME):
		var path = "res://" + data[SOURCE_ATTRIBUTE_NAME]
		if not FileAccess.file_exists(path):
			return ""
		var source := FileAccess.get_file_as_string(path)
		# Read the file and add.
		return BODY_PRE + source + BODY_POST
	elif data.has(FILES_ATTRIBUTE_NAME):
		# Should have at least from and author.
		if not data.has_all([ FROM_ATTRIBUTE_NAME, AUTHOR_ATTRIBUTE_NAME ]):
			return ""

		var from = data[FROM_ATTRIBUTE_NAME]
		var author = data[AUTHOR_ATTRIBUTE_NAME]

		if data.has(FROM_URL_ATTRIBUTE_NAME):
			var url = data[FROM_URL_ATTRIBUTE_NAME]
			from = LINK_TEMPLATE.format([url, from])

		if data.has(AUTHOR_URL_ATTRIBUTE_NAME):
			var url = data[AUTHOR_URL_ATTRIBUTE_NAME]
			author = LINK_TEMPLATE.format([url, author])

		var entry = FROM_TEMPLATE.format([from, author])

		var body := ""
		for file: String in data[FILES_ATTRIBUTE_NAME] as Array:
			body += FILE_TEMPLATE.format([file])

		return BODY_PRE + "[ul]" + entry + body + "\n[/ul]\n" + BODY_POST

	else:
		print("Rest: ", data)
		return ""


func _build_sub_section(data: Array) -> String:
	var ret := ""
	for entry in data:
		if entry is not Dictionary:
			# Malformed, skip.
			continue

		if entry.has(ELEMENTS_ATTRIBUTE_NAME):
			ret += _build_header(SUB_SECTION_TEMPLATE, entry)
			for element in entry[ELEMENTS_ATTRIBUTE_NAME] as Array:
				ret += _build_element(element)
		else:
			ret += _build_element(entry)

	return ret


func _build_section(data: Array) -> String:
	var ret := ""
	for entry in data:
		if entry is not Dictionary:
			# Malformed, skip.
			continue

		if entry.has(ELEMENTS_ATTRIBUTE_NAME):
			ret += _build_header(SECTION_TEMPLATE, entry)
			ret += _build_sub_section(entry[ELEMENTS_ATTRIBUTE_NAME])
		else:
			ret += _build_element(entry)

	return ret


func _build_super_sections(data: Array) -> String:
	var ret := ""
	for entry in data:
		if entry is not Dictionary:
			# Malformed, skip.
			continue

		if entry.has(ELEMENTS_ATTRIBUTE_NAME):
			ret += _build_header(SUPER_SECTION_TEMPLATE, entry)
			ret += _build_section(entry[ELEMENTS_ATTRIBUTE_NAME])
		else:
			ret += _build_element(entry)

	return ret


func _parse_license() -> String:
	var license_json := FileAccess.get_file_as_string("res://Misc/COPYING.json")
	var license_data = JSON.parse_string(license_json)

	if license_data is not Array:
		return ""

	return _build_super_sections(license_data)


func _fill_credits() -> void:
	credits_label.text = _parse_license()


func _on_credits_rich_text_label_meta_clicked(meta: Variant) -> void:
	# Open directly with shell.
	OS.shell_open(meta)


func _on_close_button_pressed() -> void:
	close_pressed.emit()
