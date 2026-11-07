class_name ArenaShift
extends Node2D
## MARCAS NA ARENA (v0.35, Etapa 6): o que muda na arena quando um chefe entra
## numa fase nova. Um sistema só, configurado por chefe com um dicionário —
## em vez de cada chefe reinventar "a arena pega fogo", "a luz apaga"...
##
##   Boss.phase_arena = {2: {"focos": 12, "focos_a_cada": 1.4, "dps": 12.0}}
##
## Chaves que existem hoje (dá para somar várias no mesmo dicionário):
##   "focos": N        — focos de fogo (FirePatch) nascem espalhados pelo MEIO
##                       da arena; no máximo N ao mesmo tempo. Nasceu um além
##                       do limite: o mais antigo apaga. (Aldir: a praça em chamas.)
##   "focos_a_cada": s — um foco novo a cada s segundos (padrão 1,5).
##   "focos_tipo": "raizes" — os focos são de raízes (dano físico, cor de carne)
##                       em vez de fogo. (Mabel.) Padrão: "fogo".
##   "dps": 12         — dano por segundo de cada foco (padrão 12).
##   "escuro": 0.4     — a luz da arena cai para esta fração (CanvasModulate).
##   "sono": 1.5       — a Barra de Sonolência enche 1,5× mais rápido (Nyssa).
##   "some": "mesas"   — tudo no grupo "mesas" some (as mesas da Mabel).
##   "luz_flores": true — as Flores de Pólen da arena passam a brilhar: no
##                       escuro, é a única luz no chão.
##
## v0.53.1 — A BORDA NÃO É MARCA. Até a v0.53.0 havia um "anel" que tomava a
## borda e crescia para dentro (Aldir e Mabel). Parecia o desabamento da
## Rachel, que é dela e só dela (rachel.gd, crumble()), e pesava muito: centenas
## de círculos redesenhados a cada quadro. Este sistema não mexe na borda.
##
## Quem chama: Boss.shift_arena(fase) — cada chefe, no seu _enter_phase_N.

## Os focos nascem no MEIO: só nos 70% centrais da arena, e nunca a menos de
## EDGE_MARGIN da parede — longe da borda, para não lembrar o desabamento da
## Rachel. Também não nascem embaixo do herói.
const CENTER_SHARE := 0.7
const EDGE_MARGIN := 28.0
const PLAYER_GAP := 36.0
const FOCUS_RADIUS := 14.0
## "Até o fim da luta": o foco só some pelo limite ou quando a luta acaba.
const FOCUS_LIFETIME := 9999.0

var arena := Rect2()
var config := {}
## Os focos vivos, do mais antigo para o mais novo.
var foci: Array[FirePatch] = []
var _focus_left := 0.0


static func apply(parent: Node, arena_rect: Rect2, settings: Dictionary) -> ArenaShift:
	var shift := ArenaShift.new()
	shift.arena = arena_rect
	shift.config = settings
	parent.add_child(shift)
	return shift


func _ready() -> void:
	add_to_group(&"arena_shifts")
	if config.has("escuro"):
		var level := Level.find(self)
		if level:
			var dark := float(config["escuro"])
			create_tween().tween_property(level.canvas_modulate, "color", level.canvas_modulate.color * Color(dark, dark, dark, 1.0), 1.5)
	if focus_limit() > 0:
		Sfx.play(&"fire_breath" if not is_roots() else &"slurp", -4.0)
	if config.has("some"):
		for node in get_tree().get_nodes_in_group(StringName(str(config["some"]))):
			var item := node as CanvasItem
			if item:
				var fade := item.create_tween()
				fade.tween_property(item, "modulate:a", 0.0, 0.8)
				fade.tween_callback(item.queue_free)
	var player := get_tree().get_first_node_in_group("player") as Player
	if player and config.has("sono"):
		player.drowsiness_scale = float(config["sono"])
	if config.get("luz_flores", false):
		_light_flowers()


func _exit_tree() -> void:
	var player := get_tree().get_first_node_in_group("player") as Player
	if player and config.has("sono"):
		player.drowsiness_scale = 1.0
	# A luta acabou (ou a arena foi embora): os focos apagam junto.
	for focus in foci:
		if is_instance_valid(focus):
			focus.queue_free()
	foci.clear()


## As flores acendem (uma luz lilás em cada Flor de Pólen dentro da arena).
func _light_flowers() -> void:
	for node in get_tree().get_nodes_in_group("enemies"):
		if node is FlorDePolen and arena.has_point((node as Node2D).global_position):
			var light := PointLight2D.new()
			light.texture = preload("res://assets/fx/light.png")
			light.color = Color(0.85, 0.7, 1.0)
			light.energy = 0.9
			light.texture_scale = 0.9
			light.position = Vector2(0, -8)
			light.add_to_group(&"flower_lights")
			(node as Node2D).add_child(light)


func is_roots() -> bool:
	return str(config.get("focos_tipo", "fogo")) == "raizes"


func focus_limit() -> int:
	return int(config.get("focos", 0))


func _physics_process(delta: float) -> void:
	if focus_limit() <= 0 or arena.size == Vector2.ZERO:
		return
	_focus_left -= delta
	if _focus_left <= 0.0:
		_focus_left = float(config.get("focos_a_cada", 1.5))
		spawn_focus()


## Onde os focos podem nascer (o miolo da arena).
func focus_area() -> Rect2:
	var margin_x := maxf(EDGE_MARGIN, arena.size.x * (1.0 - CENTER_SHARE) * 0.5)
	var margin_y := maxf(EDGE_MARGIN, arena.size.y * (1.0 - CENTER_SHARE) * 0.5)
	return arena.grow_individual(-margin_x, -margin_y, -margin_x, -margin_y)


## Um foco novo num ponto do meio da arena. Passou do limite: o mais antigo apaga.
func spawn_focus() -> FirePatch:
	var inner := focus_area()
	if inner.size.x <= 0.0 or inner.size.y <= 0.0:
		return null
	var player := get_tree().get_first_node_in_group("player") as Player
	var spot := inner.get_center()
	for attempt in 8:
		spot = inner.position + Vector2(randf() * inner.size.x, randf() * inner.size.y)
		if player == null or spot.distance_to(player.global_position) >= PLAYER_GAP:
			break
	var focus := FirePatch.spawn(get_parent(), spot, FOCUS_RADIUS, FOCUS_LIFETIME, float(config.get("dps", 12.0)))
	if is_roots():
		focus.kind = FirePatch.ROOTS
	foci.append(focus)
	foci = foci.filter(func(f): return is_instance_valid(f))
	while foci.size() > focus_limit():
		var oldest: FirePatch = foci.pop_front()
		if is_instance_valid(oldest):
			oldest.extinguish()
	return focus
