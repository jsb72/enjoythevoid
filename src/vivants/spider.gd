class_name Spider
extends CharacterBody2D

@onready var spiderrendu: Node2D = $spiderrendu
@onready var animated_sprite_2d: AnimatedSprite2D = $spiderrendu/AnimatedSprite2D

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D


@onready var timer: Timer = $Timer

@onready var right: RayCast2D = $right
@onready var left: RayCast2D = $left

@onready var droitebas: RayCast2D = $droitebas
@onready var droitehaut: RayCast2D = $droitehaut
@onready var gauchebas: RayCast2D = $gauchebas
@onready var gauchehaut: RayCast2D = $gauchehaut


const SPEED = 50.0

var direction : int = 0
var rng = RandomNumberGenerator.new()

func getcollisionbodyright():
	if right.is_colliding():
		var collidobj = right.get_collider()
		if collidobj is Player or collidobj is Spider :
			return collidobj
	return null
			
func getcollisionbodyleft():
	if left.is_colliding():
		var collidobj = left.get_collider()
		if collidobj is Player or collidobj is Spider :
			return collidobj
	return null
			

func is_attacking()->bool:
	return animated_sprite_2d.animation == "attack" and animated_sprite_2d.is_playing()
	
func _physics_process(delta: float) -> void:
	
	var bodycolright :CharacterBody2D=getcollisionbodyright()
	var bodycolleft :CharacterBody2D=getcollisionbodyleft()
	
	
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
	elif !is_attacking():
		
		
		"""droitebas
		droitehaut
		gauchebas
		gauchehaut"""
		
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		if velocity.x == 0 :
			animated_sprite_2d.play("idle")
		else:
			animated_sprite_2d.play("walk")
		if velocity.x < 0 :
			spiderrendu.scale.x = -1
		if velocity.x > 0 :
			spiderrendu.scale.x = 1
			
			
			
			
			
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
				
	move_and_slide()

func _on_timer_timeout() -> void:
	direction = rng.randi_range(-1, 1)
	timer.start()
