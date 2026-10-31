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
##   "bau"       abrir → entrega o item (item, count) e fica aberto.
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

var kind := "alavanca"
## Nome do estado no save (único no jogo inteiro: "atalho_galho", "bau_cidade_1").
var key := ""
var item := ""
var count := 1
var open_side := ""
var locked_dialogue := ""

var interactable: Interactable
var _body_shape: CollisionShape2D


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
	_refresh()


func is_done() -> bool:
	return Game.world_flag(key)


func _refresh() -> void:
	var done := is_done()
	match kind:
		"alavanca":
			interactable.prompt = "Puxar"
			interactable.enabled = not done
		"bau":
			interactable.prompt = "Abrir"
			interactable.enabled = not done
		"atalho":
			interactable.prompt = "Abrir"
			interactable.enabled = not done
			_body_shape.set_deferred("disabled", done)
	queue_redraw()


func _on_interacted(player: Player) -> void:
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


func _draw() -> void:
	var done := is_done()
	match kind:
		"alavanca":
			draw_rect(Rect2(-5, -4, 10, 4), Color(0.3, 0.28, 0.26))
			var tip := Vector2(5, -14) if done else Vector2(-5, -14)
			draw_line(Vector2(0, -4), tip, Color(0.62, 0.56, 0.48), 2.0)
			draw_circle(tip, 2.0, Color(0.8, 0.25, 0.2))
		"bau":
			draw_rect(Rect2(-7, -9, 14, 9), Color(0.42, 0.28, 0.16))
			draw_rect(Rect2(-7, -9, 14, 9), Color(0.2, 0.13, 0.08), false, 1.0)
			if done:
				draw_rect(Rect2(-7, -13, 14, 3), Color(0.35, 0.23, 0.13))  # tampa aberta
			else:
				draw_rect(Rect2(-1, -7, 3, 3), Color(0.85, 0.7, 0.3))  # fechadura
		"atalho":
			if not done:
				draw_rect(Rect2(-8, -16, 16, 16), Color(0.3, 0.27, 0.25))
				draw_rect(Rect2(-8, -16, 16, 16), Color(0.15, 0.13, 0.12), false, 1.0)
				draw_line(Vector2(-8, -8), Vector2(8, -8), Color(0.18, 0.16, 0.15), 1.0)
