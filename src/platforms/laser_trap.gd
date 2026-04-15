extends Node2D

@export var is_rotatingg:bool=true
@export var reverse_rotate:bool=false

@onready var timer: Timer = $Timer
@onready var player: Player = %Player
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if is_rotatingg:
		if reverse_rotate:
			animation_player.play("new_animation_reverse")
		else:
			animation_player.play("new_animation")
			


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		body.laser_dmg = true
		timer.start()
		audio_stream_player_2d.play()
		Input.start_joy_vibration(0,0.5,0.5)
		


func _on_timer_timeout() -> void:
	player.laser_dmg = false
	player.respawn()
	audio_stream_player_2d.stop()
	Input.stop_joy_vibration(0)
