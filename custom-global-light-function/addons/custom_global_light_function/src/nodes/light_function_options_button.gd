@tool
extends OptionButton

@export var CGLF: CGLF_Manager = null

func _on_item_selected(index: int) -> void:
	CGLF._current_light_function_index = index
