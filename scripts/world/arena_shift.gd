class_name ArenaShift
extends Node2D
## MARCAS NA ARENA (v0.35, Etapa 6): o que muda na arena quando um chefe entra
## numa fase nova. Um sistema só, configurado por chefe com um dicionário —
## em vez de cada chefe reinventar "a arena pega fogo", "a luz apaga"...
##
##   Boss.phase_arena = {2: {"fogo_borda": 2, "cresce": 12.0, "max": 4}}
##
## Chaves que existem hoje (dá para somar várias no mesmo dicionário):
##   "fogo_borda": N   — um anel de fogo de N tiles nas bordas da arena: quem
##                       fica nele queima (dano de fogo, a armadura conta).
##                       A arena "encolhe" sem tirar chão do mapa.
##   "cresce": s       — a cada s segundos, o anel avança 1 tile...
##   "max": N          — ...até no máximo N tiles.
##   "escuro": 0.4     — a luz da arena cai para esta fração (CanvasModulate).
##   "dps": 14         — dano por segundo do fogo (padrão 12).
##   "sono": 1.5       — a Barra de Sonolência enche 1,5× mais rápido (Nyssa).
##   "borda": "raizes" — o anel da borda é de raízes (dano físico, cor de
##                       carne) em vez de fogo. Padrão: "fogo".
##   "some": "mesas"   — tudo no grupo "mesas" some (as mesas da Mabel).
##   "luz_flores": true — as Flores de Pólen da arena passam a brilhar: no
##                       escuro, é a única luz no chão.
##
## Quem chama: Boss.shift_arena(fase) — cada chefe, no seu _enter_phase_N.

const TILE := 16
const TICK := 0.5

var arena := Rect2()
var config := {}
var border_tiles := 0.0
var _grow_left := 0.0
var _tick := 0.0
var _time := 0.0


static func apply(parent: Node, arena_rect: Rect2, settings: Dictionary) -> ArenaShift:
	var shift := ArenaShift.new()
	shift.arena = arena_rect
	shift.config = settings
	parent.add_child(shift)
	return shift


func _ready() -> void:
	add_to_group(&"arena_shifts")
	top_level = true  # desenha em coordenadas do mundo
	global_position = Vector2.ZERO
	z_index = -8
	material = Fx.unshaded
	border_tiles = float(config.get("fogo_borda", 0))
	_grow_left = float(config.get("cresce", 0.0))
	if config.has("escuro"):
		var level := Level.find(self)
		if level:
			var dark := float(config["escuro"])
			create_tween().tween_property(level.canvas_modulate, "color", level.canvas_modulate.color * Color(dark, dark, dark, 1.0), 1.5)
	if border_tiles > 0.0:
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
	return str(config.get("borda", "fogo")) == "raizes"


## A área ainda segura (fora do anel de fogo).
func safe_rect() -> Rect2:
	return arena.grow(-border_tiles * TILE)


func burns(point: Vector2) -> bool:
	return border_tiles > 0.0 and arena.has_point(point) and not safe_rect().has_point(point)


func _physics_process(delta: float) -> void:
	_time += delta
	if border_tiles > 0.0 and config.has("cresce"):
		_grow_left -= delta
		if _grow_left <= 0.0 and border_tiles < float(config.get("max", border_tiles)):
			border_tiles += 1.0
			_grow_left = float(config["cresce"])
			Sfx.play(&"fire_breath", -8.0)
	_tick -= delta
	if _tick <= 0.0:
		_tick = TICK
		var player := get_tree().get_first_node_in_group("player") as Player
		if player and not player.is_dead() and burns(player.global_position):
			player.apply_burn(float(config.get("dps", 12.0)) * TICK, "fisico" if is_roots() else "fogo")
	queue_redraw()


func _draw() -> void:
	if border_tiles <= 0.0:
		return
	var safe := safe_rect()
	var step := 12.0
	var x := arena.position.x
	while x < arena.end.x:
		var y := arena.position.y
		while y < arena.end.y:
			var point := Vector2(x, y)
			if not safe.has_point(point):
				var flick := 0.5 + 0.5 * sin(_time * 9.0 + x * 0.3 + y * 0.7)
				if is_roots():  # raízes pulsando (devagar, como veias)
					var pulse := 0.5 + 0.5 * sin(_time * 2.5 + x * 0.2 + y * 0.4)
					draw_circle(point + Vector2(6, 6), 5.5 + pulse * 1.5, Color(0.5, 0.08, 0.14, 0.75))
					draw_circle(point + Vector2(6, 5), 2.0 + pulse, Color(0.8, 0.25, 0.3, 0.8))
				else:
					draw_circle(point + Vector2(6, 6), 5.0 + flick * 2.0, Color(1.0, 0.45 + 0.2 * flick, 0.12, 0.55))
					draw_circle(point + Vector2(6, 4), 2.5 + flick, Color(1.0, 0.85, 0.4, 0.8))
			y += step
		x += step
	draw_rect(safe, Color(0.8, 0.2, 0.3, 0.35) if is_roots() else Color(1.0, 0.5, 0.2, 0.35), false, 1.0)
