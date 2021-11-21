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
				_connect_if_empty(x, y, -1, 0)
				_connect_if_empty(x, y, -1, -1)
				_connect_if_empty(x, y, 0, -1)
				_connect_if_empty(x, y, 1, -1)
				_connect_if_empty(x, y, 1, 0)
				_connect_if_empty(x, y, 1, 1)
				_connect_if_empty(x, y, 0, 1)
				_connect_if_empty(x, y, -1, 1)


func find(from: Vector2, to: Vector2) -> PoolVector2Array:
	var fx = floor(from.x / 32)
	var fy = floor(from.y / 32)
	var tx = floor(to.x / 32)
	var ty = floor(to.y / 32)
	
	return path_mesh.get_point_path(fx + fy * 100, tx + ty * 100)


func _is_empty(x: int, y: int) -> bool:
	return get_cell(x, y) == INVALID_CELL


func _connect_if_empty(x: int, y: int, dx: int, dy: int) -> void:
	if get_cell(x + dx, y + dy) == INVALID_CELL:
		path_mesh.connect_points(x + y * 100, x + dx + (y + dy) * 100)
