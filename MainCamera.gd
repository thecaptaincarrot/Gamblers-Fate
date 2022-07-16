extends Camera2D

const MINY = 0
const MAXY = -10000
const CAMERAACCELERATION = 5.0

var target_position = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("ui_up"):
		target_position -= CAMERAACCELERATION
	elif Input.is_action_pressed("ui_down"):
		target_position += CAMERAACCELERATION
	target_position = clamp(target_position,MAXY,MINY)
	position.y = lerp(position.y,target_position,.2)

