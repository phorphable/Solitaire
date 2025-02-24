class_name Card
extends Node3D

enum Decks { ONE, TWO, THREE, DRAGON_ONE, DRAGON_TWO, DRAGON_THREE, SAKURA}

signal card_moved

const ANIM_CLOSE = "card animations/Close"
const ANIM_OPEN = "card animations/Open"

#region vars
@export var card_id: int = 0
@export var deck_id: Decks = Decks.SAKURA
@export var lift_height_on_movement: float = .2
@export var move_duration: float = .25
@export var move_lift_duration: float = .05

@export var boneAttachment: BoneAttachment3D
@export var _card_mesh: MeshInstance3D
@export var _collisionSmall: CollisionShape3D
@export var _collisionBig: CollisionShape3D

var deck_asset: DeckAsset
var is_sorted: bool = false
var is_moving: bool = false
var reached_destination: bool = false

var _parent_card: Card
var _child_card: Card
var _card_slot: CardSlot

var _mouse_hover: bool = false
var _tween: Tween

static var numbered_decks: Array[Decks] = [ Decks.ONE, Decks.TWO, Decks.THREE ]
static var dragon_decks: Array[Decks] = [ Decks.DRAGON_ONE, Decks.DRAGON_TWO, Decks.DRAGON_THREE ]
static var spawn_locked: bool = false

static var _selected_card: Card
static var _hovered_card: Card

@onready var _area_3d: Area3D = $Area3D
#endregion

func _init() -> void:
	add_to_group(Groups.CARD)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action(InputActions.CLICK):
		var pressed = event.is_pressed()
		
		if _selected_card == self and not pressed:
			var card_slot = CardSlot.get_hovered()
			
			if card_slot:
				attach_card_to(card_slot)
				
			elif _hovered_card:
				attach_card_to(_hovered_card)
			
			select_card(false)
			get_viewport().set_input_as_handled()
			
		elif not _selected_card:
			if _mouse_hover and pressed:
				if can_select():
					select_card()
					get_viewport().set_input_as_handled()

func _ready() -> void:
	name = "Card_" + str(card_id) + "_" + str(deck_id)
	
	if deck_asset:
		var display_material = _card_mesh.get_surface_override_material(1) as ShaderMaterial
		
		if display_material:
			if deck_asset.card_id_icons.size() > card_id:
				display_material.set_shader_parameter("CardIcon", deck_asset.card_id_icons[card_id])
			
			display_material.set_shader_parameter("CardColor", deck_asset.deck_color)

func _process(delta: float) -> void:
	if self == _selected_card:
		var hit = Raycaster3D.instance.raycast_camera3d(1000, true, 0b10)
		
		if hit:
			var new_position = Vector3(hit.position.x, hit.position.y + lift_height_on_movement, hit.position.z)
			position = position.lerp(new_position, delta * 20)
	
	elif (_parent_card or _card_slot) and not _tween:
		if is_moving:
			var target_position = position
			
			if _parent_card:
				if _parent_card.boneAttachment:
					target_position = _parent_card.boneAttachment.global_position
			
			elif _card_slot:
				target_position = _card_slot.position
			
			if position.distance_squared_to(target_position) <= 0.1:
				reached_destination = true
			
			if position.is_equal_approx(target_position):
				position = target_position
				
				if not _selected_card:
					is_moving = false
			
			else:
				position = position.lerp(target_position, delta * 12)
				is_moving = true

func select_card(state: bool = true):
	is_moving = true
	reached_destination = false
	
	var next_child = self
	
	while next_child._child_card:
		next_child._child_card.is_moving = true
		next_child._child_card.reached_destination = false
		next_child.set_disabled(state)
		next_child = next_child._child_card
	
	if state:
		set_disabled()
		_selected_card = self
	
	else:
		if _selected_card:
			_selected_card.set_disabled(false)
			_selected_card.is_moving = true
			
			var selected_card = _selected_card
			_selected_card = null
			selected_card.set_disabled(false)

func attach_card_to(target, force: bool = false):
	var target_card = target as Card
	var target_card_slot = target as CardSlot
	
	if target_card or target_card_slot:
		if target_card:
			target_card_slot = target_card._card_slot
		
		elif target_card_slot:
			target_card = target_card_slot.get_top_card()
	
	else:
		return
	
	var can_attach = can_attach_to_card_slot(target_card_slot) or force
	
	if not target_card_slot or target_card == self or target_card_slot == _card_slot:
		return
	
	if can_attach and target_card_slot:
		update_card_slot(target_card_slot)
		
		if is_sorted:
			update_parent_card(null)
		
		else:
			update_parent_card(target_card)
		
		var next_child = _child_card
		
		while next_child:
			next_child._card_slot = _card_slot
			next_child = next_child._child_card
		
		if not (is_sorted or force):
			card_moved.emit()
		
		is_moving = true
		reached_destination = false
		
		if is_sorted:
			if not _tween:
				_tween = create_tween()
				_tween.tween_property(self, "position", Vector3(0, lift_height_on_movement, 0), move_lift_duration).as_relative()
				_tween.chain().tween_property(self, "position", Vector3(target_card_slot.position.x, lift_height_on_movement, target_card_slot.position.z), move_duration)
				_tween.chain().tween_property(self, "position", target_card_slot.position, move_lift_duration)
				_tween.tween_callback(_on_tween_finished)

func can_attach_to_card_slot(target: CardSlot) -> bool:
	if not target:
		return false
	
	if _card_slot == target:
		return false
	
	var checks: Array[bool] = []
	
	# allowed deck
	checks.append(deck_id in target.allowed_decks)
	
	# is valid final slot placement
	if target.is_final_slot:
		if target.child_card:
			# proceeding card
			checks.append(card_id == target.child_card.card_id +1)
			checks.append(deck_id == target.child_card.deck_id)
		else:
			# first card
			checks.append(card_id == 0)
	
	else:
		var top_card = target.get_top_card()
		
		if top_card != self and top_card:
			checks.append(is_valid_card_order(self, top_card))
	
	if target.limit_stack_number:
		checks.append(target.get_top_card() == null)
		checks.append(not _child_card)
	
	return not false in checks

func can_select() -> bool:
	var valid_card_order_steps: Array[bool] = []
	
	var parent_card: Card = self
	var child_card: Card = _child_card
	
	while child_card:
		if parent_card and child_card:
			valid_card_order_steps.append(is_valid_card_order(child_card, parent_card))
		
		parent_card = child_card
		child_card = parent_card._child_card
	
	return not false in valid_card_order_steps

func _on_tween_finished():
	is_moving = false
	reached_destination = true
	_tween = null
	card_moved.emit()

func is_valid_card_order(higher_card: Card, lower_card: Card) -> bool:
	if not higher_card or not lower_card:
		return false
	
	var checks: Array[bool] = []
	
	# preceeding card
	checks.append(higher_card.card_id +1 == lower_card.card_id)
	
	# different deck
	checks.append(higher_card.deck_id != lower_card.deck_id)
	
	# numbered cards
	checks.append(higher_card.deck_id in [ Decks.ONE, Decks.TWO, Decks.THREE ] and lower_card.deck_id in [ Decks.ONE, Decks.TWO, Decks.THREE ])
	
	return not false in checks

func set_disabled(state: bool = true):
	if not _area_3d:
		return
		
	if is_sorted or is_in_selected_stack() or self == _selected_card:
		_area_3d.input_ray_pickable = false
		return
	
	_area_3d.input_ray_pickable = not state

func is_disabled() -> bool:
	if _area_3d:
		return not _area_3d.input_ray_pickable
	
	return true

func update_parent_card(new_parent: Card) -> void:
	if _parent_card:
		_parent_card._child_card = null
	
	_parent_card = new_parent
	
	if _parent_card:
		_parent_card._child_card = self
		_card_slot = _parent_card._card_slot

func update_card_slot(new_card_slot: CardSlot) -> void:
	if _card_slot:
		_card_slot.detach_card(self)
	
	_card_slot = new_card_slot
	
	if _card_slot:
		_card_slot.attach_card(self)

func reset() -> void:
	if _parent_card:
		_parent_card._child_card = null
	
	if _child_card:
		_child_card._parent_card = null
	
	if _card_slot:
		_card_slot.child_card = null
	
	_parent_card = null
	_child_card = null
	_card_slot = null
	is_sorted = false
	
	hide()
	set_disabled()

func get_top_card() -> Card:
	var top_card = self
	
	while top_card._child_card:
		top_card = top_card._child_card
	
	return top_card

func is_in_selected_stack() -> bool:
	var card = self
	
	while card._parent_card:
		if card._parent_card == _selected_card:
			return true
		
		card = card._parent_card
	
	return false

static func get_hovered() -> Card:
	return _hovered_card

func _on_mouse_entered() -> void:
	_mouse_hover = true
	_hovered_card = self

func _on_mouse_exited() -> void:
	_mouse_hover = false
	
	if _hovered_card == self:
		_hovered_card = null

func _on_animation_tree_animation_started(anim_name: StringName) -> void:
	if not _collisionBig or not _collisionSmall:
		return
		
	if anim_name == ANIM_CLOSE:
		_collisionBig.disabled = true
		_collisionSmall.disabled = false
	
	elif anim_name == ANIM_OPEN:
		_collisionBig.disabled = false
		_collisionSmall.disabled = true
