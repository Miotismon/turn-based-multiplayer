class_name UnitManager
extends Node3D




var units_dict: Dictionary[Vector2i, Unit] ## Vector2i in grid coordinates, alternatively Array[Array[Unit]]
var selected_unit: Unit = null

@onready var grid_map: GridMap = %GridMap

func _ready() -> void:
	## register units from scene tree
	for child_unit: Unit in get_children():
		var unit_grid_pos: Vector3i = grid_map.local_to_map(child_unit.position) 
		var unit_grid_pos_2d: Vector2i = Vector2i(unit_grid_pos.x, unit_grid_pos.z)
		child_unit.grid_pos = unit_grid_pos_2d
		units_dict.set(unit_grid_pos_2d, child_unit)
	
	#_reposition_units_to_center_of_tile()

#func _reposition_units_to_center_of_tile() -> void:
	#for unit_pos: Vector2i in units_dict:
		#var unit: Unit = units_dict[unit_pos]
		#unit.position = grid_map.map_to_local(Vector3i(unit_pos.x, 0, unit_pos.y))


func try_select_unit(grid_pos: Vector2i) -> void:
	if !units_dict.has(grid_pos):
		print("trying to select nothing")
		return
	
	if units_dict[grid_pos].state != Unit.State.READY:
		print("trying to select inactive unit")
		return
	
	_select_unit(grid_pos)

func _select_unit(grid_pos: Vector2i) -> void:
	selected_unit = units_dict[grid_pos]
	selected_unit.state = Unit.State.SELECTED

func try_move_selected_unit(new_grid_pos: Vector2i) -> void:
	if selected_unit == null:
		push_error("trying to move a unit with no selected unit, this shouldn't be happening")
		return
	
	if is_tile_occupied(new_grid_pos):
		print("can't move unit there, tile occupied")
		return
	
	_move_selected_unit(new_grid_pos)
	


func _move_selected_unit(new_grid_pos: Vector2i) -> void:
	if !units_dict.erase(selected_unit.grid_pos):
		push_error("somehow the selected unit wasn't at this spot in the units_dict before deletion, everything from here on out might break")
	
	selected_unit.grid_pos = new_grid_pos
	units_dict.set(new_grid_pos, selected_unit)
	
	selected_unit.state = Unit.State.INACTIVE
	
	selected_unit = null


func next_turn() -> void:
	for child_unit: Unit in get_children():
		child_unit.state = Unit.State.READY


#region helpers
func is_tile_occupied(grid_pos: Vector2i) -> bool:
	return units_dict.has(grid_pos)

func did_all_units_end_turn() -> bool:
	var return_bool: bool = true
	for child_unit: Unit in get_children():
		if child_unit.state != Unit.State.INACTIVE:
			return_bool = false
			break
	
	return return_bool

#endregion
