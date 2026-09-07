@tool
extends EditorScenePostImport

func _post_import(scene):
	var mesh_instance := _find_mesh_instance(scene)
	
	if mesh_instance == null:
		push_warning("No MeshInstance3D found.")
		return scene
	
	if mesh_instance.mesh == null:
		push_warning("MeshInstance3D has no mesh.")
		return scene
	
	var source_path := get_source_file()
	var base_name := source_path.get_file().get_basename()
	
	var output_dir := "res://imported_meshes/"
	var output_path := output_dir + base_name + ".mesh"
	
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_dir))
	
	var error := ResourceSaver.save(mesh_instance.mesh, output_path)
	
	if error != OK:
		push_error("Failed to save mesh: " + output_path)
	else:
		print("Saved mesh: " + output_path)
	
	return scene


func _find_mesh_instance(node: Node) -> MeshInstance3D:
	if node is MeshInstance3D:
		return node
	
	for child in node.get_children():
		var result := _find_mesh_instance(child)
		if result != null:
			return result
	
	return null
