@tool
class_name CGLF_Manager
extends Control

var _cglf_light_functions: Array[CustomGlobalLightFunction] = []
var _current_light_function: int = 0

var _cglf_injection_path: String = "res://addons/custom_global_light_function/include_files/cglf.gdshaderinc"
var _blacklisted_files: PackedStringArray = []

var _cglf_injection_boiler_plate: String = "\n\n//CGLF - Custom Global Light Function\n"
var _cglf_injection_boiler_plate_ending: String = "\n//CGLF"

@export_category("Nodes")
@export var _light_function_options_button: OptionButton = null
@export var _cglf_inc_path_text_window: LineEdit = null
@export var _ignore_blacklist_checkbox: CheckBox = null
@export var _replace_existing_light_functions_checkbox: CheckBox = null
@export var _shader_type_spatial: CheckBox = null
@export var _shader_type_canvas_item: CheckBox = null
@export var _shader_type_particles: CheckBox = null
@export var _shader_type_sky: CheckBox = null
@export var _shader_type_fog: CheckBox = null
@export var _blacklist: ItemList = null
@export var _blacklist_input: LineEdit = null

@export_category("View Nodes")
@export var _light_function_view: Control = null
@export var _no_light_function_view: Control = null

func _ready() -> void:
	_load_light_functions()
	# LOOKOUT FOR CHANGE PULL REQUEST https://github.com/godotengine/godot/pull/107275 TO SEE IF THEY EXPOSE THE SIGNAL WRITTEN BELLOW
	EditorInterface.get_file_system_dock().get_child(3).get_child(0).cell_selected.connect(_on_filesystemdock_file_selected)
	_fill_blacklist_node()

func _load_light_functions() -> void:
	if FileAccess.file_exists(CGLF_Global_Variables.saved_light_functions_file_path):
		var file = FileAccess.open(CGLF_Global_Variables.saved_light_functions_file_path, FileAccess.READ)
		var file_data = file.get_as_text()
		file.close()
		var data = JSON.parse_string(file_data)
		if data:
			_cglf_light_functions.clear()
			_light_function_options_button.clear()
			var index = 0
			for function in data:
				var _new_light_function := CustomGlobalLightFunction.new().create(function, index)
				_cglf_light_functions.append(_new_light_function)
				_light_function_options_button.add_item(_new_light_function.inc_file_path)
				index += 1
		_no_light_function_view.hide()
		_light_function_options_button.disabled = false
		_light_function_view.show()
	else:
		_light_function_view.hide()
		_light_function_options_button.disabled = true
		_no_light_function_view.show()
		pass

func create_light_function(name: String) -> void:
	CustomGlobalLightFunction.new().create({
		"inc_file_path": CGLF_Global_Variables.light_functions_include_files_folder_path + name,
		"blacklisted_items": _blacklisted_files,
		"ignore_blacklist": _ignore_blacklist_checkbox.button_pressed,
		"replace_existing_light_functions": _replace_existing_light_functions_checkbox.button_pressed,
		"shader_type_spatial": _shader_type_spatial.button_pressed,
		"shader_type_canvas_item": _shader_type_canvas_item.button_pressed,
		"shader_type_particles": _shader_type_particles.button_pressed,
		"shader_type_sky": _shader_type_sky.button_pressed,
		"shader_type_fog": _shader_type_fog.button_pressed
	}, _cglf_light_functions.size())
	_load_light_functions()
	print("CGLF: New Light Function created with name: ", name)

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

func _inject_custom_global_light_function(shader_files: Array, code_injection_path: String = _cglf_injection_path) -> int:
	var counter: int = 0
	for shader_file in shader_files:
		if shader_file in _blacklisted_files && !_ignore_blacklist_checkbox.button_pressed: continue
		var shader_file_resource = ResourceLoader.load(shader_file, "Shader", ResourceLoader.CACHE_MODE_IGNORE_DEEP)
		if shader_file_resource is Shader:
			var code: String = shader_file_resource.code
			
			# Check project settings for this type
			var shader_type := _get_shader_type(code)
			var setting_key = "rendering/cglf/shader_types/" + shader_type
			var enabled = ProjectSettings.has_setting(setting_key) and ProjectSettings.get_setting(setting_key)
			
			if !enabled:
				var boilerplate_regex := RegEx.new()
				boilerplate_regex.compile(_cglf_injection_boiler_plate + '#include ".*"' + _cglf_injection_boiler_plate_ending)
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
			boilerplate_regex.compile(_cglf_injection_boiler_plate + '#include ".*"' + _cglf_injection_boiler_plate_ending)
			if boilerplate_regex.search(code):
				var include_regex := RegEx.new()
				include_regex.compile('#include ".*"')
				code = include_regex.sub(code, '#include "' + code_injection_path + '"', true)
			else:
				code += _cglf_injection_boiler_plate + '#include "' + code_injection_path + '"' + _cglf_injection_boiler_plate_ending
			
			shader_file_resource.code = code
			ResourceSaver.save(shader_file_resource, shader_file, ResourceSaver.FLAG_REPLACE_SUBRESOURCE_PATHS)
			
			var fs_dock = EditorInterface.get_file_system_dock()
			fs_dock.file_removed.emit(shader_file)
			
			var fs = EditorInterface.get_resource_filesystem()
			fs.reimport_files([shader_file])
			counter += 1
	return counter

func _open_cglf_inc():
	if not FileAccess.file_exists(_cglf_injection_path):
		print("CGLF: Include file not found: %s" % _cglf_injection_path)
		return
	
	var _cglf_injection = load(_cglf_injection_path)
	if _cglf_injection:
		EditorInterface.edit_resource(_cglf_injection)
	else:
		print("CGLF: Failed to load ShaderInclude resource at: %s" % _cglf_injection_path)
		
func _cglf_copy_path_pressed() -> void:
	DisplayServer.clipboard_set(_cglf_injection_path)
	print("CGLF : CGLF Include file path copied to clipboard!")
	
func _cglf_copy_boilerplate(code_injection_path: String = _cglf_injection_path):
	DisplayServer.clipboard_set(_cglf_injection_boiler_plate + '#include "' + code_injection_path + '"' + _cglf_injection_boiler_plate_ending)
	print("CGLF : CGLF Include file injection copied to clipboard!")

func _add_blacklist_item():
	if _blacklist_input.text == "":
		print("CGLF: Blacklist input is empty! You cannot add what isn't there!")
	elif  _blacklist_input.text in _blacklisted_files:
		print("CGLF: Shader file already blacklisted! You must really hate this one!!")
	elif(!FileAccess.file_exists(_blacklist_input.text)):
		print("CGLF: Shader file doesnt exist! Try another path!")
	else:
		_blacklisted_files.append(_blacklist_input.text)
		_blacklist_input.clear()
		_fill_blacklist_node()
		_save_project_setting("rendering/cglf/blacklisted_items", _blacklisted_files)

func _remove_blacklisted_item():
	if _blacklist.get_selected_items().size() == 0:
		print("CGLF: No file selected to be removed! What exactly did you think would happen? :/")
		return
	var removed_item = _blacklist.get_selected_items()[0]
	var removed_item_path =  _blacklist.get_item_text(removed_item)
	_blacklist.remove_item(removed_item)
	_blacklisted_files.remove_at(_blacklisted_files.find(removed_item_path))
	_save_project_setting("rendering/cglf/blacklisted_items", _blacklisted_files)

func _fill_blacklist_node():
	_blacklist.clear()
	for item in _blacklisted_files:
		_blacklist.add_item(item)

func _save_project_setting(setting: String, value) -> void:
	ProjectSettings.set_setting(setting, value)
	ProjectSettings.save()

func _get_shader_type(code: String) -> String:
	var regex := RegEx.new()
	regex.compile(r"(?m)^[ \t]*shader_type[ \t]+([a-zA-Z_]+)[ \t]*;")
	var match = regex.search(code)
	if match:
		return match.get_string(1)
	return ""

func _on_filesystemdock_file_selected():
	var selected_file_path = EditorInterface.get_selected_paths()[0]
	if(selected_file_path.contains(".gdshader") && !selected_file_path.contains(".gdshaderinc")):
		_blacklist_input.text = EditorInterface.get_selected_paths()[0]
	else:
		_blacklist_input.clear()

func _on_cglf_inc_path_text_window_text_changed(new_text: String) -> void:
	_cglf_injection_path = new_text
	_save_project_setting("rendering/cglf/include_file_path", _cglf_injection_path)

func _on_ignore_blacklist_pressed() -> void:
	_save_project_setting("rendering/cglf/ignore_blacklist", _ignore_blacklist_checkbox.button_pressed)

func _on_replace_existing_light_functions_pressed() -> void:
	_save_project_setting("rendering/cglf/replace_existing_light_functions", _ignore_blacklist_checkbox.button_pressed)

func _on_spatial_pressed() -> void:
	_save_project_setting("rendering/cglf/shader_types/spatial", _shader_type_spatial.button_pressed)

func _on_canvas_item_pressed() -> void:
	_save_project_setting("rendering/cglf/shader_types/canvas_item", _shader_type_canvas_item.button_pressed)

func _on_particles_pressed() -> void:
	_save_project_setting("rendering/cglf/shader_types/particles", _shader_type_particles.button_pressed)

func _on_sky_pressed() -> void:
	_save_project_setting("rendering/cglf/shader_types/sky", _shader_type_sky.button_pressed)

func _on_fog_pressed() -> void:
	_save_project_setting("rendering/cglf/shader_types/fog", _shader_type_fog.button_pressed)
