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
		<img src="https://img.shields.io/badge/Version-3.0.0-green.svg" alt="Version">
	</a>
	<a href="https://godotengine.org/asset-library/asset/465">
		<img src="https://img.shields.io/badge/Godot-AssetLibrary-blue.svg?logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAAYdEVYdFNvZnR3YXJlAHBhaW50Lm5ldCA0LjEuNv1OCegAAACZSURBVDhPzYzBDYMwEAQt0VjCJxWkq1TBkybyIU3kw58iAJ1vF1bmUBLEIyONbN/tOp3O7fGcTDwz0WwXhiMR2cJlWYjU/EIZ+sZ721aoH/sAVYfD7j1MhgapMcoOVYfD66XOGizx5I5ZVB0OGdQ37/qxiarD4S+i6uSvAQPNq1/kTEHV0QDvkbpHdUWDn0RlSxQuRfRvSGkGI8iOwHqmdCcAAAAASUVORK5CYII=" alt="AssetLibrary">
	</a>
	<a href="https://github.com/ClarkThyLord/Voxel-Core/blob/master/LICENSE">
		<img src="https://img.shields.io/badge/License-MIT-brightgreen.svg" alt="License">
	</a>
</p>

> Voxel plugin for the Godot game engine!

---

# About
Voxel-Core is a plugin for the [Godot](https://github.com/godotengine/godot) game engine made with GDScript, created as the ‘core’ for my other project [Voxly](https://github.com/ClarkThyLord/Voxly), offering various voxel features, utilities and fully fledged in-engine editors.

## Why Voxel-Core?
Voxel-Core aspires to be the all-in-one solution for voxel content, you get everything needed to create, modify, save, share, import and do more with voxel content right out of the box! And while primarily focusing on voxel objects (e.g. characters, creatures, props, etc.) it's not limited to just that. Having been built with GDScript means two things: First, it will run anywhere Godot will (Desktop, Web, Mobile), without the need for anything else. Second, its design is meant to be intuitive and extendable, allowing you to easily use and extend it to fulfill your specific need. So, whether it's something as simple as importing files from MagicaVoxel, or creating infinite voxel worlds, Voxel-Core strives to fulfill your every need!

## Features ([Video](https://youtu.be/d85DMiwnIFI))
- VoxelObject is a MeshInstance used to create and edit voxel content in-engine and in-game with ease
	- Offers many easy to use methods to create and modify voxel content 
	- Fully automatic UV Mapping, creating textured voxel content has never been easier
	- Meshing modes: naive meshing, for efficient culled meshes; greedy meshing, for optimized meshes
	- Generate and embed self maintained StaticBodies
- VoxelSet is a Resource, much like a TileSet, used to define an array of voxels used by VoxelObjects
	- Create an almost infinite variety of voxels
	- Define colors, textures, materials and more on a per face basis
	- Create Materials that can be applied to one or more voxels
	- Easily define and set textures used for UV Mapping
- In-Engine Editors, interactive and responsive editors allowing users to create and edit voxel content with ease
	- Quality of life keyboard shortcuts
	- Integrated UndoRedo support throughout
	- VoxelObjectEditor, easy and friendly way to create and modify VoxelObjects in-scene
		- Offers many operations, such as: adding, removing, swapping, filling and more
		- Apply operations individually, by area or by extruding a face
		- Mirror operations over x, y and z axis
		- Import files, apply edit effects and more...
	- VoxelSetEditor, create, modify and manage your VoxelSets with ease and simplicity
		- Add, remove, duplicate voxels on the fly
		- Live interactive 3D and 2D voxel preview
		- Various options to get the specific look you want for your voxel
- Readers, used to import files as both static and dynamic voxel content
	- Fully integrated with the editor, meaning recognized project files will be imported automatically
	- Image files (jpg, png, and all other natively supported files), quickly creating 3D prototypes
	- Vox files (MagicaVoxel), making it easy and simple to work back and forward between programs
	- Color palette files (images, vox, gpl, etc.), work with the same colors across platforms

# [Usage / Docs](https://github.com/ClarkThyLord/Voxel-Core/wiki)

# Getting Voxel-Core
## Godot Asset Library
Preferably, Voxel-Core is available in the [Godot Asset Library](https://godotengine.org/asset-library/asset/465), meaning you can add it directly to your project from within Godot. Open your project and press on the 'AssetLib' tab found at the top of the editor. Once the asset library has loaded, search for  '*Voxel-Core*'. The top result should be this plugin, press on it and you'll be given the option to download Voxel-Core. Press to download and once it's completed Godot will ask you to select what you'd like to install. If you only want the plugin then only select the `addons` folder, but you can also choose to install anything else in this repository such as the `examples` folder. 

## Clone / Download
If for whatever reason you don't want to or can't download Voxel-Core via the in-engine Godot asset library, then you can always clone or download this repository directly. Once you've cloned or downloaded this repository, you can import it directly into Godot as a project to view the various examples and edit them directly. You may as well move the plugin's folder directly into your own project’s `addons` folder.

**NOTE:** *After adding Voxel-Core to your project you'll need to activate it in your project's `Plugins` configuration!*

---

<p align="center">
	<a href="https://godotengine.org/asset-library/asset/465" style="vertical-align: middle;">
		Asset Library
	</a>
	<a href="https://github.com/ClarkThyLord/Voxel-Core/blob/master/LICENSE" style="vertical-align: middle;">
		MIT LICENSE
	</a>
</p>
