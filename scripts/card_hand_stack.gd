class_name CardHandStack
extends CardStack
## Documentation


#region signals
#endregion


#region enums
#endregion


#region constants
const COLLISION_MASK_FLOAT_PLANE = 0b10
#endregion


#region @export variables
@export var cursor_follow_lerp_speed: float = 15
#endregion


#region public variables
static var instance: CardHandStack
static var previous_card_stack: CardStack :
	set(value):
		if value != instance:
			previous_card_stack = value
#endregion


#region private variables
#endregion


#region @onready variables
#endregion


#region built-in virtuals (init)
func _init():
	instance = self
	super()

#func _enter_tree():
	#pass

#func _ready():
	#pass

#func _exit_tree():
	#pass
#endregion


#region built-in virtuals (input)
#func _input(event):
	#pass

#func _unhandled_input(event):
	#pass
#endregion


#region built-in virtuals (process)
func _process(delta):
	var hit = Raycaster3D.instance.raycast_camera3d(false, COLLISION_MASK_FLOAT_PLANE)
	
	if hit and is_instance_valid(CardHandStack.instance):
		global_position = global_position.lerp(hit.position, cursor_follow_lerp_speed * delta)

#func _physics_process(delta):
	#pass
#endregion


#region public methods
func return_cards():
	if is_instance_valid(previous_card_stack):
		previous_card_stack.stack_cards(_cards.duplicate(), false)
#endregion


#region private methods
func _on_card_move_finished(_card: Card, trigger_cards_changed: bool = true):
	pass
#endregion


#region subclasses
#endregion

