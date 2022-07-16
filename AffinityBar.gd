extends Control

const BAR = preload("res://UI/RangeBar.tscn")

const CRITCOLOR = "#00ff00"
const DAMAGECOLOR = "#c5f536"
const ATTACKCOLOR = "#fff81f"
const FAILCOLOR = "#ff6b61"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func initialize(range_info):
	print(range_info)
	var bars = [] #array of bars, will be built in the scene at the end using pixel maths
	for x in range_info: #range is a reserved keyword
		#"Range" : [-1,2]
		#"Type" : "Crit"
		#"Damage"
		#"Attack"
		#"Fail"
		var new_bar = BAR.instance()
		var range_difference = x["Range"][1] - x["Range"][0]
		if range_difference == 0:
			new_bar.rect_size.x = 16
			new_bar.get_node("Label").text = str(x["Range"][0])
		elif range_difference > 10:
			new_bar.rect_size.x = 48 + 8 * (9)
			if x["Range"][0] == -99:
				new_bar.get_node("Label").text = "<" + str(x["Range"][1])
			else:
				new_bar.get_node("Label").text = str(x["Range"][0]) + "<"
		else:
			new_bar.rect_size.x = 48 + 8 * (range_difference - 1)
			new_bar.get_node("Label").text = str(x["Range"][0]) + "-" + str(x["Range"][1])
		
		new_bar.self_modulate = "#ffffff"
		new_bar.hint_tooltip = "Something has gone wrong"
		
		match x["Type"]:#Set Tooltip TODO
			"Crit":
				new_bar.self_modulate = CRITCOLOR
				new_bar.hint_tooltip = "CRIT"
			"Damage":
				new_bar.self_modulate = DAMAGECOLOR
				new_bar.hint_tooltip = "DAMAGE"
			"Attack":
				new_bar.self_modulate = ATTACKCOLOR
				new_bar.hint_tooltip = "ATTACK"
			"Fail":
				new_bar.self_modulate = FAILCOLOR
				new_bar.hint_tooltip = "FAIL"
		add_child(new_bar)
		bars.append(new_bar)
	
	var total_bar_size = 0
	for bar in bars:
		total_bar_size += bar.rect_size.x
	
	var current_x = -total_bar_size / 2
	for bar in bars:
		bar.rect_position.x = current_x
		current_x += bar.rect_size.x + 1








