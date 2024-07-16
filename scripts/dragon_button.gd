class_name DragonButton
extends Node3D
## Documentation


#region signals
signal pressed(dragon_button: DragonButton)
#endregion


#region enums
#endregion


#region constants
#endregion


#region @export variables
@export var deck_type: CardDecks.Deck_Type
#endregion


#region public variables
#endregion


#region private variables
var _is_active = false
var _is_pressed = false
#endregion


#region @onready variables
@onready var label_state: Label3D = $MeshInstance3D/Label3DState
@onready var area_button: AreaButton = $Area3D
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
#endregion


#region built-in virtuals (init)
func _init():
	add_to_group(Groups.DRAGON_BUTTON)

#func _enter_tree():
	#pass

func _ready():
	set_active(false)
	
	if area_button:
		area_button.mouse_pressed.connect(_on_mouse_pressed)
		area_button.mouse_released.connect(_on_mouse_released)
	
	if mesh_instance:
		var material = StandardMaterial3D.new()
		material.albedo_color = SolitaireAssets.deck_colors[deck_type].color
		
		mesh_instance.material_overlay = material

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
#func _process(delta):
	#pass

#func _physics_process(delta):
	#pass
#endregion


#region public methods
func set_active(val: bool = true):
	label_state.text = str(val)
	_is_active = val
#endregion


#region private methods
func _on_mouse_pressed() -> void:
	if _is_active:
		_is_pressed = true

func _on_mouse_released() -> void:
	if _is_pressed:
		_is_pressed = false
		
		pressed.emit(self)
#endregion


#region subclasses
#endregion
