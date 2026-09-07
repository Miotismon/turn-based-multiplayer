extends Control

const SINGLEPLAYER_WORLD_PACKED_SCENE: PackedScene = preload("uid://drmntnypvqnu")


func _on_singleplayer_button_pressed() -> void:
	get_tree().change_scene_to_packed(SINGLEPLAYER_WORLD_PACKED_SCENE)
