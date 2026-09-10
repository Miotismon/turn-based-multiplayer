class_name UnitManager
extends Node3D




var units_dict: Dictionary[Vector2i, Unit] ## Vector2i in grid coordinates, alternatively Array[Array[Unit]]
var selected_unit: Unit = null
var selector_peer_id: int = 0

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

#region selecting unit
## local function to select unit
func try_select_unit(grid_pos: Vector2i, selected_by_peer_id: int) -> void:
	## validate whether we can select unit
	if !units_dict.has(grid_pos):
		print("trying to select nothing")
		ToastParty.show({"text": "Can't select no unit"})
		return
	
	if units_dict[grid_pos].state != Unit.State.READY:
		print("trying to select inactive unit")
		ToastParty.show({"text": "Can't select inactive unit"})
		return
	
	_request_select_unit.rpc(grid_pos, selected_by_peer_id)

@rpc("any_peer", "call_local", "reliable")
func _request_select_unit(grid_pos: Vector2i, selected_by_peer_id: int) -> void:
	## server only
	if !multiplayer.is_server():
		return
	
	## validate again cus we never trust the client
	if !units_dict.has(grid_pos):
		print("trying to select nothing")
		return
	
	if units_dict[grid_pos].state != Unit.State.READY:
		print("trying to select inactive unit")
		return
	
	_select_unit(grid_pos, selected_by_peer_id)

func _select_unit(grid_pos: Vector2i, selected_by_peer_id: int) -> void:
	selected_unit = units_dict[grid_pos]
	selected_unit.state = Unit.State.SELECTED
	selector_peer_id = selected_by_peer_id
	
	_broadcast_unit_selected.rpc(grid_pos, selected_by_peer_id)

@rpc("authority", "call_remote", "reliable")
func _broadcast_unit_selected(grid_pos: Vector2i, selected_by_peer_id: int) -> void:
	
	## this would presumably be different from the server code in an actual game
	selected_unit = units_dict[grid_pos]
	selected_unit.state = Unit.State.SELECTED
	selector_peer_id = selected_by_peer_id
#endregion

#region moving selected unit
func try_move_selected_unit(new_grid_pos: Vector2i, moving_peer_id: int) -> void:
	if selected_unit == null:
		push_error("trying to move a unit with no selected unit, this shouldn't be happening")
		return
	
	if !can_move_selected_unit(moving_peer_id):
		print("can't move unit, this peer didn't select it")
		ToastParty.show({"text": "Can't act, other player has unit selected"})
		return
	
	if is_tile_occupied(new_grid_pos):
		print("can't move unit there, tile occupied")
		ToastParty.show({"text": "Can't move unit to occupied tile"})
		return
	
	_request_move_selected_unit.rpc(new_grid_pos, moving_peer_id)

@rpc("any_peer", "call_local", "reliable")
func _request_move_selected_unit(new_grid_pos: Vector2i, moving_peer_id: int) -> void:
	## server only
	if !multiplayer.is_server():
		return
	
	if !units_dict.has(selected_unit.grid_pos):
		push_error("somehow the selected unit isn't in the units_dict at the correct spot, everything from here on out might break")
		return
	
	if selected_unit == null:
		push_error("trying to move a unit with no selected unit, this shouldn't be happening")
		return
	
	if !can_move_selected_unit(moving_peer_id):
		print("can't move unit, this peer didn't select it")
		return
	
	if is_tile_occupied(new_grid_pos):
		print("can't move unit there, tile occupied")
		return
	
	_move_selected_unit(new_grid_pos)

func _move_selected_unit(new_grid_pos: Vector2i) -> void:
	units_dict.erase(selected_unit.grid_pos)
	selected_unit.grid_pos = new_grid_pos
	units_dict.set(new_grid_pos, selected_unit)
	
	selected_unit.state = Unit.State.INACTIVE
	
	selected_unit = null
	
	_broadcast_selected_unit_moved.rpc(new_grid_pos)
	
	_end_turn_check()

@rpc("authority", "call_remote", "reliable")
func _broadcast_selected_unit_moved(new_grid_pos: Vector2i) -> void:
	units_dict.erase(selected_unit.grid_pos)
	selected_unit.grid_pos = new_grid_pos
	units_dict.set(new_grid_pos, selected_unit)
	
	selected_unit.state = Unit.State.INACTIVE
	
	selected_unit = null

#endregion

#region end turn check
func _end_turn_check() -> void:
	if did_all_units_end_turn():
		next_turn.rpc()

@rpc("authority", "call_local", "reliable")
func next_turn() -> void:
	for child_unit: Unit in get_children():
		child_unit.state = Unit.State.READY
#endregion

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

func can_move_selected_unit(moving_peer_id: int) -> bool:
	return selector_peer_id == moving_peer_id #multiplayer.get_unique_id()

#endregion
