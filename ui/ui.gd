extends Control
class_name UI

var _ui_screen_asset = preload("res://ui/help_screen.tscn")
var _ui_screen

static var instance: UI

func _init() -> void:
	if not instance:
		instance = self

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	
	if _ui_screen_asset:
		_ui_screen = _ui_screen_asset.instantiate() as Control
		_ui_screen.hide()
		add_child(_ui_screen)

static func show_help():
	if instance:
		if instance._ui_screen:
			instance._ui_screen.show()
