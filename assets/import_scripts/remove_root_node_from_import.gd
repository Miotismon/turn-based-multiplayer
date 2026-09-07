## this only works for imports that have ONLY a mesh and generated physics body and shape

## https://www.reddit.com/r/godot/comments/1b057fj/remove_useless_node3d_when_importing_from_blender/

@tool 
extends EditorScenePostImport

func _post_import(scene) -> Object: 
	if scene != null: 
		var root_meshes: Array[Node] = scene.get_children() 
		
		## if there's more than one mesh here they kinda have to be attached to one root Node3D 
		## (I guess you could choose one of them as like a master mesh but cmon dude)
		if root_meshes.size() > 1: 
			push_warning("Root Remover: scene had multiple possible new root meshes (or nodes i didnt specifically check for meshes)")
			return scene
		
		var root_mesh = root_meshes[0]
		scene.remove_child(root_mesh)
		root_mesh.set_owner(null)
		
		var all_children := get_all_children(root_mesh)
		for child: Node in all_children:
			child.set_owner(root_mesh) 

		#collider.add_child(mesh)
		#collider.set_owner(body)
		#mesh.set_owner(body)
		#new_objects.append(body)
		
		#if new_root_meshes.size() > 1: ## if we have multiple meshes to work with don't touch it ?
			#for root_mesh: Node in new_root_meshes:
				#scene.add_child(object)
			#return scene
		
		#elif new_root_meshes.size() == 1:
			#scene.queue_free()
			#return new_root_meshes[0] ## return our new scene root
		
		print("Root Remover: removed root successfully")
		return root_mesh
	
	push_warning("Root Remover: how did I get a null scene on post_import")
	return scene

func get_all_children(node, array: Array[Node] = []) -> Array[Node]: 
	for child in node.get_children(): 
		array.push_back(child) 
		array = get_all_children(child, array) 
	return array
