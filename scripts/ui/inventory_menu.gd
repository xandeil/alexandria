class_name InventoryMenu
extends CanvasLayer
## Inventário (Bíblia, Sistema 7): o que o herói carrega, com o texto de cada
## coisa — boa parte da lore do jogo mora nessas descrições.
##
## Esquerda: lista (agrupada por tipo). Direita: o item selecionado.
## Funciona no toque (tocar no item), no teclado e no controle (o FOCO do
## botão escolhe o item — por isso focus_entered e não só pressed).

signal closed

var _player: Player
var _list: VBoxContainer
var _scroll: ScrollContainer
var _detail_icon: TextureRect
var _detail_name: Label
var _detail_count: Label
var _detail_text: Label
var _hands: Label
var _action_button: Button
var _close_button: Button
var _selected := ""
var _buttons: Array[Button] = []


func _ready() -> void:
	layer = 31  # por cima da pausa
	process_mode = Node.PROCESS_MODE_ALWAYS
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.7)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UIStyle.panel_style())
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -200
	panel.offset_right = 200
	panel.offset_top = -115
	panel.offset_bottom = 115
	add_child(panel)
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 4)
	panel.add_child(root)
	var title := UIStyle.label("Inventário", 12, UIStyle.GOLD, UIStyle.TITLE_FONT)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(title)
	_hands = UIStyle.label("", 8, UIStyle.TEXT_DIM)
	_hands.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(_hands)
	var body := HBoxContainer.new()
	body.add_theme_constant_override("separation", 8)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(body)
	_scroll = ScrollContainer.new()
	_scroll.custom_minimum_size = Vector2(170, 0)
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(_scroll)
	_list = VBoxContainer.new()
	_list.add_theme_constant_override("separation", 2)
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scroll.add_child(_list)
	var detail := VBoxContainer.new()
	detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail.add_theme_constant_override("separation", 3)
	body.add_child(detail)
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 6)
	_detail_icon = _make_icon(32)
	header.add_child(_detail_icon)
	var names := VBoxContainer.new()
	_detail_name = UIStyle.label("", 10, UIStyle.GOLD, UIStyle.FONT_BOLD)
	_detail_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail_name.custom_minimum_size = Vector2(150, 0)
	names.add_child(_detail_name)
	_detail_count = UIStyle.label("", 9, UIStyle.TEXT_DIM, UIStyle.FONT_NUMBERS)
	names.add_child(_detail_count)
	header.add_child(names)
	detail.add_child(header)
	_detail_text = UIStyle.label("", 8, UIStyle.TEXT)
	_detail_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail_text.custom_minimum_size = Vector2(196, 0)
	_detail_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	detail.add_child(_detail_text)
	_action_button = UIStyle.button("", 9)
	_action_button.pressed.connect(_on_action)
	detail.add_child(_action_button)
	_close_button = UIStyle.button("Fechar", 10)
	_close_button.pressed.connect(close)
	root.add_child(_close_button)
	Game.items_changed.connect(func():
		if visible:
			_rebuild())
	visible = false


func open(player: Player) -> void:
	_player = player
	_rebuild()
	visible = true
	Sfx.play(&"ui_open")
	UIStyle.focus_first(_buttons, _close_button)


func close() -> void:
	if not visible:
		return
	visible = false
	Sfx.play(&"ui_click")
	closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed(&"pause") or event.is_action_pressed(&"inventory") or event.is_action_pressed(&"ui_cancel"):
		close()
		get_viewport().set_input_as_handled()


# --- Conteúdo ---------------------------------------------------------------------------

## Linhas do inventário, já agrupadas: [{id, count, text}]. Os frascos vêm dos
## contadores próprios (não do dicionário) — o jogador não precisa saber disso.
func entries() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	result.append({"id": "espada", "count": 1, "text": "%s +%d" % [Items.display_name("espada"), Game.weapon_level]})
	if Game.has_shield():
		result.append({"id": "escudo_remendado", "count": 1, "text": Items.display_name("escudo_remendado")})
	var flasks := _player.health_flasks if is_instance_valid(_player) else Game.health_flasks_max
	result.append({"id": "frasco_vida", "count": flasks, "text": "%s  %d/%d" % [Items.display_name("frasco_vida"), flasks, Game.health_flasks_max]})
	result.append({"id": "frasco_sanidade", "count": Game.sanity_flasks, "text": "%s  x%d" % [Items.display_name("frasco_sanidade"), Game.sanity_flasks]})
	for kind in [ItemData.Kind.MATERIAL, ItemData.Kind.LEMBRANCA]:
		for item_id: String in Items.CATALOG:
			var item := Items.get_item(item_id)
			if item.kind != kind or Game.item_count(item_id) <= 0:
				continue
			var count := Game.item_count(item_id)
			var text := item.display_name if item.max_stack == 1 else "%s  x%d" % [item.display_name, count]
			result.append({"id": item_id, "count": count, "text": text})
	return result


func _rebuild() -> void:
	for child in _list.get_children():
		child.queue_free()
	_buttons.clear()
	var last_kind := -1
	var first := ""
	for entry in entries():
		var item := Items.get_item(entry["id"])
		if item.kind != last_kind:
			last_kind = item.kind
			var section := UIStyle.label(ItemData.KIND_NAMES[item.kind], 8, UIStyle.TEXT_DIM)
			_list.add_child(section)
		var button := UIStyle.button(entry["text"], 9)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.icon = item.icon
		button.expand_icon = false
		button.custom_minimum_size = Vector2(0, 20)
		button.add_theme_constant_override("icon_max_width", 14)
		var item_id: String = entry["id"]
		button.focus_entered.connect(func(): _select(item_id))
		button.pressed.connect(func(): _select(item_id))
		_list.add_child(button)
		_buttons.append(button)
		if first.is_empty():
			first = item_id
	_hands.text = "Mão direita: %s +%d   ·   Mão esquerda: %s" % [
		Items.display_name("espada"), Game.weapon_level,
		Items.display_name("escudo_remendado") if Game.shield_ready() else "vazia"]
	_select(_selected if _has_entry(_selected) else first)


func _has_entry(item_id: String) -> bool:
	for entry in entries():
		if entry["id"] == item_id:
			return true
	return false


func _select(item_id: String) -> void:
	_selected = item_id
	var item := Items.get_item(item_id)
	if item == null:
		return
	_detail_icon.texture = item.icon
	_detail_name.text = item.display_name if item_id != "espada" else "%s +%d" % [item.display_name, Game.weapon_level]
	_detail_text.text = item.description
	match item_id:
		"espada":
			_detail_count.text = "Dano +%d%%" % int(round((Game.weapon_damage_multiplier() - 1.0) * 100.0))
		"frasco_vida":
			_detail_count.text = "%d/%d" % [_player.health_flasks if is_instance_valid(_player) else 0, Game.health_flasks_max]
		"frasco_sanidade":
			_detail_count.text = "x%d" % Game.sanity_flasks
		_:
			_detail_count.text = "" if item.max_stack == 1 else "x%d" % Game.item_count(item_id)
	# Só o escudo tem ação (equipar/guardar). O resto é para ler.
	_action_button.visible = item_id == "escudo_remendado"
	_action_button.text = "Guardar o escudo" if Game.shield_ready() else "Equipar na mão esquerda"


func _on_action() -> void:
	if _selected == "escudo_remendado":
		Game.set_shield_equipped(not Game.shield_ready())
		Sfx.play(&"shield_up", -4.0)
		_action_button.grab_focus()


func _make_icon(size: int) -> TextureRect:
	var rect := TextureRect.new()
	rect.custom_minimum_size = Vector2(size, size)
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	return rect
