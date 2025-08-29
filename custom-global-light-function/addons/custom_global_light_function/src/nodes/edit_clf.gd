@tool
extends Button

func _ready() -> void:
	icon = EditorInterface.get_base_control().get_theme_icon("Edit", "EditorIcons")
