@tool
extends PopupPanel

@export var CGLF: CGLF_Manager = null
@export var _clf_name_line_input: LineEdit = null
@export var _create_clf_button: Button = null

func _create_clf(name: String) -> void:
	self.hide()
	CGLF.create_clf(name)

func _on_focus_entered() -> void:
	_clf_name_line_input.grab_focus()

func _on_popup_hide() -> void:
	_clf_name_line_input.clear()

func _on_light_function_name_input_text_changed(new_text: String) -> void:
	if new_text.length() == 0:
		_create_clf_button.disabled = true
	else:
		_create_clf_button.disabled = false

func _on_light_function_name_input_text_submitted(new_text: String) -> void:
	if _create_clf_button.disabled == false:
		_create_clf(new_text)

func _on_cancel_light_function_creation_button_pressed() -> void:
	self.hide()

func _on_create_light_function_button_pressed() -> void:
	_create_clf(_clf_name_line_input.text)
