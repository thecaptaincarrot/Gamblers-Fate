extends Control

const DICEOPTION = preload("res://DiceOption.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	update()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func update():
	for N in $MarginContainer/ScrollContainer/OptionContainer.get_children():
		N.queue_free()
	
	for i in range(0,len(Inventory.dice)):
		if Inventory.get_dice_count(i) > 0:
			var new_option = DICEOPTION.instance()
			new_option.initialize(i,get_parent().field_dice)
			$MarginContainer/ScrollContainer/OptionContainer.add_child(new_option)
			new_option.connect("FieldAdd",get_parent(),"add_to_field")
			new_option.connect("FieldRemove",get_parent(),"remove_from_field")


func dice_remove(index):
	for option in $MarginContainer/ScrollContainer/OptionContainer.get_children():
		if option.inventory_index == index:
			option.on_field_dice_removed()
