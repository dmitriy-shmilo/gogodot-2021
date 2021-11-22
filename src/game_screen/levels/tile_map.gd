extends TileMap
class_name TileMapMesh

const COST_INCREASE = 2

var path_mesh: AStar2D

var _width: int = 0
var _cell_size: int = 1
var _cell_half_size: int = 1
var _map_rect: Rect2
var _offset_x: int = 0
var _offset_y: int = 0

func _ready() -> void:
	path_mesh = AStar2D.new()


func setup() -> void:
	_map_rect = get_used_rect()
	_offset_x = int(_map_rect.position.x)
	_offset_y = int(_map_rect.position.y)
	_cell_size = int(cell_size.x) # assuming square cells
	#warning-ignore:integer_division
	_cell_half_size = int(_cell_size / 2)
	_width = int(_map_rect.size.x)
	
	for y in range(_map_rect.position.y, _map_rect.end.y):
		for x in range(_map_rect.position.x, _map_rect.end.x):
			if _is_empty(x, y):
				path_mesh.add_point(_point_id(x, y),
					Vector2(x * _cell_size + _cell_half_size,
					y * _cell_size + _cell_half_size))

	for y in range(_map_rect.position.y, _map_rect.end.y):
		for x in range(_map_rect.position.x, _map_rect.end.x):
			if path_mesh.has_point(_point_id(x, y)):
				var west = x > _map_rect.position.x and _connect_if_empty(x, y, -1, 0)
				var north = y > _map_rect.position.y and _connect_if_empty(x, y, 0, -1)
				var east = x < _map_rect.end.x - 1 and _connect_if_empty(x, y, 1, 0)
				var south = y < _map_rect.end.y - 1 and _connect_if_empty(x, y, 0, 1)

				if east and south:
					var _southeast = _connect_if_empty(x, y, 1, 1)
				
				if east and north:
					var _northeast = _connect_if_empty(x, y, 1, -1)
				
				if west and south:
					var _southwest = _connect_if_empty(x, y, -1, 1)
				
				if west and north:
					var _northwest = _connect_if_empty(x, y, -1, -1)


func find(from: Vector2, to: Vector2) -> PoolVector2Array:
	var fx = floor(from.x / _cell_size)
	var fy = floor(from.y / _cell_size)
	var tx = floor(to.x / _cell_size)
	var ty = floor(to.y / _cell_size)
	
	return path_mesh.get_point_path(_point_id(fx, fy), _point_id(tx, ty))


func increase_cost(at: Vector2) -> void:
	var x = floor(at.x / _cell_size)
	var y = floor(at.y / _cell_size)
	var id = _point_id(x, y)
	var scale = path_mesh.get_point_weight_scale(id) + COST_INCREASE
	path_mesh.set_point_weight_scale(id, scale)


func _point_id(x: int, y: int) -> int:
	return x - _offset_x + (y - _offset_y) * _width


func _is_empty(x: int, y: int) -> bool:
	return get_cell(x, y) == INVALID_CELL


func _connect_if_empty(x: int, y: int, dx: int, dy: int) -> bool:
	if get_cell(x + dx, y + dy) == INVALID_CELL:
		path_mesh.connect_points(_point_id(x, y), _point_id(x + dx, y + dy))
		return true
	return false
