@tool
extends PopupPanel

@export var CGLF: CGLF_Manager = null
@export var _clf_name_line_input: LineEdit = null
@export var _warning_label: Label = null
@export var _create_clf_button: Button = null

func _create_clf(name: String) -> void:
	_warning_label.text = ""
	if !is_snake_case(name):
		_warning_label.text = "write_name_in_snake_case"
		_warning_label.show()
		return
	var display_name = CGLF.generate_display_name(name)
	for clf in CGLF.clf_array:
		if clf.name == display_name:
			_warning_label.text = "Name already taken!"
			_warning_label.show()
			return
	self.hide()
	CGLF.create_clf(name, display_name)

func _on_focus_entered() -> void:
	_warning_label.text = ""
	_clf_name_line_input.grab_focus()

func _on_popup_hide() -> void:
	_clf_name_line_input.clear()

func _on_clf_name_input_text_changed(new_text: String) -> void:
	if new_text.length() == 0:
		_create_clf_button.disabled = true
	else:
		_create_clf_button.disabled = false

func _on_clf_name_input_text_submitted(new_text: String) -> void:
	if _create_clf_button.disabled == false:
		_create_clf(new_text)

func _on_cancel_clf_creation_button_pressed() -> void:
	self.hide()

func _on_create_clf_button_pressed() -> void:
	_create_clf(_clf_name_line_input.text)

func is_snake_case(text: String) -> bool:
	var regex := RegEx.new()
	regex.compile("^[a-z0-9]+(_[a-z0-9]+)*$")
	return regex.search(text) != null
