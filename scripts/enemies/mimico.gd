class_name Mimico
extends Enemy
## O Que Guardou Demais — o mímico (v0.33, Etapa 3).
## Cobaias que guardaram algo com tanto apego que viraram o próprio cofre.
##
## Regras de leitura (justas, mas castigam quem não presta atenção):
##   • É IGUAL a um baú... só que ESPELHADO: a fechadura, a correia e o
##     arranhão ficam do lado contrário (a mesma imagem, virada).
##   • Examinar diz o mesmo nos dois: "Um baú."
##   • Bater nele acorda (um golpe basta para testar).
##   • ABRIR um mímico: ele agarra (toques no Ataque para escapar, como no
##     bloco de gelo), morde forte e come memórias enquanto segura.
##   • Acordado: pulinhos na sua direção e mordidas com avanço.
##   • Vencido, fica vencido para sempre (Game.world_state[key] = "morto") e
##     deixa o que guardava (drop_item, sempre).
##
## No mapa: Level.objects → {"kind": "mimico", "cell": Vector2i(x, y),
##   "key": "mimico_cidade", "item": "fragmento_turvo"}

enum AI { DORMANT, GRAB, AWAKE, STAGGER }

const CLOSED := preload("res://assets/props/bau_fechado.png")
const OPEN := preload("res://assets/props/mimico_aberto.png")
## A fala rara ao morrer.
const LAST_WORDS := "...Era meu. ...Era meu."

@export var bite: AttackData
@export var grab_taps := 6
@export var grab_damage_per_second := 9.0
@export var grab_memory_ratio := 0.05
@export var grab_memory_min := 10
## Ao abrir (pego de surpresa): a primeira mordida.
@export var ambush_damage := 40.0

## Nome do estado no save (vencido = "morto").
var key := ""
## v0.53: um segundo item (o botão que os mímicos guardam: Bronze, Vidro).
var extra_drop := ""
var ai := AI.DORMANT
var interactable: Interactable
var _ai_time := 0.0
var _cooldown := 0.0


static func spawn(parent: Node, def: Dictionary, at: Vector2) -> Mimico:
	var mimic := (load("res://scenes/enemies/mimico.tscn") as PackedScene).instantiate() as Mimico
	mimic.key = str(def.get("key", ""))
	mimic.drop_item = str(def.get("item", ""))
	mimic.drop_chance = 1.0 if not mimic.drop_item.is_empty() else 0.0
	mimic.extra_drop = str(def.get("item2", ""))
	mimic.position = at
	parent.add_child(mimic)
	return mimic


func _ready() -> void:
	super._ready()
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	for anim: StringName in [&"fechado", &"aberto"]:
		frames.add_animation(anim)
		frames.add_frame(anim, CLOSED if anim == &"fechado" else OPEN)
	body_sprite.sprite_frames = frames
	body_sprite.offset = Vector2(0, -6)
	body_sprite.flip_h = true  # O ESPELHO: a única diferença para um baú comum
	body_sprite.play(&"fechado")
	remove_from_group("enemies")  # dormindo, nem a mira assistida o vê como inimigo
	interactable = Interactable.new()
	interactable.prompt = "Abrir"
	var reach := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 14.0
	reach.shape = circle
	reach.position = Vector2(0, -6)
	interactable.add_child(reach)
	add_child(interactable)
	interactable.interacted.connect(_on_opened)


func scales_with_cycle() -> bool:
	return true


func _physics_process(delta: float) -> void:
	if dead:
		return
	_ai_time += delta
	_cooldown -= delta
	target = find_target()
	match ai:
		AI.DORMANT:
			velocity = Vector2.ZERO
		AI.GRAB:
			velocity = Vector2.ZERO
			if target == null or not target.is_grabbed_by(self):
				_wake()
		AI.STAGGER:
			velocity = velocity.move_toward(Vector2.ZERO, 600.0 * delta)
			if _ai_time >= stagger_time:
				_set_ai(AI.AWAKE)
		AI.AWAKE:
			regen_poise(delta)
			_chase(delta)
	move_and_slide()


func _chase(delta: float) -> void:
	if _runner.is_running():
		velocity = _runner.step(delta, velocity)
		return
	if target == null:
		velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
		return
	var to_target := target.global_position - global_position
	facing = to_target.normalized()
	body_sprite.flip_h = facing.x > 0.0  # espelhado também acordado
	if to_target.length() <= bite.reach + bite.radius + 10.0 and _cooldown <= 0.0:
		start_attack(bite, facing)
		return
	# Pulinhos: anda aos trancos, como uma caixa pesada que aprendeu a andar.
	var hop := 0.5 + 0.5 * sin(_ai_time * 9.0)
	velocity = velocity.move_toward(facing * move_speed * (0.4 + hop), acceleration * delta)
	visual.position.y = -absf(sin(_ai_time * 9.0)) * 2.0


func _set_ai(new_ai: AI) -> void:
	ai = new_ai
	_ai_time = 0.0


## Alguém abriu o "baú": surpresa.
func _on_opened(player: Player) -> void:
	if ai != AI.DORMANT:
		return
	interactable.enabled = false
	body_sprite.play(&"aberto")
	Sfx.play(&"chomp", 0.0)
	Fx.shake(4.0, 0.25)
	add_to_group("enemies")
	# Agarra PRIMEIRO (um golpe antes daria os i-frames do herói e o agarrão
	# escaparia); a mordida da surpresa vem com ele já preso.
	if player.grab(self, grab_taps, Vector2(0, -2), grab_damage_per_second, grab_memory_ratio, grab_memory_min):
		_set_ai(AI.GRAB)
		player.stats.take_damage(ambush_damage * Game.difficulty() * area_power)
		Fx.vibrate(120)
		return
	var info := HitInfo.create(ambush_damage, global_position, player.global_position)
	info.unblockable = true
	info.attack_name = "Mímico"
	info.source = self
	player.hurtbox.receive_hit(info)
	_wake()


## Primeiro golpe (ou soltou o herói): acorda de vez.
func _wake() -> void:
	if ai == AI.AWAKE:
		return
	interactable.enabled = false
	body_sprite.play(&"aberto")
	add_to_group("enemies")
	_cooldown = 0.6
	_set_ai(AI.AWAKE)


func _on_damaged(_amount: float, _info: HitInfo, _blocked: bool) -> void:
	if ai == AI.GRAB and target and target.is_grabbed_by(self):
		target.release_grab()
	if ai == AI.DORMANT:
		Fx.float_text(global_position + Vector2(-6, -24), "!", Color(1.0, 0.6, 0.5), 10)
		_wake()


func _on_poise_broken(_info: HitInfo) -> void:
	if target and target.is_grabbed_by(self):
		target.release_grab()
	_runner.cancel()
	_set_ai(AI.STAGGER)


func _on_attack_finished() -> void:
	_cooldown = randf_range(0.8, 1.3)


func _on_died() -> void:
	if target and target.is_grabbed_by(self):
		target.release_grab()
	interactable.enabled = false
	if not key.is_empty():
		Game.set_world_state(key, "morto")
	if not extra_drop.is_empty():
		ItemPickup.drop(get_parent(), global_position + Vector2(12, 4), extra_drop, 1)
	if randf() < 0.35:
		Fx.float_text(global_position + Vector2(-30, -30), LAST_WORDS, Color(0.95, 0.85, 0.75), 7)
	super._on_died()
