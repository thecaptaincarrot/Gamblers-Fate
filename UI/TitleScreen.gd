extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_StoryMode_pressed():
	MapHandler.reset_story_mode()
	Inventory.reset_inventory()
	Global.reset()
	get_tree().change_scene("res://Map.tscn")


func _on_NoEscape_pressed():
	MapHandler.reset_endless_mode()
	Inventory.reset_inventory()
	Global.reset()
	get_tree().change_scene("res://Map.tscn")


func _on_Credits_pressed():
	$CreditsPanel.show()
