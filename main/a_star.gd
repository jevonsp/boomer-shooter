extends Node3D

var astar = AStar2D.new()
var grid_size = 20

func _ready() -> void:
	create_astar_grid()
	
func create_astar_grid():
	for x in range(grid_size):
		for z in range(grid_size):
			var id = get_point_id(x, z)
			var pos = Vector2(x, z)
			astar.add_point(id, pos)
	
	for x in range(grid_size):
		for z in range(grid_size):
			var id = get_point_id(x, z)
			
			if x < grid_size - 1:
				astar.connect_points(id, get_point_id(x + 1, z), 1)
			if z < grid_size - 1:
				astar.connect_points(id, get_point_id(x, z + 1), 1)
			
func get_point_id(x, z):
	return x + z * grid_size
