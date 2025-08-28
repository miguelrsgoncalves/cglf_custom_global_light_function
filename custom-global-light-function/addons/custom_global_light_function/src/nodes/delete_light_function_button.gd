@tool
extends Button

@export var CGLF: CGLF_Manager = null

func _ready() -> void:
	icon = EditorInterface.get_base_control().get_theme_icon("Remove", "EditorIcons")

func _on_pressed() -> void:
	CGLF.delete_light_function()
