class_name Unit
extends Node3D

enum State {READY, SELECTED, INACTIVE}

const VISUAL_MOVE_SPEED: float = 10.0 ## per second

var state: State = State.READY

var grid_pos: Vector2i = Vector2i.ZERO

@onready var animation_player: AnimationPlayer = self.find_child("AnimationPlayer")
@onready var debug_label: Label3D = %DebugLabel
@onready var ready_indicator: Node3D = %ReadyIndicator


func _process(delta: float) -> void:
	
	## move visuals to grid_pos
	var target_position: Vector3 = Vector3(grid_pos.x + 0.5, self.position.y, grid_pos.y + 0.5)
	self.position = self.position.move_toward(target_position, VISUAL_MOVE_SPEED * delta)
	
	## update ready indicator
	if state == State.READY:
		ready_indicator.visible = true
	else:
		ready_indicator.visible = false
	
	## update labels
	debug_label.text = str("State: ", State.keys()[state])
