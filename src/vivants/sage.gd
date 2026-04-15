extends Node2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@onready var rich_text_label: RichTextLabel = $RichTextLabel
var iswaken : bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		if !iswaken:
			animated_sprite_2d.play("wakeup")
			
			var tween = get_tree().create_tween()
			tween.tween_property(rich_text_label, "modulate:a", 0.0, 10.0)
			
			iswaken=true
