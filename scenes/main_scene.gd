extends Control

@onready var master_slider = %Master_slider # reference to the slider
@onready var master_song_container = %Master_song_container # reference to the songs container
@onready var master_effect_container: VBoxContainer = %Master_effect_container # reference to the effects container
@onready var box_container = %BoxContainer # reference to the box container
# single song container scene that will be instantiated per song
const song_container_scene : PackedScene = preload("res://scenes/song_container.tscn")

const supported_ext : Array = [".mp3", ".MP3", ".wav", ".WAV"]

const effects_path : String = "res://resources/audios/sound_effects/" # effects dir indirect path
const songs_path : String = "res://resources/audios/bg_music/" # songs dir indirect path
var effects_dir : DirAccess = DirAccess.open(effects_path) # access of the effects dir
var songs_dir : DirAccess = DirAccess.open(songs_path) # access of the songs dir

func _ready():
	# set the value of the slider to the same of the decibel of audio bus
	master_slider.value = db_to_linear(AudioServer.get_bus_volume_db(0))
	
	# load all the resources
	load_from_dir(songs_dir)
	load_from_dir(effects_dir, true)

# DIGEST OF THE MASTER SLIDER THAT CHANGE THE VALUE OF THE MASTER AUDIO BUS
func _on_master_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(value))

# METHOD THAT LOAD ALL THE AUDIO FILES WITHIN A GIVEN DIR (IF IS A SFX THEN IS CALLED WITH SFX = TRUE)
func load_from_dir(dir : DirAccess, sfx : bool = false) -> void:
	if dir: # if the dir exist
		dir.list_dir_begin() # then I point to the top
		var file_name : String = dir.get_next() # got the first file of dir
		while file_name != "": # while I get a file
			if not dir.current_is_dir(): # If is not a dir
				# get the extension adding a . for delete it later
				var ext : String = "." + file_name.get_extension()
				if ext in supported_ext: # if the extension is a supported one
					# instantiate the container without adding to the tree
					var new_song = song_container_scene.instantiate()
					
					# assign the label_name of the container to the file_name without the extension 
					new_song.label_name = file_name.erase(file_name.find(ext), ext.length())
					
					if ext == ".mp3" or ext == ".MP3": # if is an mp3 file, it will be loaded as that
						new_song.audio_stream = AudioStreamMP3.load_from_file(dir.get_current_dir()+"/"+file_name)
					elif ext == ".wav" or ext == ".WAV": # else if is a wav or WAV then it will be loaded as that
						new_song.audio_stream = AudioStreamWAV.load_from_file(dir.get_current_dir()+"/"+file_name)
					
					if sfx: # if is a sfx, than it will be added to the effects group
						new_song.is_sfx = true
						master_effect_container.add_child(new_song)
					else: # else it will be added to the song group
						master_song_container.add_child(new_song)
			else:
				pass # TODO
			file_name = dir.get_next() # then check the next file in dir
	else: # if the dir doesn't exist
		if sfx: # dir will be maked based on which is missing
			DirAccess.make_dir_recursive_absolute(effects_path)
			effects_dir = DirAccess.open(effects_path)
		else:
			DirAccess.make_dir_recursive_absolute(songs_path)
			songs_dir = DirAccess.open(songs_path)

# DIGEST OF THE RE-IMPORT BUTTON THAT RELOAD ALL RESOURSES
func _on_reimport_pressed() -> void:
	# free all the previus containers
	for i in master_effect_container.get_children(true):
		if i is SongContainer:
			i.queue_free()
	for i in master_song_container.get_children(true):
		if i is SongContainer:
			i.queue_free()
	# then import all files
	load_from_dir(songs_dir, false)
	load_from_dir(effects_dir, true)

func _on_option_button_pressed() -> void:
	var node
	if box_container is VBoxContainer:
		node = HBoxContainer.new()
	elif box_container is HBoxContainer:
		node = VBoxContainer.new()
	
	node.name = box_container.name
	box_container.replace_by(node, true)
	box_container = node
