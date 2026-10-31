class_name WorldObject
extends StaticBody2D
## INTERAGÍVEL COM ESTADO (v0.31, Etapa 1): alavanca, baú, porta de atalho.
##
## A diferença para um NPC: ele LEMBRA. O estado fica em Game.world_state
## (salvo no save) e NUNCA volta ao descansar nem ao morrer — atalho aberto é
## atalho aberto para sempre (Dark Souls).
##
## Tipos (kind):
##   "alavanca"  puxar uma vez → world_state[key] = true. Portas, pontes e
##               saídas que pedem "estado:<key>" se abrem na hora.
##   "bau"       abrir → entrega o item (item, count) e fica aberto ("aberto").
##               BATER 3 vezes nele o QUEBRA ("quebrado"): o item de dentro se
##               perde e no lugar cai sempre o mesmo, o "Algo Quebrado" (Etapa 3).
##               O desenho tem detalhes de um lado só — o mímico é o espelho dele.
##   "atalho"    uma porta que BLOQUEIA a passagem e só abre de UM lado
##               (abre_de: "norte", "sul", "leste" ou "oeste"). Do lado errado,
##               vira "Examinar" com a fala `locked_dialogue`.
##
## No mapa: Level.objects → {"kind": "atalho", "cell": Vector2i(12, 5),
##   "key": "atalho_galho", "abre_de": "oeste", "locked_dialogue": "galho_trancado"}
## Atalho e alavanca também ligam a FLAG de mesmo nome (Game.set_flag), para as
## falas e portas poderem perguntar "flag:atalho_galho".

signal state_changed(object: WorldObject)

const TILE := 16
const SIDES := {"norte": Vector2.UP, "sul": Vector2.DOWN, "leste": Vector2.RIGHT, "oeste": Vector2.LEFT}
const CHEST_CLOSED := preload("res://assets/props/bau_fechado.png")
const CHEST_OPEN := preload("res://assets/props/bau_aberto.png")
const CHEST_BROKEN := preload("res://assets/props/bau_quebrado.png")
## Golpes para quebrar um baú.
const HITS_TO_BREAK := 3

var kind := "alavanca"
## Nome do estado no save (único no jogo inteiro: "atalho_galho", "bau_cidade_1").
var key := ""
var item := ""
var count := 1
var open_side := ""
var locked_dialogue := ""

var interactable: Interactable
var hurtbox: Hurtbox
var _body_shape: CollisionShape2D
var _sprite: Sprite2D
var _hits := 0


static func spawn(parent: Node, def: Dictionary, at: Vector2) -> WorldObject:
	var object := WorldObject.new()
	object.kind = str(def.get("kind", "alavanca"))
	object.key = str(def.get("key", ""))
	object.item = str(def.get("item", ""))
	object.count = int(def.get("count", 1))
	object.open_side = str(def.get("abre_de", ""))
	object.locked_dialogue = str(def.get("locked_dialogue", ""))
	object.position = at
	parent.add_child(object)
	return object


func _ready() -> void:
	add_to_group("world_objects")
	collision_layer = 1  # sólido, como parede
	collision_mask = 0
	_body_shape = CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = Vector2(TILE, TILE) if kind == "atalho" else Vector2(12, 8)
	_body_shape.shape = box
	_body_shape.position = Vector2(0, -8) if kind == "atalho" else Vector2(0, -4)
	add_child(_body_shape)
	interactable = Interactable.new()
	var reach := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 14.0
	reach.shape = circle
	reach.position = Vector2(0, -6)
	interactable.add_child(reach)
	add_child(interactable)
	interactable.interacted.connect(_on_interacted)
	if kind == "bau":
		_sprite = Sprite2D.new()
		_sprite.offset = Vector2(0, -6)
		add_child(_sprite)
		hurtbox = Hurtbox.new()
		hurtbox.collision_layer = 16  # a camada que os golpes do herói procuram
		hurtbox.collision_mask = 0
		hurtbox.owner_body = self
		var hurt_shape := CollisionShape2D.new()
		var hurt_box := RectangleShape2D.new()
		hurt_box.size = Vector2(16, 12)
		hurt_shape.shape = hurt_box
		hurt_shape.position = Vector2(0, -6)
		hurtbox.add_child(hurt_shape)
		add_child(hurtbox)
		hurtbox.hit_received.connect(_on_hit)
	_refresh()


func is_done() -> bool:
	return Game.world_flag(key)


## "aberto", "quebrado" ou "" (ainda fechado) — para os baús.
func chest_state() -> String:
	var value: Variant = Game.world_state.get(key, "")
	return str(value) if value is String else ("aberto" if value == true else "")


func _refresh() -> void:
	var done := is_done()
	match kind:
		"alavanca":
			interactable.prompt = "Puxar"
			interactable.enabled = not done
		"bau":
			var state := chest_state()
			interactable.prompt = "Examinar" if state == "quebrado" else "Abrir"
			interactable.enabled = state != "aberto"
			_sprite.texture = {"aberto": CHEST_OPEN, "quebrado": CHEST_BROKEN}.get(state, CHEST_CLOSED)
			if hurtbox:
				hurtbox.invulnerable = done
		"atalho":
			interactable.prompt = "Abrir"
			interactable.enabled = not done
			_body_shape.set_deferred("disabled", done)
	queue_redraw()


func _on_interacted(player: Player) -> void:
	if kind == "bau" and chest_state() == "quebrado":
		var level_of := Level.find(self)
		if level_of:
			level_of.examine("bau_quebrado", "Baú quebrado")
		return
	if is_done():
		return
	if kind == "atalho" and not can_open_from(player.global_position):
		var level := Level.find(self)
		if level and not locked_dialogue.is_empty():
			level.examine(locked_dialogue, "")
		return
	activate()


## Do lado certo? O jogador precisa estar do lado "abre_de" da porta.
func can_open_from(point: Vector2) -> bool:
	if open_side.is_empty() or not SIDES.has(open_side):
		return true
	var side: Vector2 = SIDES[open_side]
	return (point - (global_position + Vector2(0, -8))).dot(side) > 0.0


## Aciona (também usado pelos testes e por eventos de roteiro).
func activate() -> void:
	if is_done() or key.is_empty():
		return
	match kind:
		"bau":
			Sfx.play(&"door", -6.0)
			if not item.is_empty():
				Game.add_item(item, count)
			Game.set_world_state(key, "aberto")
			_refresh()
			state_changed.emit(self)
			return
		"alavanca":
			Sfx.play(&"clank", -4.0)
		"atalho":
			Sfx.play(&"door_slide", -4.0)
			Fx.dust(global_position, 6)
	Game.set_world_state(key, true)
	if kind != "bau":
		Game.set_flag(key)  # falas e portas podem perguntar "flag:<key>"
	_refresh()
	state_changed.emit(self)


## Golpe no baú: no terceiro, ele quebra (e o que tinha dentro se perde).
func _on_hit(_info: HitInfo) -> void:
	if kind != "bau" or not chest_state().is_empty():
		return
	_hits += 1
	Sfx.play(&"clank", -6.0, 0.15)
	Fx.sparks(global_position + Vector2(0, -6), Vector2.UP, Color(0.8, 0.65, 0.4), 4)
	var shake := create_tween()
	shake.tween_property(_sprite, "position:x", 1.5, 0.04)
	shake.tween_property(_sprite, "position:x", -1.5, 0.04)
	shake.tween_property(_sprite, "position:x", 0.0, 0.04)
	if _hits >= HITS_TO_BREAK:
		break_open()


func break_open() -> void:
	if not chest_state().is_empty():
		return
	Sfx.play(&"crumble", -2.0)
	Fx.dust(global_position, 10)
	Game.set_world_state(key, "quebrado")
	ItemPickup.drop(get_parent(), global_position + Vector2(0, 8), "algo_quebrado", 1)
	_refresh()
	state_changed.emit(self)


func _draw() -> void:
	var done := is_done()
	match kind:
		"alavanca":
			draw_rect(Rect2(-5, -4, 10, 4), Color(0.3, 0.28, 0.26))
			var tip := Vector2(5, -14) if done else Vector2(-5, -14)
			draw_line(Vector2(0, -4), tip, Color(0.62, 0.56, 0.48), 2.0)
			draw_circle(tip, 2.0, Color(0.8, 0.25, 0.2))
		"atalho":
			if not done:
				draw_rect(Rect2(-8, -16, 16, 16), Color(0.3, 0.27, 0.25))
				draw_rect(Rect2(-8, -16, 16, 16), Color(0.15, 0.13, 0.12), false, 1.0)
				draw_line(Vector2(-8, -8), Vector2(8, -8), Color(0.18, 0.16, 0.15), 1.0)
