class_name MiniBoss
extends Boss
## Base dos MINI-CHEFES: chefes "de rua", sem névoa nem arena fechada.
##
## Diferença para o Boss das arenas:
##   • ACORDA sozinho quando vê o herói por perto (wake_distance) — a barra de
##     chefe aparece nessa hora (a fase escuta fight_started).
##   • Se o herói FOGE para longe (reset_distance) ou morre, ele volta ao posto
##     com a vida cheia e a barra some (fight_reset). Nada de "puxar" o
##     mini-chefe para o outro lado do mapa.
##   • Vencido, fica vencido (Game.mark_boss_defeated) e não volta ao descansar.
##
## As subclasses só escrevem a luta em _fight(delta). Mesmo padrão do resto do
## projeto: a base cuida do ciclo de vida, a filha cuida do comportamento.

signal fight_reset(boss: Boss)

## Longe do posto por mais que isso (ou o herói longe demais): desiste e volta.
@export var reset_distance := 260.0
@export var reset_time := 2.5
## Margem para acordar DE NOVO: o herói precisa estar este tanto mais perto do
## posto do que a distância de desistir. Sem ela, quem ficava na beirada (um
## pouco além do reset_distance) via o chefe acordar, desistir, voltar com a
## vida cheia e acordar de novo em loop — a barra "piscava" e enchia sozinha
## (v0.30.7, feedback: "a barra do Sargento bugou quando me afastei").
const WAKE_MARGIN := 50.0

var _away_time := 0.0


func _ready() -> void:
	super._ready()
	visible = true


func _physics_process(delta: float) -> void:
	if dead:
		velocity = velocity.move_toward(Vector2.ZERO, 600.0 * delta)
		move_and_slide()
		return
	target = find_target()
	if not active:
		_dormant(delta)
	else:
		regen_poise(delta)
		if _should_reset(delta):
			reset_fight()
			return
		_fight(delta)
	move_and_slide()
	_after_move(delta)


## Parado no posto. Acorda quando VÊ o herói por perto.
func _dormant(delta: float) -> void:
	var to_home := home_position - global_position
	if to_home.length() > 3.0:
		velocity = velocity.move_toward(to_home.normalized() * move_speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
	if target and global_position.distance_to(target.global_position) <= wake_distance \
			and target.global_position.distance_to(home_position) <= reset_distance - WAKE_MARGIN \
			and can_see(target.global_position):
		start_fight()
		_on_wake()


func _should_reset(delta: float) -> bool:
	if target == null:
		return true
	var far := target.global_position.distance_to(home_position) > reset_distance
	_away_time = _away_time + delta if far else 0.0
	return _away_time >= reset_time


## Desiste: volta ao posto, vida cheia, barra some.
func reset_fight() -> void:
	active = false
	_away_time = 0.0
	_runner.cancel()
	hitbox.deactivate()
	remove_from_group("enemies")
	hurtbox.invulnerable = true
	stats.revive()
	poise = max_poise
	_on_reset()
	fight_reset.emit(self)


## Vencido: memórias, registro no save e o corpo se desfaz.
func _defeat(last_words: String = "") -> void:
	dead = true
	active = false
	_runner.cancel()
	hitbox.deactivate()
	remove_from_group("enemies")
	hurtbox.set_deferred("monitorable", false)
	set_deferred("collision_layer", 0)
	if not last_words.is_empty():
		speech.emit(last_words)
	var reward := data.memory_reward if data else memory_reward
	Game.earn_memories(reward)
	if target:
		Fx.memory_motes(global_position + Vector2(0, -10), target, 14)
	if data:
		Game.mark_boss_defeated(data.id)
	Sfx.play(&"boss_phase", -4.0)
	Fx.slow_motion(0.3, 0.5)
	fight_won.emit(self)
	_play_death()


func _on_died() -> void:
	_defeat()


# --- Ganchos para as subclasses -----------------------------------------------------

func _fight(_delta: float) -> void:
	pass


func _on_wake() -> void:
	pass


func _on_reset() -> void:
	pass


func _after_move(delta: float) -> void:
	update_body_animation(delta)
