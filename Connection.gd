extends Node3D

var debug = false

var start_point : Vector3
var end_point : Vector3
var final_length
var temp_end_point : Vector3

var maxStrain = 4
var strainCount = 0

var pointCount = Array()
var passes = 0
var startPoints : Array
var endPoints : Array

var connectSpeed = .1
var do = true

var grassNode = preload("res://Grass.tscn")
var grass = grassNode.instantiate()
var grassStart = false

func _ready():
	add_to_group("connections")
	if debug == true:
		set_start_end_points(Vector3(0,0,-5),Vector3(0.,0,5))
	final_length = start_point.distance_to(end_point)
	var result = _generate_points(start_point,end_point)
	startPoints = result[0]
	endPoints = result[1]
	strainCount = 0
	for i in range(len(startPoints)):
		pointCount.append(0)

func _process(delta):
	for strain in range(maxStrain):
		
		if pointCount[strain] < len(startPoints[strain]):
			if strain == 0 and do == false:
				do = true
				pass
			elif strain == 0 and do == true:
				do = false
			var Connection = CSGCylinder3D.new()
			var s = startPoints[strain][pointCount[strain]]
			var e = endPoints[strain][pointCount[strain]]
			_adjust_connection(Connection,s,e,0,s.distance_to(e))
			if strain>0:
				Connection.radius /= strain
			add_child(Connection)
			pointCount[strain] += 1
		elif pointCount[strain] == len(startPoints[strain]) and strain == 0:
			for node in get_parent().get_tree().get_nodes_in_group("tree"):
				if node is Node3D and (node.position==end_point) :
					if not node._is_connected():
						node._connect()
						
		elif pointCount[strain] == len(startPoints[strain]) and strain == maxStrain-1:
			
			if grassStart == false:
				grass._set_center_and_extent(Vector3(0,0,0),final_length)
				
				grass.position = start_point+(end_point-start_point)/2
				grass.rotation = _get_angle(start_point,end_point)
				grass.rotation.z = 0
				add_child(grass)
				grassStart = true


		
func _adjust_connection(Connection, fromVec, toVec, angleRange, length = connectSpeed):
	Connection.material = preload("res://art/Glowing/Connection.tres")
	Connection.radius = 0.02
	Connection.rotation = _get_angle(fromVec,toVec)
	Connection.rotation_degrees.y += randf_range(-angleRange,angleRange)

	var end = _get_end_point(fromVec, Connection.rotation, length)
	end.x = fromVec.x - length*cos(Connection.rotation.y)
	end.z = fromVec.z + length*sin(Connection.rotation.y)
	var result = center_length_from_points(fromVec,end)
	Connection.position = result[0]
	Connection.height = length
	return end

func _get_end_point(start_point, angle, length):
	var end : Vector3
	end.x = start_point.x - length*cos(angle.y)
	end.z = start_point.z + length*sin(angle.y)
	return end
	
func _get_angle(start_point, end_point):
	var angle : Vector3
	angle.z = PI/2
	angle.y = PI/2 + atan2(end_point.x - start_point.x, end_point.z - start_point.z)
	angle.x = 0
	return angle
	
func _generate_points(start_point, end_point):
	var current_length = 0
	var temp_start_point = start_point
	var allPointsStart = Array()
	var allPointsEnd = Array()
	var pointsStart = Array()
	var pointsEnd = Array()
	
	while (current_length < 0.95*final_length):
		var angle = _get_angle(temp_start_point,end_point)
		angle.y += randf_range(-45,45)*PI/180
		var variation = randf_range(connectSpeed/2,connectSpeed*3/2)
		temp_end_point = _get_end_point(temp_start_point,angle,variation)
		pointsStart.append(temp_start_point)
		pointsEnd.append(temp_end_point)
		temp_start_point = temp_end_point
		current_length = start_point.distance_to(temp_end_point)
	
	allPointsStart.append(pointsStart)
	allPointsEnd.append(pointsEnd)
	strainCount += 1
		
	while strainCount < maxStrain:
		pointsStart = Array()
		pointsEnd = Array()
		for i in range(len(allPointsStart[strainCount-1])-1):
			var randRepeat = randf_range(0,1)
			var repeat = 2
			if randRepeat < (1/(strainCount+0.1)):
				repeat = 1

			for loop in range(repeat):
				var angle = Vector3.ZERO
				if strainCount == 1:
					angle = _get_angle(start_point,end_point)
					angle.y += sign(randf_range(-1,1))*PI/2 + randf_range(-PI/3,PI/3)
				else:
					angle = (_get_angle(find_closest_point(allPointsEnd[strainCount-1][i], allPointsStart[0]),allPointsEnd[strainCount-1][i]))
					angle.y += randf_range(-2*PI,2*PI)/(i)+ randf_range(-PI/4,PI/4)
				var variation = 0.75*connectSpeed
				temp_end_point = _get_end_point(allPointsEnd[strainCount-1][i],angle,(connectSpeed)+variation)
				pointsStart.append(allPointsEnd[strainCount-1][i])
				pointsEnd.append(temp_end_point)
		allPointsEnd.append(pointsEnd)
		allPointsStart.append(pointsStart)
		strainCount += 1
	
	return [allPointsStart,allPointsEnd]
	
func set_start_end_points(start,end):
	start_point = start
	end_point = end
	
func center_length_from_points(p1, p2):
	var distance = p1.distance_to(p2)
	var center = p1 + (p2 - p1)/2
	return [center, distance]
	
func find_closest_point(target_point: Vector3, points_array: Array) -> Vector3:
	var closest_point: Vector3 = Vector3.ZERO
	var closest_distance: float = 1e8

	for point in points_array:
		var distance = target_point.distance_to(point)
		if distance < closest_distance:
			closest_distance = distance
			closest_point = point
	return closest_point
	
func _delete():
	queue_free()
