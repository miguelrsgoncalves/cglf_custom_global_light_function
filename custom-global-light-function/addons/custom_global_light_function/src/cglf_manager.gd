@tool
class_name CGLF_Manager
extends Control

var clf_array: Array[CustomLightFunction] = []
var current_clf: CustomLightFunction = null
var current_clf_index: int = 0

var _injection_boiler_plate_start: String = "\n\n//CGLF - "
var _injection_boiler_plate_ending: String = "\n//CGLF"

@export_category("Nodes")
@export var _clf_options_button: OptionButton = null
@export var _replace_existing_light_functions_checkbox: CheckBox = null
@export var _shader_type_spatial: CheckBox = null
@export var _shader_type_canvas_item: CheckBox = null
@export var _shader_type_particles: CheckBox = null
@export var _shader_type_sky: CheckBox = null
@export var _shader_type_fog: CheckBox = null
@export var _blacklist: ItemList = null
@export var _blacklist_input: LineEdit = null
@export var _whitelist: ItemList = null
@export var _whitelist_input: LineEdit = null

@export_category("View Nodes")
@export var _dock_views: TabContainer = null

func _ready() -> void:
	_load_saved_clf()
	# LOOKOUT FOR CHANGE PULL REQUEST https://github.com/godotengine/godot/pull/107275 TO SEE IF THEY EXPOSE THE SIGNAL WRITTEN BELLOW
	EditorInterface.get_file_system_dock().get_child(3).get_child(0).cell_selected.connect(_on_filesystemdock_file_selected)

func _load_saved_clf() -> void:
	clf_array.clear()
	_clf_options_button.clear()
	if FileAccess.file_exists(CGLF_GV.saved_clf_file_path):
		var file = FileAccess.open(CGLF_GV.saved_clf_file_path, FileAccess.READ)
		var file_data = file.get_as_text()
		file.close()
		var data = JSON.parse_string(file_data)
		if data && len(data) > 0:
			var index = 0
			for function in data:
				var _light_function := CustomLightFunction.new().instantiate(function, index)
				clf_array.append(_light_function)
				_clf_options_button.add_item(_light_function.name)
				index += 1
			_clf_options_button.disabled = false
			_dock_views.current_tab = 0
			_clf_options_button.selected = current_clf_index
			current_clf = clf_array[current_clf_index]
			_load_settings()
			_fill_lists_node()
		else:
			_clf_options_button.disabled = true
			_dock_views.current_tab = 1
	else:
		_clf_options_button.disabled = true
		_dock_views.current_tab = 1
		pass

func create_clf(name: String) -> void:
	var _split_name = name.split("_")
	var _split_name_capitulized: PackedStringArray = []
	for word in _split_name:
		_split_name_capitulized.append(word.capitalize())
	var _name_capitalized = " ".join(_split_name_capitulized)
	CustomLightFunction.new().create({
		"name": _name_capitalized,
		"include_file_path": CGLF_GV.clf_include_files_folder_path + name,
	}, clf_array.size())
	print("CGLF: New Light Function created with name: ", _name_capitalized)
	current_clf_index = _clf_options_button.item_count
	_load_saved_clf()

func delete_light_function() -> void:
	if clf_array.size() > 0:
		var _index: int = _clf_options_button.get_selected_id()
		print("CGLF: Deleted Light Function with name: ", clf_array[_index].name)
		clf_array[_index].delete(_index)
		clf_array.remove_at(_index)
		current_clf_index = clampi(_index - 1, 0, INF as int)
		_load_saved_clf()

func _update_shaders() -> void:
	var shader_files = _find_shader_files("res://")
	if shader_files.size() > 0:
		print("CGLF: The following ERRORS, one per shader file updated, are expected and are part of the inner works of the plugin! Didn't find a way to not make them appear :(")
		var files_injected: int = _inject_custom_global_light_function(shader_files)
		if files_injected > 0:
			print("CGLF: Added Custom Global Light Function to ", files_injected, " shaders!")
		else:
			print("CGLF: OOOPS... No shaders were updated!")
	else:
		print("CGLF: No shaders files found! Go create some!")

func _find_shader_files(path: String) -> Array:
	var results: Array = []
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				results += _find_shader_files(path.path_join(file_name))
			elif file_name.ends_with(".gdshader") or file_name.ends_with(".shader"):
				results.append(path.path_join(file_name))
			file_name = dir.get_next()
		dir.list_dir_end()
	return results

func _inject_custom_global_light_function(shader_files: Array) -> int:
	var counter: int = 0
	for shader_file in shader_files:
		if shader_file in current_clf.blacklist: continue
		var shader_file_resource = ResourceLoader.load(shader_file, "Shader", ResourceLoader.CACHE_MODE_IGNORE_DEEP)
		if shader_file_resource is Shader:
			var code: String = shader_file_resource.code
			
			# Check project settings for this type
			var shader_type := _get_shader_type(code)
			var setting_key = "rendering/cglf/shader_types/" + shader_type
			var enabled = ProjectSettings.has_setting(setting_key) and ProjectSettings.get_setting(setting_key)
			
			if !enabled:
				var boilerplate_regex := RegEx.new()
				boilerplate_regex.compile(_injection_boiler_plate_start + '#include ".*"' + _injection_boiler_plate_ending)
				if boilerplate_regex.search(code):
					code = boilerplate_regex.sub(code, "", true)
					shader_file_resource.code = code
					ResourceSaver.save(shader_file_resource, shader_file, ResourceSaver.FLAG_REPLACE_SUBRESOURCE_PATHS)
					
					var fs_dock = EditorInterface.get_file_system_dock()
					fs_dock.file_removed.emit(shader_file)
					
					var fs = EditorInterface.get_resource_filesystem()
					fs.reimport_files([shader_file])
				continue
			
			# Skip file if it has a light func and replace_existing_light_func is OFF
			var light_func_regex := RegEx.new()
			light_func_regex.compile(r"(?ms)^[ \t\r\n]*void[ \t]+light\s*\([^)]*\)\s*\{.*?\}[ \t\r\n]*")
			var has_light_func = light_func_regex.search(code)
			if has_light_func && !_replace_existing_light_functions_checkbox.button_pressed: continue
			
			var commented_light_func_regex := RegEx.new()
			commented_light_func_regex.compile(r"(?ms)^[ \t\r\n]*//[ \t]*void[ \t]+light\s*\([^)]*\)\s*\{.*?\}[ \t\r\n]*")
			code = commented_light_func_regex.sub(code, "", true)
			
			if has_light_func && _replace_existing_light_functions_checkbox.button_pressed:
				code = light_func_regex.sub(code, "", true)
			
			# Checks for already injected CGLF
			var boilerplate_regex := RegEx.new()
			boilerplate_regex.compile(_injection_boiler_plate_start + '#include ".*"' + _injection_boiler_plate_ending)
			if boilerplate_regex.search(code):
				var include_regex := RegEx.new()
				include_regex.compile('#include ".*"')
				code = include_regex.sub(code, '#include "' + current_clf.include_file_path + '"', true)
			else:
				code += _injection_boiler_plate_start + '#include "' + current_clf.include_file_path + '"' + _injection_boiler_plate_ending
			
			shader_file_resource.code = code
			ResourceSaver.save(shader_file_resource, shader_file, ResourceSaver.FLAG_REPLACE_SUBRESOURCE_PATHS)
			
			var fs_dock = EditorInterface.get_file_system_dock()
			fs_dock.file_removed.emit(shader_file)
			
			var fs = EditorInterface.get_resource_filesystem()
			fs.reimport_files([shader_file])
			counter += 1
	return counter

func generate_boilerplate():
	var name: String = current_clf.name
	var path: String = current_clf.include_file_path
	var boiler_plate: String = _injection_boiler_plate_start + name + "\n" + '#include "' + path + '"' + _injection_boiler_plate_ending
	return boiler_plate

func _get_shader_type(code: String) -> String:
	var regex := RegEx.new()
	regex.compile(r"(?m)^[ \t]*shader_type[ \t]+([a-zA-Z_]+)[ \t]*;")
	var match = regex.search(code)
	if match:
		return match.get_string(1)
	return ""

func _load_settings():
	_replace_existing_light_functions_checkbox.button_pressed = current_clf.replace_existing_light_functions
	_shader_type_spatial.button_pressed = current_clf.shader_types.get("spatial")
	_shader_type_canvas_item.button_pressed = current_clf.shader_types.get("canvas_item")
	_shader_type_particles.button_pressed = current_clf.shader_types.get("particles")
	_shader_type_sky.button_pressed = current_clf.shader_types.get("sky")
	_shader_type_fog.button_pressed = current_clf.shader_types.get("fog")

func _fill_lists_node():
	_blacklist.clear()
	_whitelist.clear()
	for item in current_clf.blacklist:
		_blacklist.add_item(item)
	for item in current_clf.whitelist:
		_whitelist.add_item(item)

func _on_filesystemdock_file_selected():
	var path = EditorInterface.get_selected_paths()[0]
	var selected_file_path = path
	if(selected_file_path.contains(".gdshader") && !selected_file_path.contains(".gdshaderinc")):
		_blacklist_input.text = path
		_blacklist_input.text_changed.emit(path)
		_whitelist_input.text = path
		_blacklist_input.text_changed.emit(path)
	else:
		_blacklist_input.clear()
		_whitelist_input.clear()

func add_blacklisted_item():
	var path = _blacklist_input.text
	if  path in current_clf.blacklist:
		print("CGLF: Shader file already blacklisted! You must really hate this one!!")
		_blacklist_input.clear()
	elif(!FileAccess.file_exists(path)):
		print("CGLF: Shader file doesnt exist! It hasn't even been made and you already hate it!!")
	else:
		current_clf.add_list_item("blacklist", path, current_clf_index)
		_blacklist_input.clear()
		print("CGLF: Shader file blacklisted! Good job!")
		_fill_lists_node()

func remove_blacklisted_item():
	var removed_item = _blacklist.get_selected_items()[0]
	var removed_item_path =  _blacklist.get_item_text(removed_item)
	_blacklist.remove_item(removed_item)
	current_clf.remove_list_item("blacklist", removed_item_path, current_clf_index)
	print("CGLF: Shader back in business!")

func add_whitelisted_item():
	var path = _whitelist_input.text
	if  path in current_clf.whitelist:
		print("CGLF: Shader file already whitelisted! You must really love this one!!")
		_whitelist_input.clear()
	elif(!FileAccess.file_exists(path)):
		print("CGLF: Shader file doesnt exist! It hasn't even been made and you already love it!!")
	else:
		current_clf.add_list_item("whitelist", path, current_clf_index)
		_whitelist_input.clear()
		print("CGLF: Shader file whitelisted! Good job!")
		_fill_lists_node()

func remove_whitelisted_item():
	var removed_item = _whitelist.get_selected_items()[0]
	var removed_item_path =  _whitelist.get_item_text(removed_item)
	_whitelist.remove_item(removed_item)
	current_clf.remove_list_item("whitelist", removed_item_path, current_clf_index)
	print("CGLF: Shader no longer among the favorites!")
