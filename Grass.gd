extends Node3D
#var dir = "res://art/Grass/"
#var auraNode : PackedScene
#var aura : Node3D
#var files : Array
var center = Vector3(0,0,0)
var extent = 1
var meshMax = 0.2
#var growSpeed = 0.0005
#var grassNum = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	$MultiMeshInstance3D.position.y = - 1
	$MultiMeshInstance3D.scale.y = meshMax
	$MultiMeshInstance3D.scale.x *= extent/5
	$MultiMeshInstance3D.scale.z *= extent/5
	#add_to_group("grass")
	#randomize()
	#var grassPoints = generate_random_points(grassNum,0.05)
	#rotation.y = randf_range(0,360)
	#dir_contents(dir)
	#
	#for point in grassPoints:
		#var grassfile = randi_range(0,len(files)-1)
		#var grassNode = load(dir+files[grassfile])
		#print(dir+files[grassfile])
		#var grass = grassNode.instantiate()
		#grass.position = point
		#add_child(grass)
		#
	#for node in get_children():
		#if node is Node3D:
			#node.scale = Vector3(0.1,0.1,0.1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#$GrassBase.scale.x -= 0.1
	$MultiMeshInstance3D.position.y = clamp($MultiMeshInstance3D.position.y+0.05*delta,-extent,0)
	
	
	#
	##for node in get_children():
		##if node is Node3D and node.scale.x<1:
			##node.scale += Vector3(growSpeed,growSpeed,growSpeed)*randf_range(0.001,10)
	#
#func dir_contents(path):
	#var dir = DirAccess.open(path)
	#if dir:
		#dir.list_dir_begin()
		#var file_name = dir.get_next()
		#while file_name != "":
			#if file_name.ends_with(".glb"):
				#files.append(file_name)
			#file_name = dir.get_next()
	#else:
		#print("An error occurred when trying to access the path.")
	#return 1
#
func _set_center_and_extent(center_point : Vector3, extent_f : float):
	center = center_point
	extent = extent_f
	#
#func generate_random_points(num_points: int, min_distance: float) -> Array:
	#var points: Array = []
#
	#for i in range(num_points):
		#var new_point = Vector3(randfn(center.x,extent),0, randfn(center.z,extent))
#
		## Ensure minimum distance
		#for existing_point in points:
			#var distance = new_point.distance_to(existing_point)
			#if distance < min_distance:
				## Adjust the new point to satisfy the minimum distance requirement
				#var angle = randf() * 2 * PI
				#new_point.x += min_distance * cos(angle)
				#new_point.y += min_distance * sin(angle)
#
		#points.append(new_point)
#
	#return points
