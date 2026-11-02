class_name LuciaAliada
extends Ally
## Lúcia Avelar lutando ao seu lado (v0.42, Etapa 7). Ajuda contra Aldir,
## Nyssa e Cassian — sempre chamada na antessala ("Lute comigo").
##
## Cair NÃO tira força dela: tira MEMÓRIA. Cada queda soma 1 em
## "lucia_quedas" — e quem cai muito, no fim, nem pergunta o próprio nome.
##
## Contra Nyssa, a Barra de Sonolência também pega nela: o sono que chega em
## você chega nela. Cheia, ela dorme uns segundos (não luta).

const FRAMES := preload("res://assets/sprites/lucia_aliado_frames.tres")
const SLEEP_TIME := 3.0
const DROWSY_DECAY := 9.0

var drowsiness := 0.0
var asleep_left := 0.0
var _last_player_drowsiness := 0.0


func _setup() -> void:
	ally_id = "lucia"
	display_name = "Espada de Lúcia"
	frames = FRAMES
	max_health = 170.0
	strike_damage = 16.0
	move_speed = 82.0


func _physics_process(delta: float) -> void:
	_follow_player_sleep(delta)
	if asleep_left > 0.0:
		asleep_left -= delta
		velocity = Vector2.ZERO
		modulate = Color(0.75, 0.75, 1.0)
		if asleep_left <= 0.0:
			modulate = Color.WHITE
			drowsiness = 0.0
		return
	super._physics_process(delta)


## O sono que chega em você chega nela (só sobe; desce sozinho).
func _follow_player_sleep(delta: float) -> void:
	if not is_instance_valid(player):
		return
	var gained := player.drowsiness - _last_player_drowsiness
	_last_player_drowsiness = player.drowsiness
	if gained > 0.0:
		add_drowsiness(gained)
	drowsiness = maxf(drowsiness - DROWSY_DECAY * delta, 0.0)


func add_drowsiness(amount: float) -> void:
	if asleep_left > 0.0 or fallen:
		return
	drowsiness = minf(drowsiness + amount, 100.0)
	if drowsiness >= 100.0:
		asleep_left = SLEEP_TIME
		_windup_left = -1.0
		Fx.float_text(global_position + Vector2(-6, -28), "Zz", Color(0.8, 0.8, 1.0), 7)


func is_asleep() -> bool:
	return asleep_left > 0.0


## Caiu: volta para o lugar dela — mas esquece um pouco.
func _on_fall() -> String:
	Game.flags["lucia_quedas"] = int(Game.flags.get("lucia_quedas", 0)) + 1
	Game.flags["lucia_acompanha"] = false
	return "Lúcia caiu. Ela volta para onde estava — um pouco menos ela."
