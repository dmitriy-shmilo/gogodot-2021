extends TileMap
class_name TileMapMesh

var path_mesh: AStar2D

func _ready() -> void:
	path_mesh = AStar2D.new()
	

func setup() -> void:
	for y in 100:
		for x in 100:
			if _is_empty(x, y):
				path_mesh.add_point(x + y * 100, Vector2(x * 32 + 16, y * 32 + 16))

	for y in 100:
		for x in 100:
			if path_mesh.has_point(x + y * 100):
				var west = x > 0 and _connect_if_empty(x, y, -1, 0)
				var north = y > 0 and _connect_if_empty(x, y, 0, -1)
				var east = x < 99 and _connect_if_empty(x, y, 1, 0)
				var south = y < 99 and _connect_if_empty(x, y, 0, 1)

				if east and south:
					var _southeast = _connect_if_empty(x, y, 1, 1)
				
				if east and north:
					var _northeast = _connect_if_empty(x, y, 1, -1)
				
				if west and south:
					var _southwest = _connect_if_empty(x, y, -1, 1)
				
				if west and north:
					var _northwest = _connect_if_empty(x, y, -1, -1)


func find(from: Vector2, to: Vector2) -> PoolVector2Array:
	var fx = floor(from.x / 32)
	var fy = floor(from.y / 32)
	var tx = floor(to.x / 32)
	var ty = floor(to.y / 32)
	
	return path_mesh.get_point_path(fx + fy * 100, tx + ty * 100)


func _is_empty(x: int, y: int) -> bool:
	return get_cell(x, y) == INVALID_CELL


func _connect_if_empty(x: int, y: int, dx: int, dy: int) -> bool:
	if get_cell(x + dx, y + dy) == INVALID_CELL:
		path_mesh.connect_points(x + y * 100, x + dx + (y + dy) * 100)
		return true
	return false
