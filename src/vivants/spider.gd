class_name Spider
extends CharacterBody2D

@onready var spiderrendu: Node2D = $spiderrendu
@onready var animated_sprite_2d: AnimatedSprite2D = $spiderrendu/AnimatedSprite2D

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

@onready var timer: Timer = $Timer

@onready var right: RayCast2D = $right
@onready var left: RayCast2D = $left
@onready var down: RayCast2D = $down
@onready var top: RayCast2D = $top

func _physics_process(delta: float) -> void:
	#atk_logik()
	if !is_attacking():move_logic(delta)
	
	move_animation()
	
const SPEED = 50.0
var rng = RandomNumberGenerator.new()
var direction : int = 0
var last_surface : String = ""
func move_logic(delta)->void:
	"""if getCollisionSurface(top):
		last_surface="top"
	if getCollisionSurface(down):
		last_surface="down"
	if getCollisionSurface(right):
		last_surface="right"
	if getCollisionSurface(left):
		last_surface="left"
	"""
	if last_surface=="":
		if getCollisionSurface(right):
			last_surface="right"
		if getCollisionSurface(left):
			last_surface="left"
		if getCollisionSurface(top):
			last_surface="top"
		if getCollisionSurface(down):
			last_surface="down"
	if last_surface=="down":
		if getCollisionSurface(right):
			last_surface="right"
		if getCollisionSurface(left):
			last_surface="left"
	if last_surface=="top":
		if getCollisionSurface(right):
			last_surface="right"
		if getCollisionSurface(left):
			last_surface="left"
	if last_surface=="right":
		if getCollisionSurface(top):
			last_surface="top"
		if getCollisionSurface(down):
			last_surface="down"
	if last_surface=="left":
		if getCollisionSurface(top):
			last_surface="top"
		if getCollisionSurface(down):
			last_surface="down"

	if direction :
		if last_surface=="top" or last_surface=="down":
			velocity.x = direction * SPEED
		if last_surface=="right" or last_surface=="left":
			velocity.y = direction * SPEED
	else:
		if last_surface=="top" or last_surface=="down":
			velocity.x = move_toward(velocity.x, 0, SPEED)
		if last_surface=="right" or last_surface=="left":
			velocity.y = move_toward(velocity.y, 0, SPEED)
		
	move_and_slide()
	
func move_animation()->void:
	if direction == 0 :
		animated_sprite_2d.play("idle")
	else:
		animated_sprite_2d.play("walk")
		if direction == -1 :
			spiderrendu.scale.x = -1
		if direction == 1 :
			spiderrendu.scale.x = 1
		
	if last_surface=="top":
		spiderrendu.scale.y = -1
	if last_surface=="down":
		spiderrendu.scale.y = 1
	if last_surface=="right":
		rotation_degrees=-90
	if last_surface=="left":
		rotation_degrees=90
		
func atk_logik()->void:
	var bodycolright :CharacterBody2D=getcollisionbody(right)
	var bodycolleft :CharacterBody2D=getcollisionbody(left)
	
	if bodycolright !=null or bodycolleft !=null:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		animated_sprite_2d.play("attack")
		audio_stream_player_2d.play()
		
		if bodycolleft != null and bodycolright == null:
			spiderrendu.scale.x = -1
			await get_tree().create_timer(0.1).timeout
			bodycolleft.position.x -= 2
		if bodycolright != null and bodycolleft == null:
			spiderrendu.scale.x = 1
			await get_tree().create_timer(0.1).timeout
			bodycolright.position.x += 2
			
func is_attacking()->bool:
	return animated_sprite_2d.animation == "attack" and animated_sprite_2d.is_playing()
	
func getcollisionbody(rcast:RayCast2D):
	if rcast.is_colliding():
		var collidobj = rcast.get_collider()
		if collidobj is Player or collidobj is Spider :
			return collidobj
	return null

func getCollisionSurface(rcast:RayCast2D):
	if rcast.is_colliding():
		var collidobj = rcast.get_collider()
		if collidobj is StaticBody2D :
			return collidobj
	return null

func _on_timer_timeout() -> void:
	direction = rng.randi_range(-1, 1)
	timer.start()
