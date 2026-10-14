class_name TouchControls
extends CanvasLayer
## Controles de toque: joystick à esquerda; Ataque, Dash e Interação/Cura à
## direita (como na Bíblia), mais o Frasco de Sanidade.
##
##   Ataque: TOQUE = golpe leve (combo de 3) · SEGURAR = golpe forte
##   Cura: vira "Interagir" perto de NPCs e da Câmara
##   Escudo (só com o Escudo Remendado equipado): SEGURAR = defesa erguida

const ICON_ATTACK := preload("res://assets/ui/icon_attack.png")
const ICON_DASH := preload("res://assets/ui/icon_dash.png")
const ICON_HEAL := preload("res://assets/ui/icon_heal.png")
const ICON_SANITY := preload("res://assets/ui/icon_sanity.png")
const ICON_INTERACT := preload("res://assets/ui/icon_interact.png")
const ICON_BLOCK := preload("res://assets/ui/icon_block.png")

var joystick: TouchJoystick
var attack_button: TouchButton
var dash_button: TouchButton
var heal_button: TouchButton
var sanity_button: TouchButton
var block_button: TouchButton

var _player: Player
var _root: Control


func _ready() -> void:
	layer = 11
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)
	joystick = TouchJoystick.new()
	joystick.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.add_child(joystick)
	attack_button = _make_button(&"attack", ICON_ATTACK, 25.0, "", Color(1.0, 0.85, 0.6))
	dash_button = _make_button(&"dash", ICON_DASH, 18.0, "", Color(0.6, 0.85, 1.0))
	heal_button = _make_button(&"heal", ICON_HEAL, 17.0, "", Color(1.0, 0.5, 0.5))
	sanity_button = _make_button(&"sanity", ICON_SANITY, 13.0, "", Color(0.9, 0.95, 1.0))
	block_button = _make_button(&"block", ICON_BLOCK, 17.0, "", Color(0.75, 0.8, 0.95))
	get_viewport().size_changed.connect(_layout)
	Game.sanity_flasks_changed.connect(func(_c: int): _refresh_sanity())
	Game.vision_changed.connect(func(_v: int): _refresh_sanity())
	Game.items_changed.connect(_refresh_block)
	_layout()
	_refresh_sanity()
	_refresh_block()


func bind_player(player: Player) -> void:
	_player = player
	player.health_flasks_changed.connect(func(current: int, _max: int):
		heal_button.badge = current
		heal_button.queue_redraw())
	player.interact_target_changed.connect(_on_interact_target_changed)
	# Agarrado: o botão de Ataque avisa que é ELE que solta.
	player.grab_changed.connect(func(grabbed: bool, _taps: int):
		attack_button.label_text = "Solte-se!" if grabbed else ""
		attack_button.accent = Color(1.0, 0.55, 0.5) if grabbed else Color(1.0, 0.85, 0.6)
		attack_button.queue_redraw())
	heal_button.badge = player.health_flasks
	heal_button.queue_redraw()


func set_enabled(enabled: bool) -> void:
	visible = enabled
	if not enabled:
		release_all()


## Solta joystick e botões (diálogo abrindo, morte, pausa...).
func release_all() -> void:
	joystick.release()
	for button: TouchButton in [attack_button, dash_button, heal_button, sanity_button, block_button]:
		button.release()


func _make_button(action: StringName, icon: Texture2D, radius: float, label: String, accent: Color) -> TouchButton:
	var button := TouchButton.new()
	button.action = action
	button.icon = icon
	button.radius = radius
	button.label_text = label
	button.accent = accent
	_root.add_child(button)
	return button


## Posições relativas ao canto inferior direito + área segura (entalhe/notch).
func _layout() -> void:
	var view := get_viewport().get_visible_rect().size
	var safe := _safe_margins(view)
	var corner := Vector2(view.x - safe.y, view.y)
	attack_button.place_at(corner + Vector2(-40, -44))
	dash_button.place_at(corner + Vector2(-90, -28))
	heal_button.place_at(corner + Vector2(-82, -84))
	sanity_button.place_at(corner + Vector2(-36, -100))
	block_button.place_at(corner + Vector2(-132, -62))
	joystick.rest_position = Vector2(safe.x + 52, view.y - 52)
	joystick._reset()


## Margens esquerda/direita da área segura, convertidas para coordenadas do jogo.
func _safe_margins(view: Vector2) -> Vector2:
	if not OS.has_feature("mobile"):
		return Vector2(8, 8)
	var window := Vector2(DisplayServer.window_get_size())
	var safe_rect := DisplayServer.get_display_safe_area()
	if window.x <= 0.0 or safe_rect.size.x <= 0:
		return Vector2(8, 8)
	var scale := view.x / window.x
	var left := safe_rect.position.x * scale
	var right := (window.x - safe_rect.end.x) * scale
	return Vector2(maxf(left, 8.0), maxf(right, 8.0))


func _refresh_sanity() -> void:
	sanity_button.badge = Game.sanity_flasks
	sanity_button.dimmed = Game.sanity_flasks <= 0 or Game.vision_loss <= 0
	sanity_button.queue_redraw()


## O botão do escudo só existe com o escudo na mão (botão inútil na tela confunde).
func _refresh_block() -> void:
	var ready := Game.shield_ready()
	if not ready:
		block_button.release()
	block_button.visible = ready


func _on_interact_target_changed(target: Interactable) -> void:
	if target:
		heal_button.icon = ICON_INTERACT
		heal_button.label_text = target.prompt
		heal_button.accent = Color(0.85, 0.95, 1.0)
	else:
		heal_button.icon = ICON_HEAL
		heal_button.label_text = ""
		heal_button.accent = Color(1.0, 0.5, 0.5)
	heal_button.queue_redraw()
