class_name LevelUpMenu
extends CanvasLayer
## Menu da Fada: "aumenta o nível em troca de memórias".
## Os atributos calculam Vida Máxima (Vitalidade) e Estamina (Fôlego).

signal _closed

const ROWS := [
	["vitalidade", "Vitalidade", "Vida máxima"],
	["folego", "Fôlego", "Estamina máxima"],
	["forca", "Força", "Dano do golpe forte"],
	["destreza", "Destreza", "Dano dos golpes leves"],
]

var _player: Player
var _info: Label
var _rows := {}
var _close_button: Button


func _ready() -> void:
	add_to_group(&"pad_menu")  # PadMenus: ✕ confirma e o foco nunca se perde no controle
	layer = 20
	process_mode = Node.PROCESS_MODE_ALWAYS
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.55)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UIStyle.panel_style())
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -130
	panel.offset_right = 130
	panel.offset_top = -95
	panel.offset_bottom = 95
	add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	panel.add_child(box)
	var title := UIStyle.label("A Fada", 12, UIStyle.GOLD, UIStyle.TITLE_FONT)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	_info = UIStyle.label("", 9, UIStyle.TEXT, UIStyle.FONT_NUMBERS)
	_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(_info)
	for row in ROWS:
		var line := HBoxContainer.new()
		line.add_theme_constant_override("separation", 6)
		var name_label := UIStyle.label(row[1], 10, UIStyle.TEXT, UIStyle.FONT_BOLD)
		name_label.custom_minimum_size = Vector2(64, 0)
		var value_label := UIStyle.label("10", 10, UIStyle.GOLD, UIStyle.FONT_NUMBERS)
		value_label.custom_minimum_size = Vector2(20, 0)
		var effect_label := UIStyle.label("", 8, UIStyle.TEXT_DIM)
		effect_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var plus := UIStyle.button("+", 11)
		plus.custom_minimum_size = Vector2(26, 18)
		var attribute: String = row[0]
		plus.pressed.connect(func(): _level_up(attribute))
		line.add_child(name_label)
		line.add_child(value_label)
		line.add_child(effect_label)
		line.add_child(plus)
		box.add_child(line)
		_rows[attribute] = {"value": value_label, "effect": effect_label, "button": plus, "text": row[2]}
	_close_button = UIStyle.button("Sair", 10)
	_close_button.pressed.connect(func():
		Sfx.play(&"ui_click")
		_closed.emit())
	box.add_child(_close_button)
	visible = false


func run(player: Player) -> void:
	_player = player
	_refresh()
	visible = true
	_focus_default()
	Sfx.play(&"ui_open")
	await _closed
	visible = false


## ○ (ou Esc) sai, igual ao botão "Sair".
func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed(&"ui_cancel"):
		Sfx.play(&"ui_click")
		_closed.emit()
		get_viewport().set_input_as_handled()


## Foco no primeiro "+" que dá para comprar; sem memórias, no "Sair".
func _focus_default() -> void:
	var buttons: Array = []
	for attribute in _rows:
		buttons.append(_rows[attribute]["button"])
	UIStyle.focus_first(buttons, _close_button)


func _level_up(attribute: String) -> void:
	if Game.try_level_up(attribute):
		Sfx.play(&"memory")
		_player.apply_progress(false)
		Fx.splash(_player.global_position + Vector2(0, -12), Color(0.75, 0.95, 1.0), 10)
	else:
		Sfx.play(&"ui_click")
	_refresh()
	# Ficou sem memórias? O botão focado desabilitou: o foco vai para outro.
	var focused := get_viewport().gui_get_focus_owner() as BaseButton
	if focused == null or focused.disabled:
		_focus_default()


func _refresh() -> void:
	var cost := Game.level_up_cost()
	_info.text = "Nível %d   ·   Memórias %d   ·   Custo %d" % [Game.level(), Game.memories, cost]
	for attribute in _rows:
		var row: Dictionary = _rows[attribute]
		(row["value"] as Label).text = str(Game.attributes.get(attribute, 10))
		var effect := str(row["text"])
		match attribute:
			"vitalidade":
				effect = "Vida máx. %d" % int(_player.stats.max_health)
			"folego":
				effect = "Estamina máx. %d" % int(_player.stats.max_stamina)
		(row["effect"] as Label).text = effect
		(row["button"] as Button).disabled = Game.memories < cost
