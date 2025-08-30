@tool
extends Button

@export var _popup: PopupPanel = null

func _ready() -> void:
	icon = EditorInterface.get_base_control().get_theme_icon("New", "EditorIcons")

func _on_pressed() -> void:
	_popup.popup()
