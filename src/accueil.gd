extends Node2D

@onready var timer: Timer = $Timer
@onready var video_stream_player: VideoStreamPlayer = $VideoStreamPlayer
@onready var rich_text_label: RichTextLabel = $RichTextLabel
@onready var loading: Label = $CanvasLayer/loading

func load_game()->void:
	get_tree().change_scene_to_file("res://src/vhs.tscn")
	#get_tree().change_scene_to_file("res://src/levels/room_blueprint.tscn")
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Global.debug_mod:
		load_game()
	
var key_pressed:bool=false
func _input(event: InputEvent) -> void:
	if !key_pressed:
		if event is InputEventKey or event is InputEventJoypadButton or event is InputEventMouseButton:
			key_pressed=true
			Fadetoblack.transition(5)
			await Fadetoblack.on_transition_finished
			rich_text_label.hide()	
			video_stream_player.play()
			timer.start()

func _on_timer_timeout() -> void:
	loading.show()
	Fadetoblack.transition(5)
	await Fadetoblack.on_transition_finished
	load_game()
	
	
