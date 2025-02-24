extends BoardButton
class_name DragonButton

@export var dragon_deck_id: Card.Decks
@export var deck_asset: DeckAsset

@onready var _mesh: MeshInstance3D = $dragon_button/DragonButton

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action(InputActions.CLICK):
		if _mouse_hover:
			var pressed = event.is_pressed()
			
			if not pressed:
				button_pressed.emit()
	
func _init() -> void:
	add_to_group(Groups.DRAGON_BUTTON)

func _ready() -> void:
	super._ready()
	
	if deck_asset and _mesh:
		var material = _mesh.get_active_material(0).duplicate() as StandardMaterial3D
		material.albedo_color = deck_asset.deck_color
		_mesh.set_surface_override_material(0, material)
	
	_disable_button()

func _on_board_update_dragon_buttons(decks) -> void:
	if dragon_deck_id in decks:
		_disable_button(false)
	
	else:
		_disable_button()

func _disable_button(state: bool = true):
	input_ray_pickable = not state
	
	if deck_asset and _mesh:
		var material = _mesh.get_surface_override_material(0) as StandardMaterial3D
		var color = deck_asset.deck_color as Color
		
		if state:
			color.r = color.r * .75
			color.g = color.g * .75
			color.b = color.b * .75
			
		material.albedo_color = color
		_mesh.set_surface_override_material(0, material)
