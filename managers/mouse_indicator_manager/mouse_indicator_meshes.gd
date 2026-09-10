class_name MouseIndicatorMeshes
extends Node3D

enum MeshType {CORNERS, DOTTED, LINE, ROUND_CORNERS}
const INDICATOR_SQUARE_CORNERS_MESH: ArrayMesh = preload("uid://dkxhy82opslj5")
const INDICATOR_SQUARE_DOTTED_MESH: ArrayMesh = preload("uid://dgfh1exlnnsd7")
const INDICATOR_SQUARE_LINE_MESH: ArrayMesh = preload("uid://dlski3ci6ogfw")
const INDICATOR_SQUARE_ROUND_CORNERS_MESH: ArrayMesh = preload("uid://gpph5rbiob6e")

@export var selected_square_mesh_type: MeshType
@export var move_square_mesh_type: MeshType
@export var mesh_color: Color = Color.ORANGE


@onready var selected_square_indicator: MeshInstance3D = %SelectedSquareIndicator
@onready var move_square_indicator: MeshInstance3D = %MoveSquareIndicator

func _enter_tree() -> void: 
	## NOT _ready() since we need this to happen before all the child nodes, but also not _init() since we need this to happen after we set up the node's name and add it to the tree
	## (_enter_tree() goes down the tree, _ready() moves up the tree, https://kidscancode.org/godot_recipes/4.x/basics/tree_ready_order/index.html)
	set_multiplayer_authority(name.to_int())


func _process(_delta: float) -> void:
	_update_selected_indicator_mesh(selected_square_mesh_type)
	_update_move_indicator_mesh(move_square_mesh_type)
	_update_color(mesh_color)

func _update_selected_indicator_mesh(new_mesh_enum: MeshType) -> void:
	var new_mesh: ArrayMesh
	
	match new_mesh_enum:
		MeshType.CORNERS:
			new_mesh = INDICATOR_SQUARE_CORNERS_MESH
		MeshType.DOTTED:
			new_mesh = INDICATOR_SQUARE_DOTTED_MESH
		MeshType.LINE:
			new_mesh = INDICATOR_SQUARE_LINE_MESH
		MeshType.ROUND_CORNERS:
			new_mesh = INDICATOR_SQUARE_ROUND_CORNERS_MESH
	
	selected_square_indicator.mesh = new_mesh

func _update_move_indicator_mesh(new_mesh_enum: MeshType) -> void:
	var new_mesh: ArrayMesh
	
	match new_mesh_enum:
		MeshType.CORNERS:
			new_mesh = INDICATOR_SQUARE_CORNERS_MESH
		MeshType.DOTTED:
			new_mesh = INDICATOR_SQUARE_DOTTED_MESH
		MeshType.LINE:
			new_mesh = INDICATOR_SQUARE_LINE_MESH
		MeshType.ROUND_CORNERS:
			new_mesh = INDICATOR_SQUARE_ROUND_CORNERS_MESH
	
	move_square_indicator.mesh = new_mesh


func _update_color(new_color: Color) -> void: 
	#print(self, " setting color: ", new_color)
	var selected_square_material := selected_square_indicator.get_surface_override_material(0) as StandardMaterial3D
	selected_square_material.albedo_color = new_color
	var move_square_material := move_square_indicator.get_surface_override_material(0) as StandardMaterial3D
	move_square_material.albedo_color = new_color
