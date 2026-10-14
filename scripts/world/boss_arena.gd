class_name BossArena
extends Node2D
## Orquestra a luta contra um Pecado:
##   (diálogo →) o chefe entra na arena → a névoa aparece → o herói entra →
##   a névoa endurece (SEALED) → o chefe "acorda" e a luta começa → vitória
##   (memória recuperada) ou morte.
## Se o herói morrer, a cena é recarregada na Câmara e tudo volta ao começo.

## A névoa fechou atrás do herói (o chefe pode ainda estar "dormindo").
signal sealed(boss: Boss)
signal fight_started(boss: Boss)
signal fight_ended(victory: bool)

enum State { IDLE, ARMED, SEALED, FIGHTING, DONE }

## Selado há tanto tempo sem chegar perto: o chefe acorda mesmo assim.
const WAKE_TIMEOUT := 6.0

var boss: Boss
var seated_npc: NPC
var fog_walls: Array[FogWall] = []
var arena_rect := Rect2()
var landing_point := Vector2.ZERO
var state := State.IDLE

var _boss_ready := false
var _sealed_time := 0.0


func setup(new_boss: Boss, seated: NPC, fogs: Array[FogWall], rect: Rect2, landing: Vector2) -> void:
	boss = new_boss
	seated_npc = seated
	fog_walls = fogs
	arena_rect = rect
	landing_point = landing
	boss.arena_rect = rect
	boss.fight_won.connect(_on_boss_won)
	boss.ready_to_fight.connect(func(): _boss_ready = true)
	if boss.data and Game.is_boss_defeated(boss.data.id):
		state = State.DONE
		boss.queue_free()
		if is_instance_valid(seated_npc):
			seated_npc.queue_free()


func is_busy() -> bool:
	return state == State.ARMED or state == State.SEALED or state == State.FIGHTING


## Depois do diálogo ("Desembainhar"): o chefe sai da plateia e salta ao palco.
func arm() -> void:
	if state != State.IDLE or not is_instance_valid(boss):
		return
	state = State.ARMED
	if is_instance_valid(seated_npc):
		boss.global_position = seated_npc.global_position
		seated_npc.queue_free()
	boss.enter_arena(landing_point)
	for fog in fog_walls:
		fog.appear()
	Sfx.play(&"fog")


func _physics_process(delta: float) -> void:
	if not _boss_ready or not is_instance_valid(boss):
		return
	var player := get_tree().get_first_node_in_group("player") as Player
	if player == null or player.is_dead():
		return
	match state:
		State.ARMED:
			if arena_rect.grow(-14.0).has_point(player.global_position):
				_seal()
		State.SEALED:
			_sealed_time += delta
			var close := player.global_position.distance_to(boss.global_position) <= boss.wake_distance
			if boss.wake_distance <= 0.0 or close or _sealed_time >= WAKE_TIMEOUT:
				_start()


## A névoa endurece atrás do herói: não dá mais para fugir.
func _seal() -> void:
	state = State.SEALED
	_sealed_time = 0.0
	for fog in fog_walls:
		fog.set_solid(true)
	Sfx.play(&"fog")
	sealed.emit(boss)


func _start() -> void:
	state = State.FIGHTING
	boss.start_fight()
	fight_started.emit(boss)


func _on_boss_won(_boss: Boss) -> void:
	state = State.DONE
	if boss.data:
		Game.mark_boss_defeated(boss.data.id)
	for fog in fog_walls:
		fog.vanish()
	fight_ended.emit(true)
