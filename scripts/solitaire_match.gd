class_name SolitaireMatch
extends Node3D
## Singleton Class which manages Solitaire Gameplay


#region signals
signal win_state(state: bool)
#endregion


#region enums
#endregion


#region constants
const CHECK_MATCH_DELAY_AFTER_RESTART = 0.5
const CHECK_MATCH_DELAY_AFTER_CARDS_CHANGED = 0.1
#endregion


#region @export variables
@export var camera: Camera3D
@export var card_template: PackedScene
@export var card_stack_substack: CardStack
@export var card_spawn_point: Marker3D
#endregion


#region public variables
static var instance: SolitaireMatch
var dealing_cards: bool = false
#endregion


#region private variables
var _card_stacks := {}
var _dragon_buttons := {}
var _all_cards: Array[Card]
var _check_cards_queue: Array[Callable]
var _check_match_tween: Tween
#endregion


#region @onready variables
#endregion


#region built-in virtuals (init)
#func _init():
	#pass

#func _enter_tree():
	#pass

func _ready():
	instance = self
	if camera:
		camera.make_current()
	
	for stack_type in CardStack.Stack_Type.values():
		_card_stacks[stack_type] = []
	
	var stacks = get_tree().get_nodes_in_group(Groups.CARD_STACKS)
	stacks.erase(CardHandStack.instance)
	
	for stack: CardStack in stacks:
		_card_stacks[stack.stack_type].append(stack)
		stack.cards_changed.connect(_check_match_status_delayed_by, CHECK_MATCH_DELAY_AFTER_CARDS_CHANGED)
	
	var dragon_buttons = get_tree().get_nodes_in_group(Groups.DRAGON_BUTTON)
	
	for button: DragonButton in dragon_buttons:
		_dragon_buttons[button.deck_type] = button
		button.pressed.connect(_on_dragon_button_pressed)
	
	_new_game()

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
#endregion


#region private methods
func _new_game():
	win_state.emit(false)
	dealing_cards = true
	
	if not card_template:
		return
	
	_clear_game()
		
	for deck_type_numbered in CardDecks.deck_types_numbered:
		for card_id_numbered in CardDecks.card_ids_numbered:
			var new_card = card_template.instantiate().set_data(card_id_numbered, deck_type_numbered)
			_all_cards.append(new_card)
	
	for deck_type_dragon in CardDecks.deck_types_dragon:
		for card_id_dragon in CardDecks.card_ids_dragon:
			var new_card = card_template.instantiate().set_data(card_id_dragon, deck_type_dragon)
			_all_cards.append(new_card)
	
	for deck_type_sakura in CardDecks.deck_types_sakura:
		for card_id_sakura in CardDecks.card_ids_sakura:
			var new_card = card_template.instantiate().set_data(card_id_sakura, deck_type_sakura)
			_all_cards.append(new_card)
	
	var shuffled_cards = _all_cards.duplicate()
	shuffled_cards.shuffle()
	
	while not shuffled_cards.is_empty():
		if _card_stacks.get(CardStack.Stack_Type.Default):
			for stack in _card_stacks.get(CardStack.Stack_Type.Default):
				var card = shuffled_cards.pop_front() as Card
				
				if card_spawn_point:
					card_spawn_point.add_child(card)
					
				stack.stack_card(card)
				
				if shuffled_cards.is_empty():
					break
		
		else:
			break
	
	dealing_cards = false
	_unlock_cards(true)
	_check_match_status_delayed_by(CHECK_MATCH_DELAY_AFTER_RESTART)


func _clear_game():
	var stacks = get_tree().get_nodes_in_group(Groups.CARD_STACKS)
	
	for card in _all_cards:
		if is_instance_valid(card):
			card.free()
	
	_all_cards.clear()
	
	for stack: CardStack in stacks:
		stack.clear()


func _lock_cards():
	for stack: CardStack in _card_stacks[CardStack.Stack_Type.Default]:
		stack.is_locked = true
	
	for stack: CardStack in _card_stacks[CardStack.Stack_Type.Dragon]:
		stack.is_locked = true


func _unlock_cards(force_unlock: bool = false):
	for stack: CardStack in _card_stacks[CardStack.Stack_Type.Default]:
		stack.is_locked = false
	
	for stack: CardStack in _card_stacks[CardStack.Stack_Type.Dragon]:
		if stack.can_be_unlocked or force_unlock:
			stack.is_locked = false
			
			if force_unlock:
				stack.can_be_unlocked = true


func _on_card_check_moved(card: Card):
	if card.move_animation_finished.is_connected(_on_card_check_moved):
		card.move_animation_finished.disconnect(_on_card_check_moved)
	
	_check_match_status_delayed_by(CHECK_MATCH_DELAY_AFTER_CARDS_CHANGED)


func _check_match_status_delayed_by(delay: float = 0.1):
	if _check_match_tween:
		if not _check_match_tween.is_valid():
			_check_match_tween = create_tween()
		
		elif _check_match_tween.is_running():
			_check_match_tween.kill()
			_check_match_tween = create_tween()
			
	else:
		_check_match_tween = create_tween()
	
	_check_match_tween.tween_interval(delay)
	_check_match_tween.tween_callback(_check_match_status)


func _check_match_status():
	_check_cards_queue.clear()
	
	_lock_cards()
	_check_cards_queue.append(Callable(self, "_check_match_sakura"))
	_check_cards_queue.append(Callable(self, "_check_match_numbered"))
	_check_cards_queue.append(Callable(self, "_check_match_dragons"))
	_check_cards_queue.append(Callable(self, "_check_win_state"))
	_check_cards_queue.append(Callable(self, "_unlock_cards"))
	
	_check_cards_queue.front().call()


func _check_match_status_advance():
	if not _check_cards_queue.is_empty():
		_check_cards_queue.pop_front()
		
		if not _check_cards_queue.is_empty():
			_check_cards_queue.front().call()


func _check_match_numbered() -> void:
	var final_pairs = {}
	var first_free_final_stack: CardStack
	var lowest_final_card_id = CardDecks.card_ids_numbered[CardDecks.card_ids_numbered.size() -2]
	
	for deck_type in CardDecks.deck_types_numbered:
		final_pairs[deck_type] = FinalCardPair.new()
	
	for final_stack: CardStack in _card_stacks[CardStack.Stack_Type.Final]:
		var top_card = final_stack.get_top_card()
		
		if top_card:
			final_pairs[top_card.deck_id].stack = final_stack
			
			if top_card.card_id < lowest_final_card_id:
				lowest_final_card_id = top_card.card_id
		
		else:
			if not first_free_final_stack:
				first_free_final_stack = final_stack
				lowest_final_card_id = 0
	
	var default_and_dragon_stacks = []
	default_and_dragon_stacks.append_array(_card_stacks[CardStack.Stack_Type.Default])
	default_and_dragon_stacks.append_array(_card_stacks[CardStack.Stack_Type.Dragon])
	
	for default_stack: CardStack in default_and_dragon_stacks:
		var top_card = default_stack.get_top_card() as Card
		
		if top_card:
			if top_card.deck_id in CardDecks.deck_types_numbered:
				var final_stack = first_free_final_stack
				
				if final_pairs[top_card.deck_id].stack:
					final_stack = final_pairs[top_card.deck_id].stack
				
				var final_top_card = final_stack.get_top_card()
				var final_top_card_id = -1
				var final_top_deck_id = -1
				
				if final_top_card:
					final_top_card_id = final_top_card.card_id
					final_top_deck_id = final_top_card.deck_id
				
				if CardDecks.can_stack_on(final_stack.stack_type, top_card.deck_id, top_card.card_id, final_top_deck_id, final_top_card_id):
					var move_card = false
					
					if top_card.card_id == CardDecks.card_ids_numbered[0] or top_card.card_id == CardDecks.card_ids_numbered[1]:
						move_card = true
					
					if top_card.card_id == lowest_final_card_id +1:
						move_card = true
					
					if move_card:
						_lock_cards()
						top_card.move_animation_finished.connect(_on_card_check_moved)
						final_stack.stack_card(top_card)
						return
	
	_check_match_status_advance()


func _check_match_sakura() -> void:
	var sakura_stack = _card_stacks[CardStack.Stack_Type.SAKURA].front() as CardStack
	
	if sakura_stack:
		if not sakura_stack.get_top_card():
			for default_stack: CardStack in _card_stacks[CardStack.Stack_Type.Default]:
				var top_card = default_stack.get_top_card() as Card
				
				if top_card:
					if top_card.deck_id in CardDecks.deck_types_sakura:
						_lock_cards()
						top_card.move_animation_finished.connect(_on_card_check_moved)
						sakura_stack.stack_card(top_card)
						return
	
	_check_match_status_advance()


func _check_match_dragons() -> void:
	_disable_dragon_buttons()
	
	var dragon_cards = {}
	var dragon_card_on_dragon_stack = {}
	var free_dragon_stack_exists = false
	
	for dragon_type in CardDecks.deck_types_dragon:
		dragon_cards[dragon_type] = 0
		dragon_card_on_dragon_stack[dragon_type] = false
	
	for default_stack: CardStack in _card_stacks[CardStack.Stack_Type.Default]:
		var top_card = default_stack.get_top_card() as Card
		
		if top_card:
			if top_card.deck_id in CardDecks.deck_types_dragon:
				dragon_cards[top_card.deck_id] += 1
	
	for dragon_stack: CardStack in _card_stacks[CardStack.Stack_Type.Dragon]:
		var top_card = dragon_stack.get_top_card() as Card
		
		if top_card:
			if top_card.deck_id in CardDecks.deck_types_dragon:
				dragon_cards[top_card.deck_id] += 1
				dragon_card_on_dragon_stack[top_card.deck_id] = true
		
		else:
			free_dragon_stack_exists = true
	
	for dragon_type in CardDecks.deck_types_dragon:
		if dragon_cards[dragon_type] == CardDecks.card_ids_dragon.size():
			if dragon_card_on_dragon_stack[dragon_type] or free_dragon_stack_exists:
				_enable_dragon_button(dragon_type)
	
	_check_match_status_advance()


func _check_win_state():
	var empty_stacks = true
	
	for stack: CardStack in _card_stacks[CardStack.Stack_Type.Default]:
		if stack.get_top_card():
			empty_stacks = false
			break
	
	if empty_stacks:
		win_state.emit(true)
	
	_check_match_status_advance()


func _enable_dragon_button(deck_type: CardDecks.Deck_Type, active: bool = true):
	if _dragon_buttons.has(deck_type):
		_dragon_buttons[deck_type].set_active(active)

func _disable_dragon_buttons():
	for dragon_button: DragonButton in _dragon_buttons.values():
		dragon_button.set_active(false)


func _on_dragon_button_pressed(dragon_button: DragonButton):
	var dragon_cards = []
	
	for default_stack: CardStack in _card_stacks[CardStack.Stack_Type.Default]:
		var top_card = default_stack.get_top_card()
		
		if top_card:
			if top_card.deck_id == dragon_button.deck_type:
				dragon_cards.append(top_card)
	
	var final_dragon_stack: CardStack
	
	for dragon_stack: CardStack in _card_stacks[CardStack.Stack_Type.Dragon]:
		var top_card = dragon_stack.get_top_card() as Card
		
		if top_card:
			if top_card.deck_id == dragon_button.deck_type:
				if not final_dragon_stack:
					final_dragon_stack = dragon_stack
				
				else:
					dragon_cards.append(top_card)
		
		else:
			if not final_dragon_stack:
				final_dragon_stack = dragon_stack
	
	if final_dragon_stack:
		_lock_cards()
		
		if not dragon_cards.back().move_animation_finished.is_connected(_on_card_check_moved):
			dragon_cards.back().move_animation_finished.connect(_on_card_check_moved)
		
		for card: Card in dragon_cards:
			final_dragon_stack.stack_card(card)
			final_dragon_stack.can_be_unlocked = false
			_enable_dragon_button(dragon_button.deck_type, false)


func _on_ui_retry_pressed():
	_new_game()


#endregion


#region subclasses
class FinalCardPair:
	var stack: CardStack
	var card: Card
#endregion
