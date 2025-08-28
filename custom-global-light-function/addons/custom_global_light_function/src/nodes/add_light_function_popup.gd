@tool
extends PopupPanel

@export var CGLF: CGLF_Manager = null
@export var _light_function_name_input: LineEdit = null
@export var _create_light_function_button: Button = null

func _create_light_function(name: String) -> void:
	self.hide()
	CGLF.create_light_function(name)

func _on_focus_entered() -> void:
	_light_function_name_input.grab_focus()

func _on_popup_hide() -> void:
	_light_function_name_input.clear()

func _on_light_function_name_input_text_changed(new_text: String) -> void:
	if new_text.length() == 0:
		_create_light_function_button.disabled = true
	else:
		_create_light_function_button.disabled = false

func _on_light_function_name_input_text_submitted(new_text: String) -> void:
	if _create_light_function_button.disabled == false:
		_create_light_function(new_text)

func _on_cancel_light_function_creation_button_pressed() -> void:
	self.hide()

func _on_create_light_function_button_pressed() -> void:
	_create_light_function(_light_function_name_input.text)
