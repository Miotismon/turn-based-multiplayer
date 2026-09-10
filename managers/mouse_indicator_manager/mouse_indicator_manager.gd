class_name MouseIndicatorManager
extends Node3D

enum Mode{HOVER, MOVE}



const PLAYER_COLORS: Array[Color] = [Color.RED, Color.AQUA, Color.GREEN, Color.YELLOW, Color.PURPLE]

const MOUSE_INDICATOR_MESHES_PACKED_SCENE: PackedScene = preload("uid://bsfkh5pwmohyn")


var current_mode: Mode = Mode.HOVER
var controlled_meshes: MouseIndicatorMeshes = null

@onready var mouse_indicator_meshes_local: MouseIndicatorMeshes = %MouseIndicatorMeshesLocal
@onready var unit_manager: UnitManager = %UnitManager

func _ready() -> void:
	controlled_meshes = mouse_indicator_meshes_local

func _process(_delta: float) -> void:
	_update_mode()

func _update_mode() -> void:
	if unit_manager.selected_unit and unit_manager.selector_peer_id == multiplayer.get_unique_id():
		_set_mode(MouseIndicatorManager.Mode.MOVE)
	else:
		_set_mode(MouseIndicatorManager.Mode.HOVER)

func _set_mode(new_mode: Mode) -> void:
	current_mode = new_mode
	if !controlled_meshes:
		return
	match new_mode:
		Mode.HOVER:
			controlled_meshes.move_square_indicator.visible = false
		
		Mode.MOVE:
			controlled_meshes.move_square_indicator.visible = true


func spawn_indicator_meshes(peer_id: int) -> void:
	var new_indicator_meshes := MOUSE_INDICATOR_MESHES_PACKED_SCENE.instantiate() as MouseIndicatorMeshes
	new_indicator_meshes.name = str(peer_id)
	#new_indicator_meshes.mesh_color = new_color
	add_child(new_indicator_meshes)
	for i in get_children().size():
		var child_meshes_node_name := get_child(i).name
		_broadcast_set_color_of_indicator_meshes.rpc(child_meshes_node_name, PLAYER_COLORS[i])
	
	
	if peer_id == multiplayer.get_unique_id():
		controlled_meshes = new_indicator_meshes


func set_visibility(visibility: bool) -> void:
	if !controlled_meshes:
		return
	controlled_meshes.visible = visibility

func set_indicator_position(new_pos: Vector3) -> void:
	if !controlled_meshes:
		return
	match current_mode:
		Mode.HOVER:
			controlled_meshes.selected_square_indicator.position = new_pos
		
		Mode.MOVE:
			controlled_meshes.move_square_indicator.position = new_pos


func set_hovered_tile_state(tile_state: World.TileState) -> void:
	if !controlled_meshes:
		return
	match current_mode:
		Mode.HOVER:
			match tile_state:
				World.TileState.EMPTY:
					controlled_meshes.selected_square_mesh_type = MouseIndicatorMeshes.MeshType.CORNERS
				World.TileState.OCCUPIED:
					controlled_meshes.selected_square_mesh_type = MouseIndicatorMeshes.MeshType.LINE
		
		Mode.MOVE:
			match tile_state:
				World.TileState.EMPTY:
					controlled_meshes.move_square_mesh_type = MouseIndicatorMeshes.MeshType.ROUND_CORNERS
				World.TileState.OCCUPIED:
					controlled_meshes.move_square_mesh_type = MouseIndicatorMeshes.MeshType.LINE




## called on clients when host requested MultiplayerSpawner spawns happen (of any kind, automatic(auto spawn list) or manual(.spawn()))
func _on_multiplayer_spawner_spawned(node: Node) -> void:
	if int(node.name) == multiplayer.get_unique_id():
		controlled_meshes = node



@rpc("authority", "call_local", "reliable")
func _broadcast_set_color_of_indicator_meshes(meshes_node_name: String, new_color: Color) -> void:
	#print(get_children(), " looking for name: ", meshes_node_name)
	var indicator_meshes: MouseIndicatorMeshes = find_child(meshes_node_name, false, false)
	indicator_meshes.mesh_color = new_color
