extends Node

# navigate between those two menus
const main_menu:PackedScene = preload("res://menu/main_menu.tscn")
const game_menu:PackedScene = preload("res://menu/game_menu.tscn")

# template to create a new player
const player_template:PackedScene = preload("res://player/player.tscn")

# store available rooms and models in the game
var rooms :Dictionary
var models:Dictionary


func _ready():
	var path_rooms  = "res://world/rooms/"
	var path_models = "res://player/models/"
	
	self.rooms  = prepare_scenes(path_rooms , list_files(path_rooms ))
	self.models = prepare_scenes(path_models, list_files(path_models))


### SPAWN ###

# generate a new character for the given player in the specified room
# the player will always appear at (0,0,0)
remotesync func spawn(id:int, room:String, model:String)->void:
	if not self.models.has(model):
		print("Model '" + model + "' does not exists, will pick a random model.")
		model = self.models.keys()[0]
	
	# prepare a new player
	var player:Player = self.player_template.instance() # base
	var mod:PlayerModel = self.models[model].instance() # model
	player.name = str(id) # set name as id
	player.add_child(mod)
	self.add_child(player)
	player.set_network_master(id, true) # set network master as id
	player.set_room(room)


### LOAD RESOURCES ###

# filter scenes, preload them and store them into a dictionary
static func prepare_scenes(directory:String, scenes:Array)->Dictionary:
	var prepared:Dictionary = {}
	
	for scene in scenes:
		# filter out non scene files
		if scene.ends_with(".tscn"):
			var nm:String=scene.left(scene.length() - 5)
			# prepare scenes in PackedScene
			prepared[nm] = load(directory + scene)
	
	return prepared


# list the files of the directory
static func list_files(path:String)->Array:
	# iterate through the directory
	var dir:Directory = Directory.new()
	if dir.open(path) == OK:
		var list:Array = []
		
		# begin iteration
		dir.list_dir_begin()
		var file_name:String = dir.get_next()
		while (file_name != ""):
			
			# ignore sub-directories
			if not dir.current_is_dir(): list.append(file_name)
			file_name = dir.get_next()
		
		# close iteration and return list of files
		dir.list_dir_end()
		return list
	
	# if we failed to open the directory, return no array
	else: return []