class_name RestMenu
extends CanvasLayer
## Menu da Câmara (descanso), no espírito da fogueira dos soulslike:
##   esquerda — o herói DESCENDO na cápsula (desenhado com as peças do jogo:
##              a cápsula aberta, o sprite da aparência dele e a tampa fechando);
##   direita  — as Câmaras já desbloqueadas, cada uma com a miniatura da região.
##              Escolher uma = viajar até ela.
##
## O menu não sabe viajar: `run()` devolve a cena escolhida ("" = Levantar) e
## quem chamou (a fase) faz a viagem. Mesmo padrão do Ferreiro e da criação.

signal _picked(scene_path: String)

const CAPSULE_OPEN := preload("res://assets/props/capsule_empty.png")
const CAPSULE_CLOSED := preload("res://assets/props/capsule_occupied.png")
const SCALE := 5.0
## Tempo da descida e da tampa fechando.
const DESCEND_TIME := 1.3
const LID_TIME := 0.5

var _here := ""
var _stage: Control
var _capsule: TextureRect
var _hero_clip: Control
var _hero: AnimatedSprite2D
var _grid: GridContainer
var _leave_button: Button
var _place: Label
var _time := 0.0


func _ready() -> void:
	add_to_group(&"pad_menu")  # PadMenus: ✕ confirma e o foco nunca se perde no controle
	layer = 22
	process_mode = Node.PROCESS_MODE_ALWAYS
	var dim := ColorRect.new()
	dim.color = Color(0.0, 0.0, 0.0, 0.88)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	_build_stage()
	_build_travel()
	visible = false


# --- Esquerda: a descida -----------------------------------------------------------------

func _build_stage() -> void:
	_stage = Control.new()
	_stage.position = Vector2(26, 38)
	_stage.size = Vector2(190, 200)
	_stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.draw.connect(_draw_glow)
	add_child(_stage)
	_capsule = TextureRect.new()
	_capsule.texture = CAPSULE_OPEN
	_capsule.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_capsule.stretch_mode = TextureRect.STRETCH_SCALE
	_capsule.size = CAPSULE_OPEN.get_size() * SCALE
	_capsule.position = Vector2((_stage.size.x - _capsule.size.x) * 0.5, 80)
	_stage.add_child(_capsule)
	# O herói fica dentro de um "recorte": tudo que desce abaixo da borda da
	# cápsula some — é isso que dá a impressão de ele estar ENTRANDO nela.
	_hero_clip = Control.new()
	_hero_clip.clip_contents = true
	_hero_clip.position = Vector2(0, 0)
	_hero_clip.size = Vector2(_stage.size.x, _capsule.position.y + 11 * SCALE)
	_hero_clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(_hero_clip)
	_hero = AnimatedSprite2D.new()
	_hero.scale = Vector2.ONE * 4.0
	_hero.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_hero_clip.add_child(_hero)
	var title := UIStyle.label("DESCANSO", 14, Color(0.92, 0.9, 0.85), UIStyle.TITLE_FONT)
	title.position = Vector2(26, 10)
	add_child(title)
	_place = UIStyle.label("", 8, UIStyle.TEXT_DIM)
	_place.position = Vector2(28, 30)
	add_child(_place)


func _draw_glow() -> void:
	var center := _capsule.position + _capsule.size * Vector2(0.5, 0.75)
	_stage.draw_set_transform(center, 0.0, Vector2(1.0, 0.35))
	var pulse := 0.8 + 0.2 * sin(_time * 1.6)
	for i in 6:
		_stage.draw_circle(Vector2.ZERO, 95.0 * (1.0 - i / 6.0), Color(0.4, 0.86, 0.53, 0.035 * pulse))
	_stage.draw_set_transform(Vector2.ZERO)


## A animação: o herói desce, some dentro da cápsula e a tampa fecha.
func _play_descent() -> void:
	_capsule.texture = CAPSULE_OPEN
	_capsule.modulate = Color.WHITE
	_hero.sprite_frames = Appearance.sprite_frames(Game.appearance)
	_hero.play(&"idle")
	var top := Vector2(_stage.size.x * 0.5, _capsule.position.y - 12)
	var inside := Vector2(_stage.size.x * 0.5, _capsule.position.y + 22 * SCALE)
	_hero.position = top
	_hero.modulate = Color.WHITE
	var tween := create_tween()
	tween.tween_property(_hero, "position", inside, DESCEND_TIME).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(_hero, "modulate", Color(0.75, 1.0, 0.85), DESCEND_TIME)
	tween.tween_callback(func():
		_capsule.texture = CAPSULE_CLOSED  # a tampa fecha: agora ele está lá dentro
		Sfx.play(&"capsule_open", -8.0))
	tween.tween_property(_capsule, "modulate", Color(1.15, 1.25, 1.15), LID_TIME * 0.5)
	tween.tween_property(_capsule, "modulate", Color.WHITE, LID_TIME * 0.5)


# --- Direita: viajar ---------------------------------------------------------------------

func _build_travel() -> void:
	var box := VBoxContainer.new()
	box.position = Vector2(236, 30)
	box.size = Vector2(230, 230)
	box.add_theme_constant_override("separation", 4)
	add_child(box)
	box.add_child(UIStyle.label("VIAJAR PARA", 9, Color(0.75, 0.68, 0.5), UIStyle.TITLE_FONT))
	_grid = GridContainer.new()
	_grid.columns = 3
	_grid.add_theme_constant_override("h_separation", 6)
	_grid.add_theme_constant_override("v_separation", 4)
	box.add_child(_grid)
	_leave_button = DSMenuButton.make("Levantar", 11)
	_leave_button.pressed.connect(func():
		Sfx.play(&"ui_click")
		_picked.emit(""))
	box.add_child(_leave_button)


func _rebuild_travel() -> void:
	for child in _grid.get_children():
		_grid.remove_child(child)
		child.queue_free()
	for info in Game.unlocked_capsules():
		_grid.add_child(_make_card(info))


## Um "cartão" de Câmara: miniatura + nome. A Câmara em que você está fica marcada.
func _make_card(info: Dictionary) -> Button:
	var scene_path: String = info["scene"]
	var here := scene_path == _here
	var card := Button.new()
	card.custom_minimum_size = Vector2(70, 62)
	card.icon = load("res://assets/ui/capsula_%s.png" % info["thumb"])
	card.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	card.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
	card.expand_icon = false
	card.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	card.text = "Você está aqui" if here else str(info["name"])
	card.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	card.add_theme_font_override("font", UIStyle.FONT)
	card.add_theme_font_size_override("font_size", 7)
	card.add_theme_color_override("font_color", UIStyle.TEXT_DIM if here else UIStyle.TEXT)
	card.add_theme_color_override("font_focus_color", Color(0.98, 0.94, 0.82))
	card.add_theme_color_override("font_hover_color", Color(0.98, 0.94, 0.82))
	card.add_theme_color_override("font_disabled_color", Color(0.55, 0.85, 0.6))
	for state in ["normal", "pressed", "disabled"]:
		card.add_theme_stylebox_override(state, _card_style(false))
	for state in ["hover", "focus", "hover_pressed"]:
		card.add_theme_stylebox_override(state, _card_style(true))
	card.disabled = here  # já está aqui: não viaja para o mesmo lugar
	card.set_meta("scene", scene_path)
	card.mouse_entered.connect(func():
		if not card.disabled:
			card.grab_focus())
	card.pressed.connect(func():
		Sfx.play(&"ui_open")
		_picked.emit(scene_path))
	return card


func _card_style(lit: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.06, 0.06, 0.9) if not lit else Color(0.15, 0.14, 0.11, 0.95)
	style.border_color = Color(0.98, 0.94, 0.82) if lit else Color(0.28, 0.26, 0.22)
	style.set_border_width_all(1)
	if lit:
		style.shadow_color = Color(1.0, 0.92, 0.7, 0.25)
		style.shadow_size = 3
	style.content_margin_top = 3
	style.content_margin_left = 2
	style.content_margin_right = 2
	return style


# --- Abrir --------------------------------------------------------------------------------

## Mostra o menu e espera a escolha: a cena para onde viajar, ou "" (Levantar).
func run(here_scene: String) -> String:
	_here = here_scene
	var info := Game.capsule_info(here_scene)
	_place.text = str(info.get("name", ""))
	_rebuild_travel()
	visible = true
	_time = 0.0
	_play_descent()
	_leave_button.grab_focus()
	var picked: String = await _picked
	visible = false
	return picked


func cards() -> Array[Button]:
	var result: Array[Button] = []
	for child in _grid.get_children():
		result.append(child as Button)
	return result


func _process(delta: float) -> void:
	if visible:
		_time += delta
		_stage.queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed(&"ui_cancel"):  # ○ = Levantar
		get_viewport().set_input_as_handled()
		Sfx.play(&"ui_click")
		_picked.emit("")


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST and visible:
		_picked.emit("")
