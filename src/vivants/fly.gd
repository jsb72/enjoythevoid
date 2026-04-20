extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer
@onready var bomb: RigidBody2D = $bomb
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var pin_joint_2d: PinJoint2D = $PinJoint2D


const SPEED = 75.0

var direction : int = 0
var rng = RandomNumberGenerator.new()
var rng2 = RandomNumberGenerator.new()

var throwing_bomb : bool = false

var initial_pos : Vector2
func _ready() -> void:
	initial_pos=global_position
	
func _physics_process(delta: float) -> void:

	if global_position.x > initial_pos.x + 600:
		if direction > 0 :
			direction = 0
	if global_position.x < initial_pos.x - 600:
		if direction < 0 :
			direction = 0
		
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if velocity.x < 0 :
		animated_sprite_2d.flip_h=false
	if velocity.x > 0 :
		animated_sprite_2d.flip_h=true

	move_and_slide()
	
		
		
	#collision mask only collide mask 2 (player is layer collision 2)
	if ray_cast_2d.is_colliding() and !throwing_bomb:
		var collidobj = ray_cast_2d.get_collider()
		pin_joint_2d.set_node_b("")
		throwing_bomb=true 
		
		await get_tree().create_timer(1).timeout
		
		var bombpacked = load("res://src/elements/bomb.tscn")
		var new_bomb = bombpacked.instantiate()
		add_child(new_bomb)
		new_bomb.position = Vector2(0,95)
		pin_joint_2d.set_node_b(new_bomb.get_path())
		throwing_bomb=false


func _on_timer_timeout() -> void:
	direction = rng.randi_range(-1, 1)
	timer.start()
