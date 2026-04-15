extends Node2D
@onready var player: Player = %Player

@onready var locklayer: CanvasLayer = $locklayer
@onready var animation_player: AnimationPlayer = $Sprite2D/AnimationPlayer
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var ouverture: AudioStreamPlayer2D = $ouverture



@onready var label: Label = $locklayer/Node2D/Label
@onready var label_2: Label = $locklayer/Node2D/Label2
@onready var label_3: Label = $locklayer/Node2D/Label3
@onready var label_6: Label = $locklayer/Node2D/Label6
@onready var label_5: Label = $locklayer/Node2D/Label5
@onready var label_4: Label = $locklayer/Node2D/Label4
@onready var label_9: Label = $locklayer/Node2D/Label9
@onready var label_8: Label = $locklayer/Node2D/Label8
@onready var label_7: Label = $locklayer/Node2D/Label7

@onready var line3: Array[Label] = [label, label_2, label_3]
@onready var line2: Array[Label] = [label_4, label_5, label_6]
@onready var line1: Array[Label] = [label_7, label_8, label_9]

@onready var pad: Array[Array] = [line1, line2, line3]

var x_select : int = 1
var y_select : int = 1

@onready var touche_prec : Label = label_7
@onready var resfalse: Label = $locklayer/Node2D/resfalse
@onready var res: Label = $locklayer/Node2D/res
@onready var fadeoutdigit: AnimationPlayer = $locklayer/Node2D/fadeoutdigit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	touche_prec.modulate.a = 0.3
	
	if Global.cube_opened:animation_player.play("up_door")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if x_select==0 and Input.is_action_pressed("left"):
		player.dead_=false
		locklayer.hide()
		x_select=1
		y_select=1
	
	if locklayer.visible:
		if Input.is_action_just_released("right"):
			if x_select < 2:
				x_select += 1
		if Input.is_action_just_released("left"):
			if x_select > 0:
				x_select -= 1
		if Input.is_action_just_released("up"):
			if y_select > 0:
				y_select -= 1
		if Input.is_action_just_released("down"):
			if y_select < 2:
				y_select += 1
				
		var line  = pad[y_select]
		var touche = line[x_select]
		
		if touche != touche_prec :
			audio_stream_player_2d.play()
			touche_prec.modulate.a = 1
			touche.modulate.a = 0.5
			touche_prec = touche
			
		if Input.is_action_just_released("jump"):
			res.text += touche_prec.text

		if res.text.length()>4 :
			res.text = ""
			
	if res.text == "1972":
		if !Global.cube_opened:
			Global.cube_opened = true
			player.dead_ = false
			ouverture.play()
			
			
			fadeoutdigit.play("new_animation")
			await get_tree().create_timer(1).timeout
			locklayer.hide()
			
			animation_player.play("up_door")
		
func _on_openlockzone_body_entered(body: Node2D) -> void:
	if body is Player :
		if !Global.cube_opened:
			locklayer.show()
			#line_edit.grab_focus()
			body.dead_=true


"""
func _on_line_edit_text_changed(new_text: String) -> void:
	if new_text == "1972":
		animation_player.play("up_door")
		locklayer.hide()
		opened = true
	if new_text.length()>4 :
		line_edit.clear()"""
