class_name DancarinaEngrenagem
extends MiniBoss
## A Dançarina de Engrenagem — mini-chefe opcional das Forjas (v0.35, Etapa 6).
## Bailarina de bronze que Durgan forjou para mostrar que fazia mais que Âncoras.
##
## A leitura é PELO OUVIDO: ela gira tocando uma melodia de caixinha de música
## que acelera. Quando a música PARA, ela dispara em curva na sua direção.
## Fase 2 (metade da vida): dois ou três disparos seguidos — o último com um
## atraso a mais, para pegar quem rolou cedo demais.
## Examinar: "Feita para dançar para alguém. Ninguém veio ver."

enum Mode { SPIN, SILENCE, DART, RECOVER }

## A melodia (alturas relativas da mesma nota de caixinha).
const MELODY := [1.0, 1.26, 1.5, 1.26, 1.0, 0.84, 1.0, 1.26, 1.68, 1.5, 1.26, 1.12]
const FIRST_NOTE_GAP := 0.42
const NOTE_SPEEDUP := 0.86
const MIN_NOTE_GAP := 0.11
## Silêncio entre a última nota e o disparo (a deixa).
const SILENCE_TIME := 0.32
const LATE_EXTRA := 0.45

@export var dart_speed := 290.0
@export var dart_time := 0.62
## Quanto ela consegue virar por segundo durante o disparo (a curva).
@export var dart_turn := 2.6
@export var dart_damage := 42.0
@export var recover_time := 1.0

var mode := Mode.SPIN
var phase := 1
var notes_played := 0
var notes_this_song := 8
var darts_left := 0
var _note_gap := FIRST_NOTE_GAP
var _note_left := 0.0
var _mode_time := 0.0
var _dart_dir := Vector2.RIGHT
var _darts_in_volley := 1


func _on_wake() -> void:
	_start_song()


func _set_mode(new_mode: Mode) -> void:
	mode = new_mode
	_mode_time = 0.0


func _start_song() -> void:
	_set_mode(Mode.SPIN)
	notes_played = 0
	notes_this_song = randi_range(7, 11)
	_note_gap = FIRST_NOTE_GAP
	_note_left = 0.2
	hitbox.deactivate()
	body_sprite.play(&"spin")


func _fight(delta: float) -> void:
	_mode_time += delta
	if phase == 1 and stats.health_ratio() <= 0.5:
		phase = 2
		phase_changed.emit("Fase 2")
	match mode:
		Mode.SPIN:
			velocity = velocity.move_toward(Vector2.ZERO, 400.0 * delta)
			_note_left -= delta
			if _note_left <= 0.0:
				play_note()
		Mode.SILENCE:
			velocity = Vector2.ZERO
			var wait := SILENCE_TIME + (LATE_EXTRA if darts_left == 1 and _darts_in_volley > 1 else 0.0)
			if _mode_time >= wait:
				start_dart()
		Mode.DART:
			_steer(delta)
			velocity = _dart_dir * dart_speed
			if _mode_time >= dart_time:
				hitbox.deactivate()
				darts_left -= 1
				if darts_left > 0:
					_set_mode(Mode.SILENCE)
				else:
					_set_mode(Mode.RECOVER)
					body_sprite.play(&"idle")
		Mode.RECOVER:
			velocity = velocity.move_toward(Vector2.ZERO, 900.0 * delta)
			if _mode_time >= recover_time:
				_start_song()


## Uma nota da caixinha; a música acelera. Na última, silêncio — e o disparo.
func play_note() -> void:
	Sfx.play_pitched(&"music_box", MELODY[notes_played % MELODY.size()], -4.0)
	notes_played += 1
	_note_gap = maxf(_note_gap * NOTE_SPEEDUP, MIN_NOTE_GAP)
	_note_left = _note_gap
	if notes_played >= notes_this_song:
		_darts_in_volley = 1 if phase == 1 else randi_range(2, 3)
		darts_left = _darts_in_volley
		body_sprite.play(&"idle")
		_set_mode(Mode.SILENCE)


func start_dart() -> void:
	if target == null:
		_start_song()
		return
	_set_mode(Mode.DART)
	_dart_dir = (target.global_position - global_position).normalized()
	# Sai de lado e faz a curva: quem só anda em linha reta é pego.
	_dart_dir = _dart_dir.rotated(randf_range(0.5, 0.8) * (1.0 if randf() < 0.5 else -1.0))
	body_sprite.play(&"dart")
	body_sprite.flip_h = _dart_dir.x < 0.0
	Sfx.play(&"dash", -2.0)
	hitbox.activate_raw(dart_damage, 30.0, 140.0, true, "Disparo da Dançarina")


func _steer(delta: float) -> void:
	if target == null:
		return
	var want := (target.global_position - global_position).normalized()
	var angle := _dart_dir.angle_to(want)
	_dart_dir = _dart_dir.rotated(clampf(angle, -dart_turn * delta, dart_turn * delta))


func _can_be_staggered() -> bool:
	return mode == Mode.RECOVER


func _on_reset() -> void:
	phase = 1
	hitbox.deactivate()
	_set_mode(Mode.SPIN)
	body_sprite.play(&"idle")


func _on_died() -> void:
	hitbox.deactivate()
	_defeat()


func _after_move(_delta: float) -> void:
	pass
