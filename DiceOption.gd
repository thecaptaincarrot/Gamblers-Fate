extends Panel

const D4 = preload("res://DiceSprites/D4.png")
const D6 =  preload("res://DiceSprites/D6.png")
const D8 =  preload("res://DiceSprites/D8.png")
const D10 =  preload("res://DiceSprites/D10.png")

const BREAK = preload("res://DiceSprites/DiceBreak.png")
const SHIELD = preload("res://DiceSprites/Shield.png")

const SIDE = preload("res://UI/Side.tscn")

var inventory_index = -1

var inventory_amount = -1

signal FieldAdd
signal FieldRemove
#inventory index 0 is always the devil's knucklebone

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func initialize(index,field_dice):
	inventory_index = index
	var die_identity = Inventory.dice[index][0]
	$VBoxContainer/Title.text = die_identity["Name"]
	$Available.text = str(Inventory.get_dice_count(index) - field_dice.count(index))
	inventory_amount = Inventory.get_dice_count(index)
#	$TextContainer/Description.text = die_identity["Description"]
	
	var num_sides = len(die_identity["Values"])
	
	#Big Dice Texture
	$DiceSprite.texture = D6
	match num_sides:
		4:
			$DiceSprite.texture = D4
		8:
			$DiceSprite.texture = D8
		10:
			$DiceSprite.texture = D10
	$DiceSprite.self_modulate = die_identity["Color"]
	
	var values = die_identity["Values"]
	values.sort()
	$Num.text = str(values[len(values)-1])
	
	#Side Textures
	var side_texture = D6
	match num_sides:
		4:
			side_texture = D4
		8:
			side_texture = D8
		10:
			side_texture = D10
	
	for i in range(0,len(values)):
		var new_side = SIDE.instance()
		new_side.name = "Side" + str(i)
		new_side.get_node("DiceShape").texture = side_texture
		new_side.get_node("DiceShape").self_modulate = die_identity["Color"]
		
		new_side.get_node("DiceShape/Value").text = str(values[i])
		
		#Specials
		#Breaks
		var breaks = die_identity["Break"]
		if breaks.has(float(i)):
			new_side.get_node("Modifier").texture = BREAK
		
		$VBoxContainer/DiceValues.add_child(new_side)
		

func _on_TextureButton_pressed():
	emit_signal("FieldAdd",inventory_index)
	if int($Available.text) > 0:
		$Available.text = str(int($Available.text) - 1)

func _on_Plus_pressed():
	emit_signal("FieldAdd",inventory_index)
	if int($Available.text) > 0:
		$Available.text = str(int($Available.text) - 1)


func _on_Minus_pressed():
	emit_signal("FieldRemove",inventory_index)
	if int($Available.text) < inventory_amount:
		$Available.text = str(int($Available.text) + 1)
