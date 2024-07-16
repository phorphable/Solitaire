class_name SolitaireAssets
extends Node
## Documentation


#region signals
#endregion


#region enums
#endregion


#region constants
#endregion


#region @export variables
#endregion


#region public variables
static var deck_colors = {
	CardDecks.Deck_Type.NUMBERED_RED: preload("res://data/deck_visual_numbered_red.tres"),
	CardDecks.Deck_Type.NUMBERED_GREEN: preload("res://data/deck_visual_numbered_green.tres"),
	CardDecks.Deck_Type.NUMBERED_BLUE: preload("res://data/deck_visual_numbered_blue.tres"),
	CardDecks.Deck_Type.DRAGON_CYAN: preload("res://data/deck_visual_dragon_cyan.tres"),
	CardDecks.Deck_Type.DRAGON_MAGENTA: preload("res://data/deck_visual_dragon_magenta.tres"),
	CardDecks.Deck_Type.DRAGON_YELLOW: preload("res://data/deck_visual_dragon_yellow.tres"),
	CardDecks.Deck_Type.SAKURA: preload("res://data/deck_visual_sakura.tres")
}

static var card_template := preload("res://scenes/card.tscn")

static var curve_card_move_distance_increase := preload("res://data/curves/card_move_distance_increase.tres")
#endregion


#region private variables
#endregion


#region public methods
#endregion


#region private methods
#endregion


#region subclasses
#endregion

