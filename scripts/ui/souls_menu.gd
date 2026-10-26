class_name SoulsMenu
extends CanvasLayer
## Base dos menus "de balcão" (Loja do Vendedor e Forja do Ferreiro), no mesmo
## estilo do inventário: cabeçalho com o RETRATO de quem atende, abas (L1/R1),
## grade de espaços com ícones, ficha à direita e a legenda dos botões.
##
## Por que uma classe base? Os dois menus têm o MESMO esqueleto e só mudam o
## conteúdo e a cor. Sem a base, seriam ~200 linhas copiadas duas vezes — e
## todo ajuste de layout teria que ser feito em dois lugares (DRY: "Don't
## Repeat Yourself"). Cada filho só sobrescreve os ganchos:
##   _tabs()            — nomes das abas
##   _entries(tab)      — o que aparece na grade: [{id, icon, corner, dim}]
##   _show_detail(id)   — preenche a ficha
##   _activate(id)      — ✕ num espaço (comprar, vender, forjar...)
##   _hint_items()      — a legenda do rodapé

signal _closed

const SLOT := 30
const COLUMNS := 5
const LIT := Color(0.98, 0.94, 0.82)
const SLOT_BG := Color(0.07, 0.065, 0.06, 0.95)
const SLOT_EDGE := Color(0.3, 0.27, 0.22)

## Cor de destaque de cada balcão (o Vendedor é brasa; o Ferreiro, ferro quente).
var accent := Color(0.62, 0.52, 0.32)
var keeper_name := ""
var keeper_line := ""
var portrait_texture: Texture2D
## Quantos quadros o sprite do retrato tem (usa o primeiro).
var portrait_frames := 2

var _tab := 0
var _tab_buttons: Array[Button] = []
var _grid: GridContainer
var _slots: Array[Button] = []
var _empty: Label
var _selected := ""
var _memories: Label
var _line: Label
var _hint: ButtonHintBar
var _close_button: Button

# Ficha (a mesma anatomia da ficha do inventário).
var detail_name: Label
var detail_kind: Label
var detail_icon: TextureRect
var detail_stats: Label
var detail_extra: VBoxContainer
var detail_text: Label
var detail_status: Label


func _ready() -> void:
	add_to_group(&"pad_menu")  # PadMenus: ✕ confirma e o foco nunca se perde no controle
	layer = 30
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build()
	visible = false


# --- Montagem -------------------------------------------------------------------------------

func _build() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.97)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.draw.connect(func(): _draw_frame(root))
	add_child(root)

	# Cabeçalho: retrato + nome + uma fala; memórias à direita.
	var portrait := TextureRect.new()
	if portrait_texture:
		var atlas := AtlasTexture.new()
		atlas.atlas = portrait_texture
		var frame_w := portrait_texture.get_width() / maxi(portrait_frames, 1)
		atlas.region = Rect2(0, 0, frame_w, portrait_texture.get_height())
		portrait.texture = atlas
	portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.position = Vector2(12, 4)
	portrait.size = Vector2(44, 44)
	root.add_child(portrait)
	var name_label := UIStyle.label(keeper_name.to_upper(), 12, LIT, UIStyle.TITLE_FONT)
	name_label.position = Vector2(60, 6)
	root.add_child(name_label)
	_line = UIStyle.label(keeper_line, 7, accent.lightened(0.35))
	_line.position = Vector2(61, 26)
	_line.size = Vector2(250, 16)
	_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(_line)
	_memories = UIStyle.label("", 9, LIT, UIStyle.FONT_NUMBERS)
	_memories.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_memories.offset_left = -150
	_memories.offset_right = -14
	_memories.offset_top = 10
	_memories.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	root.add_child(_memories)

	# Abas.
	var tabs := HBoxContainer.new()
	tabs.position = Vector2(14, 50)
	tabs.size = Vector2(290, 16)
	tabs.add_theme_constant_override("separation", 10)
	root.add_child(tabs)
	tabs.add_child(UIStyle.label("‹ L1", 7, UIStyle.TEXT_DIM))
	var names := _tabs()
	for i in names.size():
		var tab := DSMenuButton.make(names[i], 10)
		tab.focus_mode = Control.FOCUS_NONE  # aba muda com L1/R1 ou toque
		tab.custom_minimum_size = Vector2(0, 16)
		tab.pressed.connect(func(): set_tab(i))
		tabs.add_child(tab)
		_tab_buttons.append(tab)
	tabs.add_child(UIStyle.label("R1 ›", 7, UIStyle.TEXT_DIM))

	# Grade.
	var center := VBoxContainer.new()
	center.position = Vector2(14, 74)
	center.size = Vector2(COLUMNS * (SLOT + 3), 160)
	root.add_child(center)
	_grid = GridContainer.new()
	_grid.columns = COLUMNS
	_grid.add_theme_constant_override("h_separation", 3)
	_grid.add_theme_constant_override("v_separation", 3)
	center.add_child(_grid)
	_empty = UIStyle.label("Nada aqui.", 8, UIStyle.TEXT_DIM)
	center.add_child(_empty)

	# Ficha.
	var detail := VBoxContainer.new()
	detail.position = Vector2(196, 70)
	detail.size = Vector2(272, 164)
	detail.add_theme_constant_override("separation", 2)
	root.add_child(detail)
	detail_name = UIStyle.label("", 11, LIT, UIStyle.TITLE_FONT)
	detail_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_name.custom_minimum_size = Vector2(272, 0)
	detail.add_child(detail_name)
	detail_kind = UIStyle.label("", 8, UIStyle.TEXT_DIM)
	detail.add_child(detail_kind)
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 8)
	detail_icon = TextureRect.new()
	detail_icon.custom_minimum_size = Vector2(32, 32)
	detail_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	detail_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	detail_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	head.add_child(detail_icon)
	detail_stats = UIStyle.label("", 8, UIStyle.TEXT, UIStyle.FONT_NUMBERS)
	head.add_child(detail_stats)
	detail.add_child(head)
	detail_extra = VBoxContainer.new()
	detail_extra.add_theme_constant_override("separation", 1)
	detail.add_child(detail_extra)
	detail_text = UIStyle.label("", 7, UIStyle.TEXT)
	detail_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_text.custom_minimum_size = Vector2(272, 0)
	detail.add_child(detail_text)
	detail_status = UIStyle.label("", 8, accent.lightened(0.4))
	detail_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_status.custom_minimum_size = Vector2(272, 0)
	detail.add_child(detail_status)

	# Rodapé.
	_hint = ButtonHintBar.new()
	_hint.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	_hint.offset_left = 14
	_hint.offset_top = -22
	_hint.offset_right = 380
	_hint.offset_bottom = -6
	root.add_child(_hint)
	_close_button = DSMenuButton.make("Sair", 10)
	_close_button.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_close_button.offset_left = -80
	_close_button.offset_right = -10
	_close_button.offset_top = -26
	_close_button.offset_bottom = -4
	_close_button.pressed.connect(close)
	root.add_child(_close_button)


func _draw_frame(canvas: Control) -> void:
	var view := canvas.size
	var line := Color(accent, 0.6)
	canvas.draw_line(Vector2(10, 46), Vector2(view.x - 10, 46), line, 1.0)
	canvas.draw_line(Vector2(10, 68), Vector2(view.x - 10, 68), Color(line, 0.3), 1.0)
	canvas.draw_line(Vector2(10, view.y - 30), Vector2(view.x - 10, view.y - 30), line, 1.0)
	canvas.draw_line(Vector2(188, 74), Vector2(188, view.y - 38), Color(line, 0.3), 1.0)
	var c := Vector2(view.x * 0.5, 46)
	canvas.draw_colored_polygon(PackedVector2Array([c + Vector2(0, -3), c + Vector2(3, 0), c + Vector2(0, 3), c + Vector2(-3, 0)]), accent.lightened(0.3))


func slot_style(lit: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = SLOT_BG if not lit else Color(0.16, 0.14, 0.11, 0.95)
	style.border_color = LIT if lit else SLOT_EDGE
	style.set_border_width_all(1)
	if lit:
		style.shadow_color = Color(accent.lightened(0.4), 0.3)
		style.shadow_size = 3
	return style


# --- Abrir / fechar / abas ------------------------------------------------------------------

## Abre e espera fechar (como o run() antigo do Ferreiro: a fase faz await).
func run(_player: Player = null) -> void:
	_tab = 0
	_selected = ""
	visible = true
	Sfx.play(&"ui_open")
	refresh()
	_focus_grid()
	await _closed
	visible = false


func close() -> void:
	if not visible:
		return
	Sfx.play(&"ui_click")
	_closed.emit()


func set_tab(index: int) -> void:
	_tab = posmod(index, _tabs().size())
	_selected = ""
	Sfx.play(&"ui_click", -4.0)
	refresh()
	_focus_grid()


func _focus_grid() -> void:
	if not _slots.is_empty():
		_slots[0].grab_focus()
	else:
		_close_button.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed(&"ui_cancel") or event.is_action_pressed(&"pause"):
		get_viewport().set_input_as_handled()
		close()
		return
	var direction := 0
	if event is InputEventJoypadButton and event.pressed:
		if event.button_index == JOY_BUTTON_LEFT_SHOULDER:
			direction = -1
		elif event.button_index == JOY_BUTTON_RIGHT_SHOULDER:
			direction = 1
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode in [KEY_Q, KEY_PAGEUP]:
			direction = -1
		elif event.keycode in [KEY_E, KEY_PAGEDOWN]:
			direction = 1
	if direction != 0:
		get_viewport().set_input_as_handled()
		set_tab(_tab + direction)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST and visible:
		close()


# --- Conteúdo -------------------------------------------------------------------------------

## Reconstrói a grade e a ficha (chame depois de comprar/vender/forjar).
func refresh() -> void:
	for i in _tab_buttons.size():
		var on := i == _tab
		_tab_buttons[i].add_theme_color_override("font_color", LIT if on else DSMenuButton.DIM)
		_tab_buttons[i].text = ("◆ " if on else "") + _tabs()[i]
	_memories.text = "Memórias  %d" % Game.memories
	var keep := _selected
	for child in _grid.get_children():
		_grid.remove_child(child)
		child.queue_free()
	_slots.clear()
	var list := _entries(_tab)
	for entry in list:
		_grid.add_child(_make_slot(entry))
	_empty.visible = list.is_empty()
	_hint.items = _hint_items()
	_selected = ""
	if list.is_empty():
		_clear_detail()
		return
	var ids := list.map(func(e): return e["id"])
	select(keep if ids.has(keep) else str(list[0]["id"]))


func _make_slot(entry: Dictionary) -> Button:
	var slot := Button.new()
	slot.custom_minimum_size = Vector2(SLOT, SLOT)
	slot.icon = entry.get("icon")
	slot.expand_icon = true
	slot.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	slot.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	slot.add_theme_constant_override("icon_max_width", 22)
	for state in ["normal", "pressed", "disabled"]:
		slot.add_theme_stylebox_override(state, slot_style(false))
	for state in ["hover", "focus", "hover_pressed"]:
		slot.add_theme_stylebox_override(state, slot_style(true))
	if entry.get("dim", false):
		slot.modulate = Color(0.45, 0.45, 0.45)
	var id: String = entry["id"]
	slot.set_meta("id", id)
	slot.focus_entered.connect(func(): select(id))
	slot.mouse_entered.connect(func(): slot.grab_focus())
	slot.pressed.connect(func():
		select(id)
		_activate(id))
	var corner_text := str(entry.get("corner", ""))
	if not corner_text.is_empty():
		var corner := Control.new()
		corner.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		corner.mouse_filter = Control.MOUSE_FILTER_IGNORE
		corner.draw.connect(func():
			var font := UIStyle.FONT_NUMBERS
			corner.draw_string_outline(font, Vector2(1, SLOT - 2), corner_text, HORIZONTAL_ALIGNMENT_RIGHT, SLOT - 3, 7, 2, Color.BLACK)
			corner.draw_string(font, Vector2(1, SLOT - 2), corner_text, HORIZONTAL_ALIGNMENT_RIGHT, SLOT - 3, 7, LIT))
		slot.add_child(corner)
	_slots.append(slot)
	return slot


func select(id: String) -> void:
	if id == _selected:
		return
	_selected = id
	for child in detail_extra.get_children():
		detail_extra.remove_child(child)
		child.queue_free()
	detail_status.text = ""
	_show_detail(id)


func selected() -> String:
	return _selected


func _clear_detail() -> void:
	_selected = ""
	detail_icon.texture = null
	for label in [detail_name, detail_kind, detail_stats, detail_text, detail_status]:
		(label as Label).text = ""
	for child in detail_extra.get_children():
		detail_extra.remove_child(child)
		child.queue_free()


## Tabela de letras FOR DES MAG FÉ SOR (a mesma do inventário).
func add_scaling_table(weapon: WeaponData) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
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
		row.add_child(cell)
	detail_extra.add_child(row)


## Uma linha "ícone + texto" na ficha (custos: sucata, Lembrança...).
func add_cost_line(icon: Texture2D, text: String, ok: bool) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	var picture := TextureRect.new()
	picture.texture = icon
	picture.custom_minimum_size = Vector2(12, 12)
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	picture.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	row.add_child(picture)
	row.add_child(UIStyle.label(text, 8, UIStyle.TEXT if ok else Color(0.95, 0.55, 0.5)))
	detail_extra.add_child(row)


## Resposta visual a uma compra/forja: o espaço pisca na cor do balcão.
func flash_slot(id: String) -> void:
	for slot in _slots:
		if slot.get_meta("id") == id:
			slot.modulate = Color(2.0, 1.7, 1.2)
			create_tween().tween_property(slot, "modulate", Color.WHITE, 0.4)
			slot.grab_focus()


# --- Ganchos (cada balcão sobrescreve) --------------------------------------------------------

func _tabs() -> Array[String]:
	return ["Itens"]


func _entries(_tab_index: int) -> Array[Dictionary]:
	return []


func _show_detail(_id: String) -> void:
	pass


func _activate(_id: String) -> void:
	pass


func _hint_items() -> Array:
	return [["cross", "Enter", "Escolher"], ["circle", "Esc", "Sair"], ["L1/R1", "Q/E", "Aba"]]
