class_name Card
extends Node3D
## Documentation


#region signals
signal move_animation_finished(card: Card)
#endregion


#region enums
#endregion


#region constants
const COLLISION_MASK_FLOAT_PLANE = 0b10
const COLLISION_MASK_NOT_FLOAT_PLANE = 0b01
const MOVEMENT_SPEED = 0.04
#endregion


#region @export variables
@export var deck_id: int = 0
@export var card_id: int = 0
#endregion


#region public variables
var card_stack: CardStack
#endregion


#region private variables
var _is_picked_up: bool = false
var _movement_tween: Tween
var _wait_for_movement: bool = false
#endregion


#region @onready variables
@onready var area_button: AreaButton = $Area3D
@onready var _mesh: MeshInstance3D = $MeshInstance3D
@onready var _label_card_id: Label3D = $MeshInstance3D/CardNumber
@onready var _label_deck_id: Label3D = $MeshInstance3D/DeckNumber
#endregion


#region built-in virtuals (init)
func _init():
	add_to_group(Groups.CARDS)


#func _enter_tree():
	#pass


func _ready():
	if area_button:
		area_button.mouse_pressed.connect(_pick)
		area_button.mouse_released.connect(_drop)
	
	var card_id_text = str(card_id)
	var deck_id_text = str(deck_id)
	
	if _label_deck_id:
		match deck_id:
			CardDecks.Deck_Type.NUMBERED_RED:
				deck_id_text = ""
			CardDecks.Deck_Type.NUMBERED_GREEN:
				deck_id_text = ""
			CardDecks.Deck_Type.NUMBERED_BLUE:
				deck_id_text = ""
			CardDecks.Deck_Type.DRAGON_CYAN:
				card_id_text = ""
				deck_id_text = "D"
			CardDecks.Deck_Type.DRAGON_MAGENTA:
				card_id_text = ""
				deck_id_text = "D"
			CardDecks.Deck_Type.DRAGON_YELLOW:
				card_id_text = ""
				deck_id_text = "D"
			CardDecks.Deck_Type.SAKURA:
				card_id_text = ""
				deck_id_text = "S"
			
		_label_deck_id.text = deck_id_text
	
	if _label_card_id:
		_label_card_id.text = card_id_text
	
	if _mesh:
		var material = StandardMaterial3D.new()
		material.albedo_color = SolitaireAssets.deck_colors[deck_id].color
		
		_mesh.material_overlay = material


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
func set_data(new_card_id: int, new_deck_id: int):
	card_id = new_card_id
	deck_id = new_deck_id
	return self


func move_smooth(speed_multiplier: float = 1.0):
	if _movement_tween:
		if not _movement_tween.is_valid():
			_movement_tween = create_tween()
		
		elif _movement_tween.is_running():
			_movement_tween.kill()
			_movement_tween = create_tween()
			
	else:
		_movement_tween = create_tween()
	
	var tween_time = MOVEMENT_SPEED * Vector3.ZERO.distance_to(position) * speed_multiplier
	_wait_for_movement = true
	_movement_tween.stop()
	_movement_tween.tween_property(self, "position", Vector3.ZERO, tween_time)
	_movement_tween.tween_callback(_movement_finished)
	_movement_tween.play()
#endregion


#region private methods
func _movement_finished():
	_wait_for_movement = false
	
	if card_stack != CardHandStack.instance:
		move_animation_finished.emit(self)


func _pick():
	if _wait_for_movement:
		return
	
	if card_stack and not _is_picked_up and is_instance_valid(CardHandStack.instance):
		if card_stack.is_locked:
			return
		
		if card_stack.get_top_card() == self:
			CardHandStack.instance.stack_cards(card_stack.get_substack_cards(self))
			_is_picked_up = true
		
		elif SolitaireSettings.can_pick_substacks:
			if card_stack.can_pick_substack_at(self):
				CardHandStack.instance.stack_cards(card_stack.get_substack_cards(self))
				_is_picked_up = true


func _drop():
	if _is_picked_up and is_instance_valid(CardHandStack.instance):
		var hit
		
		var other
		var other_stack: CardStack
		var other_card: Card
		
		var other_card_id = -1
		var other_deck_id = -1

		if _is_picked_up:
			_is_picked_up = false
			
			var substack_cards = card_stack.get_substack_cards(self)
			var ignore_area_buttons = [] as Array[RID]
			
			for substack_card in substack_cards:
				var substack_card_area_button = substack_card.area_button
				ignore_area_buttons.append(substack_card_area_button.get_rid())
			
			hit = Raycaster3D.instance.raycast_camera3d(true, COLLISION_MASK_NOT_FLOAT_PLANE, ignore_area_buttons)
		
		if hit:
			other = hit.collider.get_parent()
				
			if other is Card:
				other_card = other as Card
				other_stack = other_card.card_stack
			
			elif other is CardStack:
				other_stack = other as CardStack
			
			if other_stack == card_stack or not other_stack or not card_stack:
				return
			
			other_card = other_stack.get_top_card()
			
			if other_card:
				other_card_id = other_card.card_id
				other_deck_id = other_card.deck_id
		
		var reset_substack = true
		
		if other_stack:
			if CardDecks.can_stack_on(other_stack.stack_type, deck_id, card_id, other_deck_id, other_card_id):
				if CardHandStack.instance.card_count <= other_stack.max_stacked_cards:
					other_stack.stack_cards(card_stack.get_substack_cards(self))
					reset_substack = false
		
		if reset_substack:
			CardHandStack.instance.return_cards()
#endregion


#region subclasses
#endregion
