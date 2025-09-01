# CGLF — Custom Global Light Function

Provides a manager to define and customize a single centralized custom global light() function shared across all or chosen shaders in the project.

## Why use this plugin?

- Development friendly manager to keep consistent lighting throughout your project. No more copy and paste nightmares!
- Change your lighting logic in one place and it automatically updates on all shaders files!
- No extra resources cost for running screen-space lighting logic. More FPS, more happiness!

## Features
- Define a global `light()` function once and reuse it everywhere.
- Easily managed through the plugin dock.
- Create as many `light()` profiles as desired, called CLF (Custom Light Function).
- Choose which shader types get affected.
- CLLF (Custom Local Light Function) allows for smaller, isolated environments where one `light()` affects only desired shaders.
- Blacklist for shader files not meant to be affected by CLF.
- Currently only `.gdshader` files are supported.

## Installation

### A — Asset Library

1. Add the plugin to your project via the Asset Library.
2. In Godot, go to **Project → Project Settings → Plugins** and enable **CGLF — Custom Global Light Function**.

### B — Repository

1. Download or clone this repository.
2. Copy the `addons/cglf_custom_global_light_function` folder into your Godot project.
3. In Godot, go to **Project → Project Settings → Plugins** and enable **CGLF — Custom Global Light Function**.

## Usage
1. Find the plugin's dock on Godot's right dock.
2. Usage:
   	- **Create CLF** → To start create a CLF.
	- **Edit** → Open the `.gdshaderinc` file to edit.
	- **Copy Injection Code** → Copies include boiler plate to clipboard for manually addition.
	- **Inject Shaders** → Injects all shaders with CLF's current settings.
	- **CLLF** → Converts the CLF into a CLLF, changing it to a Custom Local Light Function which affects only shaders whitelisted.
   	- **Replace Existing Light Functions** → Automatically replaces `light()` functions already present in shaders.
	- **Shader Types** → List of shader types to be affected by the current CLF.
   	- **Blacklist** → List of shaders to exclude.
	- **Whitelist** → List of shaders to be affected only by the current CLF.

## Planned Future Additions

- Add support for in-scene saved Shaders
- Add support to Materials
- Add support to visual shaders