class_name Player
extends CharacterBody2D

signal wall_entered
signal wall_exited

@export var flip_h: bool: set = set_flip_h

@export_group("Horizontal Movement")
@export var max_speed: float
@export_range(1.0, 5.0) var max_h_velocity_ratio: float # Multiplied by max_speed

@export_subgroup("On Floor")
@export_range(0.0, 1.0) var running_acc_time: float
@export_range(0.0, 1.0) var running_dec_time: float

@export_subgroup("In Air")
@export_range(0.0, 1.0) var jumping_acc_time: float
@export_range(0.0, 1.0) var jumping_dec_time: float
@export_range(0.0, 1.0) var falling_acc_time: float
@export_range(0.0, 1.0) var falling_dec_time: float

@export_group("Vertical Movement")
@export_subgroup("Gravity")
@export_range(1.0, 2.0) var jump_not_held_gravity_ratio: float
@export_range(1.0, 2.0) var down_held_gravity_ratio: float
@export var gravity_limit: float
@export_range(1.0, 2.0) var down_held_gravity_limit_ratio: float

@export_subgroup("Jump")
@export var jump_height: float
@export_range(0.0, 1.0) var jump_time_to_peak: float
@export_range(0.0, 1.0) var jump_time_to_land: float
@export_range(1.0, 5.0) var max_up_velocity_ratio: float # Multiplied by jump_velocity
@export var jump_peak_boost: float # Boost applied to horizontal velocity after reaching jump peak
@export_range(0.0, 1.0) var jump_peak_gravity_ratio: float
@export var corner_correction_distance: int
@export var oneway_platform_assist_distance: int

@export_group("On Wall")
@export_subgroup("Wall Slide")
@export var max_wall_slide_speed: float
@export_range(1.0, 2.0) var down_held_wall_slide_ratio: float
@export_range(0.0, 1.0) var wall_slide_acc_time: float # Downward acceleration

@export_subgroup("Wall Jump")
@export_range(0.0, 1.0) var wall_jump_v_velocity_ratio: float # Multiplied by jump_velocity
@export var wall_jump_h_velocity: float
# Horizontal acceleration/deceleration after wall jumping.
@export_range(0.0, 1.0) var wall_jumping_acc_time: float
@export_range(0.0, 1.0) var wall_jumping_dec_time: float
@export_range(0.0, 1.0) var wall_jumping_towards_wall_dec_time: float # While the player is moving towards the wall

@export_group("Dash")
@export var dash_speed: float
@export var dash_distance: float
@export var after_dash_speed: float
@export_range(0.0, 1.0) var after_dash_gravity_ratio: float

@export_group("Animation")
@export_range(-90.0, 90.0, 0.1, "degrees") var max_move_skew: float
@export_range(0.0, 1.0) var shape_rescale_weight: float

@export_subgroup("Squash")
@export_range(1.0, 2.0) var squash_width_scale_at_rest: float
@export_range(1.0, 2.0) var squash_width_scale_at_max_fall: float
@export_range(0.0, 1.0) var squash_height_scale_at_rest: float
@export_range(0.0, 1.0) var squash_height_scale_at_max_fall: float

@export_subgroup("Stretch")
@export_range(0.0, 1.0) var stretch_width_scale: float
@export_range(1.0, 2.0) var stretch_height_scale: float

var dash_allowed: bool = false
var _on_wall: bool = false: # This variable mustn't be edited manually
	set(value):
		if value != _on_wall:
			(wall_entered if value else wall_exited).emit()
		
		_on_wall = value

@onready var jump_velocity: float = -(2.0 * jump_height) / jump_time_to_peak
@onready var max_up_velocity: float = jump_velocity * max_up_velocity_ratio
@onready var max_h_velocity: float = max_speed * max_h_velocity_ratio
@onready var jumping_gravity: float = (2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)
@onready var falling_gravity: float = (2.0 * jump_height) / (jump_time_to_land * jump_time_to_land)

@onready var shape: Node2D = $Shape as Node2D
@onready var state_machine: StateMachine = $StateMachine as StateMachine
@onready var collision_shape: CollisionShape2D = $CollisionShape2D as CollisionShape2D

@onready var jump_peak_gravity_timer: Timer = %JumpPeakGravity as Timer
@onready var jump_coyote_timer: Timer = %JumpCoyote as Timer
@onready var jump_buffer_timer: Timer = %JumpBuffer as Timer
@onready var wall_jump_coyote_timer: Timer = %WallJumpCoyote as Timer
@onready var wall_jump_buffer_timer: Timer = %WallJumpBuffer as Timer
@onready var dash_cooldown_timer: Timer = %DashCooldown as Timer
@onready var after_dash_gravity_timer: Timer = %AfterDashGravity as Timer

@onready var _default_shape_scale: Vector2 = shape.scale

var can_double_jump : bool = true

func _ready() -> void:
	pass
	
func _physics_process(_delta: float) -> void:
	_on_wall = is_on_wall()
	
	logic_spe()

func try_double_jump() -> void:
	if Input.is_action_just_pressed("jump") and can_double_jump and Global.doublejump_unlock:
		jump()
		can_double_jump = false	

func get_facing_dir() -> float:
	return -1.0 if flip_h else 1.0

func set_flip_h(value: bool) -> void:
	if not is_node_ready():
		await ready
	
	flip_h = value
	shape.scale.x = absf(shape.scale.x) * get_facing_dir()
	sprite.scale.x = absf(sprite.scale.x) * get_facing_dir()

func update_flip_h() -> void:
	var h_input_dir: float = signf(get_input_vector().x)
	
	if h_input_dir:
		flip_h = h_input_dir != 1.0

func get_input_vector() -> Vector2:
	if dead_: return Vector2(0,0)
	else : return Input.get_vector("left", "right", "up", "down")

func apply_movement(delta: float, acc_time: float, dec_time: float) -> void:
	var speed_dir: float = max_speed * get_input_vector().x
	var h_velocity_dir: float = signf(velocity.x)
	var apply_acc: bool = (
			h_velocity_dir == 0.0
			or (velocity.x - speed_dir) * h_velocity_dir <= 0.0
	)
	
	var step: float = max_speed / (acc_time if apply_acc else dec_time)
	
	velocity.x = move_toward(velocity.x, speed_dir, step * delta)
	velocity.x = clampf(velocity.x, -max_h_velocity, max_h_velocity)

func apply_gravity(delta: float) -> void:
	velocity.y += calculate_gravity() * delta
	velocity.y = clampf(velocity.y, max_up_velocity, calculate_gravity_limit())
	if dead_:velocity.y = 0

func get_default_gravity() -> float:
	return falling_gravity if velocity.y >= 0.0 else jumping_gravity

func calculate_gravity() -> float:
	return get_default_gravity() * (
			jump_peak_gravity_ratio if not jump_peak_gravity_timer.is_stopped()
			else after_dash_gravity_ratio if not after_dash_gravity_timer.is_stopped()
			else jump_not_held_gravity_ratio if not Input.is_action_pressed("jump") or inside_nojump_portal
			else down_held_gravity_ratio if Input.is_action_pressed("down") and velocity.y > 0
			else 1.0
	)

func calculate_gravity_limit() -> float:
	return gravity_limit * (
			down_held_gravity_ratio if Input.is_action_pressed("down") and velocity.y > 0
			else 1.0
	)

func jump() -> void:
	if !inside_nojump_portal:
		velocity.y = jump_velocity
		apply_stretch()
			
		try_play_new_anim("jumpup")
		jump_sound.play()
		jump_particle.restart()

func try_jump() -> void:
	if Input.is_action_just_pressed("jump") and !dead_:
		jump()

func try_coyote_jump() -> void:
	if not jump_coyote_timer.is_stopped():
		try_jump()

func try_jump_buffer_timer() -> void:
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer.start()

func try_buffer_jump() -> void:
	if not jump_buffer_timer.is_stopped():
		jump()

func stop_jump_timers() -> void:
	jump_coyote_timer.stop()
	jump_buffer_timer.stop()
	wall_jump_coyote_timer.stop()
	wall_jump_buffer_timer.stop()

func get_last_wall_dir() -> float:
	return -signf(get_wall_normal().x)

func apply_wall_slide(delta: float) -> void:
	var step: float = max_wall_slide_speed / wall_slide_acc_time
	velocity.y = move_toward(velocity.y, calculate_wall_slide_speed(), step * delta)

func can_wall_slide() -> bool:
	# Can wall slide if the player is touching the wall and moving towards it.
	return is_on_wall() and get_input_vector().x * get_last_wall_dir() > 0

func try_wall_slide() -> void:
	if can_wall_slide():
		state_machine.activate_state_by_name("WallSlideState")

func calculate_wall_slide_speed() -> float:
	return max_wall_slide_speed * (
			down_held_wall_slide_ratio if Input.is_action_pressed("down")
			else 1.0
	)

func wall_jump() -> void:
	var wall_jump_dir: float = -get_last_wall_dir()
	
	velocity.y = jump_velocity * wall_jump_v_velocity_ratio
	velocity.x = wall_jump_h_velocity * wall_jump_dir
	apply_stretch()
	
	state_machine.activate_state_by_name("WallJumpState")
		
	try_play_new_anim("jumpup",0.33*wall_jump_dir)
	walljump_sound.play()
	jump_particle.restart()

func try_wall_jump(ignore_wall: bool = false) -> void:
	if Input.is_action_just_pressed("jump") and (is_on_wall() or ignore_wall) and !dead_:
		wall_jump()

func try_coyote_wall_jump() -> void:
	if not wall_jump_coyote_timer.is_stopped():
		try_wall_jump(true)

func try_wall_jump_buffer_timer() -> void:
	if Input.is_action_just_pressed("jump"):
		wall_jump_buffer_timer.start()

func _on_wall_entered() -> void:
	if not wall_jump_buffer_timer.is_stopped():
		wall_jump()

func _on_wall_exited() -> void:
	if velocity.y > 0:
		wall_jump_coyote_timer.start()

func calculate_wall_jumping_dec_time() -> float:
	var h_input_dir: float = signf(get_input_vector().x)
	
	return (
			wall_jumping_towards_wall_dec_time if h_input_dir == get_last_wall_dir()
			else wall_jumping_dec_time
	)

func can_dash() -> bool:
	return dash_allowed and dash_cooldown_timer.is_stopped()

func try_dash() -> void:
	if Input.is_action_just_pressed("dash") and can_dash() and Global.dash_unlock and !dead_:
		state_machine.activate_state_by_name("DashState")
		dash_sound.play()

func try_corner_correction(delta: float) -> void:
	var v_motion: Vector2 = Vector2(0.0, velocity.y * delta)
	
	if not test_move(global_transform, v_motion):
		return
	
	# Multiplied by 2 so each offset increments by 0.5 instead of 1.0.
	for offset_step: int in range(1, corner_correction_distance * 2 + 1):
		var offset: float = offset_step / 2.0
	
		for dir: float in [-1.0, 1.0]:
			var h_offset: Vector2 = Vector2(offset * dir, 0)
			var test_transform: Transform2D = global_transform.translated(h_offset)
			
			if not test_move(test_transform, v_motion):
				translate(h_offset)
				
				# Stop the player if they are moving opposite to the corner's direction.
				if velocity.x * dir < 0.0:
					velocity.x = 0.0
				
				return

func try_oneway_platform_assist() -> void:
	if test_move(global_transform, Vector2.DOWN):
		return
	
	# Multiplied by 2 so each offset increments by 0.5 instead of 1.0.
	for offset_step: int in range(oneway_platform_assist_distance * 2 + 1):
		var offset: float = offset_step / 2.0
		var v_offset: Vector2 = Vector2.UP * offset
		
		var test_transform: Transform2D = global_transform.translated(v_offset)
		
		if test_move(test_transform, Vector2.DOWN):
			# Make sure the player doesn't get stuck.
			if not test_move(test_transform, Vector2.UP):
				translate(v_offset)
			
			return

func apply_move_anim() -> void:
	var max_move_skew_rad: float = deg_to_rad(max_move_skew)
	
	shape.skew = remap(velocity.x, -max_speed, max_speed, -max_move_skew_rad, max_move_skew_rad)
	sprite.skew = remap(velocity.x, -max_speed, max_speed, -max_move_skew_rad, max_move_skew_rad)

func update_shape_scale(delta: float) -> void:
	var target: Vector2 = _default_shape_scale * shape.scale.sign()
	var target2: Vector2 = _default_sprite_scale * sprite.scale.sign()
	var frame_weight: float = 1.0 - pow(1.0 - shape_rescale_weight, 60.0 * delta)
	
	shape.scale = shape.scale.lerp(target, frame_weight)
	sprite.scale = sprite.scale.lerp(target2, frame_weight)

func apply_squash() -> void:
	var max_fall_speed: float = calculate_gravity_limit()
	var vertical_speed: float = get_position_delta().y / get_physics_process_delta_time()
	
	shape.scale.x *= remap(vertical_speed, 0.0, max_fall_speed, squash_width_scale_at_rest, squash_width_scale_at_max_fall)
	shape.scale.y *= remap(vertical_speed, 0.0, max_fall_speed, squash_height_scale_at_max_fall, squash_height_scale_at_rest)
	sprite.scale.x *= remap(vertical_speed, 0.0, max_fall_speed, squash_width_scale_at_rest, squash_width_scale_at_max_fall)
	sprite.scale.y *= remap(vertical_speed, 0.0, max_fall_speed, squash_height_scale_at_max_fall, squash_height_scale_at_rest)

func apply_stretch() -> void:
	shape.scale *= Vector2(stretch_width_scale, stretch_height_scale)
	sprite.scale *= Vector2(stretch_width_scale, stretch_height_scale)
	
	
	
	
	
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var _default_sprite_scale: Vector2 = sprite.scale

@onready var jump_sound: AudioStreamPlayer = $jump_sound
@onready var land_sound: AudioStreamPlayer = $land_sound
@onready var walljump_sound: AudioStreamPlayer = $walljump_sound
@onready var dash_sound: AudioStreamPlayer = $dash_sound
@onready var slide_sound: AudioStreamPlayer = $slide_sound
@onready var falling_sound: AudioStreamPlayer = $falling_sound
@onready var run_sound: AudioStreamPlayer = $run_sound
@onready var jump_particle: CPUParticles2D = $jump_particle
@onready var ground_particle: CPUParticles2D = $ground_particle
@onready var slide_particle: CPUParticles2D = $slide_particle
@onready var run_particle: CPUParticles2D = $run_particle
@onready var blood_particle: CPUParticles2D = $blood_particle


@onready var cam: PhantomCamera2D = %cam
@onready var cam_2: PhantomCamera2D = %cam2
@onready var camoffesetbottom: PhantomCamera2D = %camoffesetbottom
@onready var camoffesetbottom_2: PhantomCamera2D = %camoffesetbottom2
@onready var zoomcam: PhantomCamera2D = %zoomcam

@onready var shakecamtimer: Timer = $shakecamtimer


var inside_portal : bool = false
var inside_nojump_portal : bool = false
var save_velocity : Vector2
func portal_logic():
	if !is_on_floor() and !is_on_wall():
		save_velocity = velocity
	else :
		if !inside_portal : save_velocity.y = -jump_velocity

func sprint_logic():
	if Input.is_action_pressed("dash") and !(state_machine.active_state is DashState):
		max_speed = 389.0*1.5
	else:
		max_speed = 389

func logic_spe():
	
	Engine.time_scale = 1
	if Input.is_action_pressed("timeslow"):
			Engine.time_scale = 0.1
			
	portal_logic()
	respawn_logic()
	
	sprite_animation()
	
	sound_animation()
	
	camera_logic()
	
	laser_logic_anim()
	
	if Global.sprint_unlock:
		sprint_logic()
		
	

	
func camera_logic()->void:
	if velocity.x > 0 and is_on_floor_only(): 
		cam.priority = 1
		cam_2.priority = 0
	if velocity.x < 0 and is_on_floor_only(): 
		cam.priority = 0
		cam_2.priority = 1
	
	if camoffesetbottom.priority == 10 or camoffesetbottom_2.priority == 10:
		if velocity.x > 0 and is_on_floor_only(): 
			camoffesetbottom.priority = 10
			camoffesetbottom_2.priority = 0
		if velocity.x < 0 and is_on_floor_only(): 
			camoffesetbottom.priority = 0
			camoffesetbottom_2.priority = 10
		
	if state_machine.active_state is DashState or !shakecamtimer.is_stopped():
		cam.noise.positional_noise= true
		camoffesetbottom.noise.positional_noise= true
		zoomcam.noise.positional_noise= true
	else :
		cam.noise.positional_noise= false
		camoffesetbottom.noise.positional_noise= false
		zoomcam.noise.positional_noise= false

func try_play_new_anim(anim,rotation_=0.0) -> void:
	if sprite.animation != anim or anim=="jumpup":
		sprite.rotation=rotation_
		sprite.play(anim)
		
	"""if sprite.animation =="jumpdown":
		sprite.material.set("shader_parameter/activated",false);
	else:
		sprite.material.set("shader_parameter/activated",false);"""
		
var en_train_de_tomber = false
func sprite_animation() -> void:
	
	if is_on_wall_only():
		#sprite.rotation=get_last_wall_dir()*0.15
		if !dead_:slide_particle.emitting = true
		if get_facing_dir() > 0 :
			slide_particle.position.x = 13
		if get_facing_dir() < 0 :
			slide_particle.position.x = -13
	else :
		slide_particle.emitting = false
	
	
	run_particle.emitting = false
	if is_on_floor() :
		if sprite.animation=="jumpground" and sprite.is_playing():
			pass
		else:
			if velocity.x < -150 or velocity.x > 150 :
				try_play_new_anim("run")
				run_particle.emitting = true
			else:
				try_play_new_anim("idle")
	
	if velocity.y > 0.0:
		try_play_new_anim("robe")
		en_train_de_tomber = true
		
	if en_train_de_tomber and is_on_floor():
		try_play_new_anim("jumpground")
		en_train_de_tomber = false
		
	if inside_portal:
		try_play_new_anim("teleport")
		
			
var saut_en_cours_for_sound = false
var falling_started = false
func sound_animation() -> void:
	if is_on_floor() and velocity.x != 0.0:
		if !run_sound.playing and !land_sound.playing : 
			run_sound.play()
	else :
		run_sound.stop()
		
	if is_on_wall_only():
		if !slide_sound.playing and !dead_: slide_sound.play()
	else :
		slide_sound.stop()
		
		if velocity.y > 800 :
			if !falling_sound.playing and !dead_: 
				if !falling_started:
					var tween = get_tree().create_tween()
					tween.tween_property(falling_sound, "volume_db", 0.0, 1.0)
					falling_started=true
				
				falling_sound.play()
		else :
			falling_sound.stop()
			var tween = get_tree().create_tween()
			tween.tween_property(falling_sound, "volume_db", -80.0, 1.0)
			falling_started=false
		
	if velocity.y != 0.0 :
		saut_en_cours_for_sound = true
	if is_on_floor() and !inside_portal:
		if saut_en_cours_for_sound :
			saut_en_cours_for_sound = false
			if !respawned :
				land_sound.play()
				ground_particle.restart()
			
var last_floor_pos : Vector2
@onready var ray_cast_2d: RayCast2D = $RayCast2D

func respawn_logic():
	
	if ray_cast_2d.is_colliding():
		#print(ray_cast_2d.get_collider().get_class())
		var collidobj = ray_cast_2d.get_collider()
		if collidobj is Ptblueprint :
			last_floor_pos.x = collidobj.global_position.x
			last_floor_pos.y = global_position.y
			
@onready var animated_sprite_for_teleport_shader: AnimatedSprite2D = $AnimatedSpriteForTeleportShader
@onready var animation_player_for_teleport_shader: AnimationPlayer = $AnimatedSpriteForTeleportShader/AnimationPlayerForTeleportShader
var respawned : bool = false
func respawn():
	
	respawned=true
	sprite.hide()
	sprite_shader.hide()
	global_position = last_floor_pos
	velocity = Vector2(0.0,0.0)
	await get_tree().create_timer(0.1).timeout
	if get_facing_dir() > 0 :
		animated_sprite_for_teleport_shader.flip_h = false
	if get_facing_dir() < 0 :
		animated_sprite_for_teleport_shader.flip_h = true
	animated_sprite_for_teleport_shader.show()
	animation_player_for_teleport_shader.play("new_animation")
	await get_tree().create_timer(1).timeout
	animated_sprite_for_teleport_shader.hide()
	sprite.show()
	
	respawned=false
	
			
@onready var sprite_shader: AnimatedSprite2D = $SpriteShader
var laser_dmg:bool=false
func laser_logic_anim():
	if laser_dmg :
		Engine.time_scale = 0.04
		velocity=velocity/7
		duplicate_sprite()
		sprite.hide()
		sprite_shader.show()
func duplicate_sprite():
	sprite_shader.position = sprite.position
	sprite_shader.rotation = sprite.rotation
	sprite_shader.scale = sprite.scale
	sprite_shader.skew = sprite.skew
	sprite_shader.animation = sprite.animation
	sprite_shader.frame = sprite.frame

@onready var deathspriteanim: AnimatedSprite2D = $deathspriteanim
@onready var point_light_2d: PointLight2D = $PointLight2D
@onready var point_light_2d_2: PointLight2D = $PointLight2D2

var dead_ : bool = false
func play_death_anim():
	
	blood_particle.restart()
	dead_ = true
	sprite.hide()
	point_light_2d.hide()
	deathspriteanim.show()
	
	deathspriteanim.play("default")
		
