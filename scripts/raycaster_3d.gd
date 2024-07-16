class_name Raycaster3D
extends Node3D

const RAY_LENGTH = 1000

var space_state: PhysicsDirectSpaceState3D
static var instance: Raycaster3D

func _init():
	instance = self

func _ready():
	space_state = get_world_3d().direct_space_state

func raycast(origin: Vector3, direction: Vector3, collide_with_areas: bool = true, collision_mask: int = 0xFFFFFFFF, exclude: Array[RID] = []):
	if not space_state:
		return null
	
	var query = PhysicsRayQueryParameters3D.create(origin, direction * RAY_LENGTH, collision_mask, exclude)
	query.collide_with_areas = collide_with_areas
	
	var hit = space_state.intersect_ray(query) as Dictionary
	
	if hit.is_empty():
		return false
	
	return hit

func raycast_camera3d(collide_with_areas: bool = true, collision_mask: int = 0xFFFFFFFF, exclude: Array[RID] = []):
	var viewport = get_viewport()
	var camera = null
	
	if viewport:
		camera = viewport.get_camera_3d()
	
	if not camera:
		return null
	
	var mouse_position = get_viewport().get_mouse_position()
	var origin = camera.project_ray_origin(mouse_position)
	var end = camera.project_ray_normal(mouse_position) * RAY_LENGTH
	
	return raycast(origin, end, collide_with_areas, collision_mask, exclude)
