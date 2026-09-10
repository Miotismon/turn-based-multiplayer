class_name World
extends Node3D

enum Gamemode {SINGLE, MULTIPLAYER_HOST, MULTIPLAYER_CLIENT}

enum TileState {EMPTY, OCCUPIED}

const MOUSE_RAY_LENGTH = 1000.0

var gamemode: Gamemode = Gamemode.SINGLE
var player_count: int = 1

var turn_number: int = 1

var is_hovering_tile: bool = false
var hovered_tile: Vector2i = Vector2i.ZERO
var hovered_tile_state: TileState = TileState.EMPTY

@onready var camera: Camera3D = %Camera3D
@onready var grid_map: GridMap = %GridMap
@onready var mouse_indicator_manager: MouseIndicatorManager = %MouseIndicatorManager
@onready var unit_manager: UnitManager = %UnitManager
@onready var multiplayer_spawner: MultiplayerSpawner = %MultiplayerSpawner


## should be called before adding to scene tree
func initialize(new_gamemode: Gamemode) -> void:
	gamemode = new_gamemode

func _ready() -> void:
	Steamworks.host_created.connect(_on_steam_host_created)
	
	match gamemode:
		Gamemode.SINGLE:
			pass
		Gamemode.MULTIPLAYER_HOST:
			%MouseIndicatorMeshesLocal.queue_free()
			Steamworks.host_lobby()
		Gamemode.MULTIPLAYER_CLIENT:
			%MouseIndicatorMeshesLocal.queue_free()
			pass


#region mouse input shenanigans
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_button_event := event as InputEventMouseButton
		if mouse_button_event.button_index == MOUSE_BUTTON_LEFT and mouse_button_event.pressed == true:
			if is_hovering_tile:
				if unit_manager.selected_unit == null:
					unit_manager.try_select_unit(hovered_tile, multiplayer.get_unique_id())
				else: 
					unit_manager.try_move_selected_unit(hovered_tile, multiplayer.get_unique_id())


func _physics_process(_delta: float) -> void:
	var mouse_ray_result: Dictionary = _get_mouse_3d_ray_result()
	if mouse_ray_result:
		var mouse_grid_pos: Vector3i = grid_map.local_to_map(mouse_ray_result.position + Vector3.UP * 0.1) ## move it a bit up to make sure we are in our grid square
		var mouse_grid_pos_2d: Vector2i = Vector2i(mouse_grid_pos.x, mouse_grid_pos.z)
		
		is_hovering_tile = true
		hovered_tile = mouse_grid_pos_2d
		
		if unit_manager.is_tile_occupied(mouse_grid_pos_2d):
			hovered_tile_state = TileState.OCCUPIED
		else:
			hovered_tile_state = TileState.EMPTY
		
		#print("MOUSE HIT: ", mouse_ray_result.position)
		#print("mouse_grid_pos: ", mouse_grid_pos)
		mouse_indicator_manager.set_visibility(true)
		mouse_indicator_manager.set_indicator_position(grid_map.map_to_local(mouse_grid_pos) + Vector3.UP * 0.1)
		mouse_indicator_manager.set_hovered_tile_state(hovered_tile_state)
		
		
	else:
		#print("mouseh it nothing :(")
		is_hovering_tile = false
		mouse_indicator_manager.set_visibility(false)


func _get_mouse_3d_ray_result() -> Dictionary:
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var ray_origin: Vector3 = camera.project_ray_origin(mouse_pos)
	var ray_end: Vector3 = ray_origin + camera.project_ray_normal(mouse_pos) * MOUSE_RAY_LENGTH
	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	var result: Dictionary = space_state.intersect_ray(query)
	return result
#endregion


#region multiplayer connection
func _on_steam_host_created() -> void:
	## setup authority stuff
	#multiplayer_spawner.spawn_function = custom_spawn_function
	
	## spawn host indicator mesh
	mouse_indicator_manager.spawn_indicator_meshes(multiplayer.get_unique_id())
	
	## connect to listen for client connections
	multiplayer.peer_connected.connect(_on_multiplayer_peer_connected)

## runs on host when client connects
func _on_multiplayer_peer_connected(peer_id: int) -> void:
	player_count += 1
	## spawn client indicator mesh
	mouse_indicator_manager.spawn_indicator_meshes(peer_id)

## gets called by host on clients when a custom MultiplayerSpawner.spawn() happens (it doesn't currently)
#func custom_spawn_function(data) -> void:
	#print("custom spawn function data: ", data)
	#
	#return 
#endregion
