extends Node

var debug_mod:bool=true

var nb_fractal:int = 0

var door_opened:bool = false
var cube_opened : bool = false

var dash_unlock:bool = false
var sprint_unlock:bool = false
var doublejump_unlock:bool = false

var list_des_morts: Array[Vector2]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("escape"):
		get_tree().quit()
	
	if debug_mod:
		dash_unlock = true
		sprint_unlock = true
		doublejump_unlock = true
		

		
		
		
		
		
		
