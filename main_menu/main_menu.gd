extends Control


func _on_singleplayer_button_pressed() -> void:
	get_tree().change_scene_to_packed(SceneManager.WORLD_PACKED_SCENE)


func _on_host_button_pressed() -> void:
	var new_scene: Node = SceneManager.WORLD_PACKED_SCENE.instantiate()
	var new_world_scene: World = new_scene as World
	new_world_scene.initialize(World.Gamemode.MULTIPLAYER_HOST)
	get_tree().change_scene_to_node(new_scene)
