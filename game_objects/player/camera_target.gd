extends Node3D
class_name CameraTarget

#region vars
@export var view_target_size: Vector2 = Vector2(1, .5)
@export var movement_curve: Curve
@export var speed: float = 5

var _view_target: Vector3 = Vector3.ZERO
#endregion

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var viewport_size = get_viewport().get_visible_rect().size
		
		var mouse_pos_x = remap(event.position.x, 0, viewport_size.x, -1, 1)
		var pos_x = movement_curve.sample(abs(mouse_pos_x))
		pos_x *= view_target_size.x
		
		if mouse_pos_x < 0:
			pos_x *= -1
		
		var mouse_pos_y = remap(event.position.y, 0, viewport_size.y, -1, 1)
		var pos_y = movement_curve.sample(abs(mouse_pos_y))
		pos_y *= view_target_size.y
		
		if mouse_pos_y < 0:
			pos_y *= -1
		
		_view_target = Vector3(pos_x, 0, pos_y)

func _process(delta: float) -> void:
	position = position.lerp(_view_target, delta * speed)
