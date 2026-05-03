extends Node2D

@onready var timer: Timer = $Timer
@onready var video_stream_player: VideoStreamPlayer = $VideoStreamPlayer
@onready var rich_text_label: RichTextLabel = $RichTextLabel
@onready var loading: Label = $CanvasLayer/loading

func _ready() -> void:
	if Global.first_cycle_done:
		rich_text_label.text = "Truth is impenetrable"

var has_begun:bool=false
func _process(delta: float) -> void:
	if !has_begun:
		has_begun=true
		if Global.debug_mod:
			load_game()
		if Global.first_cycle_done:
			await get_tree().create_timer(1).timeout
			Fadetoblack.transition(5)
			await Fadetoblack.on_transition_finished
			rich_text_label.text = "Your thirst for knowledge will kill you"
			await get_tree().create_timer(2).timeout
			start_game()
	
var key_pressed:bool=false
func _input(event: InputEvent) -> void:
	if !key_pressed and !Global.first_cycle_done:
		if event is InputEventKey or event is InputEventJoypadButton or event is InputEventMouseButton:
			key_pressed=true
			start_game()

func _on_timer_timeout() -> void:
	loading.show()
	Fadetoblack.transition(5)
	await Fadetoblack.on_transition_finished
	load_game()
	
func start_game()->void:
	Fadetoblack.transition(5)
	await Fadetoblack.on_transition_finished
	rich_text_label.hide()	
	video_stream_player.play()
	timer.start()
	
func load_game()->void:
	get_tree().change_scene_to_file("res://src/vhs.tscn")
	#get_tree().change_scene_to_file("res://src/levels/room_blueprint.tscn")
