extends Sprite

const D4 = preload("res://DiceSprites/D4.png")
const D6 =  preload("res://DiceSprites/D6.png")
const D8 =  preload("res://DiceSprites/D8.png")
const D10 =  preload("res://DiceSprites/D10.png")

var mouse_in = false

var values = [1,2,3,4,5,6]
var roll = -1

var index = -1

var animation_queue = []

signal RemoveFromPlay

# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _input(event):
	if event.is_action_pressed("LMB") and mouse_in:
		print("Hello")
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
	
	self_modulate = dice_dict["Color"]
	
	values.sort()
	$Num.text = str(values[len(values)-1])

func set_roll(value):
	roll = value


func play_roll_animation():
	$AnimationPlayer.play("Roll")


func roll():
	
	$Num.text = str(values[rand_range(0,len(values))])


func final_roll():
	$Num.text = str(values[roll])


func _on_Area2D_mouse_entered():
	mouse_in = true


func _on_Area2D_mouse_exited():
	mouse_in = false


func _on_AnimationPlayer_animation_finished(anim_name):
	print(animation_queue)
	if animation_queue != []:
		var next_animation = animation_queue.pop_front()
		$AnimationPlayer.play(next_animation)
	elif anim_name == "Break":
		hide()
		queue_free()
