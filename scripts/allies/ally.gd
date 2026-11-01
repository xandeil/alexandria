class_name Ally
extends CharacterBody2D
## BASE DOS ALIADOS (v0.31, Etapa 1) — extraída do Guarda Sem Posto.
## Todo companheiro que luta ao seu lado herda daqui: Lúcia, Galeno, Tião,
## Bastião, Heitor... Cada um só escolhe a aparência, os números e o que
## acontece quando cai (o gancho _on_fall).
##
## NÍVEL: Game.ally_level(ally_id). Cada chefe (ou mini-chefe) vencido com o
## aliado em pé = +1 nível (Level chama Game.raise_ally). Cada nível acima do 1
## soma LEVEL_BONUS à vida e ao dano. Cair NÃO tira nível.
##
## ARENAS: por padrão, aliado não entra nas arenas dos Pecados. A opção "Lute
## comigo" (ação de diálogo "lute_comigo:<id>") liga a flag "<id>_na_arena" e
## ele entra na PRÓXIMA luta de chefe. Ou: can_enter_arenas = true, sempre.
##
## Regras de luta simples e legíveis:
##   • Segue você de perto. Inimigo perto de VOCÊ? Ele vai até o inimigo e corta.
##   • Os golpes dele são HitInfo como os seus (o inimigo não sabe a diferença).
##   • Os golpes dos inimigos acertam ele também (a hurtbox dele está na mesma
##     camada que a sua). Os inimigos não o escolhem como alvo: ele se põe no meio.
##   • Caiu de joelhos? Some (cada aliado decide para onde volta: _on_fall).

const SHADOW := preload("res://assets/fx/shadow.png")
## +15% de vida e de dano por nível acima do 1.
const LEVEL_BONUS := 0.15
## Todos os aliados do jogo: id → script. Level usa para chamar quem está
## acompanhando ("<id>_acompanha") ou foi chamado para a arena ("<id>_na_arena").
const REGISTRY := {
	"guarda": "res://scripts/allies/guarda_aliado.gd",
	"lucia": "res://scripts/allies/lucia_aliada.gd",
}

## Quem é (o id do save: "guarda", "lucia"...).
var ally_id := ""
var display_name := ""
var frames: SpriteFrames
## true = entra nas arenas dos Pecados sem precisar de "Lute comigo".
var can_enter_arenas := false

@export var max_health := 160.0
@export var move_speed := 78.0
@export var follow_distance := 26.0
@export var engage_range := 100.0
@export var strike_reach := 22.0
@export var strike_damage := 14.0
@export var windup := 0.35
@export var cooldown := 0.9

var health := 160.0
var player: Player
var target: Enemy
var facing := Vector2.RIGHT
var fallen := false

var _sprite: AnimatedSprite2D
var _hurtbox: Hurtbox
var _windup_left := -1.0
var _cooldown := 0.0
var _side := 1.0


## Cria o aliado pelo id (REGISTRY) ao lado do herói.
static func spawn_by_id(id: String, parent: Node, near: Player) -> Ally:
	if not REGISTRY.has(id):
		return null
	var ally := (load(REGISTRY[id]) as GDScript).new() as Ally
	ally.player = near
	ally.position = near.position + Vector2(-18, 6)
	parent.add_child(ally)
	return ally


## Multiplicador de vida e dano do nível atual (nível 1 = 1.0).
func level_multiplier() -> float:
	return 1.0 + LEVEL_BONUS * (Game.ally_level(ally_id) - 1)


func _ready() -> void:
	add_to_group(&"allies")
	_setup()
	max_health *= level_multiplier()
	strike_damage *= level_multiplier()
	health = max_health
	collision_layer = 0  # não empurra você nem os inimigos
	collision_mask = 1  # mas respeita paredes
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	var body := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 4.5
	body.shape = circle
	body.position = Vector2(0, -3)
	add_child(body)
	var shadow := Sprite2D.new()
	shadow.texture = SHADOW
	shadow.position = Vector2(0, -1)
	add_child(shadow)
	_sprite = AnimatedSprite2D.new()
	_sprite.sprite_frames = frames
	_sprite.offset = Vector2(0, -11)
	_sprite.play(&"idle")
	add_child(_sprite)
	_hurtbox = Hurtbox.new()
	_hurtbox.collision_layer = 8  # a mesma camada da sua hurtbox: golpes inimigos acertam
	_hurtbox.collision_mask = 0
	_hurtbox.owner_body = self
	var hurt_shape := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = Vector2(12, 16)
	hurt_shape.shape = box
	hurt_shape.position = Vector2(0, -8)
	_hurtbox.add_child(hurt_shape)
	add_child(_hurtbox)
	_hurtbox.hit_received.connect(_on_hit)
	_side = -1.0 if randf() < 0.5 else 1.0


func _physics_process(delta: float) -> void:
	if fallen or not is_instance_valid(player):
		velocity = Vector2.ZERO
		return
	_cooldown -= delta
	if player.is_dead():
		velocity = velocity.move_toward(Vector2.ZERO, 600.0 * delta)
		move_and_slide()
		return
	if global_position.distance_to(player.global_position) > 240.0:
		global_position = player.global_position + Vector2(-16 * _side, 8)  # ficou preso: alcança você
	target = _pick_target()
	if _windup_left >= 0.0:
		velocity = velocity.move_toward(Vector2.ZERO, 900.0 * delta)
		_windup_left -= delta
		if _windup_left < 0.0:
			_strike()
	elif target:
		var to_target := target.global_position - global_position
		facing = to_target.normalized()
		if to_target.length() <= strike_reach and _cooldown <= 0.0:
			_windup_left = windup
		else:
			velocity = velocity.move_toward(facing * move_speed, 700.0 * delta)
	else:
		var spot := player.global_position + Vector2(-follow_distance * _side, 6)
		var to_spot := spot - global_position
		if to_spot.length() > 6.0:
			velocity = velocity.move_toward(to_spot.normalized() * move_speed * clampf(to_spot.length() / 30.0, 0.4, 1.2), 700.0 * delta)
			facing = to_spot.normalized()
		else:
			velocity = velocity.move_toward(Vector2.ZERO, 700.0 * delta)
	move_and_slide()
	_update_visual()


## O inimigo mais perto de VOCÊ (ele protege você, não caça sozinho).
func _pick_target() -> Enemy:
	var best: Enemy = null
	var best_distance := engage_range
	for node in get_tree().get_nodes_in_group("enemies"):
		var enemy := node as Enemy
		if enemy == null or enemy.dead or not enemy.is_targetable():
			continue
		var distance := enemy.global_position.distance_to(player.global_position)
		if distance < best_distance:
			best_distance = distance
			best = enemy
	return best


func _strike() -> void:
	_cooldown = cooldown
	Sfx.play(&"swing", -6.0, 0.1)
	for node in get_tree().get_nodes_in_group("enemies"):
		var enemy := node as Enemy
		if enemy == null or enemy.dead:
			continue
		var to := enemy.global_position - global_position
		if to.length() > strike_reach + 8.0 or absf(rad_to_deg(facing.angle_to(to))) > 70.0:
			continue
		var info := HitInfo.create(strike_damage, global_position, enemy.global_position)
		info.knockback = 110.0
		info.poise_damage = 18.0
		info.attack_name = display_name
		info.source = self
		enemy.hurtbox.receive_hit(info)


func _on_hit(info: HitInfo) -> void:
	if fallen:
		return
	health -= info.damage * 0.7  # um veterano: aguenta um pouco mais que você
	Fx.flash(_sprite, 0.1)
	velocity += info.direction * info.knockback * 0.5
	if health <= 0.0:
		fall()


## Caiu de joelhos: avisa, some aos poucos (o gancho _on_fall diz o resto).
func fall() -> void:
	fallen = true
	_hurtbox.set_deferred("monitorable", false)
	if _sprite.sprite_frames and _sprite.sprite_frames.has_animation(&"caido"):
		_sprite.play(&"caido")
	Sfx.play(&"hit_heavy", -4.0)
	var message := _on_fall()
	var level := Level.find(self)
	if level and level.hud and not message.is_empty():
		level.hud.toast(message)
	var tween := create_tween()
	tween.tween_interval(1.2)
	tween.tween_property(self, "modulate:a", 0.0, 1.0)
	tween.tween_callback(queue_free)


# --- Ganchos de cada aliado -----------------------------------------------------------

## Aparência e números (ally_id, display_name, frames, max_health, strike_damage...).
func _setup() -> void:
	pass


## Caiu: o que muda no save, e o aviso na tela ("" = nenhum).
func _on_fall() -> String:
	Game.flags["%s_acompanha" % ally_id] = false
	return ""


func _update_visual() -> void:
	if absf(facing.x) > 0.15:
		_sprite.flip_h = facing.x < 0.0
	var anim := &"idle"
	if _windup_left >= 0.0 or _cooldown > cooldown - 0.2:
		anim = &"golpe"
	elif velocity.length() > 8.0:
		anim = &"walk"
	if _sprite.animation != anim and _sprite.sprite_frames and _sprite.sprite_frames.has_animation(anim):
		_sprite.play(anim)
