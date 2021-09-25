## Guild

### Game Description

A turn-based RPG inspired by the team compositions of FFXIV and the class system of FFV/FF Tactics.

Prove your worth to the Guild's effort in stopping the ever-growing corruption of all nature by exploring dungeons, defeating monsters, travelling the world and recruiting members to fight for the cause.

Customize your characters through a job system with 12 different classes, allowing you to fight in which way you prefer and learn about their story and motivations.

### Screenshots

Coming Soon!

### Project Structure
```
- assets -------------------> Contains all assets for the game
	- sprites --------------> 2D sprites and textures (.png and .jpeg files)
		- animations
		- backgrounds
		- portraits
		- tilesets
	- sound ---------------> Sound files for the project (.ogg and .wav files)
		- bgm
		- sfx
	- ui ------------------> Custom panels and fonts
		- fonts
		- panels
	- others --------------> Miscellaneous assets
		- maps
		- shaders
- code --------------------> Contains all the code and scenes for the game (.gd and .tscn files)
	- battle --------------> Scenes and code related to Battle
		- classes
		- menus
		- post_battle
	- classes -------------> Code defining the important game classes
		- entities
		- events
		- objects
		- util
	- config --------------> Various global configuration code such as display, audio, etc
	- overworld -----------> Code for the overworld objects and entities
		- npcs
		- objects
	- maps ----------------> Contains the scenes for all maps in the game's overworld
		- forest
		- hub
	- ui -----------------> Menus from the game
		- main_menu
		- menu
	- state --------------> Singletons which contains game state on runtime
	- root ---------------> Starter scene
- data -------------------> Contains all files with the necessary game data (.json files)
	- game_data ----------> Game data
	- save_data ----------> User save data
```

### Contribution Guide

1. Check out the issues and tasks on the `Project` board
2. Develop your code in a separate branch with an informative name
	- Make sure you follow the [style guide](https://docs.godotengine.org/en/stable/getting_started/scripting/gdscript/gdscript_styleguide.html)
	- Make sure all assets used are CC0 or given correct atribution in the `Credits` session
3. Open a Pull Request (PR) for the `master` branch
4. Done!