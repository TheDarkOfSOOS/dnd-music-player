extends HBoxContainer

var play_icon : Texture2D = preload("res://resources/img/play_icon.png")
var pause_icon : Texture2D = preload("res://resources/img/pause_icon.png")

@onready var label: Label = $Label
@onready var play_pause_button: Button = $Play
@onready var restart: Button = $Restart
@onready var fade: Button = $Fade
@onready var slider : HSlider = $HSlider
@onready var player: AudioStreamPlayer2D = $AudioStreamPlayer2D

@export var label_name : String
@export var audio_stream : AudioStreamMP3

var bus_name: String
var is_sfx : bool = false

func _ready() -> void:
	label.text = label_name
	player.stream = audio_stream
	AudioServer.add_bus(1)
	AudioServer.set_bus_name(1, label_name)
	bus_name = AudioServer.get_bus_name(1)
	player.bus = bus_name
	slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(bus_name)))

func _process(delta: float) -> void:
	pass

func _on_button_pressed() -> void:
	if not player.playing and not player.stream_paused:
		player.play()
		play_pause_button.icon = pause_icon
	else:
		if player.stream_paused:
			play_pause_button.icon = pause_icon
			player.stream_paused = false
		else:
			play_pause_button.icon = play_icon
			player.stream_paused = true

func _on_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus_name), linear_to_db(value))
	if slider.value == 0:
		_on_button_pressed()

func _on_fade_pressed() -> void:
	if player.playing:
		var tween : Tween = get_tree().create_tween()
		tween.tween_property(slider, "value", 0.0, 3.3)

func _on_restart_pressed() -> void:
	player.stop()
	_on_button_pressed()

func _on_audio_stream_player_2d_finished() -> void:
	if is_sfx:
		play_pause_button.icon = play_icon
