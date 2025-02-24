extends Marker3D
class_name CardSpawn

signal finished_queue

@export var spawn_time: float = .3
@export var spawn_variance: float = 0.2
@export var target_slot: CardSlot

static var card_amount_queued: int = 0

var _cards_queue: Array[Card] = []
var _is_spawning_cards: bool = false
var _spawn_timer: float = 0
var _spawn_time: float = 0

func _init() -> void:
	add_to_group(Groups.CARD_SPAWNER)

func _process(delta: float) -> void:
	if _is_spawning_cards:
		_spawn_timer += delta
		
		if _spawn_timer >= _spawn_time:
			spawn_card()
			
			_spawn_timer = 0
			_spawn_time = spawn_time + randf_range(-spawn_variance, spawn_variance)

func spawn_cards() -> void:
	_is_spawning_cards = true
	Card.spawn_locked = true
	_spawn_timer = 0
	_spawn_time = spawn_time + randf_range(-spawn_variance, spawn_variance)

func abort_spawn_cards() -> void:
	_is_spawning_cards = false
	Card.spawn_locked = false
	card_amount_queued -= _cards_queue.size()
	_cards_queue.clear()

func queue_card(card: Card) -> void:
	card_amount_queued += 1
	card.reset()
	_cards_queue.append(card)

func spawn_card():
	var card: Card = _cards_queue.pop_front()
	
	if card:
		card.position = position
		card.show()
		card.set_disabled(false)
		
		var attach_target = target_slot.get_top_card()
		
		if not attach_target:
			attach_target = target_slot
		
		card.attach_card_to(attach_target, true)
		card_amount_queued -= 1

	if _cards_queue.size() == 0:
		_is_spawning_cards = false
		
		if card_amount_queued == 0:
			Card.spawn_locked = false
			finished_queue.emit()
