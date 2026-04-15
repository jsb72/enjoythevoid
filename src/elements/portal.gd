extends Area2D
class_name Portal

@export var portal_target:Portal
@export var portal_reverse_color:bool = false
@export var black_portal:bool = false
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var point_light_2d: PointLight2D = $PointLight2D
@onready var sound: AudioStreamPlayer2D = $sound


func _ready() -> void:
	if portal_reverse_color :
		point_light_2d.color = Color("d477ffff")
		animated_sprite_2d.play("reverse")
	if black_portal:
		point_light_2d.color = Color("5c5c5cff")
		animated_sprite_2d.play("black")
func _process(delta: float) -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if body is Player or body is Ball:
		if !body.inside_portal:
			body.global_position = portal_target.global_position 
			#body.velocity.y = body.save_velocity.y * -1
			#body.velocity = body.velocity.rotated(portal_target.rotation)   
			#body.velocity = body.save_velocity.bounce(Vector2(-1,0).rotated(portal_target.rotation))
			var magnitude = body.save_velocity.length()
			var vecteur_droit = Vector2(-magnitude,0)
			var vecteur_rotated = vecteur_droit.rotated(portal_target.rotation)
			body.velocity = vecteur_rotated
			
			
			
			body.inside_portal = true
			
			sound.play()
			#body.shakecamtimer.start()
			
			body.hide()
			await get_tree().create_timer(0.02).timeout
			body.show()
			
			await get_tree().create_timer(0.1).timeout
			body.inside_portal = false
			
	

func _on_no_jump_body_entered(body: Node2D) -> void:
	if body is Player :
		
		body.inside_nojump_portal = true
		await get_tree().create_timer(0.5).timeout
		body.inside_nojump_portal = false
