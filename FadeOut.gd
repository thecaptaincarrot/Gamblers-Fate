extends ColorRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$Tween.interpolate_property(self,"color",Color(0,0,0,0),Color(0,0,0,1),3.0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Tween_tween_all_completed():
	get_tree().change_scene("res://GameOver.tscn")
