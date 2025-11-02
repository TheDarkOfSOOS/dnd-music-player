extends Control

@export
var bus_name: String = "Master"
var bus_index: int
@onready var master_slider = %Master_slider
@onready var master_song_container = %Master_song_container
@onready var master_effect_container: VBoxContainer = %Master_effect_container
const song_container_scene : PackedScene = preload("res://scenes/song_container.tscn")

const effects_path : String = "res://resources/audios/sound_effects/"
const songs_path : String = "res://resources/audios/bg_music/"
var effects_dir : DirAccess = DirAccess.open(effects_path)
var songs_dir : DirAccess = DirAccess.open(songs_path)

func _ready():
	bus_index = AudioServer.get_bus_index(bus_name)
	master_slider.value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))
	
	load_from_dir(songs_dir, false)
	load_from_dir(effects_dir, true)
	

func _on_master_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))

func load_from_dir(dir : DirAccess, sfx : bool) -> void:
	if dir:
		dir.list_dir_begin()
		var file_name : String = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				if not ".import" in file_name:
					var new_song = song_container_scene.instantiate()
					var ext : String = "." + file_name.get_extension()
					new_song.label_name = file_name.erase(file_name.find(ext), ext.length())
					new_song.audio_stream = AudioStreamMP3.load_from_file(dir.get_current_dir()+"/"+file_name)
					if sfx:
						new_song.is_sfx = true
						master_effect_container.add_child(new_song)
					else:
						master_song_container.add_child(new_song)
			else:
				pass
			file_name = dir.get_next()
	else:
		if sfx:
			DirAccess.make_dir_recursive_absolute(effects_path)
		else:
			DirAccess.make_dir_recursive_absolute(songs_path)
