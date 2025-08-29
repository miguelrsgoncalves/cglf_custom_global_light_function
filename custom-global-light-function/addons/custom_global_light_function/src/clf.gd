@tool
class_name CustomLightFunction
extends RefCounted

## General

var name: String = ""

## Update Shaders Settings ------------- ##
var include_file_path: String = ""
var blacklisted_items: PackedStringArray = []
var ignore_blacklist: bool = false
var replace_existing_light_functions: bool = false

## Shader Types
var shader_types: Dictionary = {
		"spatial": false,
		"canvas_item": false,
		"particles": false,
		"sky": false,
		"fog": false
}
##-------------------------------------- ##

## Creates a new CLF object and saves it to Saved GLF
func create(dict: Dictionary, index: int) -> CustomLightFunction:
	_load_from_dict(dict)
	save(index)
	return self

## Creates CLF object
func instantiate(dict: Dictionary, index: int) -> CustomLightFunction:
	_load_from_dict(dict)
	return self

## Converts class to dictionary to save to JSON file
func _save_to_dict() -> Dictionary:
	return {
		"name": name,
		"include_file_path": include_file_path,
		"blacklisted_items": blacklisted_items,
		"ignore_blacklist": ignore_blacklist,
		"replace_existing_light_functions": replace_existing_light_functions,
		"shader_types": {
				"spatial": shader_types.get("spatial", false),
				"canvas_item": shader_types.get("canvas_item", false),
				"particles": shader_types.get("particles", false),
				"sky": shader_types.get("sky", false),
				"fog": shader_types.get("fog", false),
		}
	}

## Saves values from dictionary to class
func _load_from_dict(data: Dictionary) -> void:	
	name = data.get("name", "")
	include_file_path = data.get("include_file_path", "")
	blacklisted_items = data.get("blacklisted_items", PackedStringArray([]))
	ignore_blacklist = data.get("ignore_blacklist", false)
	replace_existing_light_functions = data.get("replace_existing_light_functions", false)
	shader_types = data.get("shader_types", {
			"spatial": false,
			"canvas_item": false,
			"particles": false,
			"sky": false,
			"fog": false
	})

## Saves this instance into the JSON file by ID, replacing if it exists or adds if not
func save(index: int) -> void:
	var file: FileAccess
	if not FileAccess.file_exists(CGLF_GV.saved_clf_file_path):
		file = FileAccess.open(CGLF_GV.saved_clf_file_path, FileAccess.WRITE_READ)
		file.store_string("[]")
	else:
		file = FileAccess.open(CGLF_GV.saved_clf_file_path, FileAccess.READ)
	var file_data = file.get_as_text()
	file.close()
	var data = JSON.parse_string(file_data)
	if index >= 0 and index < data.size():
		data[index] = _save_to_dict()
	else:
		data.append(_save_to_dict())
	file = FileAccess.open(CGLF_GV.saved_clf_file_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t", false))
	file.close()

## Loads an instance from the given index
func load(index: int) -> void:
	var file = FileAccess.open(CGLF_GV.saved_clf_file_path, FileAccess.READ)
	var file_data = file.get_as_text()
	file.close()
	var data = JSON.parse_string(file_data)
	if data:
		_load_from_dict(data[index])

## Deletes an instance with the given index
func delete(index: int) -> void:
	var file = FileAccess.open(CGLF_GV.saved_clf_file_path, FileAccess.READ)
	var file_data = file.get_as_text()
	file.close()
	var data = JSON.parse_string(file_data)
	data.remove_at(index)
	file = FileAccess.open(CGLF_GV.saved_clf_file_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t", false))
	file.close()
