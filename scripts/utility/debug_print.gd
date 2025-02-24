extends CanvasLayer
class_name DebugPrint

var _vbox: VBoxContainer

var _fps_label: Label
var _show_fps: bool = true

func _ready() -> void:
	_vbox = VBoxContainer.new()
	_vbox.offset_top = 5
	_vbox.offset_left = 5
	add_child(_vbox)
	
	var label_settings = LabelSettings.new()
	label_settings.font_color = Color.WHITE
	label_settings.font_size = 10
	label_settings.outline_color = Color.BLACK
	label_settings.outline_size = 2
	
	_fps_label = Label.new()
	_fps_label.label_settings = label_settings
	_vbox.add_child(_fps_label)

func _process(delta: float) -> void:
	if _show_fps:
		_fps_label.text = "fps: " + str(round(1 / delta)) + " / " + str(Engine.get_frames_per_second())
