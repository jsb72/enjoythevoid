extends CharacterBody2D


@onready var timer: Timer = $Timer
@onready var bomb: RigidBody2D = $bomb
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var ray_cast_2d_2: RayCast2D = $RayCast2D2

@onready var rendu: Node2D = $rendu

@onready var ancrerouge: ColorRect = $RopeAnchor/ancrerouge

@export var free_zone:Area2D

const SPEED = 75.0

var directionx : int = 0
var directiony : int = 0
var rng = RandomNumberGenerator.new()
var rng2 = RandomNumberGenerator.new()

var throwing_bomb : bool = false
var new_bomb : RigidBody2D
func _ready() -> void:
	new_bomb=bomb
	
func _physics_process(delta: float) -> void:
	new_bomb.global_position=ancrerouge.global_position
	new_bomb.gravity_scale=0
	
	if (ray_cast_2d.is_colliding() or ray_cast_2d_2.is_colliding()) and !throwing_bomb:#collision mask only collide mask 2 (player is layer collision 2)
		throwing_bomb=true 
		
		new_bomb.gravity_scale=1
		
		var bombpacked = load("res://src/elements/bomb.tscn")
		new_bomb = bombpacked.instantiate()
		await get_tree().create_timer(1).timeout
		
		
		new_bomb.modulate.a=0
		add_child(new_bomb)
		new_bomb.hide()
		await get_tree().create_timer(0.1).timeout
		new_bomb.show()
		var tween = get_tree().create_tween()
		tween.tween_property(new_bomb, "modulate:a", 1, 0.5)
		
		throwing_bomb=false

	
	
	
	
	

		
	var vec_tmp = Vector2(directionx,directiony)
	vec_tmp = vec_tmp.normalized()
	if vec_tmp != Vector2(0,0):
		velocity.x = vec_tmp.x * SPEED
		velocity.y = vec_tmp.y * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)
	if velocity.x < 0 :
		rendu.scale.x=1
	if velocity.x > 0 :
		rendu.scale.x=-1

	move_and_slide()
	
	if !free_zone.overlaps_body(self) and!timer.paused:
		timer.paused=true
		directionx=-directionx
		directiony=-directiony
		await get_tree().create_timer(1).timeout
		timer.paused=false


func _on_timer_timeout() -> void:
	directionx = rng.randi_range(-1, 1)
	directiony = rng.randi_range(-1, 1)
	timer.start()
