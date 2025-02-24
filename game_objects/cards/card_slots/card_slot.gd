extends Area3D
class_name CardSlot

@export var limit_stack_number: bool = false
@export var is_final_slot: bool = false
@export var allowed_decks: Array[Card.Decks] = [ Card.Decks.ONE, Card.Decks.TWO, Card.Decks.THREE, Card.Decks.SAKURA, Card.Decks.DRAGON_ONE, Card.Decks.DRAGON_TWO, Card.Decks.DRAGON_THREE ]
@export var is_dragon_slot: bool = false

var child_card: Card

static var _hovered_card_slot: CardSlot

func _on_mouse_entered() -> void:
	_hovered_card_slot = self

func _on_mouse_exited() -> void:
	if _hovered_card_slot == self:
		_hovered_card_slot = null

func get_top_card() -> Card:
	if not child_card:
		return null
	
	return child_card.get_top_card()

static func get_hovered() -> CardSlot:
	return _hovered_card_slot

func attach_card(card: Card):
	if is_final_slot or is_dragon_slot:
		if child_card:
			child_card.hide()
			
		child_card = card
	
	if not child_card:
		child_card = card

func detach_card(card: Card):
	if card == child_card:
		child_card = null
