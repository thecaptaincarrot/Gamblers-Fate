extends Node

const MINX = 0
const MAXX = 6

var map_height = 9

var map = []
var player_position = 0 #default start, by index


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	EnemyHandler.load_enemies()
	EventHandler.load_events()
	initialize_map()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func initialize_map():
	#Map dictionary: {"Type": ("Enemy",Event"),"Identifier":(Name of file we're loading, either event or enemy)\
	#"GridVector":Vector2((0-7),(1+)),"MapPosition":Vector2(where to draw), "Connections":[index, on, array]}
	#var map = []
	
	#1 initialize start
	var new_start = {"Index": 0, "Type": "Start","Identifier": null, "GridVector" : Vector2(3,0),"MapPosition" : Vector2(282,300), "Connections" : [] }
	var index = 1
	map.append(new_start)
	#Connections added one step back
	for i in range (1,map_height):
		var num_nodes = 0 #random between 2 and 3?
		var x_possible = []
		
		#Generating what x positions to create nodes
		#This also tells us how many to make
		var x_vectors = []
		var previous_row = get_row(i-1)
		#Generate x_possible
		for node in previous_row:
			var offsets = [-1,0,1]
			var node_x = node["GridVector"].x
			for offset in offsets:
				if offset + node_x >= MINX  and offset + node_x <= MAXX and !x_possible.has(offset + node_x):
					x_possible.append(offset + node_x)
		#Generate required exits, all nodes must have at least one possible exit
		for node in previous_row:
			var offset = 1 - randi() % 3
			var x_candidate = node["GridVector"].x + offset
			x_candidate = clamp(x_candidate,MINX,MAXX)
			if !x_vectors.has(x_candidate) and x_possible.has(x_candidate):
				x_vectors.append(x_candidate)
				x_possible.erase(x_candidate)
		#Generate a random number of extra possible exits
		var extra_nodes = 0
		if x_possible != []:
			extra_nodes = randi() % len(x_possible) + 1
		for k in range(0,extra_nodes):
			x_possible.shuffle()
			x_vectors.append(x_possible.pop_front())
		#Generate Nodes from X positions
		var current_row = []
		for x in x_vectors:
			var new_node = {}
			#Type and Identifier
			var type_tupple = random_type()
			new_node["Type"] = type_tupple[0]
			new_node["Identifier"] = type_tupple[1]
			#Grid Vector and Map Position
			new_node["GridVector"] = Vector2(x,i)
			new_node["MapPosition"] = Vector2(48 + x * 80 + rand_range(-8,8),300 - 100 * i + rand_range(-8,8))
			new_node["Connections"] = []
			#unique identifier
			new_node["Index"] = index
			index += 1
			#Add 
			current_row.append(new_node)
		
		#Make Connections to previous
		#Force at least one connection from previous to current
		#two loops:
		#first loops generates one forced exit for each in previous row, then creates extra exits with "coin" flip
		#Second loop is a failsafe to force one entry to current row
		#connections are always progressive and not regressive.
		#As in connections go from preivous to current, not other way around
		for node in previous_row:
			var offsets = [-1,0,1]
			#find all possible connections with current row
			var possible_connections = []
			for offset in offsets:
				var test_x = node["GridVector"].x + offset
				for current_node in current_row:
					if current_node["GridVector"].x == test_x and !possible_connections.has(current_node["Index"]):
						possible_connections.append(current_node["Index"])
			#first forced connection
			possible_connections.shuffle()
			node["Connections"].append(possible_connections.pop_front())
			#randomize other connections
			for connection in possible_connections:
				if randi() % 4 == 1 and !node["Connections"].has(connection):
					node["Connections"].append(connection)
			#Randomly select one forced connection
			#add that connection to the node in the curren row: all connections run backwards.
			
		#
		for node in current_row:
			#check to see if previous row has at least one connection to this node
			var no_connection = true
			for prev_node in previous_row:
				if prev_node["Connections"].has(node["Index"]):
					no_connection = false
			
			if no_connection:
				var possible_connections = []
				#Force create one connection between previous and current
				var offsets = [-1,0,1]
				for prev_node in previous_row:
					for offset in offsets:
						var test_x = offset + node["GridVector"].x
						if test_x == prev_node["GridVector"].x and !possible_connections.has(prev_node):
							possible_connections.append(prev_node)
				
				possible_connections.shuffle()
				possible_connections.front()["Connections"].append(node["Index"])
			
			pass

			map.append(node)
	
	var new_exit = {"Index": index, "Type": "Exit","Identifier": null, "GridVector" : Vector2(3,0),"MapPosition" : Vector2(282,300 + (map_height * -100)), "Connections" : [] }
	for node in get_row(map_height - 1):
		node["Connections"].append(new_exit["Index"])
	print(new_exit)
	map.append(new_exit)


func random_type():
	var dice_roll = randi() % 10
	if dice_roll <= 4: # 1 or 0, coin flip
		return ["Enemy",EnemyHandler.get_random_enemy()]
	elif dice_roll <= 8:
		return ["Event",EventHandler.get_random_event()]
	else:
		return ["Boss",EnemyHandler.get_random_boss()]

func get_row(index):
	var nodes = []
	for node in map:
		if node["GridVector"].y == index:
			nodes.append(node)
	return nodes


func get_node_from_index(index):
	for node in map:
		if node["Index"] == index:
			return node


func get_current_node():
	return get_node_from_index(player_position)


func get_current_connection():
	#returns current possible connection indices from player position
	return get_node_from_index(player_position)["Connections"]
