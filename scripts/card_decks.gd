class_name CardDecks
## Documentation

#region enums
enum Deck_Type { NUMBERED_RED, NUMBERED_GREEN, NUMBERED_BLUE, DRAGON_CYAN, DRAGON_MAGENTA, DRAGON_YELLOW, SAKURA }
#endregion


#region constants
#endregion


#region public variables
static var card_ids_numbered := [1, 2, 3, 4, 5, 6, 7, 8, 9]
static var card_ids_dragon := [0, 0, 0, 0]
static var card_ids_sakura := [0]

static var deck_types_numbered = [
	Deck_Type.NUMBERED_RED,
	Deck_Type.NUMBERED_GREEN,
	Deck_Type.NUMBERED_BLUE
]

static var deck_types_dragon = [
	Deck_Type.DRAGON_CYAN,
	Deck_Type.DRAGON_MAGENTA,
	Deck_Type.DRAGON_YELLOW
]

static var deck_types_sakura = [
	Deck_Type.SAKURA
]
#endregion


#region built-in virtuals (init)
#func _init():
	#pass
#endregion


#region public methods
static func can_stack_on(stack_type: CardStack.Stack_Type, this_deck_type: Deck_Type, this_card_id: int, other_deck_type: Deck_Type, other_card_id: int = -1) -> bool:
	var current_flag: int = 0
	
	if not other_card_id == -1:
		current_flag |= Stack_Validity_Flags.Stack_Has_Cards
		
		if this_deck_type == other_deck_type:
			current_flag |= Stack_Validity_Flags.Same_Deck
			
		if this_card_id == other_card_id +1:
			current_flag |= Stack_Validity_Flags.Card_Is_One_More
			
		if this_card_id +1 == other_card_id:
			current_flag |= Stack_Validity_Flags.Card_Is_One_Less
	
	if this_deck_type in deck_types_sakura:
		current_flag |= Stack_Validity_Flags.Card_Is_Sakura
	
	if this_card_id == CardDecks.card_ids_numbered.front():
		current_flag |= Stack_Validity_Flags.Card_Is_Zero
	
	if this_deck_type in deck_types_numbered:
		current_flag |= Stack_Validity_Flags.Card_Is_Numbered
	
	match stack_type:
		CardStack.Stack_Type.Default:
			current_flag |= Stack_Validity_Flags.Stack_Is_Default
		
		CardStack.Stack_Type.Dragon:
			current_flag |= Stack_Validity_Flags.Stack_Is_Dragon
		
		CardStack.Stack_Type.SAKURA:
			current_flag |= Stack_Validity_Flags.Stack_Is_Sakura
		
		CardStack.Stack_Type.Final:
			current_flag |= Stack_Validity_Flags.Stack_Is_Final
		
	if current_flag in Stack_Validity_Flags.Valid_Flags:
		return true
	
	return false
#endregion


#region private methods
#endregion


#region subclasses
#endregion


