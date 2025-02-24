extends Node3D

signal set_disable_cards
signal update_dragon_buttons

@export var card_slots_dragon: Array[CardSlot]
@export var card_slot_sakura: CardSlot
@export var card_slots_final: Array[CardSlot]
@export var card_slots_other: Array[CardSlot]

@export var card_asset_path: Resource = preload("res://game_objects/cards/card.tscn")

@export var _cards_to_spawn: Dictionary = {
	Card.Decks.ONE: [0, 1, 2, 3, 4, 5, 6, 7, 8],
	Card.Decks.TWO: [0, 1, 2, 3, 4, 5, 6, 7, 8],
	Card.Decks.THREE: [0, 1, 2, 3, 4, 5, 6, 7, 8],
	Card.Decks.SAKURA: [0],
	Card.Decks.DRAGON_ONE: [0, 0, 0, 0],
	Card.Decks.DRAGON_TWO: [0, 0, 0, 0],
	Card.Decks.DRAGON_THREE: [0, 0, 0, 0]
}

@export var _card_deck_assets: Dictionary = {
	Card.Decks.ONE: preload("res://game_objects/cards/deck_numbered_one.tres"),
	Card.Decks.TWO: preload("res://game_objects/cards/deck_numbered_two.tres"),
	Card.Decks.THREE: preload("res://game_objects/cards/deck_numbered_three.tres"),
	Card.Decks.SAKURA: preload("res://game_objects/cards/deck_sakura.tres"),
	Card.Decks.DRAGON_ONE: preload("res://game_objects/cards/deck_dragon_one.tres"),
	Card.Decks.DRAGON_TWO: preload("res://game_objects/cards/deck_dragon_two.tres"),
	Card.Decks.DRAGON_THREE: preload("res://game_objects/cards/deck_dragon_three.tres")
}
var _cards: Array[Card] = []
var _spawns: Array[CardSpawn] = []

var _sort_tween: Tween
var _sort_moved_card: Card
var _sort_queue_delay: float = .5
var _sort_time_max: float = .25
var _sort_time_min: float = .1
var _sort_time_step: float = .05
var _sort_counter: int = 0
var _dragon_deck_sort_interval: float = .25

func _ready() -> void:
	var spawns = get_tree().get_nodes_in_group(Groups.CARD_SPAWNER) as Array[CardSpawn]
	
	for spawn in spawns:
		_spawns.append(spawn)
		spawn.finished_queue.connect(on_spawn_queue_finished)
	
	instantiate_cards()

func instantiate_cards() -> void:
	if card_asset_path:
		for deck_id in _cards_to_spawn:
			for card_id in _cards_to_spawn[deck_id]:
				var card: Card = card_asset_path.instantiate()
				
				if card:
					_cards.append(card)
					card.deck_id = deck_id
					card.card_id = card_id
					
					card.deck_asset = _card_deck_assets[deck_id]
					
					card.hide()
					card.card_moved.connect(queue_auto_sort)
					set_disable_cards.connect(card.set_disabled)
					add_child(card)

func on_spawn_queue_finished():
	queue_auto_sort()

func new_game() -> void:
	if not _cards.is_empty() and not _spawns.is_empty():
		_cards.shuffle()
		
		var spawn_index = 0
		
		for spawn in _spawns:
			spawn.abort_spawn_cards()
		
		for card in _cards:
			_spawns[spawn_index].queue_card(card)
			spawn_index += 1
			
			if spawn_index >= _spawns.size():
				spawn_index = 0
	
		for spawn in _spawns:
			spawn.spawn_cards()

func exit_game():
	get_tree().quit()

func auto_sort_cards() -> void:
	var sorted_cards: Dictionary = {}
	var first_empty_final_slot: CardSlot = null
	var lowest_sorted_card_id = 10
	
	for card_slot in card_slots_final:
		var child_card = card_slot.child_card
		
		if child_card:
			sorted_cards[child_card.deck_id] = child_card
			
			if child_card.card_id < lowest_sorted_card_id:
				lowest_sorted_card_id = child_card.card_id
		
		elif not first_empty_final_slot:
			first_empty_final_slot = card_slot
			lowest_sorted_card_id = -1
	
	var possible_cards_to_sort: Dictionary = {}
	
	var card_slots = []
	card_slots.append_array(card_slots_other)
	card_slots.append_array(card_slots_dragon)
	
	var dragon_decks_exposed: Array[Card.Decks] = []
	
	# retrieve smallest value cards from play area | count exposed dragon cards
	for card_slot in card_slots:
		var card = card_slot.get_top_card()
		
		if card:
			if card.deck_id not in Card.dragon_decks:
				if possible_cards_to_sort.has(card.deck_id):
					if possible_cards_to_sort[card.deck_id].deck_id == card.deck_id:
						if possible_cards_to_sort[card.deck_id].card_id > card.card_id:
							possible_cards_to_sort[card.deck_id] = card
				
				else:
					possible_cards_to_sort[card.deck_id] = card
			
			else:
				if possible_cards_to_sort.has(card.deck_id):
					possible_cards_to_sort[card.deck_id] += 1
				
				else:
					possible_cards_to_sort[card.deck_id] = 1
				
				if possible_cards_to_sort[card.deck_id] == _cards_to_spawn[card.deck_id].size():
					dragon_decks_exposed.append(card.deck_id)
	
	update_dragon_buttons.emit(dragon_decks_exposed)
	
	# key: card | value: target
	var valid_sort_pairs: Dictionary = {}
	
	# assign card -> target pairs
	if possible_cards_to_sort.has(Card.Decks.SAKURA):
		valid_sort_pairs[possible_cards_to_sort[Card.Decks.SAKURA]] = card_slot_sakura
	
	else:
		for deck_id in Card.numbered_decks:
			if possible_cards_to_sort.has(deck_id):
				var possible_card = possible_cards_to_sort[deck_id]
				var possible_target = null
				
				if sorted_cards.has(deck_id):
					possible_target = sorted_cards[deck_id]
				
				if possible_card.card_id == 0:
					valid_sort_pairs[possible_card] = first_empty_final_slot
				
				elif possible_card.card_id == 1 and possible_target:
					valid_sort_pairs[possible_card] = possible_target
					
				
				elif possible_target and possible_target is Card:
					if possible_card.card_id == possible_target.card_id +1:
						valid_sort_pairs[possible_card] = possible_target
	
	var card_to_sort: Card = null
	var sort_target = null
	
	# find lowest value pair
	for card in valid_sort_pairs:
		if valid_sort_pairs[card]:
			if not (card_to_sort and sort_target):
				card_to_sort = card
				sort_target = valid_sort_pairs[card]
			
			elif card_to_sort.card_id > card.card_id:
				card_to_sort = card
				sort_target = valid_sort_pairs[card]
	
	var is_sorting = false
	
	if card_to_sort and sort_target:
		if card_to_sort.card_id in [0, 1] or (card_to_sort.card_id == lowest_sorted_card_id +1 and card_to_sort.card_id > 1):
			card_to_sort.is_sorted = true
			card_to_sort.set_disabled()
			card_to_sort.attach_card_to(sort_target, true)
			_sort_moved_card = card_to_sort
			is_sorting = true
	
	set_disable_cards.emit(is_sorting)
	
	if is_sorting:
		_sort_counter += 1
		_sort_tween = self.create_tween()
		var sort_time = clampf(_sort_time_max - (_sort_time_step * _sort_counter), _sort_time_min, _sort_time_max)
		_sort_tween.tween_interval(sort_time)
		_sort_tween.tween_callback(auto_sort_cards)
	
	else:
		_sort_counter = 0

func queue_auto_sort():
	if _sort_tween:
		if _sort_tween.is_valid():
			return
	
	_sort_counter = 0
	
	_sort_tween = self.create_tween()
	_sort_tween.tween_interval(_sort_queue_delay)
	_sort_tween.tween_callback(auto_sort_cards)

func can_auto_sort(card: Card, card_slot: CardSlot) -> bool:
	if card and card_slot:
		if card_slot.child_card:
			if card.deck_id == card_slot.child_card.deck_id:
				if card.card_id == 1 or card.card_id == card_slot.child_card.card_id +1:
					return true
		else:
			if card.card_id == 0:
				return true
	
	return false

func sort_dragon_deck(deck_id) -> void:
	var target_card_slot= null
	
	for card_slot in card_slots_dragon:
		if card_slot.child_card:
			if card_slot.child_card.deck_id == deck_id:
				target_card_slot = card_slot
				break
		
		else:
			target_card_slot = card_slot
			break
	
	var dragon_cards: Array[Card] = []
	
	for card_slot in card_slots_dragon:
		var card: Card = card_slot.child_card
		
		if card:
			if card.deck_id == deck_id:
				dragon_cards.append(card)
	
	for card_slot in card_slots_other:
		var card: Card = card_slot.get_top_card()
		
		if card:
			if card.deck_id == deck_id:
				dragon_cards.append(card)
	
	if dragon_cards.size() == _cards_to_spawn[deck_id].size():
		set_disable_cards.emit()
		
		var tween = self.create_tween()
		
		while dragon_cards.size() > 0:
			var card = dragon_cards.pop_front()
			
			if not card._card_slot == target_card_slot:
				tween.tween_callback(sort_dragon_card.bind(card, target_card_slot))
				tween.tween_interval(_dragon_deck_sort_interval)
		
		tween.tween_callback(on_dragon_cards_sorted)

func sort_dragon_card(card: Card, card_slot: CardSlot) -> void:
	card.is_sorted = true
	card.set_disabled()
	card.attach_card_to(card_slot, true)

func on_dragon_cards_sorted() -> void:
	queue_auto_sort()

func _on_dragon_button_pressed(extra_arg_0: int) -> void:
	sort_dragon_deck(extra_arg_0)

func show_help() -> void:
	UI.show_help()

func show_settings() -> void:
	pass # Replace with function body.
