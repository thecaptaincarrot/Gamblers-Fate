extends MarginContainer

var event


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func load_event(event_dict):
	#0 initialize some stuff
	for button in $Panel/OptionContainer.get_children():
		button.hide()
	#1 load the basic event structure
	event = event_dict
	
	$Panel/Title.text = event["Name"]
	$Panel/Background.texture = load(event["Background"])
	$Panel/Background/Image.texture = load(event["Image"])
	$Panel/Text.bbcode_text = event["Text"]
	
	var button_num = 1
	for choice in event["Choices"]:
		var button = get_node("Panel/OptionContainer/Button" + str(button_num))
		button.show()
		button.text = choice["Text"]
		#if !Requirements: TODO
			#button.disabled = true
		button_num += 1


func choice_chosen(button_num):
	
	#button_num is 0, 1, or 2
	#0 initialize some stuff
	for button in $Panel/OptionContainer.get_children():
		button.hide()
	$Panel/OptionContainer/OkButton.show()
	#1. figure out what the outcome is
	var choice = event["Choices"][button_num]
	
	var total_prob = 0
	for x in choice["Outcomes"]:
		total_prob += x["Probability"]
	
	var dice_roll = rand_range(0,total_prob)
	var outcome = null
	total_prob = 0
	
	for x in choice["Outcomes"]:
		total_prob += x["Probability"]
		if dice_roll <=total_prob:
			outcome = x
			break
	
	if outcome == null:
		return
	
	#2. reset event window to new options
	$Panel/Background/Image.texture = load(outcome["Image"])
	$Panel/Text.bbcode_text = outcome["Text"]
	var effect_text = ""
	for event in outcome["Events"]:
		match event:
			"OneDamage": #TODO this can kill you
				Global.player_health -= 1
				effect_text += "\n[color=red]You've taken one damage[/color]"
			"HealOne":
				if Global.player_health < Global.player_max_health:
					Global.player_health += 1
					effect_text += "\n[color=green]You health one point of damage[/color]"
				else:
					effect_text += "\nYou're already at full health"
			"HealAll":
				if Global.player_health < Global.player_max_health:
					Global.player_health = Global.player_max_health
					effect_text += "\n[color=green]You've been fully healed[/color]"
				else:
					effect_text += "\nYou're already at full health"
			"NewDice":
				var num_dice = (randi() % 3) + 2
				for i in range(0,num_dice):
					var new_dice = DiceHandler.generate_dice()
					match DiceHandler.dice[new_dice]["Rarity"]:
						"Common":
							effect_text += "\nAcquired new die: [color=yellow]" + DiceHandler.dice[new_dice]["Name"] + "[/color]"
						"Uncommon":
							effect_text += "\nAcquired new die: [color=green]" + DiceHandler.dice[new_dice]["Name"] + "[/color]"
						"Rare":
							effect_text += "\nAcquired new die: [color=blue]" + DiceHandler.dice[new_dice]["Name"] + "[/color]"
							
					Inventory.add_dice(DiceHandler.dice[new_dice])
	
	$Panel/Text.bbcode_text += effect_text
	
		#TODO match statement
		#TODO extra text with markdown



func _on_Button1_pressed():
	choice_chosen(0)


func _on_Button2_pressed():
	choice_chosen(1)


func _on_Button3_pressed():
	choice_chosen(2)
