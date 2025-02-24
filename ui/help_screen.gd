extends Control

func _input(event: InputEvent) -> void:
	if visible:
		if event.is_action(InputActions.CLICK):
			hide()
