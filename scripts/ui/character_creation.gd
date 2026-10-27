class_name CharacterCreation
extends Control
## Criação de personagem, no estilo da tela de título: fundo preto, texto branco,
## sem caixas. À esquerda o personagem andando (ampliado); à direita as escolhas.
##
## A tela NÃO mexe no save nem no Game: só devolve o dicionário escolhido no
## sinal `confirmed`. Quem decide o que fazer com ele é a tela de título — assim
## esta tela pode ser testada sozinha e reaproveitada (ex.: um "espelho" no jogo).
##
## v0.27: escolhe também a ARMA (uma das comuns). Ela não vem na mão: fica
## largada no chão do Prólogo, perto da cápsula — quem não vê, começa no soco.
## O dicionário devolvido leva a escolha na chave "arma".
## No NG+ (`journey_cycle` > 0) o título muda: é outro experimento acordando.

signal confirmed(look: Dictionary)
signal cancelled

const PREVIEW_SCALE := 5.0

var look := Appearance.default_data()
## Uma das Game.BASIC_WEAPONS.
var weapon := Game.START_WEAPON
## 0 = primeira jornada; 1+ = NG+ (só muda os textos).
var journey_cycle := 0
var _weapon_icon: TextureRect
var _preview: AnimatedSprite2D
var _values := {}  # campo -> Label com o valor atual
var _first_focus: Control
var _walk_timer := 0.0


func _ready() -> void:
	add_to_group(&"pad_menu")  # PadMenus: ✕ confirma e o foco nunca se perde no controle
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build()
	_refresh()
	_first_focus.grab_focus()


func _build() -> void:
	var background := ColorRect.new()
	background.color = Color(0, 0, 0)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var heading := "QUEM DESPERTA?" if journey_cycle <= 0 else "OUTRO EXPERIMENTO DESPERTA"
	var title := UIStyle.label(heading, 16, Color(0.9, 0.88, 0.84), UIStyle.TITLE_FONT)
	title.set_anchors_preset(Control.PRESET_CENTER_TOP)
	title.offset_left = -200
	title.offset_right = 200
	title.offset_top = 18
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(title)
	if journey_cycle > 0:
		var note := UIStyle.label("%s · o mundo está mais duro · o corpo é novo, o nível é herdado" % Game.cycle_label(journey_cycle),
			8, UIStyle.GOLD)
		note.set_anchors_preset(Control.PRESET_CENTER_TOP)
		note.offset_left = -220
		note.offset_right = 220
		note.offset_top = 40
		note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		add_child(note)

	# Prévia: um "palco" com luz fraca embaixo e o personagem andando.
	var stage := Control.new()
	stage.set_anchors_preset(Control.PRESET_CENTER)
	stage.offset_left = -170
	stage.offset_right = -40
	stage.offset_top = -80
	stage.offset_bottom = 90
	stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage.draw.connect(func():
		var c := stage.size * Vector2(0.5, 0.86)
		for i in 6:  # elipses concêntricas = um brilho suave sem textura
			var k := 1.0 - i / 6.0
			stage.draw_set_transform(c, 0.0, Vector2(1.0, 0.28))
			stage.draw_circle(Vector2.ZERO, 58.0 * k, Color(0.9, 0.85, 0.75, 0.025))
		stage.draw_set_transform(Vector2.ZERO))
	add_child(stage)
	_preview = AnimatedSprite2D.new()
	_preview.scale = Vector2.ONE * PREVIEW_SCALE
	_preview.position = Vector2(65, 92)
	_preview.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	stage.add_child(_preview)

	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.offset_left = -10
	box.offset_right = 200
	box.offset_top = -78
	box.offset_bottom = 100
	box.add_theme_constant_override("separation", 2)
	add_child(box)
	var titles := {"sexo": "Sexo", "corpo": "Corpo", "rosto": "Rosto", "cabelo": "Cabelo"}
	for field in Appearance.FIELDS:
		_add_row(box, field, titles[field])
	_add_weapon_row(box)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 8)
	box.add_child(spacer)
	var random := DSMenuButton.make("Aleatório", 11)
	random.pressed.connect(randomize_look)
	box.add_child(random)
	var confirm := DSMenuButton.make("Despertar", 12)
	confirm.pressed.connect(_confirm)
	box.add_child(confirm)
	var back := DSMenuButton.make("Voltar", 11)
	back.pressed.connect(_cancel)
	box.add_child(back)


func _add_row(box: VBoxContainer, field: String, title: String) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	var name_label := UIStyle.label(title, 10, Color(0.8, 0.78, 0.74))
	name_label.custom_minimum_size = Vector2(56, 0)
	row.add_child(name_label)
	var minus := DSMenuButton.make("‹", 14)
	minus.custom_minimum_size = Vector2(24, 0)
	minus.pressed.connect(func(): step(field, -1))
	row.add_child(minus)
	var value := UIStyle.label("", 10, UIStyle.GOLD, UIStyle.TITLE_FONT)
	value.custom_minimum_size = Vector2(96, 0)
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	row.add_child(value)
	var plus := DSMenuButton.make("›", 14)
	plus.custom_minimum_size = Vector2(24, 0)
	plus.pressed.connect(func(): step(field, 1))
	row.add_child(plus)
	box.add_child(row)
	_values[field] = value
	if _first_focus == null:
		_first_focus = plus


## A arma: mesmo ‹ valor › das outras linhas, com o ícone ao lado.
func _add_weapon_row(box: VBoxContainer) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	var name_label := UIStyle.label("Arma", 10, Color(0.8, 0.78, 0.74))
	name_label.custom_minimum_size = Vector2(56, 0)
	row.add_child(name_label)
	var minus := DSMenuButton.make("‹", 14)
	minus.custom_minimum_size = Vector2(24, 0)
	minus.pressed.connect(func(): step_weapon(-1))
	row.add_child(minus)
	var value := UIStyle.label("", 9, UIStyle.GOLD, UIStyle.TITLE_FONT)
	value.custom_minimum_size = Vector2(80, 0)
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	value.clip_text = true
	row.add_child(value)
	_weapon_icon = TextureRect.new()
	_weapon_icon.custom_minimum_size = Vector2(14, 14)
	_weapon_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_weapon_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_weapon_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	row.add_child(_weapon_icon)
	var plus := DSMenuButton.make("›", 14)
	plus.custom_minimum_size = Vector2(24, 0)
	plus.pressed.connect(func(): step_weapon(1))
	row.add_child(plus)
	box.add_child(row)
	_values["arma"] = value
	var hint := UIStyle.label("Ela vai estar no chão, perto de onde você acordar.", 7, UIStyle.TEXT_DIM)
	box.add_child(hint)


func step_weapon(direction: int) -> void:
	var list := Game.BASIC_WEAPONS
	weapon = list[posmod(list.find(weapon) + direction, list.size())]
	Sfx.play(&"ui_click")
	_refresh()


## Avança (+1) ou volta (-1) uma opção, dando a volta no fim da lista.
func step(field: String, direction: int) -> void:
	var count := Appearance.option_count(field, look["sexo"])
	look[field] = posmod(int(look[field]) + direction, count)
	look = Appearance.sanitized(look)
	Sfx.play(&"ui_click")
	_refresh()


func randomize_look() -> void:
	look["sexo"] = randi() % Appearance.SEXES.size()
	for field in ["corpo", "rosto", "cabelo"]:
		look[field] = randi() % Appearance.option_count(field, look["sexo"])
	Sfx.play(&"ui_click")
	_refresh()


func _refresh() -> void:
	for field in Appearance.FIELDS:
		_values[field].text = Appearance.option_name(field, look)
	_preview.sprite_frames = Appearance.sprite_frames(look)
	_preview.play(&"walk")
	var data := Items.get_weapon(weapon)
	_values["arma"].text = data.display_name.replace(" de Cobaia", "")
	_weapon_icon.texture = data.icon


func _process(delta: float) -> void:
	# A cada 3 s o personagem para um instante e vira de lado: dá para ver os
	# dois perfis (o jogo espelha o sprite quando se anda para a esquerda).
	_walk_timer += delta
	if _walk_timer > 3.0:
		_walk_timer = 0.0
		_preview.flip_h = not _preview.flip_h


func _confirm() -> void:
	Sfx.play(&"ui_open")
	var choice := look.duplicate()
	choice["arma"] = weapon
	confirmed.emit(choice)


func _cancel() -> void:
	Sfx.play(&"ui_click")
	cancelled.emit()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		_cancel()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST and is_visible_in_tree():
		_cancel()
