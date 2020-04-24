<p align="center">
	<a>
		<img width="128px" src="./assets/VoxelCore.svg?sanitize=true" alt="VOXEL-CORE" />
		<h1 align="center">
			Voxel-Core
		</h1>
	</a>
</p>


<p align="center">
	<a href="https://github.com/ClarkThyLord/Voxel-Core/releases">
		<img src="https://img.shields.io/badge/Version-2.0.3-green.svg" alt="Version">
	</a>
	<a href="https://godotengine.org/asset-library/asset/465">
		<img src="https://img.shields.io/badge/Godot-AssetLibrary-blue.svg?logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAAYdEVYdFNvZnR3YXJlAHBhaW50Lm5ldCA0LjEuNv1OCegAAACZSURBVDhPzYzBDYMwEAQt0VjCJxWkq1TBkybyIU3kw58iAJ1vF1bmUBLEIyONbN/tOp3O7fGcTDwz0WwXhiMR2cJlWYjU/EIZ+sZ721aoH/sAVYfD7j1MhgapMcoOVYfD66XOGizx5I5ZVB0OGdQ37/qxiarD4S+i6uSvAQPNq1/kTEHV0QDvkbpHdUWDn0RlSxQuRfRvSGkGI8iOwHqmdCcAAAAASUVORK5CYII=" alt="AssetLibrary">
	</a>
	<a href="https://github.com/ClarkThyLord/Voxel-Core/blob/master/LICENSE">
		<img src="https://img.shields.io/badge/License-MIT-brightgreen.svg" alt="License">
	</a>
</p>

> Voxels in Godot!

---

# About
Voxel-Core is a plugin for [Godot](https://github.com/godotengine/godot) made with GDScript, it was created as the ‘core’ for my other project [Voxly](https://github.com/ClarkThyLord/Voxly), offering various VoxelObjects used to display voxels, as well as a in-engine editor.

## Features
- VoxelSet, inherits [Node](https://docs.godotengine.org/en/latest/classes/class_node.html), functions as a sort of TileSet in which you predefine voxels
- VoxelObject, inherits [MeshInstance](https://docs.godotengine.org/en/latest/classes/class_meshinstance.html), used to visualize voxels
	- UV Mapping, optional
	- Meshing, capable of naive(culled) and greedy meshing
	- StaticBody, optional, generates and maintains their own trimesh [StaticBody](https://docs.godotengine.org/en/latest/classes/class_staticbody.html)
- VoxelEditor, inherits [Spatial](https://docs.godotengine.org/en/latest/classes/class_spatial.html), can be used to edit VoxelObjects in a interactive way
- A fully featured VoxelEditor in-engine
	- Undo & Redo operations
	- Miror x, y and z operations
	- Individual or Area operations
	- Tools: add, sub, swap, pick and more
	- Much more...
- Import Textures and Vox(MagicaVoxel) files as Meshes or VoxelObjects

## [Feature Video](https://youtu.be/CLgzs6Z6BhA)

# [Usage / Docs](https://github.com/ClarkThyLord/Voxel-Core/wiki)


# Getting Voxel-Core
The following are two main ways you can get Voxel-Core:

## Godot Asset Library
Preferably, since Voxel-Core is available in [Godot Asset Library](https://godotengine.org/asset-library/asset/465), you can download and install it directly to your project from within Godot through the 'AssetLib' tab in-engine, search for 'Voxel-Core'. Once you're installing Voxel-Core, Godot will ask you to select what you'd like to install, if you only want the plugin then only select the `addons` folder, but you can also choose to install anything else in this repository such as the `examples`. After installing, you'll need to activate Voxel-Core in your projects configuration.

## Download / Clone
If you don't feel like downloading it from within Godot, you can also download / clone this repository, and once you do you'll find that the plugin is contained in: `Voxel-Core/addons/Voxel-Core/`


You can move the Voxel-Core plugin folder to your own project’s `addons` folder, after which you'll need to activate Voxel-Core in your projects configuration to use it. Another thing you can do is import and run the project itself, as it contains several examples of how the plugin can be used.

---

<p align="center">
	<a href="https://godotengine.org/asset-library/asset/465" style="vertical-align: middle;">
		Asset Library
	</a>
	<a href="https://github.com/ClarkThyLord/Voxel-Core/blob/master/LICENSE" style="vertical-align: middle;">
		MIT LICENSE
	</a>
</p>
