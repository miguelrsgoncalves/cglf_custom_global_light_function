@tool
extends EditorPlugin

var dock : Control

func _enter_tree() -> void:
	dock = preload("res://addons/custom_global_light_function/src/cglf_dock.tscn").instantiate()
	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_UL, dock)

func _exit_tree() -> void:
	remove_control_from_docks(dock)
	dock.free()
