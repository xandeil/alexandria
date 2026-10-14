extends Node
## Autoload "Sfx": toca efeitos sonoros a partir de um "pool" de players.
##
## Por que um pool? Criar um AudioStreamPlayer novo a cada golpe gera lixo e
## travadas. Reaproveitamos 12 players em rodízio (padrão Object Pool).

const LIBRARY := {
	&"swing": "res://assets/sfx/swing.wav",
	&"swing_heavy": "res://assets/sfx/swing_heavy.wav",
	&"hit": "res://assets/sfx/hit.wav",
	&"hit_heavy": "res://assets/sfx/hit_heavy.wav",
	&"clang": "res://assets/sfx/clang.wav",
	&"block": "res://assets/sfx/block.wav",
	&"armor_break": "res://assets/sfx/armor_break.wav",
	&"dash": "res://assets/sfx/dash.wav",
	&"hurt": "res://assets/sfx/hurt.wav",
	&"heal": "res://assets/sfx/heal.wav",
	&"sanity": "res://assets/sfx/sanity.wav",
	&"memory": "res://assets/sfx/memory.wav",
	&"death": "res://assets/sfx/death.wav",
	&"enemy_death": "res://assets/sfx/enemy_death.wav",
	&"boss_phase": "res://assets/sfx/boss_phase.wav",
	&"ui_click": "res://assets/sfx/ui_click.wav",
	&"ui_open": "res://assets/sfx/ui_open.wav",
	&"rest": "res://assets/sfx/rest.wav",
	&"fog": "res://assets/sfx/fog.wav",
	&"door": "res://assets/sfx/door.wav",
	&"telegraph": "res://assets/sfx/telegraph.wav",
	&"step_heavy": "res://assets/sfx/step_heavy.wav",
	&"amb_theater": "res://assets/sfx/amb_theater.wav",
	&"amb_city": "res://assets/sfx/amb_city.wav",
	&"amb_boss": "res://assets/sfx/amb_boss.wav",
	&"slam": "res://assets/sfx/slam.wav",
	&"crumble": "res://assets/sfx/crumble.wav",
	&"fall": "res://assets/sfx/fall.wav",
	&"roar": "res://assets/sfx/roar.wav",
	&"shockwave": "res://assets/sfx/shockwave.wav",
	&"laugh": "res://assets/sfx/laugh.wav",
	&"scream": "res://assets/sfx/scream.wav",
	&"swing_small": "res://assets/sfx/swing_small.wav",
	&"door_slide": "res://assets/sfx/door_slide.wav",
	&"capsule_open": "res://assets/sfx/capsule_open.wav",
	&"echo": "res://assets/sfx/echo.wav",
	&"amb_lab": "res://assets/sfx/amb_lab.wav",
	&"bark": "res://assets/sfx/bark.wav",
	&"shot": "res://assets/sfx/shot.wav",
	&"moan": "res://assets/sfx/moan.wav",
	&"whistle": "res://assets/sfx/whistle.wav",
	&"pickup": "res://assets/sfx/pickup.wav",
	&"shield_up": "res://assets/sfx/shield_up.wav",
	&"guard_break": "res://assets/sfx/guard_break.wav",
	&"forge": "res://assets/sfx/forge.wav",
	&"purify": "res://assets/sfx/purify.wav",
	&"yawn": "res://assets/sfx/yawn.wav",
	&"puff": "res://assets/sfx/puff.wav",
	&"hooves": "res://assets/sfx/hooves.wav",
	&"chime": "res://assets/sfx/chime.wav",
	&"stone_wake": "res://assets/sfx/stone_wake.wav",
	&"burst": "res://assets/sfx/burst.wav",
	&"amb_forest": "res://assets/sfx/amb_forest.wav",
	&"grab": "res://assets/sfx/grab.wav",
	&"chomp": "res://assets/sfx/chomp.wav",
	&"slurp": "res://assets/sfx/slurp.wav",
	&"splat": "res://assets/sfx/splat.wav",
	&"root_burst": "res://assets/sfx/root_burst.wav",
	&"gulp": "res://assets/sfx/gulp.wav",
	&"amb_roots": "res://assets/sfx/amb_roots.wav",
	&"zap": "res://assets/sfx/zap.wav",
	&"clank": "res://assets/sfx/clank.wav",
	&"hum": "res://assets/sfx/hum.wav",
	&"mirror": "res://assets/sfx/mirror.wav",
	&"quake": "res://assets/sfx/quake.wav",
	&"amb_forge": "res://assets/sfx/amb_forge.wav",
}
const POOL_SIZE := 12

var muted := false
var _cache := {}
var _pool: Array[AudioStreamPlayer] = []
var _next := 0
var _ambience: AudioStreamPlayer
var _ambience_name: StringName = &""
var _ambience_tween: Tween


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in POOL_SIZE:
		var player := AudioStreamPlayer.new()
		add_child(player)
		_pool.append(player)
	_ambience = AudioStreamPlayer.new()
	add_child(_ambience)


func play(sound: StringName, volume_db: float = 0.0, pitch_jitter: float = 0.07) -> void:
	if muted or not LIBRARY.has(sound):
		return
	var player := _pool[_next]
	_next = (_next + 1) % POOL_SIZE
	player.stream = _stream(sound)
	player.volume_db = volume_db
	player.pitch_scale = 1.0 + randf_range(-pitch_jitter, pitch_jitter)
	player.play()


func play_ambience(sound: StringName, volume_db: float = -10.0) -> void:
	if muted or (_ambience_name == sound and _ambience.playing):
		return
	_ambience_name = sound
	var stream := _stream(sound) as AudioStreamWAV
	if stream:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin = 0
		stream.loop_end = int(stream.get_length() * stream.mix_rate)
	_ambience.stream = stream
	_ambience.volume_db = -40.0
	_ambience.play()
	_fade_ambience(volume_db, 1.2)


func stop_ambience(fade: float = 1.0) -> void:
	_ambience_name = &""
	_fade_ambience(-40.0, fade, true)


func _fade_ambience(target_db: float, duration: float, stop_after: bool = false) -> void:
	if _ambience_tween and _ambience_tween.is_valid():
		_ambience_tween.kill()
	_ambience_tween = create_tween()
	_ambience_tween.set_ignore_time_scale(true)
	_ambience_tween.tween_property(_ambience, "volume_db", target_db, duration)
	if stop_after:
		_ambience_tween.tween_callback(_ambience.stop)


## Silencia tudo e solta os sons da memória (chamado ao fechar o jogo).
## O servidor de áudio libera os sons alguns milissegundos DEPOIS do stop() —
## por isso o Game.quit_game() espera um instante antes de sair de verdade.
func shutdown() -> void:
	muted = true
	if _ambience_tween and _ambience_tween.is_valid():
		_ambience_tween.kill()
	_ambience.stop()
	_ambience.stream = null
	for player in _pool:
		player.stop()
		player.stream = null
	_cache.clear()


func _exit_tree() -> void:
	shutdown()


func _stream(sound: StringName) -> AudioStream:
	if not _cache.has(sound):
		_cache[sound] = load(LIBRARY[sound])
	return _cache[sound]
