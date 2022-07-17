extends Sprite

const D4 = preload("res://DiceSprites/D4.png")
const D6 =  preload("res://DiceSprites/D6.png")
const D8 =  preload("res://DiceSprites/D8.png")
const D10 =  preload("res://DiceSprites/D10.png")

const BREAK = preload("res://DiceSprites/DiceBreak.png")
const SHIELD = preload("res://DiceSprites/Shield.png")
const HEAL = preload("res://DiceSprites/Heal.png")
const TARGET = preload("res://DiceSprites/Target.png")

var mouse_in = false

var block_values = []
var break_values = []
var target_values = []
var heal_values = []

var values = [1,2,3,4,5,6]
var roll = -1

var index = -1

var animation_queue = []

signal RemoveFromPlay
signal AllAnimFinished

# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _input(event):
	if event.is_action_pressed("LMB") and mouse_in:
		emit_signal("RemoveFromPlay",index)


func initialize(dice_index):
	index = dice_index
	var dice_dict = Inventory.get_dice_dict(dice_index)
	var sides = len(dice_dict["Values"])
	match sides:
		4:
			texture = D4
		8:
			texture = D8
		10:
			texture = D10
	
	values = dice_dict["Values"]
	
	$Face.hide()
	if dice_dict.keys().has("Break"):
		break_values = dice_dict["Break"]
		if break_values.has(float(sides-1)):
			$Face.texture = BREAK
			$Face.show()
	if dice_dict.keys().has("Block"):
		block_values = dice_dict["Block"]
		if block_values.has(float(sides-1)):
			$Face.texture = SHIELD
			$Face.show()
	if dice_dict.keys().has("Heal"):
		heal_values = dice_dict["Heal"]
		if heal_values.has(float(sides-1)):
			$Face.texture = HEAL
			$Face.show()
	if dice_dict.keys().has("Target"):
		target_values = dice_dict["Target"]
		if target_values.has(float(sides-1)):
			$Face.texture = TARGET
			$Face.show()

	self_modulate = dice_dict["Color"]
	
	values.sort()
	$Num.text = str(values[len(values)-1])

func set_roll(value):
	roll = value


func play_roll_animation():
	$AnimationPlayer.play("Roll")


func roll():
	var new_roll = floor(rand_range(0,len(values)))
	var value = values[new_roll]
	$Face.hide()
	if break_values.has(new_roll):
		$Face.show()
		$Face.texture = BREAK
	if heal_values.has(new_roll):
		$Face.show()
		$Face.texture = HEAL
	if target_values.has(new_roll):
		$Face.show()
		$Face.texture = TARGET
	if block_values.has(new_roll):
		$Face.show()
		$Face.texture = SHIELD

	$Num.text = str(value)


func final_roll():
	$Num.text = str(values[roll])
	$Face.hide()
	if break_values.has(roll):
		$Face.show()
		$Face.texture = BREAK
	if heal_values.has(roll):
		$Face.show()
		$Face.texture = HEAL
	if target_values.has(roll):
		$Face.show()
		$Face.texture = TARGET
	if block_values.has(roll):
		$Face.show()
		$Face.texture = SHIELD

func _on_Area2D_mouse_entered():
	mouse_in = true


func _on_Area2D_mouse_exited():
	mouse_in = false


func _on_AnimationPlayer_animation_finished(anim_name):
	if animation_queue != []:
		var next_animation = animation_queue.pop_front()
		$AnimationPlayer.play(next_animation)
	elif anim_name == "Break":
		hide()
		emit_signal("AllAnimFinished")
		queue_free()
	else:
		emit_signal("AllAnimFinished")
