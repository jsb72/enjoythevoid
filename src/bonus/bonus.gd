extends Node2D

@onready var text_anim: AnimationPlayer = $Node2D/info_bonus/text_anim
@onready var move_y_anim: AnimationPlayer = $Node2D/move_y_anim
@onready var light_effect_anim: AnimationPlayer = $Node2D/sprites/Sprite2D2/light_effect_anim
@onready var fadout_sprit_anim: AnimationPlayer = $Node2D/sprites/fadout_sprit_anim

@export var type_bonus : String = ""
@onready var info_bonus: RichTextLabel = $Node2D/info_bonus
@onready var sprintsprite: Sprite2D = $Node2D/sprites/sprintsprite
@onready var dashsprite: Sprite2D = $Node2D/sprites/dashsprite
@onready var doublejump: Sprite2D = $Node2D/sprites/doublejump

@onready var dash_icon: TextureRect = $Node2D/info_bonus/dash_icon
@onready var jump_icon: TextureRect = $Node2D/info_bonus/jump_icon


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprintsprite.hide()
	dashsprite.hide()
	if !Global.sprint_unlock:
		if type_bonus == "sprint":
			info_bonus.text = "[color=#FFFFFF]You can now sprint! Just hold[/color]"
			
			dash_icon.show()
			jump_icon.hide()
			
			sprintsprite.show()
	if !Global.dash_unlock:
		if type_bonus == "dash":
			info_bonus.text = "[color=#FFFFFF]You can now dash![/color]"
			
			dash_icon.show()
			jump_icon.hide()
			
			dashsprite.show()
	if !Global.doublejump_unlock:
		if type_bonus == "doublejump":
			info_bonus.text = "[color=#FFFFFF]You can now double jump![/color]"
			
			jump_icon.show()
			dash_icon.hide()
			
			doublejump.show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func anim():
	move_y_anim.stop()
	light_effect_anim.stop()
	fadout_sprit_anim.play("new_animation")
	text_anim.play("new_animation")
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		if !Global.sprint_unlock and type_bonus == "sprint":
			Global.sprint_unlock = true
			anim()

		if !Global.dash_unlock and type_bonus == "dash":
			Global.dash_unlock = true
			anim()
			
		if !Global.doublejump_unlock and type_bonus == "doublejump":
			Global.doublejump_unlock = true
			anim()
