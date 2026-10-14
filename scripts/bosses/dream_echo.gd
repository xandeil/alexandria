class_name DreamEcho
extends Node2D
## Fase 2 de Nyssa ("O Pesadelo"): o ECO de um chefe que você já venceu.
## Bíblia: "ela invoca ecos fracos de chefes já derrotados, cada um com um
## único ataque." / "Os ecos reaproveitam animações de chefes que já existem."
##
## Um eco surge (branco, translúcido — o mesmo shader dos ecos da Governanta),
## AVISA, faz o golpe que você conhece daquele chefe e se desfaz. Não dá para
## bater num eco: a lição é reconhecer o aviso que você já aprendeu.

const ECHO_MATERIAL := preload("res://shaders/echo_material.tres")
## id do chefe → aparência (folha, tamanho do quadro, qual quadro) e o ÚNICO golpe.
const KINDS := {
	"helena": {"sheet": "res://assets/sprites/helena_body.png", "size": Vector2i(32, 32), "frame": 0, "attack": "estocada"},
	"aldir": {"sheet": "res://assets/sprites/aldir_body.png", "size": Vector2i(40, 40), "frame": 0, "attack": "onda"},
	"governanta": {"sheet": "res://assets/sprites/governanta_body.png", "size": Vector2i(32, 40), "frame": 0, "attack": "grito"},
	"sargento": {"sheet": "res://assets/sprites/sargento.png", "size": Vector2i(24, 24), "frame": 0, "attack": "estocada"},
	"couraca": {"sheet": "res://assets/sprites/couraca.png", "size": Vector2i(32, 32), "frame": 0, "attack": "giro"},
	"vigia": {"sheet": "res://assets/sprites/vigia.png", "size": Vector2i(48, 48), "frame": 1, "attack": "martelada"},
	"mae_esporos": {"sheet": "res://assets/sprites/mae_esporos.png", "size": Vector2i(48, 48), "frame": 0, "attack": "esporos"},
}

var kind := "aldir"
var source: Node2D
var damage := 20.0
## Tempo do aviso antes do golpe.
var warn_time := 0.9

var _time := 0.0
var _struck := false
var _fading := false
var _aim := Vector2.RIGHT
var _target_point := Vector2.ZERO
var _sprite: Sprite2D
var _telegraph: TelegraphDrawer
var _lunge_from := Vector2.ZERO
var _lunge_hit := false


static func spawn(parent: Node, at: Vector2, boss_id: String, owner_node: Node2D) -> DreamEcho:
	var echo := DreamEcho.new()
	echo.kind = boss_id if KINDS.has(boss_id) else "aldir"
	echo.source = owner_node
	parent.add_child(echo)
	echo.global_position = at
	return echo


func attack_name() -> String:
	return KINDS[kind]["attack"]


func _ready() -> void:
	add_to_group("dream_echoes")
	var spec: Dictionary = KINDS[kind]
	var size: Vector2i = spec["size"]
	var atlas := AtlasTexture.new()
	atlas.atlas = load(spec["sheet"])
	atlas.region = Rect2(int(spec["frame"]) * size.x, 0, size.x, size.y)
	_sprite = Sprite2D.new()
	_sprite.texture = atlas
	_sprite.offset = Vector2(0, -size.y * 0.5 + 1)
	_sprite.material = ECHO_MATERIAL
	_sprite.modulate.a = 0.0
	add_child(_sprite)
	_telegraph = TelegraphDrawer.new()
	add_child(_telegraph)
	var player := _player()
	if player:
		_aim = (player.global_position - global_position).normalized()
		_target_point = player.global_position
		_sprite.flip_h = _aim.x < 0.0
	Sfx.play(&"echo", -6.0, 0.1)


func _player() -> Player:
	var player := get_tree().get_first_node_in_group("player") as Player
	return player if player and not player.is_dead() else null


func _physics_process(delta: float) -> void:
	_time += delta
	if _fading:
		return
	_sprite.modulate.a = minf(_time / 0.4, 0.85)
	var player := _player()
	# A mira acompanha até 70% do aviso; depois TRAVA (como no chefe de verdade).
	if player and _time < warn_time * 0.7:
		_aim = (player.global_position - global_position).normalized()
		_target_point = player.global_position
		_sprite.flip_h = _aim.x < 0.0
	if not _struck:
		_draw_warning()
		if _time >= warn_time:
			_struck = true
			_telegraph.clear()
			_strike()
		return
	if attack_name() == "estocada":
		_lunge(delta)
	elif _time >= warn_time + 0.5:
		_fade()


func _draw_warning() -> void:
	var t := clampf(_time / warn_time, 0.0, 1.0)
	match attack_name():
		"estocada", "onda":
			_telegraph.line_visible = true
			_telegraph.line_origin = global_position + Vector2(0, -6)
			_telegraph.line_direction = _aim
			_telegraph.line_length = 140.0 if attack_name() == "estocada" else 200.0
			_telegraph.line_locked = _time >= warn_time * 0.7
		"giro":
			_telegraph.circle_visible = true
			_telegraph.circle_center = global_position
			_telegraph.circle_radius = 34.0
			_telegraph.circle_progress = t
		"martelada", "esporos":
			_telegraph.circle_visible = true
			_telegraph.circle_center = _target_point
			_telegraph.circle_radius = 26.0
			_telegraph.circle_progress = t
		"grito":
			_telegraph.circle_visible = true
			_telegraph.circle_center = global_position
			_telegraph.circle_radius = 12.0 + 8.0 * t
			_telegraph.circle_progress = t


func _strike() -> void:
	var parent := get_parent()
	match attack_name():
		"estocada":
			_lunge_from = global_position
			Sfx.play(&"swing_heavy", -4.0)
		"onda":
			Shockwave.launch(parent, global_position, _aim, source, damage, 160.0, 200.0, 0.0)
		"grito":
			ScreamRing.launch(parent, global_position, source, damage * 0.8, 120.0, 110.0)
			Sfx.play(&"scream", -8.0)
		"giro":
			_area_hit(global_position, 34.0)
			Sfx.play(&"swing_heavy", -4.0)
		"martelada":
			_area_hit(_target_point, 26.0)
			Fx.shake(4.0, 0.2)
			Fx.dust(_target_point, 12)
			Sfx.play(&"hit_heavy", -2.0)
		"esporos":
			for i in 2:
				PollenCloud.spawn(parent, _target_point + Vector2.from_angle(i * PI + 0.3) * 14.0, 28.0, 3.0)
			Sfx.play(&"puff", -2.0)


## A estocada: o eco atravessa a linha travada (140 px em 0,25 s).
func _lunge(delta: float) -> void:
	var t := clampf((_time - warn_time) / 0.25, 0.0, 1.0)
	global_position = _lunge_from + _aim * 140.0 * t
	var player := _player()
	if not _lunge_hit and player and player.global_position.distance_to(global_position) < 14.0:
		_lunge_hit = true
		_hit_player(player, damage)
	if t >= 1.0:
		_fade()
	if fmod(_time, 0.05) < delta:
		Fx.dust(global_position, 2)


func _area_hit(center: Vector2, radius: float) -> void:
	var player := _player()
	if player and player.global_position.distance_to(center) <= radius:
		_hit_player(player, damage)


func _hit_player(player: Player, amount: float) -> void:
	var info := HitInfo.create(amount, global_position, player.global_position)
	info.knockback = 160.0
	info.poise_damage = 20.0
	info.is_heavy = true
	info.attack_name = "Eco"
	info.source = source
	player.hurtbox.receive_hit(info)


func _fade() -> void:
	if _fading:
		return
	_fading = true
	_telegraph.clear()
	var tween := create_tween()
	tween.tween_property(_sprite, "modulate:a", 0.0, 0.4)
	tween.tween_callback(queue_free)
