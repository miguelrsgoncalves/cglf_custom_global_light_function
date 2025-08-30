@tool
extends LineEdit

@export var _CGLF: CGLF_Manager = null
@export var _add_button: Button = null

func _ready() -> void:
	clear()

func _on_text_changed(new_text: String) -> void:
	if new_text.is_empty(): _add_button.disabled = true
	else: _add_button.disabled = false

func _on_text_submitted(new_text: String) -> void:
	if not new_text.is_empty(): _CGLF.add_whitelisted_item()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		clear()
