class_name UISolitaire
extends Control
## Documentation


#region signals
signal retry_pressed
#endregion


#region enums
#endregion


#region constants
#endregion


#region @export variables
@onready var win_panel: Control = $PanelWin
@onready var settings_panel: Control = $PanelSettings
@onready var settings_check_button_substack_movement: CheckButton = $PanelSettings/VBoxContainer/HBoxContainer/CheckButtonSubstackMovement
#endregion


#region public variables
#endregion


#region private variables
#endregion


#region @onready variables
#endregion


#region built-in virtuals (init)
#func _init():
	#pass


#func _enter_tree():
	#pass


func _ready():
	if win_panel:
		win_panel.hide()
	
	if settings_panel:
		settings_panel.hide()
	
	if settings_check_button_substack_movement:
		settings_check_button_substack_movement.button_pressed = SolitaireSettings.can_pick_substacks


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
func _on_button_retry_pressed():
	retry_pressed.emit()


func _on_settings_pressed():
	if settings_panel:
		settings_panel.visible = not settings_panel.visible


func _on_exit_pressed():
	pass # Replace with function body.


func _on_win(state: bool):
	if state:
		win_panel.show()
	
	else:
		win_panel.hide()


func _on_settings_substack_movement_toggled(toggled_on):
	SolitaireSettings.can_pick_substacks = toggled_on
#endregion


#region subclasses
#endregion










