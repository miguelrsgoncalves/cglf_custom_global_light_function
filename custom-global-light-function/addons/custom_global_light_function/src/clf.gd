@tool
class_name CustomLightFunction
extends RefCounted

# General

var name: String = ""

# Update Shaders Settings ------------- #
var include_file_path: String = ""
var ignore_blacklist: bool = false
var replace_existing_light_functions: bool = false

# Shader Types
var shader_types: Dictionary = {
		"spatial": false,
		"canvas_item": false,
		"particles": false,
		"sky": false,
		"fog": false
}

# Lists
var blacklist: PackedStringArray = []
var whitelist: PackedStringArray = []
#-------------------------------------- #

## Creates a new CLF object and saves it to Saved GLF
func create(dict: Dictionary, index: int) -> CustomLightFunction:
	_load_from_dict(dict)
	if not FileAccess.file_exists(include_file_path):
		DirAccess.open("res://").make_dir_recursive(CGLF_GV.clf_include_files_folder_path)
		var file := FileAccess.open(include_file_path, FileAccess.WRITE)
		var file_boilerplate: String = CGLF_GV.clf_include_boilerplate + name + "\nvoid light() {\n\n}"
		file.store_string(file_boilerplate)
		file.close()
	save(index)
	print("CGLF: New Light Function created with name: ", name)
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
		"ignore_blacklist": ignore_blacklist,
		"replace_existing_light_functions": replace_existing_light_functions,
		"shader_types": {
				"spatial": shader_types.get("spatial", false),
				"canvas_item": shader_types.get("canvas_item", false),
				"particles": shader_types.get("particles", false),
				"sky": shader_types.get("sky", false),
				"fog": shader_types.get("fog", false),
		},
		"blacklist": blacklist,
		"whitelist": whitelist
	}

## Saves values from dictionary to class
func _load_from_dict(data: Dictionary) -> void:	
	name = data.get("name", "")
	include_file_path = data.get("include_file_path", "")
	ignore_blacklist = data.get("ignore_blacklist", false)
	replace_existing_light_functions = data.get("replace_existing_light_functions", false)
	shader_types = data.get("shader_types", {
			"spatial": false,
			"canvas_item": false,
			"particles": false,
			"sky": false,
			"fog": false
	})
	blacklist = data.get("blacklist", PackedStringArray([]))
	whitelist = data.get("whitelist", PackedStringArray([]))

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
	OS.move_to_trash(ProjectSettings.globalize_path(include_file_path))
	file.close()
	print("CGLF: Deleted Light Function with name: ", name)

## Adds an item to one of the lists: blacklist or whitelist
func add_list_item(list: String, path: String, index: int):
	if list == "blacklist":
		blacklist.append(path)
	elif list == "whitelist":
		whitelist.append(path)
	else: push_error("CGLF: No list found with name: ", list)
	save(index)

## Removes an item to one of the lists: blacklist or whitelist
func remove_list_item(list: String, path: String, index: int):
	if list == "blacklist":
		blacklist.remove_at(blacklist.find(path))
	elif list == "whitelist":
		whitelist.remove_at(whitelist.find(path))
	else: push_error("CGLF: No list found with name: ", list)
	save(index)
