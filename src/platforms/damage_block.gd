extends Node2D

@export var black:bool= false
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var sprite_2d_2: Sprite2D = $Sprite2D2

@onready var player: Player = %Player

@onready var timer: Timer = $Timer
@onready var reloadtimer: Timer = $reloadtimer

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if black : 
		sprite_2d.show()
		sprite_2d_2.hide()
	else:
		sprite_2d.hide()
		sprite_2d_2.show()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		#Global.list_des_morts.push_back(body.global_position)
		timer.start()
		reloadtimer.start()
		audio_stream_player_2d.play()
		Input.start_joy_vibration(0,0.5,0.5)
		body.play_death_anim()
		body.shakecamtimer.start()

	
func _on_timer_timeout() -> void:
	audio_stream_player_2d.stop()
	Input.stop_joy_vibration(0)


func _on_reloadtimer_timeout() -> void:
	player.dead_ = false
	player.deathspriteanim.hide()
	player.respawn()
	


func _on_area_2d_body_exited(body: Node2D) -> void:
	pass
