extends Camera2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$CameraTween.interpolate_property(self,"zoom",Vector2(.01,.01),Vector2(1.0,1.0),0.5)
	$CameraTween.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
