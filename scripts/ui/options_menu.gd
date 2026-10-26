class_name OptionsMenu
extends CanvasLayer
## Opções do aparelho: volume dos efeitos e do ambiente, vibração, tamanho dos
## botões de toque e as dicas. Abre por cima da pausa E do título (por isso
## processa sempre). Cada mudança já vale e já fica gravada (Settings).

signal closed

var _rows := {}
var _back_button: Button


func _ready() -> void:
	add_to_group(&"pad_menu")  # PadMenus: ✕ confirma e o foco nunca se perde no controle
	layer = 40
	process_mode = Node.PROCESS_MODE_ALWAYS
	var dim := ColorRect.new()
	dim.color = Color(0.0, 0.0, 0.0, 0.96)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.offset_left = -120
	box.offset_right = 120
	box.offset_top = -112
	box.offset_bottom = 112
	box.add_theme_constant_override("separation", 5)
	add_child(box)
	var title := UIStyle.label("Opções", 16, UIStyle.TEXT, UIStyle.TITLE_FONT)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	_add_stepper(box, "efeitos", "Efeitos", func(d): Settings.step_sfx(d))
	_add_stepper(box, "ambiente", "Música e ambiente", func(d): Settings.step_ambience(d))
	_add_toggle(box, "vibracao", func(): Settings.toggle_vibration())
	_add_toggle(box, "controle", func(): Settings.cycle_controls())
	_add_toggle(box, "botoes", func(): Settings.cycle_button_size())
	_add_toggle(box, "dicas", func(): Settings.toggle_hints())
	_back_button = DSMenuButton.make("Voltar")
	_back_button.pressed.connect(close)
	box.add_child(_back_button)
	Settings.changed.connect(_refresh)
	visible = false


## Uma linha "Nome  [−] 80% [+]": botões grandes o bastante para o dedo.
func _add_stepper(box: VBoxContainer, key: String, title: String, step: Callable) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	var name_label := UIStyle.label(title, 10, Color(0.8, 0.78, 0.74))
	name_label.custom_minimum_size = Vector2(110, 0)
	row.add_child(name_label)
	var minus := DSMenuButton.make("‹", 14)
	minus.custom_minimum_size = Vector2(24, 0)
	minus.pressed.connect(func():
		step.call(-0.1)
		Sfx.play(&"ui_click"))
	row.add_child(minus)
	var value := UIStyle.label("", 12, UIStyle.GOLD, UIStyle.FONT_NUMBERS)
	value.custom_minimum_size = Vector2(40, 0)
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	row.add_child(value)
	var plus := DSMenuButton.make("›", 14)
	plus.custom_minimum_size = Vector2(24, 0)
	plus.pressed.connect(func():
		step.call(0.1)
		Sfx.play(&"ui_click"))
	row.add_child(plus)
	box.add_child(row)
	_rows[key] = value


func _add_toggle(box: VBoxContainer, key: String, action: Callable) -> void:
	var button := DSMenuButton.make("", 10, UIStyle.FONT)
	button.pressed.connect(func():
		action.call()
		Sfx.play(&"ui_click"))
	box.add_child(button)
	_rows[key] = button


func open() -> void:
	_refresh()
	visible = true
	_back_button.grab_focus()
	Sfx.play(&"ui_open")


func close() -> void:
	if not visible:
		return
	visible = false
	closed.emit()


func is_open() -> bool:
	return visible


func _refresh() -> void:
	if _rows.is_empty():
		return
	(_rows["efeitos"] as Label).text = "%d%%" % roundi(Settings.sfx_volume * 100.0)
	(_rows["ambiente"] as Label).text = "%d%%" % roundi(Settings.ambience_volume * 100.0)
	(_rows["vibracao"] as Button).text = "Vibração: %s" % ("ligada" if Settings.vibration else "desligada")
	(_rows["controle"] as Button).text = "Controles: %s" % {
		"toque": "Toque (botões na tela)",
		"controle": "Controle (legenda do PlayStation)",
		"limpo": "Limpo (nada na tela)",
	}[Settings.controls_mode()]
	(_rows["botoes"] as Button).text = "Botões de toque: %s" % Settings.button_size
	(_rows["botoes"] as Button).disabled = Settings.controller_mode  # sem toque, o tamanho não importa
	(_rows["dicas"] as Button).text = "Dicas: %s" % ("ligadas" if Settings.hints else "desligadas")


func _unhandled_input(event: InputEvent) -> void:
	if visible and (event.is_action_pressed(&"pause") or event.is_action_pressed(&"ui_cancel")):
		close()
		get_viewport().set_input_as_handled()
