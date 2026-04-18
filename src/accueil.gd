extends Node2D

@onready var timer: Timer = $Timer
@onready var video_stream_player: VideoStreamPlayer = $VideoStreamPlayer

func load_game()->void:
	get_tree().change_scene_to_file("res://src/vhs.tscn")
	#get_tree().change_scene_to_file("res://src/levels/room_blueprint.tscn")
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Global.debug_mod:
		load_game()
	
	Fadetoblack.transition(3)
	await Fadetoblack.on_transition_finished	
	video_stream_player.play()
	timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_timer_timeout() -> void:
	Fadetoblack.transition(3)
	await Fadetoblack.on_transition_finished
	load_game()
	
	
