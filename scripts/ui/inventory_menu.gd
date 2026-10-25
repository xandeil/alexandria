class_name InventoryMenu
extends CanvasLayer
## Inventário no estilo dos soulslike (uma mistura nossa de Dark Souls 1/2/3
## e Lies of P — parecido no ESPÍRITO, não uma cópia):
##
##   ┌ L1 ‹  Armas · Escudos · Frascos · Materiais · Lembranças  › R1 ┐
##   │ EQUIPADO        │  grade de espaços   │  ficha do item          │
##   │ (mãos, frascos) │  (DS1/DS3)          │  (letras de escala, LoP)│
##   └ legenda dos botões ─────────────────────────────────────────────┘
##
## Tudo funciona no toque (tocar), no teclado/mouse e no controle (o FOCO do
## espaço escolhe o item; L1/R1 trocam a aba).

signal closed

const TABS: Array[String] = ["Armas", "Escudos", "Frascos", "Materiais", "Lembranças"]
const SLOT := 30
const COLUMNS := 5
const GOLD_LINE := Color(0.62, 0.52, 0.32, 0.55)
const SLOT_BG := Color(0.07, 0.065, 0.06, 0.95)
const SLOT_EDGE := Color(0.3, 0.27, 0.22)
const SLOT_LIT := Color(0.98, 0.94, 0.82)

var _player: Player
var _tab := 0
var _tab_buttons: Array[Button] = []
var _grid: GridContainer
var _slots: Array[Button] = []
var _equip_rows := {}  # "direita"/"esquerda"/"vida"/"sanidade" -> Button
var _detail_name: Label
var _detail_kind: Label
var _detail_icon: TextureRect
var _detail_stats: Label
var _scaling_box: HBoxContainer
var _detail_skill: Label
var _detail_text: Label
var _hint: ButtonHintBar
var _empty: Label
var _back_button: Button
var _selected := ""


func _ready() -> void:
	layer = 31  # por cima da pausa
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build()
	Game.items_changed.connect(func():
		if visible:
			_rebuild())
	Game.weapon_changed.connect(func(_id):
		if visible:
			_rebuild())
	visible = false


# --- Montagem -----------------------------------------------------------------------

func _build() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0.0, 0.0, 0.0, 0.97)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.draw.connect(func(): _draw_frame(root))
	add_child(root)

	# Abas (L1/R1). Cada uma é um DSMenuButton: só texto, clareia ao focar.
	var tabs := HBoxContainer.new()
	tabs.set_anchors_preset(Control.PRESET_CENTER_TOP)
	tabs.offset_left = -220
	tabs.offset_right = 220
	tabs.offset_top = 6
	tabs.offset_bottom = 26
	tabs.alignment = BoxContainer.ALIGNMENT_CENTER
	tabs.add_theme_constant_override("separation", 10)
	root.add_child(tabs)
	var left_hint := UIStyle.label("‹ L1", 8, UIStyle.TEXT_DIM)
	tabs.add_child(left_hint)
	for i in TABS.size():
		var tab := DSMenuButton.make(TABS[i], 10)
		tab.focus_mode = Control.FOCUS_NONE  # aba muda com L1/R1 ou toque, não rouba o foco da grade
		tab.pressed.connect(func(): set_tab(i))
		tabs.add_child(tab)
		_tab_buttons.append(tab)
	tabs.add_child(UIStyle.label("R1 ›", 8, UIStyle.TEXT_DIM))

	# Coluna da esquerda: o que está equipado (como a tela de equipamento do DS3).
	var equip := VBoxContainer.new()
	equip.position = Vector2(14, 40)
	equip.size = Vector2(118, 190)
	equip.add_theme_constant_override("separation", 3)
	root.add_child(equip)
	equip.add_child(UIStyle.label("EQUIPADO", 8, GOLD_LINE.lightened(0.4), UIStyle.TITLE_FONT))
	for key in ["direita", "esquerda", "vida", "sanidade"]:
		var row := Button.new()
		row.flat = true
		row.alignment = HORIZONTAL_ALIGNMENT_LEFT
		row.expand_icon = false
		row.add_theme_constant_override("icon_max_width", 16)
		row.add_theme_font_override("font", UIStyle.FONT)
		row.add_theme_font_size_override("font_size", 8)
		row.add_theme_color_override("font_color", UIStyle.TEXT)
		row.add_theme_color_override("font_focus_color", SLOT_LIT)
		row.add_theme_color_override("font_hover_color", SLOT_LIT)
		for state in ["normal", "hover", "pressed", "focus"]:
			row.add_theme_stylebox_override(state, _slot_style(state == "focus" or state == "hover"))
		row.custom_minimum_size = Vector2(118, 26)
		row.clip_text = true
		var tab_for: int = {"direita": 0, "esquerda": 1, "vida": 2, "sanidade": 2}[key]
		row.pressed.connect(func(): set_tab(tab_for))
		equip.add_child(row)
		_equip_rows[key] = row
	var memories := UIStyle.label("", 8, UIStyle.TEXT_DIM, UIStyle.FONT_NUMBERS)
	memories.name = "Memorias"
	equip.add_child(memories)

	# Centro: a grade de espaços.
	var center := VBoxContainer.new()
	center.position = Vector2(142, 40)
	center.size = Vector2(COLUMNS * (SLOT + 3), 190)
	root.add_child(center)
	_grid = GridContainer.new()
	_grid.columns = COLUMNS
	_grid.add_theme_constant_override("h_separation", 3)
	_grid.add_theme_constant_override("v_separation", 3)
	center.add_child(_grid)
	_empty = UIStyle.label("Nada aqui.", 8, UIStyle.TEXT_DIM)
	center.add_child(_empty)

	# Direita: a ficha do item (Lies of P: nome grande, tipo, números e as letras).
	var detail := VBoxContainer.new()
	detail.position = Vector2(312, 38)
	detail.size = Vector2(156, 196)
	detail.add_theme_constant_override("separation", 2)
	root.add_child(detail)
	_detail_name = UIStyle.label("", 11, SLOT_LIT, UIStyle.TITLE_FONT)
	_detail_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail_name.custom_minimum_size = Vector2(156, 0)
	detail.add_child(_detail_name)
	_detail_kind = UIStyle.label("", 8, UIStyle.TEXT_DIM)
	detail.add_child(_detail_kind)
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 6)
	_detail_icon = TextureRect.new()
	_detail_icon.custom_minimum_size = Vector2(32, 32)
	_detail_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_detail_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_detail_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	head.add_child(_detail_icon)
	_detail_stats = UIStyle.label("", 8, UIStyle.TEXT, UIStyle.FONT_NUMBERS)
	head.add_child(_detail_stats)
	detail.add_child(head)
	_scaling_box = HBoxContainer.new()
	_scaling_box.add_theme_constant_override("separation", 4)
	detail.add_child(_scaling_box)
	_detail_skill = UIStyle.label("", 8, UIStyle.GOLD)
	_detail_skill.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail_skill.custom_minimum_size = Vector2(156, 0)
	detail.add_child(_detail_skill)
	_detail_text = UIStyle.label("", 7, UIStyle.TEXT)
	_detail_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail_text.custom_minimum_size = Vector2(156, 0)
	detail.add_child(_detail_text)

	# Rodapé: legenda dos botões + "Voltar" (no toque é ele que fecha).
	_hint = ButtonHintBar.new()
	_hint.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	_hint.offset_left = 14
	_hint.offset_top = -22
	_hint.offset_right = 360
	_hint.offset_bottom = -6
	root.add_child(_hint)
	_back_button = DSMenuButton.make("Voltar", 10)
	_back_button.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_back_button.offset_left = -90
	_back_button.offset_right = -10
	_back_button.offset_top = -26
	_back_button.offset_bottom = -4
	_back_button.pressed.connect(close)
	root.add_child(_back_button)


## Moldura: linhas douradas finas (cabeçalho, rodapé e divisórias das colunas).
func _draw_frame(canvas: Control) -> void:
	var view := canvas.size
	canvas.draw_line(Vector2(10, 30), Vector2(view.x - 10, 30), GOLD_LINE, 1.0)
	canvas.draw_line(Vector2(10, view.y - 30), Vector2(view.x - 10, view.y - 30), GOLD_LINE, 1.0)
	canvas.draw_line(Vector2(137, 38), Vector2(137, view.y - 38), Color(GOLD_LINE, 0.25), 1.0)
	canvas.draw_line(Vector2(306, 38), Vector2(306, view.y - 38), Color(GOLD_LINE, 0.25), 1.0)
	# Losango no meio da linha de cima (o "ornamento").
	var c := Vector2(view.x * 0.5, 30)
	canvas.draw_colored_polygon(PackedVector2Array([c + Vector2(0, -3), c + Vector2(3, 0), c + Vector2(0, 3), c + Vector2(-3, 0)]), GOLD_LINE.lightened(0.3))


func _slot_style(lit: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = SLOT_BG if not lit else Color(0.16, 0.14, 0.11, 0.95)
	style.border_color = SLOT_LIT if lit else SLOT_EDGE
	style.set_border_width_all(1)
	if lit:
		style.shadow_color = Color(1.0, 0.92, 0.7, 0.25)  # o brilho do espaço escolhido
		style.shadow_size = 3
	style.content_margin_left = 3
	return style


# --- Abrir / fechar ---------------------------------------------------------------------

func open(player: Player) -> void:
	_player = player
	_tab = 0
	_rebuild()
	visible = true
	Sfx.play(&"ui_open")
	_focus_grid()


func close() -> void:
	if not visible:
		return
	visible = false
	Sfx.play(&"ui_click")
	closed.emit()


func set_tab(index: int) -> void:
	_tab = posmod(index, TABS.size())
	Sfx.play(&"ui_click", -4.0)
	_selected = ""
	_rebuild()
	_focus_grid()


func _focus_grid() -> void:
	if not _slots.is_empty():
		_slots[0].grab_focus()
	else:
		_back_button.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed(&"pause") or event.is_action_pressed(&"inventory") or event.is_action_pressed(&"ui_cancel"):
		close()
		get_viewport().set_input_as_handled()
		return
	var direction := _tab_direction(event)
	if direction != 0:
		set_tab(_tab + direction)
		get_viewport().set_input_as_handled()


## L1/R1 no controle; Q/E ou PageUp/PageDown no teclado.
func _tab_direction(event: InputEvent) -> int:
	if event is InputEventJoypadButton and event.pressed:
		match event.button_index:
			JOY_BUTTON_LEFT_SHOULDER:
				return -1
			JOY_BUTTON_RIGHT_SHOULDER:
				return 1
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_Q, KEY_PAGEUP:
				return -1
			KEY_E, KEY_PAGEDOWN:
				return 1
	return 0


# --- Conteúdo ---------------------------------------------------------------------------

## Os itens da aba: [{id, count}]. Os frascos vêm dos contadores próprios.
func entries(tab: int = -1) -> Array[Dictionary]:
	if tab < 0:
		tab = _tab
	var result: Array[Dictionary] = []
	match TABS[tab]:
		"Armas":
			for id in Game.owned_weapons():
				result.append({"id": id, "count": 1})
		"Escudos":
			if Game.has_shield():
				result.append({"id": "escudo_remendado", "count": 1})
		"Frascos":
			result.append({"id": "frasco_vida", "count": _health_flasks()})
			result.append({"id": "frasco_sanidade", "count": Game.sanity_flasks})
		"Materiais":
			result.append_array(_items_of(ItemData.Kind.MATERIAL))
		"Lembranças":
			result.append_array(_items_of(ItemData.Kind.LEMBRANCA))
	return result


func _items_of(kind: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for item_id: String in Items.CATALOG:
		var item := Items.get_item(item_id)
		if item.kind == kind and Game.item_count(item_id) > 0:
			result.append({"id": item_id, "count": Game.item_count(item_id)})
	return result


func _health_flasks() -> int:
	return _player.health_flasks if is_instance_valid(_player) else Game.health_flasks_max


func _rebuild() -> void:
	for i in _tab_buttons.size():
		var on := i == _tab
		_tab_buttons[i].add_theme_color_override("font_color", SLOT_LIT if on else DSMenuButton.DIM)
		_tab_buttons[i].text = ("◆ " if on else "") + TABS[i]
	for child in _grid.get_children():
		_grid.remove_child(child)
		child.queue_free()
	_slots.clear()
	var list := entries()
	for entry in list:
		_grid.add_child(_make_slot(entry))
	_empty.visible = list.is_empty()
	_refresh_equipped()
	_hint.items = _hint_items()
	var keep := _selected
	_selected = ""
	if not list.is_empty():
		var ids := list.map(func(e): return e["id"])
		_select(keep if ids.has(keep) else str(list[0]["id"]))
	else:
		_clear_detail()


func _make_slot(entry: Dictionary) -> Button:
	var item := Items.get_item(entry["id"])
	var slot := Button.new()
	slot.custom_minimum_size = Vector2(SLOT, SLOT)
	slot.icon = item.icon
	slot.expand_icon = true
	slot.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	slot.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	slot.add_theme_constant_override("icon_max_width", 22)
	for state in ["normal", "pressed", "disabled"]:
		slot.add_theme_stylebox_override(state, _slot_style(false))
	for state in ["hover", "focus", "hover_pressed"]:
		slot.add_theme_stylebox_override(state, _slot_style(true))
	var item_id: String = entry["id"]
	slot.focus_entered.connect(func(): _select(item_id))
	slot.mouse_entered.connect(func(): slot.grab_focus())
	slot.pressed.connect(func(): _activate(item_id))
	slot.set_meta("item_id", item_id)
	# Quantidade no canto (DS1) e "E" de equipado (DS3).
	var corner := Control.new()
	corner.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	corner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var count := int(entry["count"])
	var equipped := _is_equipped(item_id)
	corner.draw.connect(func():
		var font := UIStyle.FONT_NUMBERS
		if item.max_stack > 1 or item_id.begins_with("frasco"):
			corner.draw_string_outline(font, Vector2(SLOT - 12, SLOT - 3), str(count), HORIZONTAL_ALIGNMENT_RIGHT, 10, 8, 2, Color.BLACK)
			corner.draw_string(font, Vector2(SLOT - 12, SLOT - 3), str(count), HORIZONTAL_ALIGNMENT_RIGHT, 10, 8, SLOT_LIT)
		if equipped:
			corner.draw_rect(Rect2(2, 2, 7, 7), Color(0.85, 0.7, 0.35))
			corner.draw_string(UIStyle.FONT, Vector2(3, 8), "E", HORIZONTAL_ALIGNMENT_LEFT, -1, 6, Color.BLACK))
	slot.add_child(corner)
	_slots.append(slot)
	return slot


func _is_equipped(item_id: String) -> bool:
	if item_id == Game.equipped_weapon:
		return true
	return item_id == "escudo_remendado" and Game.shield_ready()


func _refresh_equipped() -> void:
	var weapon := Game.current_weapon()
	var right: Button = _equip_rows["direita"]
	right.icon = weapon.icon
	right.text = "%s +%d" % [weapon.display_name, Game.weapon_level]
	var left: Button = _equip_rows["esquerda"]
	left.icon = Items.get_item("escudo_remendado").icon if Game.shield_ready() else null
	left.text = Items.display_name("escudo_remendado") if Game.shield_ready() else "Mão esquerda: vazia"
	var life: Button = _equip_rows["vida"]
	life.icon = Items.get_item("frasco_vida").icon
	life.text = "Frasco de Vida  %d/%d" % [_health_flasks(), Game.health_flasks_max]
	var sanity: Button = _equip_rows["sanidade"]
	sanity.icon = Items.get_item("frasco_sanidade").icon
	sanity.text = "Humanidade  x%d" % Game.sanity_flasks
	var memories := _equip_rows["direita"].get_parent().get_node("Memorias") as Label
	memories.text = "Memórias  %d" % Game.memories


func _hint_items() -> Array:
	var result := []
	if TABS[_tab] == "Armas" or TABS[_tab] == "Escudos":
		result.append(["cross", "Enter", "Equipar"])
	result.append(["circle", "Esc", "Voltar"])
	result.append(["L1/R1", "Q/E", "Categoria"])
	return result


# --- Ficha -----------------------------------------------------------------------------

func _select(item_id: String) -> void:
	if item_id == _selected:
		return
	_selected = item_id
	var item := Items.get_item(item_id)
	if item == null:
		return
	_detail_icon.texture = item.icon
	_detail_name.text = item.display_name
	_detail_text.text = item.description
	for child in _scaling_box.get_children():
		_scaling_box.remove_child(child)  # sai da árvore já (queue_free só apaga no fim do quadro)
		child.queue_free()
	_detail_skill.text = ""
	if item is WeaponData:
		_show_weapon(item as WeaponData)
		return
	_detail_kind.text = ItemData.KIND_NAMES[item.kind]
	match item_id:
		"frasco_vida":
			_detail_stats.text = "%d/%d" % [_health_flasks(), Game.health_flasks_max]
		"frasco_sanidade":
			_detail_stats.text = "x%d" % Game.sanity_flasks
		"escudo_remendado":
			_detail_stats.text = "Equipado" if Game.shield_ready() else "Guardado"
		_:
			_detail_stats.text = "" if item.max_stack == 1 else "x%d" % Game.item_count(item_id)


func _show_weapon(weapon: WeaponData) -> void:
	var level := Game.weapon_level
	_detail_name.text = "%s +%d" % [weapon.display_name, level]
	_detail_kind.text = "%s%s" % [weapon.weapon_class, "  ·  equipada" if weapon.id == Game.equipped_weapon else ""]
	var power := Game.weapon_power(weapon)
	_detail_stats.text = "Ataque  %d / %d\n(leve / forte)" % [power.x, power.y]
	# Tabela de letras: FOR DES MAG FÉ SOR (o "-" é "não escala").
	for attribute in WeaponData.SCALING_ATTRIBUTES:
		var cell := VBoxContainer.new()
		cell.add_theme_constant_override("separation", 0)
		var head := UIStyle.label(WeaponData.ATTRIBUTE_SHORT[attribute], 7, UIStyle.TEXT_DIM)
		head.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		head.custom_minimum_size = Vector2(26, 0)
		cell.add_child(head)
		var letter := weapon.letter(attribute)
		var color := UIStyle.GOLD if letter in ["S", "A"] else (UIStyle.TEXT if letter != "-" else UIStyle.TEXT_DIM)
		var value := UIStyle.label(letter, 10, color, UIStyle.TITLE_FONT)
		value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cell.add_child(value)
		_scaling_box.add_child(cell)
	if not weapon.skill_name.is_empty():
		_detail_skill.text = "%s — %s" % [weapon.skill_name, weapon.skill_text]


func _clear_detail() -> void:
	_selected = ""
	_detail_icon.texture = null
	_detail_name.text = ""
	_detail_kind.text = ""
	_detail_stats.text = ""
	_detail_skill.text = ""
	_detail_text.text = ""
	for child in _scaling_box.get_children():
		_scaling_box.remove_child(child)  # sai da árvore já (queue_free só apaga no fim do quadro)
		child.queue_free()


## Apertar um espaço: armas equipam; o escudo entra/sai da mão esquerda.
func _activate(item_id: String) -> void:
	_select(item_id)
	if Items.get_item(item_id) is WeaponData:
		if Game.equipped_weapon != item_id:
			Game.equip_weapon(item_id)
			Sfx.play(&"shield_up", -4.0)
	elif item_id == "escudo_remendado":
		Game.set_shield_equipped(not Game.shield_ready())
		Sfx.play(&"shield_up", -4.0)
	else:
		return
	_rebuild()
	for slot in _slots:
		if slot.get_meta("item_id") == item_id:
			slot.grab_focus()
