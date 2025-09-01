@tool
extends Button

@export var CGLF: CGLF_Manager = null

func _ready() -> void:
	icon = EditorInterface.get_base_control().get_theme_icon("Edit", "EditorIcons")

func _on_pressed() -> void:
	var path = CGLF.current_clf.include_file_path
	if not FileAccess.file_exists(path):
		print("CGLF: Include file not found: %s" % path)
		return
	
	var file = load(path)
	if file:
		EditorInterface.edit_resource(file)
	else:
		print("CGLF: Failed to load ShaderInclude resource at: %s" % path)
