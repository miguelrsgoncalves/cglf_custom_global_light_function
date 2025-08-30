@tool
extends OptionButton

@export var CGLF: CGLF_Manager = null

func _on_item_selected(index: int) -> void:
	CGLF.current_clf_index = index
	CGLF.current_clf = CGLF.clf_array[index]
	CGLF.load_settings()
