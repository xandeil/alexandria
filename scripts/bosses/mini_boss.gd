class_name MiniBoss
extends Boss
## Base dos MINI-CHEFES: chefes "de rua", sem névoa nem arena fechada.
##
## Diferença para o Boss das arenas:
##   • ACORDA sozinho quando vê o herói por perto (wake_distance) — a barra de
##     chefe aparece nessa hora (a fase escuta fight_started).
##   • Se o herói FOGE para longe (reset_distance) ou morre, ele desiste e volta
##     ao posto; a barra some (fight_reset). Nada de "puxar" o mini-chefe para o
##     outro lado do mapa.
##   • v0.53.2 — A VOLTA: a vida só enche quando ele CHEGA ao posto. Apanhou no
##     caminho (espada, flecha, magia — de onde for)? Acorda, e o dano conta.
##     Quem acorda pela distância é o herói perto DELE (não do posto). Não chegou
##     em 4 s (preso na parede; a Dançarina, que não anda)? Fumaça, e reaparece
##     no posto.
##   • Vencido, fica vencido (Game.mark_boss_defeated) e não volta ao descansar.
##
## As subclasses só escrevem a luta em _fight(delta). Mesmo padrão do resto do
## projeto: a base cuida do ciclo de vida, a filha cuida do comportamento.

signal fight_reset(boss: Boss)

## Longe do posto por mais que isso (ou o herói longe demais): desiste e volta.
@export var reset_distance := 260.0
@export var reset_time := 2.5
## TRAVAS CONTRA O LOOP de acordar e desistir (v0.30.7, feedback: "a barra do
## Sargento bugou quando me afastei"). Na v0.53.2 quem acorda é a distância até
## ELE — e ele desiste justamente colado no herói, na beirada. Então:
##   • desistiu com o herói perto: a distância só volta a acordá-lo depois que o
##     herói sai do alcance uma vez (bater acorda sempre);
##   • já desistiu uma vez: só desiste de novo depois de 5 s de luta.
const GIVE_UP_LOCK := 5.0
## Voltando e não chegou ao posto neste tempo: some numa fumaça e reaparece lá.
const STUCK_TIME := 4.0
## A esta distância do posto ele "chegou" (vida cheia).
const HOME_REACHED := 6.0
## v0.35: falso = INIMIGO COMUM forte feito de um mini-chefe reaproveitado
## (Mãe Faminta, Couraça Queimada...): sem barra de chefe, sem registro no
## save, renasce ao descansar como qualquer inimigo.
@export var shows_boss_bar := true

var _away_time := 0.0
## Tempo desta luta (a trava dos 5 s).
var _fight_time := 0.0
var _gave_up_before := false
## Desistiu com o herói perto: a distância não acorda até ele sair do alcance.
var _wake_needs_leave := false
## Voltando para o posto (desistiu e ainda não chegou).
var _returning := false
var _return_time := 0.0


func _ready() -> void:
	super._ready()
	visible = true
	# Fora da luta ele não está em "enemies" (aliados e alarmes não mexem com quem
	# dorme), mas um golpe o acorda: a magia procura também neste grupo.
	# ("minibosses" é outra coisa: a lista de mini-chefes que a fase põe no mapa.)
	add_to_group(&"wake_on_hit")


## Dormindo ou voltando também é alvo: bater acorda (só fora da luta não está no
## grupo "enemies" — aliados e alarmes não mexem com quem dorme).
func is_targetable() -> bool:
	return not dead and (active or _can_wake_by_hit())


func _physics_process(delta: float) -> void:
	if dead:
		velocity = velocity.move_toward(Vector2.ZERO, 600.0 * delta)
		move_and_slide()
		return
	target = find_target()
	if not active:
		hurtbox.invulnerable = not _can_wake_by_hit()  # nada de imunidade na volta
		_dormant(delta)
		_update_return(delta)
	else:
		_fight_time += delta
		regen_poise(delta)
		if target == null or (_should_reset(delta) and _may_give_up()):
			reset_fight()
			return
		_fight(delta)
	move_and_slide()
	_after_move(delta)


func start_fight() -> void:
	super.start_fight()
	_fight_time = 0.0
	_returning = false
	_wake_needs_leave = false


## Parado no posto (ou voltando para ele). Acorda quando VÊ o herói perto DELE.
func _dormant(delta: float) -> void:
	var to_home := home_position - global_position
	if to_home.length() > 3.0:
		velocity = velocity.move_toward(to_home.normalized() * move_speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
	if target == null:
		return
	var near := global_position.distance_to(target.global_position) <= wake_distance
	if not near:
		_wake_needs_leave = false
	elif not _wake_needs_leave and can_see(target.global_position):
		start_fight()
		_on_wake()


## A volta: chegou ao posto = vida cheia. Não chegou em STUCK_TIME = fumaça.
func _update_return(delta: float) -> void:
	if active:
		return
	var at_home := global_position.distance_to(home_position) <= HOME_REACHED
	if not at_home and not _returning:  # fora do posto, dormindo = voltando
		_returning = true
		_return_time = 0.0
	if not _returning:
		return
	_return_time += delta
	if at_home:
		_arrive_home()
	elif _return_time >= STUCK_TIME:
		Fx.dust(global_position + Vector2(0, -6), 16)
		Fx.splash(global_position + Vector2(0, -10), Color(0.6, 0.6, 0.66), 12)
		Sfx.play(&"dash", -6.0)
		global_position = home_position
		velocity = Vector2.ZERO
		Fx.dust(global_position + Vector2(0, -6), 16)
		_arrive_home()


func _arrive_home() -> void:
	_returning = false
	stats.revive()
	poise = max_poise


func _should_reset(delta: float) -> bool:
	if target == null:
		return true
	var far := target.global_position.distance_to(home_position) > reset_distance
	_away_time = _away_time + delta if far else 0.0
	return _away_time >= reset_time


## Já desistiu uma vez? Então só desiste de novo depois de GIVE_UP_LOCK de luta.
func _may_give_up() -> bool:
	return not _gave_up_before or _fight_time >= GIVE_UP_LOCK


## Desiste: volta ao posto (a vida só enche quando chegar) e a barra some.
func reset_fight() -> void:
	active = false
	_away_time = 0.0
	_runner.cancel()
	hitbox.deactivate()
	remove_from_group("enemies")
	_gave_up_before = true
	_wake_needs_leave = target != null and global_position.distance_to(target.global_position) <= wake_distance
	_returning = true
	_return_time = 0.0
	if global_position.distance_to(home_position) <= HOME_REACHED:
		_arrive_home()
	_on_reset()
	fight_reset.emit(self)


## Apanhou fora da luta (dormindo ou voltando): acorda, de onde for o golpe.
func _on_hit_received(info: HitInfo) -> void:
	if not active and not dead and _can_wake_by_hit():
		start_fight()
		_on_wake()
	super._on_hit_received(info)


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
	if not shows_boss_bar:
		defeated.emit(self)  # inimigo comum: a fase anota a morte (renasce ao descansar)
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


## Pode ser acordado por um golpe AGORA? (O Minotauro, caindo do céu, não.)
func _can_wake_by_hit() -> bool:
	return true


func _after_move(delta: float) -> void:
	update_body_animation(delta)
