class_name SinoDespertar
extends MiniBoss
## O Sino de Despertar — mini-chefe opcional do Bosque (v0.35, Etapa 6).
## Máquina do Projeto coberta de musgo, feita para acordar as cobaias.
## Placa: "Unidade de despertar 2. Para quando a Fada estiver cansada."
##
## Não anda e não bate. Ela TOCA: um anel de som (dash através dele) que
## acorda os Sonâmbulos da sala e os manda atrás de você. Na fase 2 (metade
## da vida) toca mais rápido, dois anéis seguidos.
##
## Enquanto ela existe, os inimigos do Bosque enxergam mais longe. Vencida
## (flag "sino_silenciado"), eles enxergam menos (Level._spawn_enemy).

const SLEEPER_SCENE := preload("res://scenes/enemies/sonambulo.tscn")
## Alcance de visão dos inimigos do Bosque: com o sino tocando / silenciado.
const AGGRO_RINGING := 1.3
const AGGRO_SILENCED := 0.7

@export var ring_every := 3.4
@export var ring_every_phase_2 := 2.2
@export var ring_damage := 14.0
@export var ring_reach := 130.0
@export var max_sleepers := 3

var phase := 1
var sleepers: Array[Enemy] = []
var _ring_left := 1.2


## Quanto os inimigos do Bosque enxergam agora (o sino ainda toca?).
static func bosque_aggro_scale() -> float:
	return AGGRO_SILENCED if Game.has_flag("sino_silenciado") else AGGRO_RINGING


func _on_wake() -> void:
	Sfx.play(&"bell", -2.0)
	_ring_left = 0.8


func _fight(delta: float) -> void:
	velocity = Vector2.ZERO
	if phase == 1 and stats.health_ratio() <= 0.5:
		phase = 2
		phase_changed.emit("Fase 2")
		_ring_left = 0.6
	_ring_left -= delta
	if _ring_left > 0.0:
		return
	_ring_left = ring_every if phase == 1 else ring_every_phase_2
	_ring()
	if phase == 2:
		get_tree().create_timer(0.45, false).timeout.connect(func():
			if not dead and active:
				_ring())


func _ring() -> void:
	body_sprite.play(&"toca")
	Sfx.play(&"bell", 0.0)
	Fx.shake(1.2, 0.15)
	ScreamRing.launch(get_parent(), global_position + Vector2(0, -10), self, ring_damage, 150.0, ring_reach)
	for node in get_tree().get_nodes_in_group("enemies"):
		var enemy := node as Enemy
		if enemy and not enemy is Boss and not enemy.dead:
			enemy.alert(5.0)
	sleepers = sleepers.filter(func(s): return is_instance_valid(s) and not s.dead)
	if sleepers.size() < max_sleepers:
		var sleeper := SLEEPER_SCENE.instantiate() as Enemy
		sleeper.position = global_position + Vector2.from_angle(randf() * TAU) * 48.0
		get_parent().add_child(sleeper)
		sleeper.alert(8.0)
		sleepers.append(sleeper)
		Fx.dust(sleeper.position, 6)
	get_tree().create_timer(0.35, false).timeout.connect(func():
		if is_instance_valid(body_sprite):
			body_sprite.play(&"idle"))


func _can_be_staggered() -> bool:
	return false


func _on_reset() -> void:
	phase = 1
	_ring_left = 1.2
	for sleeper in sleepers:
		if is_instance_valid(sleeper):
			sleeper.queue_free()
	sleepers.clear()


func _on_died() -> void:
	Game.set_flag("sino_silenciado")
	for sleeper in sleepers:
		if is_instance_valid(sleeper) and not sleeper.dead:
			sleeper.stats.take_damage(99999.0)
	sleepers.clear()
	_defeat()


func _after_move(_delta: float) -> void:
	pass
