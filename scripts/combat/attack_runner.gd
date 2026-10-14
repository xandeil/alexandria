class_name AttackRunner
extends RefCounted
## O coração do combate "Step and Anchor". Herói, soldados e Helena usam ESTE
## mesmo código — por isso o golpe de todo mundo tem o mesmo peso.
##
## Linha do tempo de um golpe:
##
##   WINDUP ──────► LUNGE ──► ACTIVE ──► RECOVERY ──────► (fim)
##   movimento      micro-     FREIO      parado e
##   travado,       impulso    SECO +     vulnerável
##   corpo freia    p/ frente  hitbox on
##
## O AttackRunner não move ninguém: ele só diz "qual velocidade o corpo deve
## ter neste frame" (step) e avisa por sinal quando a fase muda. Quem é dono do
## corpo (CharacterBody2D) aplica a velocidade e chama move_and_slide() — então
## o avanço RESPEITA as colisões sólidas: ninguém atravessa parede no golpe.

signal phase_changed(phase: Phase)

enum Phase { IDLE, WINDUP, LUNGE, ACTIVE, RECOVERY }

## Freio aplicado durante o windup (px/s²). Alto = trava quase na hora.
const WINDUP_BRAKE := 2400.0

var data: AttackData
var direction := Vector2.RIGHT
var phase := Phase.IDLE
var time_in_phase := 0.0
## Multiplicador de velocidade da animação inteira (Helena fica mais rápida
## conforme perde a armadura; 1.0 = normal, 0.7 = 30% mais rápido).
var time_scale := 1.0


func start(attack: AttackData, dir: Vector2, speed_multiplier: float = 1.0) -> void:
	data = attack
	direction = dir.normalized() if dir.length_squared() > 0.0001 else Vector2.RIGHT
	time_scale = maxf(speed_multiplier, 0.05)
	_set_phase(Phase.WINDUP)


## Interrompe (ex.: o dono levou um golpe). Emite IDLE para desligar a hitbox.
func cancel() -> void:
	if phase != Phase.IDLE:
		_set_phase(Phase.IDLE)


func is_running() -> bool:
	return phase != Phase.IDLE


## Avança o tempo e devolve a velocidade desejada para o corpo neste frame.
func step(delta: float, current_velocity: Vector2) -> Vector2:
	if phase == Phase.IDLE:
		return current_velocity
	time_in_phase += delta
	match phase:
		Phase.WINDUP:
			var braked := current_velocity.move_toward(Vector2.ZERO, WINDUP_BRAKE * delta)
			if time_in_phase >= data.windup_time * time_scale:
				_set_phase(Phase.LUNGE)
			return braked
		Phase.LUNGE:
			if time_in_phase >= data.lunge_time:
				_set_phase(Phase.ACTIVE)
				return Vector2.ZERO  # ← o "Anchor": freio abrupto, o golpe crava parado.
			return direction * data.lunge_speed
		Phase.ACTIVE:
			if time_in_phase >= data.active_time:
				_set_phase(Phase.RECOVERY)
			return Vector2.ZERO
		Phase.RECOVERY:
			if time_in_phase >= data.recovery_time * time_scale:
				_set_phase(Phase.IDLE)
			return Vector2.ZERO
	return current_velocity


func is_hitbox_phase() -> bool:
	return phase == Phase.ACTIVE or (phase == Phase.LUNGE and data != null and data.active_during_lunge)


## Final da recuperação: aceita encadear o próximo golpe do combo.
func in_combo_window() -> bool:
	return phase == Phase.RECOVERY and time_in_phase >= data.recovery_time * time_scale - data.combo_window


## Inimigos podem corrigir a mira até a trava do windup (telegraph justo).
func can_track_target() -> bool:
	return phase == Phase.WINDUP and time_in_phase < data.windup_time * time_scale * data.track_until


## Progresso 0..1 da fase atual (usado pela animação da arma).
func phase_progress() -> float:
	var duration := 0.0
	match phase:
		Phase.WINDUP:
			duration = data.windup_time * time_scale
		Phase.LUNGE:
			duration = data.lunge_time
		Phase.ACTIVE:
			duration = data.active_time
		Phase.RECOVERY:
			duration = data.recovery_time * time_scale
	return clampf(time_in_phase / duration, 0.0, 1.0) if duration > 0.0 else 1.0


func _set_phase(new_phase: Phase) -> void:
	phase = new_phase
	time_in_phase = 0.0
	phase_changed.emit(new_phase)
