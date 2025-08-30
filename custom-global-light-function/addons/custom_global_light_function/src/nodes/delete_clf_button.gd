@tool
extends Button

@export var CGLF: CGLF_Manager = null
@export var _accept_dialog: AcceptDialog = null

func _ready() -> void:
	icon = EditorInterface.get_base_control().get_theme_icon("Remove", "EditorIcons")

func _on_pressed() -> void:
	_accept_dialog.popup()

func _on_accept_dialog_confirmed() -> void:
	CGLF.delete_light_function()
