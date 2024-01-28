extends Node3D

var debug = false
var start_point = Vector3(0,0,0)
var connectSpeed = 0.4

var strainNum = 4
var levelCount = 0
var levelNum = 5
var repetitions = 0

var points = Array()
var temp_points = Array()
# Called when the node enters the scene tree for the first time.
func _ready():
	if debug == true:
		_set_start_point(Vector3(0,0,0))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if levelCount == 0 and repetitions < 8:
		for i in range(strainNum):
			var Connection = CSGCylinder3D.new()
			var temp_end_point = _adjust_connection(Connection,start_point,Vector3(1,0,1),180)
			temp_points.append(temp_end_point)
			add_child(Connection)
		levelCount += 1
		points = temp_points
		temp_points = Array()
	
	elif levelCount<levelNum and repetitions<8:
		for point in points:
			var Connection = CSGCylinder3D.new()
			var dir = point-start_point
			var temp_end_point = _adjust_connection(Connection,point,dir*100,180/levelCount,connectSpeed/levelCount)
			temp_points.append(temp_end_point)
			Connection.radius = 0.02/levelCount
			add_child(Connection)
			var randNum = randf_range(0,1)
			if randNum>(float(levelCount)/float(levelNum)):
				Connection = CSGCylinder3D.new()
				dir = point-start_point
				temp_end_point = _adjust_connection(Connection,point,dir*100,180/levelCount,connectSpeed/levelCount)
				temp_points.append(temp_end_point)
				Connection.radius = 0.02/levelCount
				add_child(Connection)
				
		levelCount += 1
		points = temp_points
		temp_points = Array()
	
	elif levelCount == levelNum and repetitions < 8:
		levelCount = 0
		repetitions += 1
			
		
		

func _set_start_point(start):
	start_point = start
	
func _adjust_connection(Connection, fromVec, toVec, angleRange, length = connectSpeed):
	Connection.material = preload("res://art/Glowing/Connection.tres")
	Connection.radius = 0.02
	Connection.rotation_degrees.z = 90
	Connection.rotation_degrees.y = 90 + atan2(toVec.x - fromVec.x, toVec.z - fromVec.z) * 180 / PI
	Connection.rotation_degrees.y += randf_range(-angleRange,angleRange)

	var end = Vector3.ZERO
	end.x = fromVec.x - length*cos(Connection.rotation.y)
	end.z = fromVec.z + length*sin(Connection.rotation.y)
	var result = center_length_from_points(fromVec,end)
	Connection.position = result[0]
	Connection.height = length
	return end
	
func center_length_from_points(p1, p2):
	var distance = p1.distance_to(p2)
	var center = p1 + (p2 - p1)/2
	return [center, distance]
	
func _delete():
	queue_free()
