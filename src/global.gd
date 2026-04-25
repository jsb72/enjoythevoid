extends Node

var debug_mod:bool=false

var nb_fractal:int = 0

var door_opened:bool = false

var dash_unlock:bool = false
var sprint_unlock:bool = false
var doublejump_unlock:bool = false
var walljump_unlock:bool=false

var list_des_morts: Array[Vector2]

var first_cycle_done : bool = false

var fractal_list: Array[bool] = [true, true, true]


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
		walljump_unlock = true
		nb_fractal=3
		

		
		
		
		
		
		
