extends Node

var events = []


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func load_events():
	var files = []
	var dir = Directory.new()
	
	var directory_path = "res://EventFiles/"
	
	dir.open(directory_path)
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif file.ends_with(".json"):
			files.append(file)
	dir.list_dir_end()
	
	#Actually Read the Files? Why is this a seperate loop though
	for file_name in files:
		print(file_name)
		var event_dict = {}
		var file_to_read = File.new()
		
		var path_to_file = directory_path + file_name
		file_to_read.open(path_to_file, File.READ)
		
		print(file_name)
		var text = file_to_read.get_as_text()
		event_dict = JSON.parse(text).result
		file_to_read.close()
		
		events.append(event_dict)
		
	files.clear()


func get_random_event():
	var dice_roll = randi() % len(events)
	return events[dice_roll]
	
