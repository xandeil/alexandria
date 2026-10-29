class_name DialogueBox
extends CanvasLayer
## Caixa de diálogo com texto "datilografado" e opções no final.
## Uso (corrotina): var acao := await dialogue_box.run(entrada, "Nome")

signal _advance
signal _chosen(action: String)

## v0.30.2: 45 → 32 letras por segundo (testes: "os diálogos estão rápidos").
const CHARS_PER_SECOND := 32.0
## Depois que a frase termina, um instante em que o toque NÃO avança: quem
## aperta várias vezes seguidas (para completar o texto) não pula a fala sem ler.
const ADVANCE_GRACE := 0.25

var _panel: PanelContainer
var _name_label: Label
var _text_label: Label
var _hint: Label
var _choices: VBoxContainer
var _catcher: Control
var _typing := false
var _waiting := false
var _visible_chars := 0.0
var _since_finished := 0.0


func _ready() -> void:
	add_to_group(&"pad_menu")  # PadMenus: ✕ confirma e o foco nunca se perde no controle
	layer = 12
	process_mode = Node.PROCESS_MODE_ALWAYS
	_catcher = Control.new()
	_catcher.set_anchors_preset(Control.PRESET_FULL_RECT)
	_catcher.mouse_filter = Control.MOUSE_FILTER_STOP
	_catcher.gui_input.connect(_on_catcher_input)
	add_child(_catcher)

	_panel = PanelContainer.new()
	_panel.add_theme_stylebox_override("panel", UIStyle.panel_style())
	_panel.anchor_left = 0.5
	_panel.anchor_right = 0.5
	_panel.anchor_top = 1.0
	_panel.anchor_bottom = 1.0
	_panel.offset_left = -190
	_panel.offset_right = 190
	_panel.offset_top = -78
	_panel.offset_bottom = -8
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_panel)
	var box := VBoxContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_child(box)
	_name_label = UIStyle.label("", 9, UIStyle.GOLD, UIStyle.FONT_BOLD)
	box.add_child(_name_label)
	_text_label = UIStyle.label("", 10)
	_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text_label.custom_minimum_size = Vector2(360, 36)
	box.add_child(_text_label)
	_hint = UIStyle.label("▼", 8, UIStyle.TEXT_DIM)
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	box.add_child(_hint)

	_choices = VBoxContainer.new()
	_choices.anchor_left = 0.5
	_choices.anchor_right = 0.5
	_choices.anchor_top = 1.0
	_choices.anchor_bottom = 1.0
	_choices.offset_left = -95
	_choices.offset_right = 95
	_choices.offset_bottom = -92
	_choices.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_choices.add_theme_constant_override("separation", 4)
	add_child(_choices)
	visible = false


func run(entry: Dictionary, fallback_name: String = "") -> String:
	var lines: Array = entry.get("falas", [])
	_name_label.text = str(entry.get("nome", fallback_name))
	_name_label.visible = not _name_label.text.is_empty()
	visible = true
	Sfx.play(&"ui_open")
	for line in lines:
		_show_line(str(line))
		await _advance
	var action := ""
	var options: Array = entry.get("opcoes", [])
	if not options.is_empty():
		action = await _ask(options)
	visible = false
	return action


func _show_line(text: String) -> void:
	_text_label.text = text
	_visible_chars = 0.0
	_text_label.visible_characters = 0
	_typing = true
	_waiting = true
	_hint.visible = false


func _process(delta: float) -> void:
	if not visible:
		return
	if _typing:
		_visible_chars += CHARS_PER_SECOND * delta
		_text_label.visible_characters = int(_visible_chars)
		if _visible_chars >= _text_label.text.length():
			_finish_typing()
	else:
		_since_finished += delta
		_hint.modulate.a = 0.4 + 0.6 * absf(sin(Time.get_ticks_msec() * 0.005))


func _finish_typing() -> void:
	_typing = false
	_since_finished = 0.0
	_text_label.visible_characters = -1
	_hint.visible = true


func _tap() -> void:
	if not visible or not _choices.get_children().is_empty() and not _waiting:
		return
	if _typing:
		_finish_typing()
	elif _waiting and _since_finished >= ADVANCE_GRACE:
		_waiting = false
		Sfx.play(&"ui_click")
		_advance.emit()


func _on_catcher_input(event: InputEvent) -> void:
	var mouse := event as InputEventMouseButton
	if mouse and mouse.pressed and mouse.button_index == MOUSE_BUTTON_LEFT:
		_tap()


func _unhandled_input(event: InputEvent) -> void:
	if visible and (event.is_action_pressed(&"ui_accept") or event.is_action_pressed(&"attack") or event.is_action_pressed(&"heal") \
			or event.is_action_pressed(&"interact")):
		_tap()
		get_viewport().set_input_as_handled()


func _ask(options: Array) -> String:
	_waiting = false
	_hint.visible = false
	for option in options:
		var data: Dictionary = option
		var button := UIStyle.button(str(data.get("texto", "...")), 10)
		var action := str(data.get("acao", ""))
		button.pressed.connect(func():
			Sfx.play(&"ui_click")
			_chosen.emit(action))
		_choices.add_child(button)
	UIStyle.focus_first(_choices.get_children())
	var chosen: String = await _chosen
	for child in _choices.get_children():
		child.queue_free()
	return chosen
