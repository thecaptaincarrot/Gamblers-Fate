extends Node

const HEART = preload("res://Heart.tscn")
const SHIELD = preload("res://CombatNodes/Shield.tscn")

enum {GAME,VICTORY,DEFEAT}

var field_dice = []  #inventory indices ex [1,1,1,1,2,3,4,4,8,5,5,5,5,5,5,6,1,2,3,3,1]

var state = GAME
var blocking = false
var targetting = false

var animations_finished = 0

var enemy = {}
var attack_range = {}
var enemy_health = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	#Initialize player health
	var heart_y = 32
	var heart_x = 416
	for i in range(1,Global.player_max_health + 1):
		var new_heart = HEART.instance()
		new_heart.position = Vector2(heart_x,heart_y)
		heart_x += 36
		if i % 6 == 0:
			heart_y += 32
			heart_x = 416
		if i > Global.player_health:
			new_heart.frame = 0
		else:
			new_heart.frame = 1
		new_heart.name = "Heart" + str(i)
		$PeoplePlane/MCHearts.add_child(new_heart)
	var new_shield = SHIELD.instance()
	new_shield.position = Vector2(heart_x,heart_y)
	$PeoplePlane/MCHearts.add_child(new_shield)
	#Load Enemy
	load_enemy(EnemyHandler.get_current_enemy())


func load_enemy(enemy_dict):
	enemy = enemy_dict
	print(enemy["Name"])
	$PeoplePlane/EnemySprite.texture = load(enemy["Image"])
	$PeoplePlane/EnemyName.text = enemy["Name"]
	$AffinityBar.initialize(enemy["Ranges"])
	attack_range = enemy["Ranges"]
	
	enemy_health = enemy["Health"]
	#Enemy Hearts
	var heart_y = 32
	var heart_x = 832
	for i in range(1,enemy_health + 1):
		var new_heart = HEART.instance()
		new_heart.position = Vector2(heart_x,heart_y)
		heart_x += 36
		if i % 6 == 0:
			heart_y += 32
			heart_x = 832
		if i > enemy_health:
			new_heart.frame = 0
		else:
			new_heart.frame = 1
		new_heart.name = "Heart" + str(i)
		print(new_heart.name)
		$PeoplePlane/EnemyHearts.add_child(new_heart)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Global.player_health <= 0:
		$CanvasLayer/FadeOut.show()
		#TODO death animation or something
		$CanvasLayer/FadeOut/Tween.start()
	


func add_to_field(index):
	if state != GAME:
		return
	#1. check to see if an add is possible (field dice >= inventory total) DONE
	#2. add dice to field array DONE
	#3. tell dice plane to update DONE
	#4. Update Dice Selector DONE
	if field_dice.count(index) < Inventory.get_dice_count(index) and len(field_dice) < 5:
		field_dice.append(index)
		$DiceField.update_field(field_dice)
		$DiceDown.play()
	pass



func remove_from_field(index):
	if state != GAME:
		return
	field_dice.erase(index)
	$DiceSelector.dice_remove(index)
	$DiceField.update_field(field_dice)
	$DiceUp.play()


func field_dice_done():
	animations_finished -= 1
	if animations_finished <= 0:
		$DiceField/Roll.disabled = false


func _on_Roll_pressed():
	if field_dice == []:
		return 
	
	$Roll.play()
	$DiceField/Roll.disabled = true
	animations_finished = len(field_dice)
	
	var total_roll = 0
	var i = 0
	
	var to_heal = false
	
	var to_erase = []
	for die_index in field_dice:
		var current_die = $DiceField/Dice.get_child(i)
		
		var die = Inventory.dice[die_index][0]
		var die_values = die["Values"]
		
		var roll = randi() % len(die_values)
		
		var die_roll = die_values[roll]
		
		total_roll += die_roll
		
		current_die.set_roll(roll)
		current_die.play_roll_animation()
		
		if die.keys().has("Break"):
			if die["Break"].has(float(roll)):
				Inventory.remove_dice(die_index)
				to_erase.append(die_index)
				current_die.animation_queue.append("Break")
		if die.keys().has("Heal"):
			if die["Heal"].has(float(roll)):
				to_heal = true
				current_die.animation_queue.append("Heal")
		if die.keys().has("Block"):
			if die["Block"].has(float(roll)):
				blocking = true
				current_die.animation_queue.append("Block")
		if die.keys().has("Target"):
			if die["Target"].has(float(roll)):
				targetting = true
				current_die.animation_queue.append("Target")
		
		i += 1
	
	if to_erase != []:
		for erase in to_erase:
			field_dice.erase(erase)
	
	yield(get_tree().create_timer(1.0),"timeout")
	
	$DiceField/HBoxContainer/Total.text = str(total_roll)
	
	for x in attack_range:
		if total_roll >= x["Range"][0] and total_roll <= x["Range"][1]:
			match x["Type"]:
				"Crit":
					$PeoplePlane/EnemySprite/EnemyAnimations.play("Crit")
					damage_enemy(2)
					$EnemyCrit.play()
				"Damage":
					$PeoplePlane/EnemySprite/EnemyAnimations.play("Hurt")
					damage_enemy(1)
					$EnemyHit.play()
				"Attack":
					$PeoplePlane/EnemySprite/EnemyAnimations.play("Hurt")
					damage_player(1)
					damage_enemy(1)
					$BothHit.play()
				"Fail":
					damage_player(1)
					$EnemyHit.play()
	if to_heal:
		heal_player(1)
	
	$DiceSelector.update()


func heal_player(healing):
	for i in range(0,healing):
		if Global.player_health < Global.player_max_health:
			var next_heart = get_node("PeoplePlane/MCHearts/Heart" + str(Global.player_health + 1))
			next_heart.heal()
			Global.player_health += 1


func damage_player(damage):
	if blocking:
		blocking = false
		get_node("PeoplePlane/MCHearts/Shield").show()
		get_node("PeoplePlane/MCHearts/Shield").break_shield()
		return
	for i in range(0,damage):
		var next_heart = get_node("PeoplePlane/MCHearts/Heart" + str(Global.player_health))
		next_heart.hurt()
		Global.player_health -= 1


func damage_enemy(damage):
	if targetting:
		targetting = false
		$PeoplePlane/EnemySprite/Target/TargetAnimation.play("Target")
		damage += 1
	for i in range(0,damage):
		var next_heart = get_node("PeoplePlane/EnemyHearts/Heart" + str(enemy_health))
		next_heart.hurt()
		enemy_health -= 1
		if enemy_health <= 0:
			break
	
	if enemy_health <= 0:
		pass
		print("Dead")
		#kill enemy with animation
		$PeoplePlane/EnemySprite/EnemyAnimations.stop()
		$PeoplePlane/EnemySprite/EnemyAnimations.play("Die")
		#hide Dice Field
		$DiceField.hide()
		for N in $DiceSelector/MarginContainer/ScrollContainer/OptionContainer.get_children():
			N.disable_all()
		#Replace with loot screen
		$VictoryScreen.reset()
		loot()
		


func loot():
	$VictoryScreen.reset()
	#All enemies drop gold ig
	$VictoryScreen.show()
	var gold_drop = round(rand_range(enemy["Gold"][0],enemy["Gold"][1]))
	Global.gold += gold_drop
	$VictoryScreen/VictoryPanel/Spoils/Gold.bbcode_text = "[color=yellow]" + str(gold_drop) + " Gold[/color] Recovered"
	match enemy["Drops"]:
		"Bag":  #regular dice bag of 3 dice
			var new_dice = DiceHandler.generate_dice_bag() #Array of indices
			var dice_num = 1
			for index in new_dice:
				var color = "yellow"
				match DiceHandler.dice[index]["Rarity"]:
					"Uncommon":
						color = "green"
					"Rare":
						color = "blue"
				get_node("VictoryScreen/VictoryPanel/Spoils/Dice" + str(dice_num)).bbcode_text = "	-Acquired new dice: [color=" + color + "]" + DiceHandler.dice[index]["Name"] + "[/color]"
				dice_num += 1
			$VictoryScreen/VictoryAnimation.play("Bag")
		"Relic":
			pass
			$VictoryScreen/VictoryAnimation.play("Relic")
		"Both":
			var new_dice = DiceHandler.generate_dice_bag() #Array of indices
			var dice_num = 1
			for index in new_dice:
				get_node("VictoryScreen/VictoryPanel/Spoils/Dice" + str(dice_num)).bbcode_text = "	-Acquired new dice: " + DiceHandler.dice[index]["Name"]
				dice_num += 1
			pass#relic todo
			$VictoryScreen/VictoryAnimation.play("Both")
		"RareBag":
			var new_dice = DiceHandler.generate_rare_bag() #Array of indices
			print(new_dice)
			var dice_num = 1
			for index in new_dice:
				get_node("VictoryScreen/VictoryPanel/Spoils/Dice" + str(dice_num)).bbcode_text = "	-Acquired new dice: " + DiceHandler.dice[index]["Name"]
				dice_num += 1
			$VictoryScreen/VictoryAnimation.play("Bag")
		"RareBoth":
			var new_dice = DiceHandler.generate_rare_bag() #Array of indices
			var dice_num = 1
			for index in new_dice:
				get_node("VictoryScreen/VictoryPanel/Spoils/Dice" + str(dice_num)).bbcode_text = "	-Acquired new dice: " + DiceHandler.dice[index]["Name"]
				dice_num += 1
			pass #TODO Relics
			$VictoryScreen/VictoryAnimation.play("Both")
		"Gold":
			$VictoryScreen/VictoryAnimation.play("Gold")


func _on_Return_pressed():
	get_tree().change_scene("res://Map.tscn")


func _on_TextureButton_pressed():
	$CanvasLayer/Instructions.show()
