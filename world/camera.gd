extends Camera3D

var camera_speed: float = 10.0
var camera_drag_sensitivity: float = 0.05


func _process(delta: float) -> void:
	var camera_move_input: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	self.position += Vector3(camera_move_input.x * camera_speed * delta, 0.0, camera_move_input.y * camera_speed * delta)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mouse_motion_event := event as InputEventMouseMotion
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
			
			var camera_move_input: Vector2 = -mouse_motion_event.relative * camera_drag_sensitivity
			self.position += Vector3(camera_move_input.x, 0.0, camera_move_input.y)
