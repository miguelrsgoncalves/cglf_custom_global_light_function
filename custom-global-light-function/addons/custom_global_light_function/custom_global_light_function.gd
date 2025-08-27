@tool
extends EditorPlugin

var dock : Control

func _enter_tree() -> void:
	_add_project_setting()
	#_remove_project_settings()
	
	dock = preload("res://addons/custom_global_light_function/cglf.tscn").instantiate()
	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_UL, dock)

func _exit_tree() -> void:
	remove_control_from_docks(dock)
	dock.free()
	_remove_project_settings()

func _add_project_setting():
	_register_project_setting("rendering/cglf/include_file_path", "res://addons/custom_global_light_function/cglf.gdshaderinc")
	_register_project_setting("rendering/cglf/ignore_blacklist", false)
	_register_project_setting("rendering/cglf/replace_existing_light_functions", false)
	_register_project_setting("rendering/cglf/blacklisted_items", PackedStringArray([]))
	_register_project_setting("rendering/cglf/shader_types/spatial", true)
	_register_project_setting("rendering/cglf/shader_types/canvas_item", false)
	_register_project_setting("rendering/cglf/shader_types/particles", false)
	_register_project_setting("rendering/cglf/shader_types/sky", false)
	_register_project_setting("rendering/cglf/shader_types/fog", false)
	
func _register_project_setting(name: String, default_value, hint: int = PROPERTY_HINT_NONE, hint_string: String = ""):
	if not ProjectSettings.has_setting(name):
		ProjectSettings.set_setting(name, default_value)
	ProjectSettings.set_initial_value(name, default_value)
	ProjectSettings.add_property_info({
		"name": name,
		"type": typeof(default_value),
		"hint": hint,
		"hint_string": hint_string
	})

func _remove_project_settings():
	_unregister_project_setting("rendering/cglf/include_file_path")
	_unregister_project_setting("rendering/cglf/ignore_blacklist")
	_unregister_project_setting("rendering/cglf/replace_existing_light_functions")
	_unregister_project_setting("rendering/cglf/blacklisted_items")
	_unregister_project_setting("rendering/cglf/shader_types/spatial")
	_unregister_project_setting("rendering/cglf/shader_types/canvas_item")
	_unregister_project_setting("rendering/cglf/shader_types/particles")
	_unregister_project_setting("rendering/cglf/shader_types/sky")
	_unregister_project_setting("rendering/cglf/shader_types/fog")

func _unregister_project_setting(name: String):
	if ProjectSettings.has_setting(name):
		ProjectSettings.clear(name)
