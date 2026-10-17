class_name FleshBurst
extends Node2D
## Explosão de carne e seiva COM AVISO: um círculo no chão que enche até estourar.
## Usada pelo Inchado (ao morrer) e pelos frutos de carne da Mabel — que chegam
## voando em arco até o centro do círculo (fruit_from).
##
## Por que uma classe só? É a mesma regra para o jogador: "círculo vermelho
## enchendo = saia de dentro". Ensina uma vez, cobra em dois lugares.
## hurt_enemies = true: a explosão fere OUTROS inimigos também (o Inchado é uma
## arma que o jogador pode usar contra o resto do grupo).

const FRUIT := preload("res://assets/fx/flesh_fruit.png")
const SPLAT := preload("res://assets/fx/sap_splat.png")
const STONE := preload("res://assets/fx/pedra_caindo.png")
## Inimigos levam mais (o Inchado no meio do grupo é uma bomba de verdade).
const ENEMY_DAMAGE_MULTIPLIER := 1.6

var radius := 30.0
var delay := 0.8
var damage := 24.0
var source: Node2D
var hurt_enemies := false
var fruit_from := Vector2.INF
## Altura do arco do fruto (px).
var arc_height := 46.0
## "carne" (vermelho, mancha de seiva), "fogo" (laranja; deixa chamas no chão) ou
## "pedra" (cinza; a pedra que cai do alto no Núcleo, sem deixar nada).
var style := "carne"

var _time := 0.0
var _done := false
var _fruit: Sprite2D


static func spawn(parent: Node, at: Vector2, burst_radius: float, warning: float, burst_damage: float,
		owner_node: Node2D = null, enemies_too: bool = false, thrown_from: Vector2 = Vector2.INF,
		burst_style: String = "carne") -> FleshBurst:
	var burst := FleshBurst.new()
	burst.style = burst_style  # antes do add_child: o _ready já precisa saber o estilo
	burst.radius = burst_radius
	burst.delay = warning
	burst.damage = burst_damage
	burst.source = owner_node
	burst.hurt_enemies = enemies_too
	burst.fruit_from = thrown_from
	burst.position = at
	parent.add_child(burst)
	return burst


func _ready() -> void:
	add_to_group("flesh_bursts")
	z_index = -1  # o aviso fica no chão, por baixo de quem anda
	material = Fx.unshaded
	if fruit_from != Vector2.INF:
		_fruit = Sprite2D.new()
		_fruit.texture = STONE if style == "pedra" else FRUIT
		_fruit.z_as_relative = false
		_fruit.z_index = 7
		add_child(_fruit)
		_fruit.global_position = fruit_from


func _physics_process(delta: float) -> void:
	if _done:
		return
	_time += delta
	queue_redraw()
	if _fruit:
		var t := clampf(_time / delay, 0.0, 1.0)
		var flat := fruit_from.lerp(global_position, t)
		_fruit.global_position = flat + Vector2(0, -sin(t * PI) * arc_height - 6.0 * (1.0 - t))
		_fruit.rotation += delta * 9.0
	if _time >= delay:
		explode()


func is_exploded() -> bool:
	return _done


func explode() -> void:
	if _done:
		return
	_done = true
	if not is_instance_valid(source):
		source = null  # quem lançou já sumiu (o Inchado estoura junto)
	queue_redraw()
	if _fruit:
		_fruit.queue_free()
	if style == "fogo":
		Sfx.play(&"fireball", -2.0, 0.1)
		Fx.splash(global_position + Vector2(0, -6), Color(1.0, 0.55, 0.15), 18)
	elif style == "pedra":
		Sfx.play(&"slam", -4.0, 0.1)
		Fx.dust(global_position, 10)
	else:
		Sfx.play(&"splat", -2.0, 0.1)
		Fx.splash(global_position + Vector2(0, -6), Color(0.62, 0.1, 0.16), 18)
	Fx.shake(3.0, 0.2)
	_hit_player()
	if hurt_enemies:
		_hit_enemies()
	_leave_stain()
	queue_free()


func _hit_player() -> void:
	var player := get_tree().get_first_node_in_group("player") as Player
	if player == null or player.is_dead():
		return
	if player.global_position.distance_to(global_position) > radius + 4.0:
		return
	var info := HitInfo.create(damage, global_position, player.global_position)
	info.knockback = 170.0
	info.poise_damage = 25.0
	info.unblockable = true  # explosão no chão: o escudo não segura — só sair do círculo
	info.attack_name = "Explosão"
	info.source = source
	player.hurtbox.receive_hit(info)


func _hit_enemies() -> void:
	for node in get_tree().get_nodes_in_group("enemies"):
		var enemy := node as Enemy
		if enemy == null or enemy == source or enemy.dead:
			continue
		if enemy.global_position.distance_to(global_position) > radius + 4.0:
			continue
		var info := HitInfo.create(damage * ENEMY_DAMAGE_MULTIPLIER, global_position, enemy.global_position)
		info.knockback = 160.0
		info.poise_damage = 40.0
		info.attack_name = "Explosão de carne"
		enemy.hurtbox.receive_hit(info)


## A mancha vermelha fica no chão por um tempo (e some devagar).
func _leave_stain() -> void:
	if style == "fogo":
		FirePatch.spawn(get_parent(), global_position, radius * 0.6, 2.5, 8.0, source)
		return
	if style == "pedra":
		return  # a pedra se desfaz em poeira
	var stain := Sprite2D.new()
	stain.texture = SPLAT
	stain.z_index = -9  # logo acima do piso
	stain.scale = Vector2.ONE * clampf(radius / 18.0, 0.7, 1.8)
	get_parent().add_child(stain)
	stain.global_position = global_position
	var tween := stain.create_tween()
	tween.tween_interval(5.0)
	tween.tween_property(stain, "modulate:a", 0.0, 2.0)
	tween.tween_callback(stain.queue_free)


func _draw() -> void:
	if _done:
		return
	var t := clampf(_time / delay, 0.0, 1.0)
	var fill: Color = {"fogo": Color(1.0, 0.45, 0.1, 0.32), "pedra": Color(0.7, 0.66, 0.6, 0.32)}.get(style, Color(0.85, 0.12, 0.15, 0.32))
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 40, Color(1.0, 0.3, 0.25, 0.85), 1.5)
	draw_circle(Vector2.ZERO, radius * t, fill)
