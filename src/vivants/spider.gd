class_name Spider
extends CharacterBody2D

@onready var spiderrendu: Node2D = $spiderrendu
@onready var animated_sprite_2d: AnimatedSprite2D = $spiderrendu/AnimatedSprite2D

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

@onready var timer: Timer = $Timer

@onready var right: RayCast2D = $right
@onready var left: RayCast2D = $left

const SPEED = 50.0

var direction : int = 0
var rng = RandomNumberGenerator.new()

func _physics_process(delta: float) -> void:
	#atk_logik()
	if !is_attacking():move_logic(delta)
	
	move_animation()
	
func move_logic(delta)->void:
	"""if not is_on_floor():
		velocity += get_gravity() * delta"""

	if direction :
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	move_and_slide()
	
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
			
func move_animation()->void:
	if velocity.x == 0 :
		animated_sprite_2d.play("idle")
	else:
		animated_sprite_2d.play("walk")
	if velocity.x < 0 :
		spiderrendu.scale.x = -1
	if velocity.x > 0 :
		spiderrendu.scale.x = 1
	if is_on_ceiling():
		spiderrendu.scale.y = -1
		
		
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
	direction = rng.randi_range(1, 1)
	timer.start()
