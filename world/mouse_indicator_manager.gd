class_name MouseIndicatorManager
extends Node3D

enum MouseInidcatorMesh {CORNERS, DOTTED, LINE, ROUND_CORNERS}
const INDICATOR_SQUARE_CORNERS_MESH: ArrayMesh = preload("uid://dkxhy82opslj5")
const INDICATOR_SQUARE_DOTTED_MESH: ArrayMesh = preload("uid://dgfh1exlnnsd7")
const INDICATOR_SQUARE_LINE_MESH: ArrayMesh = preload("uid://dlski3ci6ogfw")
const INDICATOR_SQUARE_ROUND_CORNERS_MESH = preload("uid://gpph5rbiob6e")


enum Mode{HOVER, MOVE}
var current_mode: Mode = Mode.HOVER

@onready var selected_square_indicator: MeshInstance3D = %SelectedSquareIndicator
@onready var move_square_indicator: MeshInstance3D = %MoveSquareIndicator

func set_mode(new_mode: Mode) -> void:
	current_mode = new_mode
	match new_mode:
		Mode.HOVER:
			move_square_indicator.visible = false
		
		Mode.MOVE:
			move_square_indicator.visible = true


func set_visibility(visibility: bool) -> void:
	self.visible = visibility
	#selected_square_indicator.visible = visibility

func set_indicator_position(new_pos: Vector3) -> void:
	match current_mode:
		Mode.HOVER:
			selected_square_indicator.position = new_pos
		
		Mode.MOVE:
			move_square_indicator.position = new_pos


func set_hovered_tile_state(tile_state: World.TileState) -> void:
	match current_mode:
		Mode.HOVER:
			match tile_state:
				World.TileState.EMPTY:
					_set_selected_indicator_mesh(MouseInidcatorMesh.CORNERS)
				World.TileState.OCCUPIED:
					_set_selected_indicator_mesh(MouseInidcatorMesh.LINE)
		
		Mode.MOVE:
			match tile_state:
				World.TileState.EMPTY:
					_set_move_indicator_mesh(MouseInidcatorMesh.ROUND_CORNERS)
				World.TileState.OCCUPIED:
					_set_move_indicator_mesh(MouseInidcatorMesh.LINE)


func _set_selected_indicator_mesh(new_mesh_enum: MouseInidcatorMesh) -> void:
	var new_mesh: ArrayMesh
	
	match new_mesh_enum:
		MouseInidcatorMesh.CORNERS:
			new_mesh = INDICATOR_SQUARE_CORNERS_MESH
		MouseInidcatorMesh.DOTTED:
			new_mesh = INDICATOR_SQUARE_DOTTED_MESH
		MouseInidcatorMesh.LINE:
			new_mesh = INDICATOR_SQUARE_LINE_MESH
		MouseInidcatorMesh.ROUND_CORNERS:
			new_mesh = INDICATOR_SQUARE_ROUND_CORNERS_MESH
	
	selected_square_indicator.mesh = new_mesh

func _set_move_indicator_mesh(new_mesh_enum: MouseInidcatorMesh) -> void:
	var new_mesh: ArrayMesh
	
	match new_mesh_enum:
		MouseInidcatorMesh.CORNERS:
			new_mesh = INDICATOR_SQUARE_CORNERS_MESH
		MouseInidcatorMesh.DOTTED:
			new_mesh = INDICATOR_SQUARE_DOTTED_MESH
		MouseInidcatorMesh.LINE:
			new_mesh = INDICATOR_SQUARE_LINE_MESH
		MouseInidcatorMesh.ROUND_CORNERS:
			new_mesh = INDICATOR_SQUARE_ROUND_CORNERS_MESH
	
	move_square_indicator.mesh = new_mesh
