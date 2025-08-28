class_name CustomGlobalLightFunction
extends RefCounted

## Update Shaders Settings ------------- ##
## General
var inc_file_path: String = ""
var blacklisted_items: PackedStringArray = []
var ignore_blacklist: bool = false
var replace_existing_light_functions: bool = false

## Shader Types
var shader_type_spatial: bool = false
var shader_type_canvas_item: bool = false
var shader_type_particles: bool = false
var shader_type_sky: bool = false
var shader_type_fog: bool = false
##-------------------------------------- ##

## Converts class to dictionary to save to JSON file
func to_dict() -> Dictionary:
	return {
		"inc_file_path": inc_file_path,
		"blacklisted_items": blacklisted_items,
		"ignore_blacklist": ignore_blacklist,
		"replace_existing_light_functions": replace_existing_light_functions,
		"shader_type_spatial": shader_type_spatial,
		"shader_type_canvas_item": shader_type_canvas_item,
		"shader_type_particles": shader_type_particles,
		"shader_type_sky": shader_type_sky,
		"shader_type_fog": shader_type_fog
	}

## Saves values from dictionary to class
func from_dict(data: Dictionary) -> void:
	inc_file_path = data.get("inc_file_path", "")
	blacklisted_items = data.get("blacklisted_items", PackedStringArray([]))
	ignore_blacklist = data.get("ignore_blacklist", false)
	replace_existing_light_functions = data.get("replace_existing_light_functions", false)
	shader_type_spatial = data.get("shader_type_spatial", false)
	shader_type_canvas_item = data.get("shader_type_canvas_item", false)
	shader_type_particles = data.get("shader_type_particles", false)
	shader_type_sky = data.get("shader_type_sky", false)
	shader_type_fog = data.get("shader_type_fog", false)

## Saves this instance into the JSON file by ID, replacing if it exists or adds if not
func save(index: int, path: String = "res://addons/custom_global_light_function/src/cglf_functions.json") -> void:
	var file: FileAccess
	if not FileAccess.file_exists(path):
		file = FileAccess.open(path, FileAccess.WRITE_READ)
		file.store_string("[\n]")
	else:
		file = FileAccess.open(path, FileAccess.READ)
	var file_data = file.get_as_text()
	file.close()
	var data = JSON.parse_string(file_data)
	if index >= 0 and index < data.size():
		data[index] = to_dict()
	else:
		data.append(to_dict())
	file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t", false))
	file.close()

## Loads an instance from the given index
func load(index: int, path: String = "res://addons/custom_global_light_function/src/cglf_functions.json") -> void:
	var file = FileAccess.open(path, FileAccess.READ)
	var file_data = file.get_as_text()
	file.close()
	var data = JSON.parse_string(file_data)
	if data:
		from_dict(data[index])
