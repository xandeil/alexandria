class_name BezerroDourado
extends Enemy
## Bezerro Dourado — o "farm" da Montanha Carbonizada (v0.26).
##
## Pasta devagar numa ROTA fechada (uma volta pelo campo). Apanhou uma vez,
## dispara pela mesma rota um pouco MAIS RÁPIDO que o herói correndo com as
## cinco Escamas de Caelis — ninguém alcança por trás. O jeito é pensar:
## cortar caminho por dentro da volta, esperar na curva, usar o dash.
##
## Morre com EXATAMENTE 7 golpes, qualquer que seja a arma: a vida dele não é
## dano, é contagem. Assim o farm tem sempre a mesma dificuldade mínima — uma
## arma +5 não transforma a caçada em um clique.
##
## Quando cai, quem cuida do resto (o pai aparecer) é o FarmSpot: o bezerro só
## avisa que morreu (sinal `defeated` da base Enemy).

const HITS_TO_KILL := 7

## Pastando: passo de quem não tem pressa.
@export var graze_speed := 30.0
## Fugindo. O herói com as 5 Escamas de Caelis correndo faz 80 × 2,1 = 168.
@export var flee_speed := 178.0
## Parada para pastar em cada canto da rota (só enquanto está calmo).
@export var graze_pause := 1.4

var route: Array[Vector2] = []
var hits := 0
var fleeing := false

var _next := 0
var _pause := 0.0


func _ready() -> void:
	super._ready()
	knockback_taken = 0.0  # empurrão ia "ajudar" a pegar: ele não sai da rota


## A rota em coordenadas do mundo. Começa indo para o ponto `start_index`.
func set_route(points: Array[Vector2], start_index: int = 0) -> void:
	route = points
	_next = posmod(start_index, maxi(points.size(), 1))


func _physics_process(delta: float) -> void:
	if dead:
		velocity = velocity.move_toward(Vector2.ZERO, 600.0 * delta)
		move_and_slide()
		return
	_follow_route(delta)
	move_and_slide()
	_update_animation(delta)


func _follow_route(delta: float) -> void:
	if route.is_empty():
		velocity = Vector2.ZERO
		return
	if _pause > 0.0 and not fleeing:
		_pause -= delta
		velocity = velocity.move_toward(Vector2.ZERO, 400.0 * delta)
		return
	var speed := flee_speed if fleeing else graze_speed
	var to_goal := route[_next] - global_position
	if to_goal.length() <= maxf(3.0, speed * delta * 1.5):
		_next = (_next + 1) % route.size()
		if not fleeing:
			_pause = graze_pause
		to_goal = route[_next] - global_position
	# Fugindo, a velocidade é na hora (susto); pastando, acelera de leve.
	var wanted := to_goal.normalized() * speed
	velocity = wanted if fleeing else velocity.move_toward(wanted, 200.0 * delta)
	if velocity.length() > 1.0:
		facing = velocity.normalized()


func _update_animation(delta: float) -> void:
	if absf(facing.x) > 0.1:
		body_sprite.flip_h = facing.x < 0.0
	var anim := &"idle"
	if velocity.length() > 6.0:
		anim = &"corre" if fleeing else &"walk"
	if body_sprite.animation != anim:
		body_sprite.play(anim)
	visual.position.y = lerpf(visual.position.y, 0.0, 10.0 * delta)


# --- Dano = contagem ---------------------------------------------------------------------

## Qualquer golpe que encosta conta UM (o dano da arma não importa).
func _on_hit_received(info: HitInfo) -> void:
	if dead:
		return
	_count_hit(info.direction)


## Crítico também é um golpe só (e ele nunca dá as costas parado mesmo).
func receive_critical(_damage: float, from: Node2D) -> void:
	if not dead:
		_count_hit((global_position - from.global_position).normalized())


func can_be_backstabbed(_from: Vector2) -> bool:
	return false


func _count_hit(direction: Vector2) -> void:
	hits += 1
	fleeing = true
	_pause = 0.0
	Sfx.play(&"hit")
	Fx.flash(body_sprite, 0.1)
	Fx.sparks(global_position + Vector2(0, -8), direction, Color(1.0, 0.85, 0.35), 10)
	Fx.float_text(global_position + Vector2(-6, -28), "%d/%d" % [hits, HITS_TO_KILL], Color(1.0, 0.86, 0.4), 7)
	if hits >= HITS_TO_KILL:
		stats.take_damage(stats.health)  # a "vida" de verdade é a contagem; aqui só fecha a conta
