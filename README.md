# CGLF — Custom Global Light Function

Provides a manager to define and customize a single centralized custom global light() function shared across all or chosen shaders in the project.

## Why use this plugin?

- Development friendly manager to keep consistent lighting throughout your project. No more copy and paste nightmares!
- Change your lighting logic in one place and it automatically updates on all shaders files!
- No extra resources cost for running screen-space lighting logic. More FPS, more happiness!

## Features
- Define a global `light()` function once and reuse it everywhere.
- Easily managed through the plugin dock.
- Choose which shader types get affected.
- Optionally replace existing `light()` functions automatically.
- Blacklist for shader files not meant to be affected by CGLF.
- Currently only .gdshader files are supported.

## Installation

### A — Asset Library

1. Add the plugin to your project via the Asset Library.
2. In Godot, go to **Project → Project Settings → Plugins** and enable **CGLF — Custom Global Light Function**.

### B — Repository

1. Download or clone this repository.
2. Copy the `addons/custom_global_light_function` folder into your Godot project.
3. In Godot, go to **Project → Project Settings → Plugins** and enable **CGLF — Custom Global Light Function**.

## Usage
1. Find the plugin's dock on Godot's right dock.
2. Usage:
   	- **Include File Path** → Path to your shared `.gdshaderinc` file containing the global `light()` function.
	- **Open File Path** → Open the `.gdshaderinc` file to edit.
	- **Copy File Path** → Copies the `.gdshaderinc` file path to clipboard.
	- **Copy Injection Code** → Copies include boiler plate to clipboard for manually addition.
	- **Update Shaders** → Updates all shaders with CGLF's current settings.
   	- **Ignore Blacklist** → Ignores the blacklist rule while updating shader files.
   	- **Replace Existing Light Functions** → Automatically replaces `light()` functions already present in shaders.
   	- **Blacklist** → List of shaders to exclude.

## Planned Future Additions

- Add support for in-scene saved Shaders
- Add support to Materials
- Add support to visual shaders