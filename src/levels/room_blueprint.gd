extends Node2D
@onready var player: Player = %Player

@onready var zoomcam: PhantomCamera2D = $zoomcam
@onready var cam: PhantomCamera2D = %cam
@onready var cam_2: PhantomCamera2D = %cam2
@onready var camoffesetbottom: PhantomCamera2D = $camoffesetbottom
@onready var camoffesetbottom_2: PhantomCamera2D = %camoffesetbottom2
@onready var dezoomlvl_7: PhantomCamera2D = $dezoomlvl7

@onready var canvas_modulate: CanvasModulate = $CanvasModulate

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

@onready var ground: Sprite2D = $lvl1/ground

@onready var lvl_1: Node2D = $lvl1
@onready var lvl_2: Node2D = $lvl2

var lvl_2_loaded:bool = false

@onready var blackgroundparticle: GPUParticles2D = $lvl1/Parallax2D2/GPUParticles2D
@onready var blackgroundparticle2: GPUParticles2D = $lvl1/Parallax2D2/GPUParticles2D2
@onready var black_particule: Node2D = $"lvl1/black particule"

@onready var fractale_ciel: RigidBody2D = $fractale_ciel

@onready var cadavre: AnimatedSprite2D = $cadavre

func _ready() -> void:
	
	cam.noise.positional_noise= true
	camoffesetbottom.noise.positional_noise= true
	zoomcam.noise.positional_noise= true
	
	
	display_list_cadavre()
	
	creer_ground()
	
	#-6703.236
	
	lvl_2.hide()
	lvl_2.process_mode = Node.PROCESS_MODE_DISABLED
	
	if !Global.debug_mod:
		player.process_mode = Node.PROCESS_MODE_DISABLED
		await get_tree().create_timer(0.2).timeout
		player.process_mode = Node.PROCESS_MODE_INHERIT
	
	
		
func _process(delta: float) -> void:
	
	
	
	if player.is_on_floor():
		var tween = get_tree().create_tween()
		tween.tween_property(player.point_light_2d, "energy", 1.0, 10.0)
		var tween2 = get_tree().create_tween()
		tween2.tween_property(player.point_light_2d_2, "energy", 1.0, 10.0)
	
	if Input.is_action_just_pressed("start"):
		spawn_fractal()
	
	if player.global_position.x > 14000:
		blackgroundparticle.hide()
		blackgroundparticle2.hide()
	else:
		blackgroundparticle.show()
		blackgroundparticle2.show()
		
	if player.global_position.y > 200:
		cam.limit_right = 10000000
		cam_2.limit_right = 10000000
	else:
		cam.limit_right = 18722
		cam_2.limit_right = 18722

	if player.is_on_floor():music_player_logic()
	slowvoid_logic()
	


#FONCTIONS#FONCTIONS#FONCTIONS#FONCTIONS#FONCTIONS#FONCTIONS#FONCTIONS#FONCTIONS#FONCTIONS#FONCTIONS#FONCTIONS#FONCTIONS#FONCTIONS
var index_music : int = 0
var label_music : String = ""
var volume_music : float = -10.0
func music_player_logic():
	if !audio_stream_player.playing:
		audio_stream_player.play()
	
	
	if player.global_position.x < -3562:
		index_music=1
		label_music="noise"
		
	if !lvl_2_loaded:
		if player.global_position.x > -3562:
			index_music=0
			label_music="portal"
			
			var tween = get_tree().create_tween()
			tween.tween_property(canvas_modulate, "color", Color("b8b8b8"), 10.0)
		
	if lvl_2_loaded:		
		if player.global_position.x > -3562 and player.global_position.x < 1310:
			index_music=2
			label_music="stimulation"
			
			var tween = get_tree().create_tween()
			tween.tween_property(canvas_modulate, "color", Color("ffc7c7ff"), 2.0)
			
		if player.global_position.x > 1310:
			index_music=1
			label_music="noise"
			
	if player.global_position.x > 6500 and player.global_position.y > 658 and player.global_position.x < 13000 and player.global_position.y < 3900:
		var tween = get_tree().create_tween()
		tween.tween_property(canvas_modulate, "color", Color("dbfff4ff"), 2.0)
		
		
	if player.global_position.x > 14081 :
		if player.position.y > 300:
			index_music=3
			label_music="intense"
			
			var tween = get_tree().create_tween()
			tween.tween_property(canvas_modulate, "color", Color("ffffffff"), 10.0)
			
			
	if audio_stream_player.get_stream_playback().get_current_clip_index() !=index_music:
		audio_stream_player.get_stream_playback().switch_to_clip_by_name(label_music)
		audio_stream_player.volume_db=volume_music
		
func display_list_cadavre():
	for cadavre_elem in Global.list_des_morts:
		var cad = cadavre.duplicate()
		cad.global_position = cadavre_elem
		cad.global_position.y -= 36
		$".".add_child(cad)  

func duplicate_ground(offset_x):
	var r = ground.duplicate()
	r.position.x = r.position.x + offset_x 
	r.z_index = r.z_index -1
	$".".add_child(r)  

func creer_ground():
	var len = 0.274 * 13902
	for i in range(10):
		duplicate_ground(i*len)
	ground.hide()
	ground.process_mode = Node.PROCESS_MODE_DISABLED		
	
func slowvoid_logic():
	var limit = - 5555
	if player.global_position.x < limit:
		var diff = limit - player.global_position.x
		diff = diff/1000
		if diff >0.9:
			diff = 0.9
		Engine.time_scale = 1 - diff

func spawn_fractal()->void:
	var f_ = fractale_ciel.duplicate()
	f_.global_position = player.global_position
	f_.global_position.y -= 200
	f_.process_mode = Node.PROCESS_MODE_INHERIT
	f_.visible = true
	$".".add_child(f_)  


#CAMERA LOGIC#CAMERA LOGIC#CAMERA LOGIC#CAMERA LOGIC#CAMERA LOGIC#CAMERA LOGIC#CAMERA LOGIC#CAMERA LOGIC#CAMERA LOGIC
func _on_zoom_zone_body_entered(body: Node2D) -> void:
	if body is Player : zoomcam.priority = 10
func _on_zoom_zone_body_exited(body: Node2D) -> void:
	if body is Player : zoomcam.priority = 0
func _on_no_bottom_offset_zone_body_entered(body: Node2D) -> void:
	if body is Player : camoffesetbottom.priority = 10
func _on_no_bottom_offset_zone_body_exited(body: Node2D) -> void:
	if body is Player : 
		camoffesetbottom.priority = 0
		camoffesetbottom_2.priority = 0

func _on_no_offset_zone_lvl_2_body_entered(body: Node2D) -> void:
	if body is Player : camoffesetbottom.priority = 10
func _on_no_offset_zone_lvl_2_body_exited(body: Node2D) -> void:
	if body is Player : 
		camoffesetbottom.priority = 0
		camoffesetbottom_2.priority = 0

func _on_camzoneoffset_lvl_5_body_entered(body: Node2D) -> void:
	if body is Player : 
		camoffesetbottom.priority = 10
func _on_camzoneoffset_lvl_5_body_exited(body: Node2D) -> void:
	if body is Player : 
		camoffesetbottom.priority = 0
		camoffesetbottom_2.priority = 0
		

#CHANGE SCENE#CHANGE SCENE#CHANGE SCENE#CHANGE SCENE#CHANGE SCENE#CHANGE SCENE#CHANGE SCENE
func _on_change_scene_whenvoid_body_entered(body: Node2D) -> void:
	if body is Player:
		if !lvl_2_loaded:
			lvl_1.hide()
			lvl_1.process_mode = Node.PROCESS_MODE_DISABLED
			lvl_2.show()
			lvl_2.process_mode = Node.PROCESS_MODE_INHERIT
			
			black_particule.layer1.hide()
			black_particule.layer2.hide()
			black_particule.layer3.hide()
			
			lvl_2_loaded = true
			
		body.glitch_rect.visible=true
		await get_tree().create_timer(2).timeout
		body.glitch_rect.visible=false
		
func _on_change_scene_zone_body_entered(body: Node2D) -> void:
	if body is Player:
		if !lvl_2_loaded:
			lvl_1.hide()
			lvl_1.process_mode = Node.PROCESS_MODE_DISABLED
			lvl_2.show()
			lvl_2.process_mode = Node.PROCESS_MODE_INHERIT
			
			black_particule.layer1.hide()
			black_particule.layer2.hide()
			black_particule.layer3.hide()
			
			lvl_2_loaded = true
func _on_change_scene_zone_2_lvl_3_body_entered(body: Node2D) -> void:
	if body is Player:
		if lvl_2_loaded:
			lvl_1.show()
			lvl_1.process_mode = Node.PROCESS_MODE_INHERIT
			lvl_2.hide()
			lvl_2.process_mode = Node.PROCESS_MODE_DISABLED
			
			black_particule.layer1.show()
			black_particule.layer2.show()
			black_particule.layer3.show()
			
			lvl_2_loaded = false
			

#DEATHZONE#DEATHZONE#DEATHZONE#DEATHZONE#DEATHZONE#DEATHZONE#DEATHZONE#DEATHZONE#DEATHZONE#DEATHZONE#DEATHZONE
func _on_deathzone_body_entered(body: Node2D) -> void:
	if body is Player:
		player.respawn()
		
		
#HIDE PLAYER ZONE#HIDE PLAYER ZONE#HIDE PLAYER ZONE#HIDE PLAYER ZONE#HIDE PLAYER ZONE#HIDE PLAYER ZONE#HIDE PLAYER ZONE
func _on_novisibleplayerzone_body_entered(body: Node2D) -> void:
	if body is Player:
		body.sprite.hide()
func _on_novisibleplayerzone_body_exited(body: Node2D) -> void:
	if body is Player:
		body.sprite.show()
