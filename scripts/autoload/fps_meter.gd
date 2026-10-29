extends CanvasLayer
## Autoload "FpsMeter": o contador de FPS das Opções ("Mostrar FPS").
##
## Para que serve: quem testa diz "está lagando" — mas lag pode ser muita coisa.
## Com o número na tela a conversa vira dado: "na Cidade cai para 30 FPS e o
## quadro leva 33 ms". Mede, depois conserta (nunca o contrário).
##   FPS   = quadros desenhados por segundo (60 = liso);
##   ms    = quanto tempo leva o quadro mais lento do último meio segundo.

const UPDATE_EVERY := 0.5

var _label: Label
var _elapsed := 0.0
var _worst := 0.0


func _ready() -> void:
	layer = 120  # acima de tudo, até da cutscene
	process_mode = Node.PROCESS_MODE_ALWAYS
	_label = Label.new()
	_label.add_theme_font_override("font", UIStyle.FONT_NUMBERS)
	_label.add_theme_font_size_override("font_size", 8)
	_label.add_theme_color_override("font_color", Color(0.75, 1.0, 0.7))
	_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_label.add_theme_constant_override("outline_size", 2)
	_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_label.offset_left = -60
	_label.offset_right = 60
	_label.offset_top = 2
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_label)
	Settings.changed.connect(_on_settings_changed)
	_on_settings_changed()


func _on_settings_changed() -> void:
	visible = Settings.show_fps


func _process(delta: float) -> void:
	if not visible:
		return
	_worst = maxf(_worst, delta)
	_elapsed += delta
	if _elapsed >= UPDATE_EVERY:
		_label.text = "%d FPS · pior %.0f ms" % [Engine.get_frames_per_second(), _worst * 1000.0]
		_elapsed = 0.0
		_worst = 0.0
