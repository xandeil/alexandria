class_name Projectile
extends Node2D
## Projétil em linha reta (o tiro do Atirador de Telhado; amanhã, as bolas de
## fogo da Rachel ou o gelo do Cassian).
##
## Não usa física de corpo: a cada passo ele lança um RAIO do ponto anterior
## até o próximo contra a camada "mundo". Assim um tiro rápido não "atravessa"
## uma parede fina entre dois quadros (o famoso "tunneling").
## Paredes, barricadas e coberturas seguram o tiro. O dash (i-frames) passa
## por dentro dele.

const BULLET := preload("res://assets/fx/bala.png")
const EMBER := preload("res://assets/fx/bola_de_fogo.png")

var direction := Vector2.RIGHT
var speed := 150.0
var damage := 16.0
var knockback := 120.0
var max_distance := 320.0
## Raio em que o tiro acerta o herói.
var hit_radius := 7.0
var source: Node2D
## Bola de fogo (dragonoides): outra textura e, onde bate, um pouco de fogo no chão.
var ember := false

var _traveled := 0.0
var _done := false
var _sprite: Sprite2D


static func launch(parent: Node, from: Vector2, dir: Vector2, owner_node: Node2D, shot_damage: float,
		shot_speed: float, distance: float, fire: bool = false) -> Projectile:
	var shot := Projectile.new()
	shot.ember = fire
	shot.direction = dir.normalized() if dir != Vector2.ZERO else Vector2.RIGHT
	shot.source = owner_node
	shot.damage = shot_damage
	shot.speed = shot_speed
	shot.max_distance = distance
	parent.add_child(shot)
	shot.global_position = from
	return shot


func _ready() -> void:
	add_to_group("projectiles")  # o escudo do herói se vira para balas chegando
	z_index = 6
	_sprite = Sprite2D.new()
	_sprite.texture = EMBER if ember else BULLET
	_sprite.material = Fx.unshaded  # brasa: brilha no escuro
	_sprite.position = Vector2(0, -8)  # na altura do peito, não no chão
	add_child(_sprite)


## Bala já parada (acertou algo) não é ameaça.
func is_targetable() -> bool:
	return not _done


func _physics_process(delta: float) -> void:
	if _done:
		return
	var from := global_position
	var step := direction * speed * delta
	var query := PhysicsRayQueryParameters2D.create(from, from + step, 1)
	if is_instance_valid(source) and source is CollisionObject2D:
		query.exclude = [(source as CollisionObject2D).get_rid()]
	var hit := get_world_2d().direct_space_state.intersect_ray(query)
	if not hit.is_empty():
		global_position = hit["position"]
		_impact(true)
		return
	global_position = from + step
	_traveled += step.length()
	_try_hit_player()
	if _traveled >= max_distance:
		_impact(false)


func _try_hit_player() -> void:
	var player := get_tree().get_first_node_in_group("player") as Player
	if player == null or player.is_dead():
		return
	if player.global_position.distance_to(global_position) > hit_radius:
		return
	var info := HitInfo.create(damage, global_position - direction * 6.0, player.global_position)
	info.knockback = knockback
	info.source = source
	info.attack_name = "Bola de fogo" if ember else "Tiro"
	if player.hurtbox.receive_hit(info):  # i-frames do dash: o tiro passa direto
		_impact(true)


func _impact(spark: bool) -> void:
	_done = true
	if spark:
		Fx.sparks(global_position + Vector2(0, -8), -direction, Color(1.0, 0.75, 0.4), 6)
	if ember:
		FirePatch.spawn(get_parent(), global_position, 10.0, 1.6, 8.0, source)
	queue_free()


func is_done() -> bool:
	return _done
