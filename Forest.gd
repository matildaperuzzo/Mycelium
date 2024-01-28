extends Node3D

var camera_speed = 10.0  # Adjust the speed according to your preference
var camera_node = Camera3D
var zoom_speed = .5

var positions = Array()
var connections : Array
var glowRing : Area3D
var connectionNode : PackedScene
var connectionsNum = 0

var glowRingSpeed = 10.
var lockedIn = false

var centerPoint = Vector3(0,0,0)
var startPoint = centerPoint
var treeCentered = true

var tot_resources = 113
var resource_left = tot_resources

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# Specify the coordinates where you want to place the tree
	positions.append(centerPoint)

	positions.append(Vector3(-16,0,12))
	positions.append(Vector3(-12,0,8))
	positions.append(Vector3(-16,0,-4))
	positions.append(Vector3(-4,0,-8))
	positions.append(Vector3(-12,0,-16))
	positions.append(Vector3(4,0,16))
	positions.append(Vector3(8,0,8))
	positions.append(Vector3(8,0,-8))
	positions.append(Vector3(16,0,4))
	positions.append(Vector3(18,0,-8))
	positions.append(Vector3(20,0,16))

	
	connections = _create_connection_matrix(len(positions))
	
	var myNode = preload("res://Tree1.tscn")
	
	for position in positions:
		var tree1 = myNode.instantiate()
		tree1.name ="Tree"+str(positions.find(position,0)+1)
		add_child(tree1)
		tree1.global_position = position	
		
	var glowRingNode = preload("res://GlowRing.tscn")
	glowRing = glowRingNode.instantiate()
	glowRing.position = centerPoint
	glowRing.position.y = 5
	add_child(glowRing)
	
	$Camera3D.position += centerPoint
	
	get_tree().get_first_node_in_group("tree")._connect()
	
	glowRing.locked_in.connect(_on_locked_in)
	connectionNode = preload("res://Connection.tscn")
	
	$UI/progress.value = 100
	$UI/Resources.show()
	$UI/progress.show()
	$UI/GameOver.hide()

func _process(delta):
	# Input handling for arrow keys
	var movement = Vector3.ZERO

	# check if timer has run out
	if lockedIn == false:
		if Input.is_action_pressed("ui_right"):
			movement.x += 1
		if Input.is_action_pressed("ui_left"):
			movement.x -= 1
		if Input.is_action_pressed("ui_down"):
			movement.z += 1
		if Input.is_action_pressed("ui_up"):
			movement.z -= 1
		if movement != Vector3.ZERO:
			treeCentered = false

	if Input.is_action_just_pressed("ui_accept") and treeCentered:
		var endPoint =  Vector3(glowRing.position.x,0,glowRing.position.z)
		var cond1 = is_nan(connections[positions.find(endPoint,0)][positions.find(centerPoint,0)])
		print(resource_left)
		print(centerPoint.distance_squared_to(endPoint))
		var cond2 = resource_left < centerPoint.distance_squared_to(endPoint)
		if cond1:
			print("Here")
			pass
		else:
			startPoint = centerPoint
			print("connecting")
			centerPoint = endPoint
			print(sum(connections[positions.find(centerPoint,0)]))
			if sum(connections[positions.find(centerPoint,0)])==0:
				var connection = connectionNode.instantiate()
				connection.set_start_end_points(startPoint,endPoint)
				resource_left -= endPoint.distance_to(startPoint)
				$UI/progress.value = resource_left*100/tot_resources
				add_child(connection)
				connection.name = "Connection"+str(connectionsNum+1)
				connectionsNum += 1
				connections[positions.find(startPoint,0)][positions.find(centerPoint,0)] = connectionsNum + 1
				connections[positions.find(centerPoint,0)][positions.find(startPoint,0)] = connectionsNum + 1

			
			var displacement = endPoint-startPoint
			# move_towards
			$Camera3D.position += displacement
		
	if Input.is_action_just_pressed("ui_cancel"):
		var condition1 = connections[positions.find(startPoint,0)][positions.find(centerPoint,0)] > 0
		var condition2 = glowRing.position == startPoint
		if condition1 and condition2:
			for node in get_tree().get_nodes_in_group("tree"):
				if (node.name == "Tree"+str(positions.find(centerPoint,0)+1)):
					node._disconnect()
					resource_left += centerPoint.distance_to(startPoint)
					$UI/progress.value = 100*resource_left/tot_resources
			for node in get_tree().get_nodes_in_group("connections"):
				if (node is Node3D) and (node.name == "Connection"+str(connectionsNum)):
					node._delete()
					connections[positions.find(startPoint,0)][positions.find(centerPoint,0)] = 0
					connections[positions.find(centerPoint,0)][positions.find(startPoint,0)] = 0
					connectionsNum -= 1
					var displacement = startPoint-centerPoint
					$Camera3D.position += displacement
					centerPoint = startPoint
					startPoint = positions[connections[positions.find(centerPoint,0)].find(connectionsNum+1)]
	
	# Normalize the movement vector to ensure consistent speed in all directions
	movement = movement.normalized()
	glowRing.position += movement*glowRingSpeed*delta

	var zoom_in_input = Input.is_action_just_pressed("zoom_in")
	var zoom_out_input = Input.is_action_just_pressed("zoom_out")

	if zoom_in_input:
		$Camera3D.size -= zoom_speed
	if zoom_out_input:
		$Camera3D.size += zoom_speed
		
	if _is_game_over(connections):
		$UI/Resources.hide()
		$UI/progress.hide()
		$UI/GameOver.show()
		
	
func _on_locked_in():
	$LockedInTimer.start()
	lockedIn = true
	treeCentered = true

func _on_locked_in_timer_timeout():
	lockedIn = false

func _create_connection_matrix(N):
	var mat = Array()
	for i in range(N):
		var mat_temp = Array()
		for j in range(N):
			mat_temp.append(0)
		mat.append(mat_temp)
		
		
	var pairs : Array = [Vector2(0,1),Vector2(0,2),Vector2(0,3),Vector2(0,10),Vector2(1,6),Vector2(2,6),Vector2(7,8),Vector2(8,9),Vector2(8,6),Vector2(8,11)]
	
	for i in range(5,N):
		pairs.append(Vector2(2,i))
		pairs.append(Vector2(3,i))
	for p in pairs:
		mat[int(p.x)][int(p.y)] = NAN
		mat[int(p.y)][int(p.x)] = NAN
	return mat
	
func sum(arr:Array):
	var result = 0
	for i in arr:
		if not is_nan(i):
			result+=i
	return result

func _is_game_over(mat):
	for row in mat:

		if sum(row) == 0:
			return false
	
	return true
