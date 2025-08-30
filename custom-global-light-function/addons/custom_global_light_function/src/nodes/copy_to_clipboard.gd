@tool
extends Button

@export var CGLF: CGLF_Manager = null

func _ready() -> void:
	icon = EditorInterface.get_base_control().get_theme_icon("ActionCopy", "EditorIcons")

func _on_pressed() -> void:
	DisplayServer.clipboard_set(CGLF.generate_boilerplate())
	print("CGLF : CGLF Include file injection copied to clipboard! Go ahead and don't use the manager :(")
