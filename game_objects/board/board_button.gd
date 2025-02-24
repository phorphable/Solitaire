extends Area3D
class_name BoardButton

signal button_pressed()

@export var text: String = "Button"

var _mouse_hover: bool = false
var _mouse_pressed: bool = false
var _mouse_released: bool = false

@onready var _label: Label3D = $Label3D

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action(InputActions.CLICK):
		if _mouse_hover:
			if event.is_pressed():
				_mouse_pressed = true
			elif not event.is_pressed() and _mouse_pressed:
				_mouse_released = true
			
			if _mouse_pressed and _mouse_released:
				button_pressed.emit()
				_mouse_pressed = false
				_mouse_released = false
		
		else:
			_mouse_pressed = false
			_mouse_released = false
			

func _ready() -> void:
	if _label:
		_label.text = text

func _on_mouse_entered() -> void:
	_mouse_hover = true

func _on_mouse_exited() -> void:
	_mouse_hover = false
