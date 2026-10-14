class_name FlorDePolen
extends Enemy
## Flor de Pólen — Bosque do Sono Eterno.
## Bíblia: "Parada; solta nuvem que enche a Barra de Sonolência. O sono de
## Nyssa espalhado pelo chão."
##
## Ciclo legível: ABERTA → INCHA (aviso: cresce e treme) → SOLTA a nuvem →
## FECHADA (descansa). A janela para cortá-la é logo depois de soltar.

enum AI { IDLE, SWELL, CLOSED, STAGGER }

## Perto disso ela "percebe" o herói e começa a inchar.
@export var trigger_range := 76.0
@export var swell_time := 0.8
@export var closed_time := 3.0
@export var cloud_radius := 32.0
@export var cloud_time := 3.5
## A nuvem nasce um pouco na direção do herói.
@export var cloud_reach := 18.0

var ai := AI.IDLE
var _ai_time := 0.0


func _physics_process(delta: float) -> void:
	if dead:
		return
	_ai_time += delta
	regen_poise(delta)
	target = find_target()
	velocity = Vector2.ZERO
	match ai:
		AI.IDLE:
			if target and global_position.distance_to(target.global_position) <= trigger_range and can_see(target.global_position):
				_set_ai(AI.SWELL)
				Fx.flash(body_sprite, 0.2, Color(1.0, 0.9, 0.5))
		AI.SWELL:
			var t := _ai_time / swell_time
			visual.scale = Vector2.ONE * (1.0 + 0.15 * t) + Vector2(sin(_ai_time * 40.0) * 0.04, 0)
			if _ai_time >= swell_time:
				_puff()
		AI.CLOSED, AI.STAGGER:
			visual.scale = visual.scale.lerp(Vector2.ONE, 0.2)
			if _ai_time >= (closed_time if ai == AI.CLOSED else stagger_time):
				_set_ai(AI.IDLE)
	_update_frame()


func _set_ai(new_ai: AI) -> void:
	ai = new_ai
	_ai_time = 0.0


func _puff() -> void:
	_set_ai(AI.CLOSED)
	visual.scale = Vector2(1.25, 0.8)
	var toward := Vector2.ZERO
	if target:
		toward = (target.global_position - global_position).normalized() * cloud_reach
	var cloud := PollenCloud.spawn(get_parent(), global_position + toward, cloud_radius, cloud_time)
	cloud.drift = toward * 0.4
	Sfx.play(&"puff", -4.0, 0.15)


func _on_poise_broken(_info: HitInfo) -> void:
	_set_ai(AI.STAGGER)  # cortou no meio do inchaço: não solta


func _update_frame() -> void:
	var frame := 0
	if ai == AI.SWELL:
		frame = 1
	elif ai == AI.CLOSED:
		frame = 2
	if body_sprite.animation != &"idle":
		body_sprite.play(&"idle")
	body_sprite.frame = frame
	body_sprite.pause()
