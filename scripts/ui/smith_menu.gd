class_name SmithMenu
extends CanvasLayer
## A forja do Ferreiro Anão, em duas abas:
##   • Reforçar — memórias + Sucata Temperada → arma mais forte (+1, +2...);
##   • Forjar   — a Lembrança de um Pecado vira a arma daquele chefe.
##     A Lembrança NÃO é gasta: ela é a chave do caminho até o Núcleo.
##
## O menu NÃO sabe as regras (custos, tetos, quem já foi forjado): pergunta tudo
## ao Game. UI que só mostra e repassa cliques é fácil de trocar sem quebrar o
## balanceamento.

signal _closed

## O que o Ferreiro diz quando não dá para reforçar (motivo vem do Game).
const REASONS := {
	"cap": "\"Daqui pra frente, só com as mãos de quem martelava comigo. Não lembro dele.\"",
	"max": "\"Não há mais o que tirar desse aço.\"",
	"memories": "Faltam memórias.",
	"sucata": "Falta Sucata Temperada (inimigos da Cidade e o Vendedor).",
}
## ...e quando não dá para forjar.
const FORGE_REASONS := {
	"owned": "\"Você já tem duas. Mão tem só duas também.\"",
	"lembranca": "\"Sem a Lembrança dele, isso é só ferro. Traga a alma, eu dou a forma.\"",
	"memories": "Faltam memórias.",
	"sucata": "Falta Sucata Temperada.",
}

var _player: Player
var _tab := 0
var _tab_buttons: Array[Button] = []
var _upgrade_page: VBoxContainer
var _forge_page: HBoxContainer
var _weapon_label: Label
var _damage_label: Label
var _cost_label: Label
var _reason_label: Label
var _upgrade_button: Button
var _close_button: Button
var _icon: TextureRect
var _forge_slots: Array[Button] = []
var _forge_name: Label
var _forge_info: Label
var _forge_reason: Label
var _forge_button: Button
var _forge_selected := ""


func _ready() -> void:
	add_to_group(&"pad_menu")  # PadMenus: ✕ confirma e o foco nunca se perde no controle
	layer = 20
	process_mode = Node.PROCESS_MODE_ALWAYS
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.9)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.offset_left = -210
	box.offset_right = 210
	box.offset_top = -118
	box.offset_bottom = 118
	box.add_theme_constant_override("separation", 4)
	add_child(box)
	var title := UIStyle.label("A Forja", 14, Color(0.92, 0.9, 0.85), UIStyle.TITLE_FONT)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	var tabs := HBoxContainer.new()
	tabs.alignment = BoxContainer.ALIGNMENT_CENTER
	tabs.add_theme_constant_override("separation", 16)
	box.add_child(tabs)
	for i in 2:
		var tab := DSMenuButton.make(["Reforçar", "Forjar com Lembrança"][i], 10)
		tab.pressed.connect(func(): set_tab(i))
		tabs.add_child(tab)
		_tab_buttons.append(tab)
	_build_upgrade_page(box)
	_build_forge_page(box)
	_close_button = DSMenuButton.make("Sair", 10)
	_close_button.pressed.connect(func():
		Sfx.play(&"ui_click")
		_closed.emit())
	box.add_child(_close_button)
	visible = false


func _build_upgrade_page(box: VBoxContainer) -> void:
	_upgrade_page = VBoxContainer.new()
	_upgrade_page.add_theme_constant_override("separation", 4)
	_upgrade_page.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(_upgrade_page)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	_icon = _make_icon(24)
	row.add_child(_icon)
	_weapon_label = UIStyle.label("", 11, UIStyle.TEXT, UIStyle.FONT_BOLD)
	row.add_child(_weapon_label)
	_upgrade_page.add_child(row)
	_damage_label = _centered(9, UIStyle.TEXT, UIStyle.FONT_NUMBERS)
	_upgrade_page.add_child(_damage_label)
	_cost_label = _centered(9, UIStyle.TEXT_DIM, UIStyle.FONT_NUMBERS)
	_upgrade_page.add_child(_cost_label)
	_reason_label = _centered(8, UIStyle.TEXT_DIM, UIStyle.FONT)
	_reason_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_reason_label.custom_minimum_size = Vector2(300, 0)
	_upgrade_page.add_child(_reason_label)
	_upgrade_button = DSMenuButton.make("Melhorar", 11)
	_upgrade_button.pressed.connect(_upgrade)
	_upgrade_page.add_child(_upgrade_button)


func _build_forge_page(box: VBoxContainer) -> void:
	_forge_page = HBoxContainer.new()
	_forge_page.add_theme_constant_override("separation", 10)
	_forge_page.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(_forge_page)
	var grid := GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 3)
	grid.add_theme_constant_override("v_separation", 3)
	_forge_page.add_child(grid)
	for id in Game.smith_weapons():  # a espada inicial (cópia) e as 8 de chefe
		var weapon := Items.get_item(id) as WeaponData
		var slot := Button.new()
		slot.custom_minimum_size = Vector2(32, 32)
		slot.icon = weapon.icon
		slot.expand_icon = true
		slot.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		slot.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		for state in ["normal", "pressed", "disabled"]:
			slot.add_theme_stylebox_override(state, _slot_style(false))
		for state in ["hover", "focus", "hover_pressed"]:
			slot.add_theme_stylebox_override(state, _slot_style(true))
		slot.focus_entered.connect(func(): _select_forge(id))
		slot.mouse_entered.connect(func(): slot.grab_focus())
		slot.pressed.connect(func():
			_select_forge(id)
			if not _forge_button.disabled:
				_forge_button.grab_focus())
		slot.set_meta("weapon_id", id)
		grid.add_child(slot)
		_forge_slots.append(slot)
	var detail := VBoxContainer.new()
	detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail.add_theme_constant_override("separation", 2)
	_forge_page.add_child(detail)
	_forge_name = UIStyle.label("", 11, Color(0.98, 0.94, 0.82), UIStyle.TITLE_FONT)
	detail.add_child(_forge_name)
	_forge_info = UIStyle.label("", 8, UIStyle.TEXT)
	_forge_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_forge_info.custom_minimum_size = Vector2(250, 0)
	detail.add_child(_forge_info)
	_forge_reason = UIStyle.label("", 8, UIStyle.TEXT_DIM)
	_forge_reason.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_forge_reason.custom_minimum_size = Vector2(250, 0)
	detail.add_child(_forge_reason)
	_forge_button = DSMenuButton.make("Forjar", 11)
	_forge_button.pressed.connect(_forge)
	detail.add_child(_forge_button)


func run(player: Player) -> void:
	_player = player
	visible = true
	set_tab(0)
	Sfx.play(&"ui_open")
	await _closed
	visible = false


func set_tab(index: int) -> void:
	_tab = index
	_upgrade_page.visible = index == 0
	_forge_page.visible = index == 1
	for i in _tab_buttons.size():
		_tab_buttons[i].add_theme_color_override("font_color", Color(0.98, 0.94, 0.82) if i == index else DSMenuButton.DIM)
	_refresh()
	if index == 0:
		UIStyle.focus_first([_upgrade_button], _close_button)
	else:
		_forge_slots[0].grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed(&"ui_cancel"):  # ○ sai da forja
		Sfx.play(&"ui_click")
		_closed.emit()
		get_viewport().set_input_as_handled()
		return
	# L1/R1 (ou Q/E) trocam a aba, como no inventário.
	if (event is InputEventJoypadButton and event.pressed and event.button_index in [JOY_BUTTON_LEFT_SHOULDER, JOY_BUTTON_RIGHT_SHOULDER]) \
			or (event is InputEventKey and event.pressed and not event.echo and event.keycode in [KEY_Q, KEY_E]):
		set_tab(1 - _tab)
		get_viewport().set_input_as_handled()


# --- Reforçar ------------------------------------------------------------------------------

func _upgrade() -> void:
	if not Game.try_upgrade_weapon():
		Sfx.play(&"ui_click")
		_refresh()
		return
	Sfx.play(&"forge")
	# A bigorna "responde": o ícone pisca dourado.
	var tween := create_tween()
	_icon.modulate = Color(2.0, 1.6, 0.8)
	tween.tween_property(_icon, "modulate", Color.WHITE, 0.4)
	_refresh()
	if _upgrade_button.disabled:
		_close_button.grab_focus()


func _refresh() -> void:
	var level := Game.weapon_level
	var weapon := Game.current_weapon()
	_icon.texture = weapon.icon
	_weapon_label.text = "%s +%d" % [weapon.display_name, level]
	var now := int(round((Game.weapon_damage_multiplier() - 1.0) * 100.0))
	var reason := Game.upgrade_block_reason()
	var cost := Game.next_upgrade_cost()
	if cost.is_empty() or reason == "cap":
		_damage_label.text = "Dano +%d%%" % now
		_cost_label.text = ""
	else:
		var after := int(round(Game.WEAPON_DAMAGE_PER_LEVEL * (level + 1) * 100.0))
		_damage_label.text = "Dano +%d%%  ->  +%d%%   (vale para todas as armas)" % [now, after]
		_cost_label.text = "Custo: %d memórias (tem %d)  ·  %d sucata (tem %d)" % [
			int(cost["memories"]), Game.memories,
			int(cost["sucata_temperada"]), Game.item_count("sucata_temperada")]
	_reason_label.text = REASONS.get(reason, "\"Segura firme. Vai doer menos em você do que nele.\"")
	_upgrade_button.disabled = reason != ""
	for slot in _forge_slots:
		var id: String = slot.get_meta("weapon_id")
		slot.modulate = Color.WHITE if Game.owns_weapon(id) or Game.forge_block_reason(id) != "lembranca" else Color(0.35, 0.35, 0.35)
	if _forge_selected != "":
		var keep := _forge_selected
		_forge_selected = ""
		_select_forge(keep)


# --- Forjar --------------------------------------------------------------------------------

func _select_forge(id: String) -> void:
	if id == _forge_selected:
		return
	_forge_selected = id
	var weapon := Items.get_item(id) as WeaponData
	var reason := Game.forge_block_reason(id)
	var known := reason != "lembranca"  # sem a Lembrança, a arma é um mistério
	var copy := Game.owns_weapon(id)  # já tem uma: esta seria a cópia para a outra mão
	_forge_name.text = (weapon.display_name + (" (cópia)" if copy else "")) if known else "???"
	var lines: Array[String] = []
	if known:
		lines.append("%s  ·  %s" % [weapon.weapon_class, weapon.scaling_text()])
		lines.append("%s — %s" % [weapon.skill_name, weapon.skill_text])
	if not weapon.memory_item.is_empty():
		lines.append("Requer: %s %s" % [Items.display_name(weapon.memory_item), "(você tem)" if Game.has_item(weapon.memory_item) else "(falta)"])
	lines.append("Você tem: %d de 2 (uma para cada mão)" % Game.weapon_count(id))
	lines.append("Custo: %d memórias · %d sucata" % [weapon.forge_memories, weapon.forge_sucata])
	_forge_info.text = "\n".join(lines)
	_forge_reason.text = FORGE_REASONS.get(reason, "\"A Lembrança fica com você. Eu só copio a raiva dela no aço.\"")
	_forge_button.disabled = reason != ""
	_forge_button.text = "Forjar cópia" if copy else "Forjar"


func _forge() -> void:
	var id := _forge_selected
	if not Game.try_forge_weapon(id):
		Sfx.play(&"ui_click")
		return
	Sfx.play(&"forge")
	Fx.vibrate(40)
	_forge_selected = ""
	_refresh()
	_select_forge(id)
	for slot in _forge_slots:
		if slot.get_meta("weapon_id") == id:
			slot.grab_focus()


# --- Ajudantes ------------------------------------------------------------------------------

func _centered(size: int, color: Color, font: Font) -> Label:
	var label := UIStyle.label("", size, color, font)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return label


func _make_icon(size: int) -> TextureRect:
	var rect := TextureRect.new()
	rect.custom_minimum_size = Vector2(size, size)
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	return rect


func _slot_style(lit: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.07, 0.065, 0.06, 0.95) if not lit else Color(0.16, 0.14, 0.11, 0.95)
	style.border_color = Color(0.98, 0.94, 0.82) if lit else Color(0.3, 0.27, 0.22)
	style.set_border_width_all(1)
	if lit:
		style.shadow_color = Color(1.0, 0.92, 0.7, 0.25)
		style.shadow_size = 3
	return style
