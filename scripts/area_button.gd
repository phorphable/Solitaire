class_name AreaButton
extends Area3D
## Documentation


#region signals
signal mouse_pressed
signal mouse_released
#endregion


#region enums
#endregion


#region constants
#endregion


#region @export variables
#endregion


#region public variables
#endregion


#region private variables
var _mouse_hover = false
#endregion


#region @onready variables
#endregion


#region built-in virtuals (init)
#func _init():
	#pass

#func _enter_tree():
	#pass

#func _ready():
	#pass

#func _exit_tree():
	#pass
#endregion


#region built-in virtuals (input)
func _input(_event):
	if _mouse_hover:
		if Input.is_action_just_pressed(PlayerInput.mouse_button_left):
			mouse_pressed.emit()
			
	if Input.is_action_just_released(PlayerInput.mouse_button_left):
		mouse_released.emit()

#func _unhandled_input(event):
	#pass

func _mouse_enter():
	_mouse_hover = true

func _mouse_exit():
	_mouse_hover = false
#endregion


#region built-in virtuals (process)
#func _process(delta):
	#pass

#func _physics_process(delta):
	#pass
#endregion


#region public methods
#endregion


#region private methods
#endregion


#region subclasses
#endregion

