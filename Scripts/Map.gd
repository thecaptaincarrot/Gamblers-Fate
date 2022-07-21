extends Node

const TWEENTIME = 2.0

const ENEMY = preload("res://Map/Skull.png")
const EVENT = preload("res://Map/Event.png")
const BOSS = preload("res://Map/BossSkull.png")
const START = preload("res://Map/Spiral.png")
const EXIT = preload("res://Map/Exit.png")
const HEAL = preload("res://Sprites/Heal.png")

const GENERIC = preload("res://Map/MapNode.tscn")

const HEART = preload("res://Heart.tscn")

var movement = true

# Called when the node enters the scene tree for the first time.
func _ready():
	draw_map()
	#Put player at their position
	var starting_position = MapHandler.get_node_from_index(MapHandler.player_position)
	$PlayerSprite.position = starting_position["MapPosition"]
	
	#Move Camera
	$MainCamera.target_position = $PlayerSprite.position.y
	$MainCamera.position.y = $PlayerSprite.position.y
	
	draw_hearts()


func draw_hearts():
	var heart_num = 1
	for n in $HUD/HeartHandler.get_children():
		n.queue_free()
	for i in range(1,Global.player_max_health + 1):
		var new_heart = HEART.instance()
		new_heart.name = "Heart" + str(heart_num)
		new_heart.position.x = (i-1) * 40
		$HUD/HeartHandler.add_child(new_heart)
		if i > Global.player_health:
			new_heart.frame = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$HUD/Gold.text = str(Global.gold)


func draw_map():
	for node in MapHandler.map:
		var new_node  = GENERIC.instance()
		var texture = BOSS
		match node["Type"]:
			"Start":
				texture = START
			"Event":
				texture = EVENT
			"FakeEvent":
				texture = EVENT
			"Enemy":
				texture = ENEMY
			"Exit":
				texture = EXIT
			"Boss":
				texture = BOSS
			"Heal":
				texture = HEAL
		new_node.position = node["MapPosition"]
		new_node.texture = texture
		new_node.connect("clicked",self,"node_clicked")
		new_node.index = node["Index"]
		
		add_child(new_node)
		
		#create connections
		for connection in node["Connections"]:
			var new_line = Line2D.new()
			new_line.width = 5
			new_line.default_color = Color(.8,.5,0)
			#get the map position of connection
			var connected_node = MapHandler.get_node_from_index(connection)
			new_line.add_point(connected_node["MapPosition"])
			new_line.add_point(new_node.position)
			new_line.z_index = -1
			add_child(new_line)
		


func go_to_battle_event():
	if Global.player_health > 0:
		if !Global.photosensitivity:
			$AnimationPlayer.play("Battle")
			yield($AnimationPlayer,"animation_finished")
		else:
			$AnimationPlayer.play("Battle_Sensitivity")
			yield($AnimationPlayer,"animation_finished")
		get_tree().change_scene("res://CombatTest.tscn")
	else:
		$AnimationPlayer.play("Death")



func node_clicked(node):
	if MapHandler.get_current_connection().has(node.index):
		if movement:
			movement = false
			MapHandler.player_position = node.index
			$PlayerSprite/MovementTween.interpolate_property($PlayerSprite,"position",$PlayerSprite.position,node.position, TWEENTIME)
			$PlayerSprite/MovementTween.start()



func _on_MovementTween_tween_all_completed():
	Global.tile_completed += 1
	var current_node = MapHandler.get_current_node()
	match current_node["Type"]:
		"Enemy":
			if !Global.photosensitivity:
				$AnimationPlayer.play("Battle")
				yield($AnimationPlayer,"animation_finished")
			else:
				$AnimationPlayer.play("Battle_Sensitivity")
				yield($AnimationPlayer,"animation_finished")
			EnemyHandler.to_fight = current_node["Identifier"]
			print(current_node["Identifier"])
			get_tree().change_scene("res://CombatTest.tscn")
		"FakeEvent":
			if !Global.photosensitivity:
				$AnimationPlayer.play("Battle")
				yield($AnimationPlayer,"animation_finished")
			else:
				$AnimationPlayer.play("Battle_Sensitivity")
				yield($AnimationPlayer,"animation_finished")
			EnemyHandler.to_fight = current_node["Identifier"]
			print(current_node["Identifier"])
			get_tree().change_scene("res://CombatTest.tscn")
		"Event":
			$HUD/Event.load_event(current_node["Identifier"])
			$HUD/Event.show()
		"Boss":
			if !Global.photosensitivity:
				$AnimationPlayer.play("Battle")
				yield($AnimationPlayer,"animation_finished")
			else:
				$AnimationPlayer.play("Battle_Sensitivity")
				yield($AnimationPlayer,"animation_finished")
			EnemyHandler.to_fight = current_node["Identifier"]
			print(current_node["Identifier"])
			get_tree().change_scene("res://CombatTest.tscn")
		"Exit":
			get_tree().change_scene("res://Victory.tscn")
		"Heal":
			$Heal.play()
			if Global.player_health < Global.player_max_health:
				Global.player_health += 1
			draw_hearts()
	movement=true


func _on_OkButton_pressed():
	movement = true
	$HUD/Event.hide()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Death":
		get_tree().change_scene("res://GameOver.tscn")



func _on_Help_pressed():
	$HUD/Instructions.show()
