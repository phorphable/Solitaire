extends Node3D
class_name Stackable

@export var stack_marker: Marker3D 

func stack_add(card: Card, replace_card: bool = false):
	pass

func has_stack() -> bool:
	if stack_marker == null:
		return false
		
	if stack_marker.get_child_count() != 0:
		return true
	
	return false

func get_next_card() -> Card:
	if has_stack() == false:
		return null
	
	return stack_marker.get_child(0) as Card

func get_previous_stackable() -> Stackable:
	var stack_marker = get_parent()
	
	if stack_marker is Marker3D:
		var previous_stackable = stack_marker.get_parent()
		
		if previous_stackable is Stackable:
			return previous_stackable
	
	return null

## Returns Stack Head (Card Stack)
func get_stack_head() -> Card_Stack:
	var card_stack = self
	
	if card_stack is Card_Stack:
		return card_stack
	
	while true:
		if card_stack is Card_Stack:
			return card_stack
		
		if not card_stack is Stackable:
			return null
		
		card_stack = card_stack.get_previous_stackable()
	
	return null

## Returns the Stack Tail (Highest Stackable)
func get_stack_tail() -> Stackable:
	var stackable = self
	
	while true:
		if stackable.get_next_card() == null:
			return stackable
		
		stackable = stackable.get_next_card()
	
	return null
