extends Node2D

const FIELDSPRITE = preload("res://FieldDice.tscn")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func clear_field():
	for child in $Dice.get_children():
		child.queue_free()

func update_field(dice):
	clear_field()
	#Updates sprites, etc on the dice field.
	#no rolling is done here
	#if you roll here, you are an idiot.
	
	var x = 160
	var y = 160
	
	for die_index in dice:
		var new_field_dice = FIELDSPRITE.instance()
		new_field_dice.initialize(die_index)
		new_field_dice.position = Vector2(x,y)
		
		new_field_dice.connect("RemoveFromPlay",get_parent(),"remove_from_field")
		new_field_dice.connect("AllAnimFinished",get_parent(),"field_dice_done")
		
		x += 96
		$Dice.add_child(new_field_dice)
	pass
