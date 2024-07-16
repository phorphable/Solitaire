class_name CardStack
extends Path3D
## Documentation


#region signals
signal cards_changed
#endregion


#region enums
enum Stack_Type { Default, Dragon, Final, SAKURA }
#endregion


#region constants
#endregion


#region @export variables
@export var stack_type: Stack_Type = Stack_Type.Default
@export var max_stacked_cards: int = 9 + 4
@export var card_spacing: float = 0.5
@export var is_locked: bool = false
@export var can_be_unlocked: bool = true
#endregion


#region public variables
var card_count: int :
	get:
		return _cards.size()
#endregion


#region private variables
var _cards: Array[Card] = []
var _card_positions: Array[PathFollow3D] = []
#endregion


#region @onready variables
#endregion


#region built-in virtuals (init)
func _init():
	add_to_group(Groups.CARD_STACKS)

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
#func _process(delta):
	#pass

#func _physics_process(delta):
	#pass
#endregion


#region public methods
func stack_card(card: Card):
	if not card:
		return
	
	if _cards.find(card) != -1:
		printerr("tried to stack same card twice")
		return
	
	_cards.append(card)
	var card_position_num = _cards.size() -1
	
	if card_position_num > _card_positions.size() -1:
		_place_path_follow()
	
	_update_card_stack_of_card(card)
	_place_card_into_position(card, card_position_num)
	
	if not card.move_animation_finished.is_connected(_on_card_move_finished):
		card.move_animation_finished.connect(_on_card_move_finished)

func stack_cards(cards: Array[Card]):
	if cards.is_empty():
		return
	
	if CardHandStack.instance == self and self != CardHandStack.previous_card_stack and cards.front().card_stack != self:
		CardHandStack.previous_card_stack = cards.front().card_stack
	
	for card in cards:
		stack_card(card)

func unstack_card():
	_cards.pop_back()

func get_top_card():
	if _cards.is_empty():
		return null
	
	return _cards.back()

func clear():
	_cards.clear()

func can_pick_substack_at(card: Card) -> bool:
	var result = true
	var card_i = _cards.find(card)
	
	if card_i < 0:
		return false
	
	if card_i == _cards.size() -1:
		return true
	
	for i in range(card_i, _cards.size() -1):
		if not CardDecks.can_stack_on(stack_type, _cards[i +1].deck_id, _cards[i +1].card_id, _cards[i].deck_id, _cards[i].card_id):
			result = false
		
	return result

func cancel_substack_move(card: Card):
	var card_i = _cards.find(card)
	
	if card_i < 0:
		return
	
	if card_i == _cards.size() -1:
		return
	
	for i in range(card_i, _cards.size()):
		_cards[i].reparent(_card_positions[i], false)

func get_substack_cards(card: Card) -> Array[Card]:
	var result: Array[Card] = []
	
	var card_i = _cards.find(card)
	
	if card_i < 0 or card_i == _cards.size() -1:
		return [card]
	
	for i in range(card_i, _cards.size()):
		result.append(_cards[i])
	
	return result
#endregion


#region private methods
func _on_card_move_finished(card: Card):
	if card.move_animation_finished.is_connected(_on_card_move_finished):
		card.move_animation_finished.disconnect(_on_card_move_finished)
	
	_remove_excess_cards()
	
	if SolitaireMatch.instance:
		if not SolitaireMatch.instance.dealing_cards:
			cards_changed.emit()


func _place_card_into_position(card: Card, position_slot: int):
	if not card:
		return
	
	var card_position_slot = self
	
	if not _card_positions.is_empty() and (position_slot < _card_positions.size() and position_slot >= 0):
		if _card_positions[position_slot].get_child_count() > 0:
			return
		
		card_position_slot = _card_positions[position_slot]
	
	if card.get_parent():
		card.reparent(card_position_slot)
		card.move_smooth()
	
	else:
		card_position_slot.add_child(card)
		
		if SolitaireMatch.instance:
			if SolitaireMatch.instance.card_spawn_point:
				card.move_smooth()

func _update_card_stack_of_card(card: Card):
	if card:
		if card.card_stack != self:
			if card.card_stack != null:
				card.card_stack.unstack_card()
				
			card.card_stack = self

func _remove_excess_cards():
	if _cards.size() > max_stacked_cards:
		_cards.front().queue_free()
		_cards.pop_front()
		
		for i in _cards.size() -1:
			_place_card_into_position(_cards[i], i)

func _place_path_follow():
	if curve.point_count > 0 and _cards.size() <= max_stacked_cards:
		var path_follow = PathFollow3D.new()
		add_child(path_follow)
		path_follow.rotation_mode = PathFollow3D.ROTATION_NONE
		path_follow.progress = (_cards.size() -1) * card_spacing
		_card_positions.append(path_follow)
		
#endregion


#region subclasses
#endregion
